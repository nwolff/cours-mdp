import json

from replit import db

from . import User


def load_users():
    return [_to_object(k, v) for k, v in db.items()]


def create_or_update_user(username, encoded_password, strategy_name):
    j = json.dumps(
        {"username": username, "password": encoded_password, "strategy": strategy_name}
    )
    db[username] = j
    return _to_object(username, j)


def user_for_name(username):
    j = db.get(username)
    if j:
        return _to_object(username, j)
    else:
        return None


def delete_all():
    for k in db.keys():
        del db[k]


def _to_object(username, j):
    e = json.loads(j)
    return User(username=username, password=e["password"], strategy=e["strategy"])
