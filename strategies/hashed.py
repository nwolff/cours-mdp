import hashlib


def encode_password(p):
    return hashlib.md5(p.encode("utf-8")).hexdigest()


def is_valid_password(p, stored):
    return encode_password(p) == stored
