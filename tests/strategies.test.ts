import { describe, expect, test } from 'vitest';

import {
	encode,
	encodeLike,
	hashWithSalt,
	matches,
	newSalt,
	strategyNames
} from '../src/strategies';

describe.each(strategyNames)('%s', (name) => {
	const stored = encode(name, 'hunter2', newSalt());

	test('encode then matches', () => {
		expect(matches(name, 'hunter2', stored)).toBe(true);
	});

	test('wrong password does not match', () => {
		expect(matches(name, 'hunter3', stored)).toBe(false);
	});

	test('encodeLike reproduces the stored password', () => {
		expect(encodeLike(name, 'hunter2', stored)).toBe(stored);
	});
});

test('all strategies, in display order', () => {
	expect(strategyNames).toEqual(['plaintext', 'rot13', 'md5', 'salted_md5']);
});

test('plaintext stores password as is', () => {
	expect(encode('plaintext', 'abc', '')).toBe('abc');
});

test('rot13 round trip', () => {
	expect(encode('rot13', 'hello', '')).toBe('uryyb');
	expect(encode('rot13', 'uryyb', '')).toBe('hello');
});

test('md5 is deterministic 32 hex', () => {
	const encoded = encode('md5', 'hello', '');
	expect(encoded).toBe(encode('md5', 'hello', ''));
	expect(encoded).toMatch(/^[0-9a-f]{32}$/);
});

test('salts are 6 lowercase hex characters', () => {
	for (let i = 0; i < 50; i++) {
		expect(newSalt()).toMatch(/^[0-9a-f]{6}$/);
	}
});

test('different salts give different encodings of the same password', () => {
	const a = encode('salted_md5', 'hello', newSalt());
	const b = encode('salted_md5', 'hello', newSalt());
	expect(a).not.toBe(b);
	// Both still verify against the same password.
	expect(matches('salted_md5', 'hello', a)).toBe(true);
	expect(matches('salted_md5', 'hello', b)).toBe(true);
});

test('salted md5 format is salt$hash', () => {
	expect(encode('salted_md5', 'hello', 'abc123')).toMatch(/^abc123\$[0-9a-f]{32}$/);
});

// Fixed inputs with their expected outputs, so a change in the algorithms shows up.
describe('known values', () => {
	test('md5', () => {
		expect(encode('md5', 'hello', '')).toBe('5d41402abc4b2a76b9719d911017c592');
	});

	test('rot13 only rotates latin letters', () => {
		expect(encode('rot13', 'Hello, Wörld 123', '')).toBe('Uryyb, Jöeyq 123');
	});

	test('salted md5 hashes salt + password', () => {
		expect(hashWithSalt('abc', 'hunter2')).toBe('58916152055d74d5098420c036bd4c83');
	});

	test('salted md5 matches a stored password', () => {
		expect(matches('salted_md5', 'hunter2', 'abc$58916152055d74d5098420c036bd4c83')).toBe(true);
	});
});
