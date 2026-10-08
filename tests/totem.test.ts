import { expect, test } from 'vitest';

import { ADJECTIVES, ANIMALS, totem } from '../src/totem';

test('totem is deterministic', () => {
	expect(totem('alice')).toBe(totem('alice'));
});

test('totem is case and whitespace sensitive', () => {
	expect(totem('Alice')).not.toBe(totem('alice'));
	expect(totem('alice')).not.toBe(totem(' alice'));
});

test('different seeds likely differ', () => {
	expect(totem('alice')).not.toBe(totem('bob'));
});

test('totem has two capitalized words', () => {
	const parts = totem('alice').split(' ');
	expect(parts).toHaveLength(2);
	for (const part of parts) {
		expect(part[0]).toBe(part[0].toUpperCase());
	}
});

test('totem uses known animal and adjective', () => {
	const [animal, adjective] = totem('alice').split(' ');
	expect(ANIMALS).toContain(animal.toLowerCase());
	expect(ADJECTIVES).toContain(adjective.toLowerCase());
});

test('lists have 32 entries each', () => {
	expect(ANIMALS).toHaveLength(32);
	expect(ADJECTIVES).toHaveLength(32);
});

// Fixed seeds with their expected totems, so a change in the algorithm shows up.
test.each([
	['alice', 'Araignée Célèbre'],
	['bob', 'Zèbre Splendide'],
	['Élodie', 'Lynx Solide'],
	['hunter2', 'Écureuil Sauvage']
])('known totem: %s', (seed, expected) => {
	expect(totem(seed)).toBe(expected);
});
