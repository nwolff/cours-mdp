import hashlib


def encode(password: str) -> str:
    return hashlib.md5(password.encode("utf-8")).hexdigest()


def matches(password: str, stored_password: str) -> bool:
    return encode(password) == stored_password
