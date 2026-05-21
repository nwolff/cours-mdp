import hashlib

ANIMALS = [
    "abeille",
    "aigle",
    "âne",
    "araignée",
    "baleine",
    "biche",
    "cerf",
    "cigogne",
    "corbeau",
    "dauphin",
    "écureuil",
    "éléphant",
    "faucon",
    "gazelle",
    "girafe",
    "hibou",
    "hirondelle",
    "lion",
    "loutre",
    "lynx",
    "mésange",
    "ours",
    "panda",
    "panthère",
    "pélican",
    "raton",
    "renard",
    "requin",
    "salamandre",
    "tigre",
    "tortue",
    "zèbre",
]

# Invariant adjectives (same form in masculine / feminine) so they agree with
# any animal in the list without further inflection.
ADJECTIVES = [
    "agile",
    "aimable",
    "brave",
    "calme",
    "célèbre",
    "drôle",
    "écarlate",
    "fidèle",
    "fragile",
    "habile",
    "honnête",
    "humble",
    "intrépide",
    "jeune",
    "libre",
    "lyrique",
    "magnifique",
    "mince",
    "noble",
    "paisible",
    "propre",
    "rapide",
    "robuste",
    "rouge",
    "sage",
    "sauvage",
    "sincère",
    "solide",
    "sombre",
    "splendide",
    "tenace",
    "tranquille",
]

assert len(ANIMALS) == 32
assert len(ADJECTIVES) == 32


def totem(seed: str) -> str:
    """Deterministic French totem ("Lion Fragile") derived from an MD5 hash.

    The same seed always yields the same totem; pairs are drawn from
    32 animals × 32 adjectives = 1024 combinations.
    """
    digest = hashlib.md5(seed.encode("utf-8")).digest()
    animal = ANIMALS[digest[0] % len(ANIMALS)]
    adjective = ADJECTIVES[digest[1] % len(ADJECTIVES)]
    return f"{animal.capitalize()} {adjective.capitalize()}"
