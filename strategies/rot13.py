import codecs


def encode_password(p):
    return codecs.encode(p, "rot_13")


def is_valid_password(p, stored):
    return encode_password(p) == stored
