import 'bootstrap/dist/css/bootstrap.min.css';
import './styles.css';

import { Elm } from './Main.elm';
import { createOrUpdateUser, deleteAll, subscribeToUsers, userForName, type User } from './storage';

// The Elm app (src/Main.elm) handles everything but Firestore, which it reaches
// through the ports declared in src/Ports.elm.

const app = Elm.Main.init({
	node: document.getElementById('root'),
	// The site's address without the #/route part, for the QR code on the home page.
	flags: { siteUrl: window.location.origin + window.location.pathname }
});
const ports = app.ports;

/** How a user crosses the port: Elm has no Date, so the time travels as milliseconds. */
function toElm(user: User) {
	return { ...user, createdAt: user.createdAt.getTime() };
}

/** Runs a Firestore request; a failure goes to Elm instead of the console. */
async function reportingErrors(request: () => Promise<void>): Promise<void> {
	try {
		await request();
	} catch (error) {
		ports.storageError.send(error instanceof Error ? error.message : String(error));
	}
}

let unsubscribe: (() => void) | undefined;

ports.subscribeUsers.subscribe(() => {
	unsubscribe?.();
	unsubscribe = subscribeToUsers(
		(users) => ports.usersChanged.send(users.map(toElm)),
		(error) => ports.storageError.send(error.message)
	);
});

ports.unsubscribeUsers.subscribe(() => {
	unsubscribe?.();
	unsubscribe = undefined;
});

ports.fetchUser.subscribe((username) =>
	reportingErrors(async () => {
		const user = await userForName(username);
		ports.userFetched.send(user && toElm(user));
	})
);

ports.saveUser.subscribe(({ username, password, strategy }) =>
	reportingErrors(async () => {
		ports.userSaved.send(toElm(await createOrUpdateUser(username, password, strategy)));
	})
);

ports.deleteAllUsers.subscribe(() =>
	reportingErrors(async () => {
		await deleteAll();
		ports.allUsersDeleted.send(null);
	})
);
