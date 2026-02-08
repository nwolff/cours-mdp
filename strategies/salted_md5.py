import hashlib
import os


def encode(password: str) -> str:
    salt = os.urandom(3).hex()
    hash = hash_with_salt(password, salt)
    return f"{salt}${hash}"


def matches(password: str, stored_password: str) -> bool:
    salt, stored_hash = stored_password.split("$", 1)
    return hash_with_salt(password, salt) == stored_hash


def hash_with_salt(password: str, salt: str) -> str:
    return hashlib.md5(f"{salt}{password}".encode()).hexdigest()
