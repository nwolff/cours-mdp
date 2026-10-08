export const MIN_CHARS = 3; // Both for the username and password (also in firestore.rules)

export function credentialsAreValid(username: string, password: string): boolean {
	return Math.min(username.length, password.length) >= MIN_CHARS;
}

interface Props {
	username: string;
	onUsername: (username: string) => void;
	password: string;
	onPassword: (password: string) => void;
}

/** The name and password inputs shared by the registration and login forms. */
export default function CredentialFields(props: Props) {
	return (
		<>
			<div class="mb-3">
				<div class="form-floating">
					<input
						type="text"
						id="username"
						placeholder="Nom"
						class="form-control"
						required
						minLength={MIN_CHARS}
						autofocus
						autocapitalize="off"
						autocorrect="off"
						spellcheck={false}
						value={props.username}
						onInput={(e) => props.onUsername(e.currentTarget.value)}
					/>
					<label for="username">Nom</label>
				</div>
				<div class="form-text">Minimum {MIN_CHARS} caractères</div>
			</div>
			<div class="mb-3">
				<div class="form-floating">
					<input
						type="password"
						id="password"
						placeholder="Mot de passe"
						class="form-control"
						required
						minLength={MIN_CHARS}
						value={props.password}
						onInput={(e) => props.onPassword(e.currentTarget.value)}
					/>
					<label for="password">Mot de passe</label>
				</div>
				<div class="form-text">Minimum {MIN_CHARS} caractères</div>
			</div>
		</>
	);
}
