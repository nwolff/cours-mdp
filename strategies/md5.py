import hashlib


def encode(password):
    return hashlib.md5(password.encode("utf-8")).hexdigest()


def matches(password, stored_password):
    return encode(password) == stored_password
