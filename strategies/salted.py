import hashlib
import os


def _hash(salt, p):
    return hashlib.md5(f"{salt}{p}".encode("utf-8")).hexdigest()


def encode_password(p):
    salt = os.urandom(3).hex()
    hash = _hash(salt, p)
    return f"{salt}${hash}"


def is_valid_password(p, stored):
    salt, stored_hash = stored.split("$")
    return _hash(salt, p) == stored_hash
