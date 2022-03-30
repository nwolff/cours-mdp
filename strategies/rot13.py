import codecs


def encode(password):
    return codecs.encode(password, "rot_13")


def matches(password, stored_password):
    return password == codecs.decode(stored_password, "rot_13")
