import sqlite3
from dataclasses import asdict
from typing import Any

from . import User, iso_timestamp

DB_PATH = "accounts.db"

print(f"Using sqlite database: {DB_PATH}")

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


def load_users() -> list[User]:
    with sqlite3.connect(DB_PATH) as con:
        return [_row_to_user(row) for row in con.execute(SEL)]


def create_or_update_user(
    username: str, encoded_password: str, strategy_name: str
) -> User:
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


def delete_all() -> None:
    with sqlite3.connect(DB_PATH) as con:
        con.execute("DELETE from users")


def user_for_name(username: str) -> User | None:
    with sqlite3.connect(DB_PATH) as con:
        row = con.execute(SEL + " WHERE username=?", (username,)).fetchone()
    return _row_to_user(row) if row else None


def _row_to_user(row: list[Any]) -> User:
    return User(timestamp=row[0], username=row[1], password=row[2], strategy=row[3])
