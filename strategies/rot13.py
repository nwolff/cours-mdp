import codecs


def encode(password: str) -> str:
    return codecs.encode(password, "rot_13")


def matches(password: str, stored_password: str) -> bool:
    return password == codecs.decode(stored_password, "rot_13")
