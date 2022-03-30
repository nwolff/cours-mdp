from . import plaintext, hashed, rot13, salted

registry = {}
for module in (plaintext, rot13, hashed, salted):
    name = module.__name__.split(".")[-1]
    module.name = name
    registry[name] = module
