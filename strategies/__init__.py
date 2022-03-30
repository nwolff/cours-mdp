from . import md5, plaintext, rot13, salted_md5

registry = {}
for module in (plaintext, rot13, md5, salted_md5):
    name_without_package = module.__name__.split(".")[-1]
    registry[name_without_package] = module
