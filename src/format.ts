import { md5Hex } from './hash';

/** French rule: singular for 0 and 1, plural for 2+. */
export function pluralize(count: number, singular = '', plural = 's'): string {
	return count <= 1 ? singular : plural;
}

/** "2026-10-10 14:03:05" in the viewer's time zone. */
export function formatDateTime(date: Date): string {
	const pad = (n: number) => String(n).padStart(2, '0');
	const day = `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
	const time = `${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`;
	return `${day} ${time}`;
}

export function avatarUrl(username: string): string {
	return `https://api.dicebear.com/9.x/bottts/svg?seed=${md5Hex(username)}`;
}

export function errorMessage(error: unknown): string {
	return `Erreur : ${error instanceof Error ? error.message : String(error)}`;
}
