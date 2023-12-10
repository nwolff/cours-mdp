#!/usr/bin/env python

from flask import Flask, redirect, render_template, request

import storage.firestore as storage
from strategies import registry

MIN_CHARS = 3  # Both for the username and password

app = Flask(__name__)
app.config["SEND_FILE_MAX_AGE_DEFAULT"] = 600


@app.route("/")
def home():
    return render_template("home.html")


@app.route("/_delete")
def deleteusers():
    storage.delete_all()
    return redirect("/listusers")


@app.route("/listusers")
def listusers():
    return render_template("listusers.html", users=storage.load_users())


@app.route("/login", methods=["POST", "GET"])
def login():
    error = None
    if request.method == "POST":
        user = storage.user_for_name(request.form["username"])
        if user:
            strategy = registry[user.strategy]
            if strategy.matches(request.form["password"], user.password):
                return render_template("userinfo.html", user=user)
            else:
                error = "Mot de passe incorrect"
        else:
            error = "Utilisateur inconnu"
    return render_template("login.html", error=error)


@app.route("/register", methods=["POST", "GET"])
def register():
    error = None
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]
        if min(len(username), len(password)) >= MIN_CHARS:
            strategy_name = request.form["strategy_name"]
            strategy = registry[strategy_name]
            user = storage.create_or_update_user(
                username, strategy.encode(password), strategy_name
            )
            return render_template("userinfo.html", user=user)
        else:
            error = f"Le nom et mot de passe doivent avoir au minimum {MIN_CHARS} caractères"
    return render_template("register.html", error=error, strategies=registry)


if __name__ == "__main__":
    # Only when developing
    app.run(host="0.0.0.0", port=8080, debug=True)
