import { createSignal, For, onCleanup, Show } from 'solid-js';

import ErrorAlert from '../components/ErrorAlert';
import { errorMessage, formatDateTime, pluralize } from '../format';
import { subscribeToUsers, type User } from '../storage';
import { useTitle } from '../title';

export default function ListUsers() {
	useTitle(() => 'Comptes');

	const [users, setUsers] = createSignal<User[]>();
	const [error, setError] = createSignal<string>();

	// Firestore pushes every change, so the table stays up to date without reloading.
	const unsubscribe = subscribeToUsers(
		(list) => setUsers(list),
		(e) => setError(errorMessage(e))
	);
	onCleanup(unsubscribe);

	return (
		<>
			<ErrorAlert message={error()} />
			<Show when={users()}>
				{(list) => (
					<>
						<h2>
							{list().length} Compte{pluralize(list().length)}
						</h2>
						<div class="table-responsive">
							<table class="table table-striped table-hover">
								<thead>
									<tr>
										<th>Nom</th>
										<th>Mot de passe encodé</th>
										<th>Stratégie</th>
										<th>Date et heure de création</th>
									</tr>
								</thead>
								<tbody>
									<For each={list()}>
										{(user) => (
											<tr>
												<td>{user.username}</td>
												<td>{user.password}</td>
												<td>{user.strategy}</td>
												<td>{formatDateTime(user.createdAt)}</td>
											</tr>
										)}
									</For>
								</tbody>
							</table>
						</div>
					</>
				)}
			</Show>
		</>
	);
}
