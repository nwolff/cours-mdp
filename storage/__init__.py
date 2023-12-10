from dataclasses import asdict, dataclass
from datetime import datetime


@dataclass
class User:
    timestamp: str
    username: str
    password: str
    strategy: str

    @staticmethod
    def from_dict(source):
        return User(**source)

    def to_dict(self):
        return asdict(self)


def iso_timestamp():
    return datetime.now().isoformat()
