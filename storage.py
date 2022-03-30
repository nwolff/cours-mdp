from dataclasses import dataclass
from strategies import registry as strategy_registry
from google.cloud import datastore
import datetime

client = datastore.Client()


@dataclass
class User:
    created: datetime.datetime
    username: str
    password: str
    strategy: str


def _user_entity_to_object(e):
    return User(
        created=e["created"],
        strategy=e["strategy"],
        username=e["username"],
        password=e["password"],
    )


def load_users():
    query = client.query(kind="User")
    query.order = ["-created"]
    return [_user_entity_to_object(e) for e in query.fetch()]


def create_user(strategy, username, password):
    new_user = datastore.Entity(client.key("User"))
    new_user.update(
        {
            "created": datetime.datetime.utcnow(),
            "username": username,
            "password": strategy.encode_password(password),
            "strategy": strategy.name,
        }
    )
    client.put(new_user)
    return _user_entity_to_object(new_user)


def user_for_credentials(username, password):
    query = client.query(kind="User")
    query.add_filter("username", "=", username)
    result = list(query.fetch())
    if not result:
        return False
    for user in result:
        strategy = strategy_registry[user["strategy"]]
        if strategy.is_valid_password(password, user["password"]):
            return _user_entity_to_object(user)
    return False
