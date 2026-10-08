import { Match, Show, Switch } from 'solid-js';

import { avatarUrl, formatDateTime } from '../format';
import type { User } from '../storage';
import { totem } from '../totem';

/** What /register/done and /login/done receive as router state. */
export type AccountResult =
	| { outcome: 'created' | 'replaced'; user: User }
	| { outcome: 'logged_in'; user: User; encodedAttempt: string };

export const OUTCOME_TITLES: Record<AccountResult['outcome'], string> = {
	created: 'Compte créé',
	replaced: 'Compte remplacé',
	logged_in: 'Connecté'
};

export default function UserInfo(props: { result: AccountResult }) {
	const user = () => props.result.user;
	const encodedAttempt = () =>
		props.result.outcome === 'logged_in' ? props.result.encodedAttempt : undefined;

	return (
		<div class="mx-auto" style={{ 'max-width': '520px' }}>
			<Switch>
				<Match when={props.result.outcome === 'created'}>
					<div class="alert alert-success" role="status">
						<h4 class="alert-heading mb-1">Le compte a été créé</h4>
						<p class="mb-0">
							Vous pouvez maintenant vous connecter avec ce nom et ce mot de passe.
						</p>
					</div>
				</Match>
				<Match when={props.result.outcome === 'replaced'}>
					<div class="alert alert-warning" role="status">
						<h4 class="alert-heading mb-1">Le compte a été remplacé</h4>
						<p class="mb-0">
							Un compte portant ce nom existait déjà : son mot de passe a été écrasé.
						</p>
					</div>
				</Match>
				<Match when={props.result.outcome === 'logged_in'}>
					<div class="alert alert-primary" role="status">
						<h4 class="alert-heading mb-1">Content de vous revoir&nbsp;!</h4>
						<p class="mb-0">
							Connexion réussie : le mot de passe saisi correspond à celui enregistré.
						</p>
					</div>
				</Match>
			</Switch>

			<div class="card shadow">
				<div class="card-body text-center p-3 p-sm-4">
					<img
						src={avatarUrl(user().username)}
						alt={`Avatar de ${user().username}`}
						class="rounded-circle border bg-light mb-3"
						width="180"
						height="180"
					/>
					<h2 class="card-title mb-1">{user().username}</h2>
					<p class="fst-italic mb-1">« {totem(user().username)} »</p>
					<p class="text-muted small mb-4">Compte créé le {formatDateTime(user().createdAt)}</p>
					{/* Labels above full-width values: hashes fit on one line, and stacked encodings line up for comparison */}
					<dl class="text-start mb-0">
						<dt class="small text-muted fw-normal">Stratégie</dt>
						<dd class="mb-3">{user().strategy}</dd>
						<dt class="small text-muted fw-normal">Mot de passe stocké</dt>
						<dd class="mb-3">
							<code class="encoded d-block p-2 bg-light border rounded text-break">
								{user().password}
							</code>
						</dd>
						<Show when={encodedAttempt()}>
							<dt class="small text-muted fw-normal">Saisie encodée</dt>
							<dd class="mb-0">
								<code class="encoded d-block p-2 bg-light border rounded text-break">
									{encodedAttempt()}
								</code>
							</dd>
						</Show>
					</dl>
					<Show when={encodedAttempt()}>
						<p class="text-success small mt-2 mb-0">✓ Identiques : le mot de passe est correct</p>
					</Show>
				</div>
			</div>
		</div>
	);
}
