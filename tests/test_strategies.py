import re

import pytest

from strategies import md5, plaintext, registry, rot13, salted_md5

ALL_STRATEGIES = [plaintext, rot13, md5, salted_md5]


@pytest.mark.parametrize("strategy", ALL_STRATEGIES)
def test_encode_then_matches(strategy):
    encoded = strategy.encode("hunter2")
    assert strategy.matches("hunter2", encoded)


@pytest.mark.parametrize("strategy", ALL_STRATEGIES)
def test_wrong_password_does_not_match(strategy):
    encoded = strategy.encode("hunter2")
    assert not strategy.matches("hunter3", encoded)


def test_registry_exposes_all_strategies():
    assert set(registry) == {"plaintext", "rot13", "md5", "salted_md5"}


def test_plaintext_stores_password_as_is():
    assert plaintext.encode("abc") == "abc"


def test_rot13_round_trip():
    assert rot13.encode("hello") == "uryyb"
    assert rot13.encode(rot13.encode("hello")) == "hello"


def test_md5_is_deterministic_32_hex():
    encoded = md5.encode("hello")
    assert encoded == md5.encode("hello")
    assert re.fullmatch(r"[0-9a-f]{32}", encoded)


def test_salted_md5_uses_a_different_salt_each_call():
    a = salted_md5.encode("hello")
    b = salted_md5.encode("hello")
    assert a != b
    # Both still verify against the same password.
    assert salted_md5.matches("hello", a)
    assert salted_md5.matches("hello", b)


def test_salted_md5_format_is_salt_dollar_hash():
    encoded = salted_md5.encode("hello")
    salt, hash_part = encoded.split("$", 1)
    assert re.fullmatch(r"[0-9a-f]{6}", salt)
    assert re.fullmatch(r"[0-9a-f]{32}", hash_part)
