import sqlite3
from dataclasses import asdict

from . import User, iso_timestamp

DB_PATH = "accounts.db"

with sqlite3.connect(DB_PATH) as con:
    con.execute(
        "CREATE TABLE IF NOT EXISTS users"
        "( id INTEGER PRIMARY KEY"
        ", timestamp STRING"
        ", username STRING UNIQUE"
        ", password STRING"
        ", strategy STRING"
        ");"
    )
    con.execute("CREATE INDEX IF NOT EXISTS username_idx ON users(username)")

SEL = "SELECT timestamp, username, password, strategy FROM users"


def load_users():
    with sqlite3.connect(DB_PATH) as con:
        return [_row_to_user(row) for row in con.execute(SEL)]


def create_or_update_user(username, encoded_password, strategy_name):
    new_user = User(
        timestamp=iso_timestamp(),
        username=username,
        password=encoded_password,
        strategy=strategy_name,
    )
    with sqlite3.connect(DB_PATH) as con:
        con.execute(
            "INSERT INTO users(timestamp, username, password, strategy)"
            " VALUES(:timestamp, :username, :password, :strategy)"
            " ON CONFLICT(username)"
            " DO UPDATE SET timestamp=:timestamp, username=:username, password=:password, strategy=:strategy",
            asdict(new_user),
        )
    return new_user


def delete_all():
    with sqlite3.connect(DB_PATH) as con:
        con.execute("DELETE from users")


def user_for_name(username):
    with sqlite3.connect(DB_PATH) as con:
        row = con.execute(SEL + " WHERE username=?", (username,)).fetchone()
    if row:
        return _row_to_user(row)
    else:
        return None


def _row_to_user(row):
    return User(timestamp=row[0], username=row[1], password=row[2], strategy=row[3])
