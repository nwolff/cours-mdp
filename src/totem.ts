import { md5Bytes } from './hash';

export const ANIMALS = [
	'abeille',
	'aigle',
	'âne',
	'araignée',
	'baleine',
	'biche',
	'cerf',
	'cigogne',
	'corbeau',
	'dauphin',
	'écureuil',
	'éléphant',
	'faucon',
	'gazelle',
	'girafe',
	'hibou',
	'hirondelle',
	'lion',
	'loutre',
	'lynx',
	'mésange',
	'ours',
	'panda',
	'panthère',
	'pélican',
	'raton',
	'renard',
	'requin',
	'salamandre',
	'tigre',
	'tortue',
	'zèbre'
];

// Invariant adjectives (same form in masculine / feminine) so they agree with
// any animal in the list without further inflection.
export const ADJECTIVES = [
	'agile',
	'aimable',
	'brave',
	'calme',
	'célèbre',
	'drôle',
	'écarlate',
	'fidèle',
	'fragile',
	'habile',
	'honnête',
	'humble',
	'intrépide',
	'jeune',
	'libre',
	'lyrique',
	'magnifique',
	'mince',
	'noble',
	'paisible',
	'propre',
	'rapide',
	'robuste',
	'rouge',
	'sage',
	'sauvage',
	'sincère',
	'solide',
	'sombre',
	'splendide',
	'tenace',
	'tranquille'
];

/**
 * Deterministic French totem ("Lion Fragile") derived from an MD5 hash.
 *
 * The same seed always yields the same totem; pairs are drawn from
 * 32 animals × 32 adjectives = 1024 combinations.
 */
export function totem(seed: string): string {
	const digest = md5Bytes(seed);
	const animal = ANIMALS[digest[0] % ANIMALS.length];
	const adjective = ADJECTIVES[digest[1] % ADJECTIVES.length];
	return `${capitalize(animal)} ${capitalize(adjective)}`;
}

function capitalize(word: string): string {
	return word.charAt(0).toUpperCase() + word.slice(1);
}
