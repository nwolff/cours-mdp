from dataclasses import dataclass
from datetime import datetime


@dataclass
class User:
    timestamp: str
    username: str
    password: str
    strategy: str


def iso_timestamp():
    return datetime.now().isoformat()
