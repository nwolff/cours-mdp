import {
	collection,
	doc,
	getDoc,
	getDocs,
	onSnapshot,
	orderBy,
	query,
	serverTimestamp,
	setDoc,
	writeBatch,
	type DocumentSnapshot,
	type Timestamp
} from 'firebase/firestore';

import { db } from './firebase';

export interface User {
	username: string;
	password: string;
	/** A strategy name from src/Strategy.elm (firestore.rules lists the valid ones). */
	strategy: string;
	createdAt: Date;
}

/** One document in the `users` collection, whose id is the username. */
interface StoredUser {
	password: string;
	strategy: string;
	/** Set by Firestore when the document is written (checked by firestore.rules). */
	createdAt: Timestamp;
}

const users = collection(db, 'users');

/**
 * Calls `onChange` with every user, most recently created first, now and again
 * each time the collection changes.
 */
export function subscribeToUsers(
	onChange: (users: User[]) => void,
	onError: (error: Error) => void
): () => void {
	const newestFirst = query(users, orderBy('createdAt', 'desc'));
	return onSnapshot(newestFirst, (snapshot) => onChange(snapshot.docs.map(toUser)), onError);
}

export async function userForName(username: string): Promise<User | null> {
	const snapshot = await getDoc(doc(users, username));
	return snapshot.exists() ? toUser(snapshot) : null;
}

/** Returns the account as stored, including the creation time Firestore assigned. */
export async function createOrUpdateUser(
	username: string,
	encodedPassword: string,
	strategy: string
): Promise<User> {
	const ref = doc(users, username);
	await setDoc(ref, { password: encodedPassword, strategy, createdAt: serverTimestamp() });
	return toUser(await getDoc(ref));
}

const MAX_WRITES_PER_BATCH = 500;

export async function deleteAll(): Promise<void> {
	const { docs } = await getDocs(users);
	for (let start = 0; start < docs.length; start += MAX_WRITES_PER_BATCH) {
		const batch = writeBatch(db);
		for (const document of docs.slice(start, start + MAX_WRITES_PER_BATCH)) {
			batch.delete(document.ref);
		}
		await batch.commit();
	}
}

function toUser(snapshot: DocumentSnapshot): User {
	// firestore.rules guarantees the shape of every stored document.
	// 'estimate': a write still on its way to the server gets the local time instead of null.
	const stored = snapshot.data({ serverTimestamps: 'estimate' }) as StoredUser;
	return {
		username: snapshot.id,
		password: stored.password,
		strategy: stored.strategy,
		createdAt: stored.createdAt.toDate()
	};
}
