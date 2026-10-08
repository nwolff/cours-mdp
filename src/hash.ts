import { md5 } from '@noble/hashes/legacy.js';
import { bytesToHex, utf8ToBytes } from '@noble/hashes/utils.js';

// Browsers' built-in crypto.subtle has no MD5 (it's broken), hence the library.

export function md5Bytes(text: string): Uint8Array {
	return md5(utf8ToBytes(text));
}

export function md5Hex(text: string): string {
	return bytesToHex(md5Bytes(text));
}

export function randomHex(byteCount: number): string {
	return bytesToHex(crypto.getRandomValues(new Uint8Array(byteCount)));
}
