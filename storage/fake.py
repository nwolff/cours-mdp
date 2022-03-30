from . import User

_users = {}


def load_users():
    return _users.values()


def create_or_update_user(username, encoded_password, strategy_name):
    new_user = User(
        username=username, password=encoded_password, strategy=strategy_name
    )
    _users[username] = new_user
    return new_user


def delete_all():
    _users.clear()


def user_for_name(username):
    return _users.get(username)
