from dataclasses import asdict, dataclass
from datetime import datetime
from typing import Any


@dataclass
class User:
    timestamp: str
    username: str
    password: str
    strategy: str

    @staticmethod
    def from_dict(source: dict[str, Any]):
        return User(**source)

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


def iso_timestamp() -> str:
    return datetime.now().isoformat()
