import hashlib
import queue
import threading
from datetime import datetime

import segno
from flask import (
    Flask,
    Response,
    redirect,
    render_template,
    request,
    stream_with_context,
)
from werkzeug.middleware.proxy_fix import ProxyFix

import storage.firestore as storage
from strategies import registry
from totem import totem

MIN_CHARS = 3  # Both for the username and password

app = Flask(__name__)
app.config["SEND_FILE_MAX_AGE_DEFAULT"] = 600
# Cloud Run terminates TLS upstream and forwards as http; trust the X-Forwarded-*
# headers so request.url reflects the scheme and host the client actually used.
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1)


@app.template_filter("pluralize")
def pluralize(number, singular="", plural="s"):
    # French rule: singular for 0 and 1, plural for 2+.
    return singular if number <= 1 else plural


@app.template_filter("format_timestamp")
def format_timestamp(iso_str):
    try:
        return datetime.fromisoformat(iso_str).strftime("%Y-%m-%d %H:%M:%S")
    except (ValueError, TypeError):
        return iso_str


@app.template_filter("avatar_url")
def avatar_url(username):
    h = hashlib.md5(username.encode("utf-8")).hexdigest()
    return f"https://api.dicebear.com/9.x/bottts/svg?seed={h}"


app.add_template_filter(totem, "totem")


@app.context_processor
def inject_min_chars():
    return dict(min_chars=MIN_CHARS)


@app.route("/")
def home():
    qr_svg = segno.make(request.url, error="L").svg_inline(scale=6, border=2)
    return render_template("home.j2", qr_svg=qr_svg, qr_url=request.url)


@app.route("/_delete")
def deleteusers():
    storage.delete_all()
    return redirect("/listusers")


@app.route("/listusers")
def listusers():
    return render_template("listusers.j2", users=storage.load_users())


# Server-sent events: notify connected /listusers clients when Firestore data changes.
_listeners: set[queue.Queue] = set()
_listeners_lock = threading.Lock()


def _on_users_changed() -> None:
    with _listeners_lock:
        for q in list(_listeners):
            try:
                q.put_nowait("changed")
            except queue.Full:
                pass


storage.subscribe_to_changes(_on_users_changed)


@app.route("/listusers/stream")
def listusers_stream():
    def gen():
        q: queue.Queue = queue.Queue(maxsize=8)
        with _listeners_lock:
            _listeners.add(q)
        try:
            yield "retry: 5000\n\n"
            while True:
                try:
                    msg = q.get(timeout=30)
                    yield f"data: {msg}\n\n"
                except queue.Empty:
                    yield ": keepalive\n\n"
        finally:
            with _listeners_lock:
                _listeners.discard(q)

    return Response(stream_with_context(gen()), mimetype="text/event-stream")


@app.route("/login", methods=["POST", "GET"])
def login():
    error = None
    if request.method == "POST":
        user = storage.user_for_name(request.form["username"])
        if user:
            strategy = registry[user.strategy]
            if strategy.matches(request.form["password"], user.password):
                return render_template("userinfo.j2", user=user)
            else:
                error = "Mot de passe incorrect"
        else:
            error = "Utilisateur inconnu"
    return render_template("login.j2", error=error)


@app.route("/register", methods=["POST", "GET"])
def register():
    error = None
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]
        strategy_name = request.form.get("strategy_name")
        if min(len(username), len(password)) < MIN_CHARS:
            error = f"Le nom et mot de passe doivent avoir au minimum {MIN_CHARS} caractères"
        elif not strategy_name:
            error = "Choisir une stratégie"
        else:
            strategy = registry[strategy_name]
            user = storage.create_or_update_user(
                username, strategy.encode(password), strategy_name
            )
            return render_template("userinfo.j2", user=user)
    return render_template("register.j2", error=error, strategies=registry)


if __name__ == "__main__":
    # Only when developing
    app.run(host="0.0.0.0", port=8080, debug=True)
