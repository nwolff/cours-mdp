// Types for `import { Elm } from './Main.elm'` (compiled by vite-plugin-elm).
// They must match the ports declared in src/Ports.elm: Elm checks what it
// receives at runtime, TypeScript checks what main.ts sends.

declare module '*.elm' {
	interface ElmUser {
		username: string;
		password: string;
		strategy: string;
		createdAt: number;
	}

	/** A port Elm sends on (`port x : a -> Cmd msg`). */
	interface FromElm<T> {
		subscribe(callback: (value: T) => void): void;
	}

	/** A port Elm listens on (`port x : (a -> msg) -> Sub msg`). */
	interface ToElm<T> {
		send(value: T): void;
	}

	export const Elm: {
		Main: {
			init(options: { node: HTMLElement | null; flags: { siteUrl: string } }): {
				ports: {
					subscribeUsers: FromElm<null>;
					unsubscribeUsers: FromElm<null>;
					fetchUser: FromElm<string>;
					saveUser: FromElm<{ username: string; password: string; strategy: string }>;
					deleteAllUsers: FromElm<null>;
					usersChanged: ToElm<ElmUser[]>;
					userFetched: ToElm<ElmUser | null>;
					userSaved: ToElm<ElmUser>;
					allUsersDeleted: ToElm<null>;
					storageError: ToElm<string>;
				};
			};
		};
	};
}
