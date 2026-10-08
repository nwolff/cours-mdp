import { md5Hex, randomHex } from './hash';

/**
 * 6 hex characters. Only salted_md5 uses it, but every strategy takes one: the caller
 * draws it (with `newSalt`) and passes it in, so `encode` always gives the same result
 * for the same arguments.
 */
export type Salt = string;

export function newSalt(): Salt {
	return randomHex(3);
}

// The ways a password can be stored, from worst to least bad.
// The keys are what gets stored in Firestore (and checked by firestore.rules).
// Their order is the order shown on the registration page.
const encoders = {
	plaintext: (password) => password,
	rot13: (password) => rot13(password),
	md5: (password) => md5Hex(password),
	salted_md5: (password, salt) => `${salt}$${hashWithSalt(salt, password)}`
} satisfies Record<string, (password: string, salt: Salt) => string>;

export type StrategyName = keyof typeof encoders;

export const strategyNames = Object.keys(encoders) as StrategyName[];

export function encode(strategy: StrategyName, password: string, salt: Salt): string {
	return encoders[strategy](password, salt);
}

/**
 * Encodes an attempt so it can be compared with the stored password
 * (reusing its salt, if any: otherwise the result could never be equal).
 */
export function encodeLike(
	strategy: StrategyName,
	password: string,
	storedPassword: string
): string {
	return encode(strategy, password, saltOf(storedPassword));
}

export function matches(strategy: StrategyName, password: string, storedPassword: string): boolean {
	return encodeLike(strategy, password, storedPassword) === storedPassword;
}

export function hashWithSalt(salt: Salt, password: string): string {
	return md5Hex(`${salt}${password}`);
}

/** "abc123$5d41…" → "abc123". Strategies without a salt ignore it. */
function saltOf(storedPassword: string): Salt {
	return storedPassword.split('$')[0];
}

/**
 * Only the 26 latin letters rotate; digits, accents and symbols stay as they are.
 * Rotating by 13 twice goes all the way round the alphabet, so this also decodes.
 */
function rot13(text: string): string {
	return text.replace(/[a-z]/gi, (letter) => {
		const a = letter <= 'Z' ? 'A'.charCodeAt(0) : 'a'.charCodeAt(0);
		return String.fromCharCode(a + ((letter.charCodeAt(0) - a + 13) % 26));
	});
}
