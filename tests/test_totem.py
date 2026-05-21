from totem import ADJECTIVES, ANIMALS, totem


def test_totem_is_deterministic():
    assert totem("alice") == totem("alice")


def test_totem_is_case_and_whitespace_sensitive():
    assert totem("Alice") != totem("alice")
    assert totem("alice") != totem(" alice")


def test_different_seeds_likely_differ():
    assert totem("alice") != totem("bob")


def test_totem_has_two_capitalized_words():
    parts = totem("alice").split()
    assert len(parts) == 2
    assert all(p[0].isupper() for p in parts)


def test_totem_uses_known_animal_and_adjective():
    animal, adjective = totem("alice").split()
    assert animal.lower() in ANIMALS
    assert adjective.lower() in ADJECTIVES
