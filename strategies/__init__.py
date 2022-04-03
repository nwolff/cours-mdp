from . import plaintext, rot13, md5, salted_md5

registry = {}
for module in (plaintext, rot13, md5, salted_md5):
    name = module.__name__.split(".")[-1]
    module.name = name
    registry[name] = module
