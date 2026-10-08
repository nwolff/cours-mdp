import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';

// These values are public client identifiers, not secrets. Access is controlled
// by Firestore security rules (see firestore.rules), not by hiding this config.
// Source: Firebase console → Project settings → General → Your apps.
const firebaseConfig = {
	apiKey: 'AIzaSyCfrw-APOPpOnD9T9NPJ6ghijPbPRPAoZI',
	authDomain: 'cours-mdp-407714.firebaseapp.com',
	projectId: 'cours-mdp-407714',
	appId: '1:5563464620:web:bafaa161b19ee0f4cd5809'
};

export const db = getFirestore(initializeApp(firebaseConfig), 'cours-mdp');
