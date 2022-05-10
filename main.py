#!/usr/bin/env python
from strategies import registry
from storage import load_users, create_or_update_user, user_for_name
from flask import Flask, request, render_template

app = Flask(__name__)
app.config["SEND_FILE_MAX_AGE_DEFAULT"] = 600


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
        user = user_for_name(request.form["username"])
        if user:
            strategy = registry[user.strategy]
            if strategy.matches(request.form["password"], user.password):
                return render_template("userinfo.html", user=user)
            else:
                error = "Invalid password"
        else:
            error = "Invalid username"
    return render_template("login.html", error=error)


@app.route("/register", methods=["POST", "GET"])
def register():
    error = None
    if request.method == "POST":
        strategy = registry[request.form["strategy_name"]]
        user = create_or_update_user(request.form["username"],
                           strategy.encode(request.form["password"]),
                           strategy_name=strategy.name)
        return render_template("userinfo.html", user=user)
    return render_template("register.html",
                           error=error,
                           strategies=registry.values())


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)
