import { A, useNavigate } from '@solidjs/router';
import { createSignal } from 'solid-js';

import CredentialFields, { credentialsAreValid } from '../components/CredentialFields';
import ErrorAlert from '../components/ErrorAlert';
import type { AccountResult } from '../components/UserInfo';
import { errorMessage } from '../format';
import { userForName } from '../storage';
import { encodeLike, matches } from '../strategies';
import { useTitle } from '../title';

export default function Login() {
	useTitle(() => 'Se connecter');
	const navigate = useNavigate();

	const [username, setUsername] = createSignal('');
	const [password, setPassword] = createSignal('');
	const [error, setError] = createSignal<string>();
	const [checking, setChecking] = createSignal(false);

	const canSubmit = () => credentialsAreValid(username(), password()) && !checking();

	async function login(event: SubmitEvent) {
		event.preventDefault();
		if (!canSubmit()) {
			return;
		}
		setChecking(true);
		setError();
		try {
			const user = await userForName(username());
			if (!user) {
				setError('Utilisateur inconnu');
				return;
			}
			if (!matches(user.strategy, password(), user.password)) {
				setError('Mot de passe incorrect');
				return;
			}
			const result: AccountResult = {
				outcome: 'logged_in',
				user,
				encodedAttempt: encodeLike(user.strategy, password(), user.password)
			};
			navigate('/login/done', { state: result });
		} catch (e) {
			setError(errorMessage(e));
		} finally {
			setChecking(false);
		}
	}

	return (
		<div class="container d-flex justify-content-center align-items-center">
			<div class="card p-4 shadow" style={{ width: '100%', 'max-width': '380px' }}>
				<div class="card-body">
					<h3 class="card-title text-center mb-4">Se connecter</h3>
					<ErrorAlert message={error()} />
					<form onSubmit={login} autocomplete="off">
						<CredentialFields
							username={username()}
							onUsername={setUsername}
							password={password()}
							onPassword={setPassword}
						/>
						<div class="d-grid">
							<button type="submit" class="btn btn-primary" disabled={!canSubmit()}>
								Se connecter
							</button>
						</div>
					</form>
					<p class="text-center small mt-3 mb-0">
						Pas encore de compte ? <A href="/register">Créer un compte</A>
					</p>
				</div>
			</div>
		</div>
	);
}
