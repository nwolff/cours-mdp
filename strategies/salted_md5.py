import hashlib
import os


def encode(password):
    salt = os.urandom(3).hex()
    hash = _hash(salt, password)
    return f"{salt}${hash}"


def matches(password, stored_password):
    salt, stored_hash = stored_password.split("$")
    return _hash(salt, password) == stored_hash


def _hash(salt, password):
    return hashlib.md5(f"{salt}{password}".encode("utf-8")).hexdigest()
