#!/usr/bin/env python
from strategies import registry as strategy_registry
from storage import create_user, user_for_credentials, load_users
from flask import Flask, request, render_template


app = Flask(__name__)


@app.route("/")
def home():
    return render_template("home.html")


@app.route("/listusers")
def listusers():
    return render_template("listusers.html", users=load_users())


@app.route("/login", methods=["POST", "GET"])
def login():
    error = None
    if request.method == "POST":
        user = user_for_credentials(request.form["username"], request.form["password"])
        if user:
            return render_template("userinfo.html", user=user)
        else:
            error = "Invalid username/password"
    return render_template("login.html", error=error)


@app.route("/register", methods=["POST", "GET"])
def register():
    error = None
    if request.method == "POST":
        strategy = strategy_registry[request.form["strategy_name"]]
        user = create_user(strategy, request.form["username"], request.form["password"])
        return render_template("userinfo.html", user=user)
    return render_template(
        "register.html", error=error, strategies=strategy_registry.values()
    )


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080, debug=True)
