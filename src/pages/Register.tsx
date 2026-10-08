import { A, useNavigate } from '@solidjs/router';
import { createMemo, createSignal, For, Show } from 'solid-js';

import CredentialFields, { credentialsAreValid } from '../components/CredentialFields';
import ErrorAlert from '../components/ErrorAlert';
import type { AccountResult } from '../components/UserInfo';
import { errorMessage } from '../format';
import { createOrUpdateUser, userForName } from '../storage';
import { encode, newSalt, strategyNames, type StrategyName } from '../strategies';
import { useTitle } from '../title';

export default function Register() {
	useTitle(() => 'Créer un compte');
	const navigate = useNavigate();

	const [username, setUsername] = createSignal('');
	const [password, setPassword] = createSignal('');
	const [strategyName, setStrategyName] = createSignal<StrategyName>();
	const [error, setError] = createSignal<string>();
	const [saving, setSaving] = createSignal(false);
	// Drawn once when the page opens, so the preview shows exactly what gets stored.
	const salt = newSalt();

	const canSubmit = () =>
		credentialsAreValid(username(), password()) && strategyName() !== undefined && !saving();

	const preview = createMemo(() => {
		const name = strategyName();
		return name && password() ? encode(name, password(), salt) : undefined;
	});

	async function register(event: SubmitEvent) {
		event.preventDefault();
		const name = strategyName();
		if (!canSubmit() || !name) {
			return;
		}
		setSaving(true);
		setError();
		try {
			const existed = (await userForName(username())) !== null;
			const user = await createOrUpdateUser(username(), encode(name, password(), salt), name);
			const result: AccountResult = { outcome: existed ? 'replaced' : 'created', user };
			navigate('/register/done', { state: result });
		} catch (e) {
			setError(errorMessage(e));
		} finally {
			setSaving(false);
		}
	}

	return (
		<div class="container d-flex justify-content-center align-items-center">
			<div class="card p-4 shadow" style={{ width: '100%', 'max-width': '500px' }}>
				<div class="card-body">
					<h3 class="card-title text-center mb-4">Créer un compte</h3>
					<ErrorAlert message={error()} />
					<form onSubmit={register} autocomplete="off">
						<CredentialFields
							username={username()}
							onUsername={setUsername}
							password={password()}
							onPassword={setPassword}
						/>
						<div class="mb-3">
							<label class="form-label d-block">Stratégie</label>
							<div class="d-flex flex-wrap gap-2" role="group">
								<For each={strategyNames}>
									{(name) => (
										<>
											<input
												type="radio"
												class="btn-check"
												name="strategy_name"
												id={`strategy_${name}`}
												value={name}
												autocomplete="off"
												required
												checked={strategyName() === name}
												onChange={() => setStrategyName(name)}
											/>
											<label class="btn btn-outline-secondary" for={`strategy_${name}`}>
												{name}
											</label>
										</>
									)}
								</For>
							</div>
							<div class="form-text">Choisir une stratégie</div>
						</div>
						<div class="mb-3">
							<label class="form-label small text-muted mb-1">Aperçu du mot de passe encodé</label>
							<code
								class="d-block p-2 bg-light border rounded text-break"
								style={{ 'min-height': '2.4em' }}
							>
								<Show
									when={preview()}
									fallback={
										<span class="text-muted fst-italic">
											(saisir un mot de passe et choisir une stratégie)
										</span>
									}
								>
									{preview()}
								</Show>
							</code>
						</div>
						<div class="d-grid">
							<button type="submit" class="btn btn-primary" disabled={!canSubmit()}>
								Créer
							</button>
						</div>
					</form>
					<p class="text-center small mt-3 mb-0">
						Déjà un compte ? <A href="/login">Se connecter</A>
					</p>
				</div>
			</div>
		</div>
	);
}
