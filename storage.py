from dataclasses import dataclass
import json
from replit import db


@dataclass
class User:
    username: str
    password: str
    strategy: str


def load_users():
    return [_to_object(k, v) for k, v in db.items()]


def create_user(username, encoded_password, strategy_name):
    if username in db:
        raise Exception(f"user with name {username} already exists")
    j = json.dumps({"password": encoded_password, "strategy": strategy_name})
    db[username] = j
    return _to_object(username, j)


def user_for_name(username):
    j = db.get(username)
    if j:
        return _to_object(username, j)
    else:
        return None


def _to_object(username, j):
    e = json.loads(j)
    return User(
        username=username,
        strategy=e["strategy"],
        password=e["password"],
    )


def _delete_all():
    for k in db.keys():
        del db[k]
