from flask import Flask, redirect, render_template, request

import storage.firestore as storage
from strategies import registry

MIN_CHARS = 3  # Both for the username and password

app = Flask(__name__)
app.config["SEND_FILE_MAX_AGE_DEFAULT"] = 600


@app.template_filter("pluralize")
def pluralize(number, singular="", plural="s"):
    return singular if number == 1 else plural


@app.context_processor
def inject_min_chars():
    return dict(min_chars=MIN_CHARS)


@app.route("/")
def home():
    return render_template("home.j2")


@app.route("/_delete")
def deleteusers():
    storage.delete_all()
    return redirect("/listusers")


@app.route("/listusers")
def listusers():
    return render_template("listusers.j2", users=storage.load_users())


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
