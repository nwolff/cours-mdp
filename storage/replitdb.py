import json
from dataclasses import asdict

from replit import db

from . import User, iso_timestamp


def load_users():
    return [_to_object(v) for _, v in db.items()]


def create_or_update_user(username, encoded_password, strategy_name):
    new_user = User(
        timestamp=iso_timestamp(),
        username=username,
        password=encoded_password,
        strategy=strategy_name,
    )
    db[username] = json.dumps(asdict(new_user))
    return new_user


def user_for_name(username):
    j = db.get(username)
    if j:
        return _to_object(j)
    else:
        return None


def delete_all():
    for k in db.keys():
        del db[k]


def _to_object(j):
    e = json.loads(j)
    return User(
        timestamp=e["timestamp"],
        username=e["username"],
        password=e["password"],
        strategy=e["strategy"],
    )
