import { useNavigate } from '@solidjs/router';
import { createSignal, onMount, Show } from 'solid-js';

import ErrorAlert from '../components/ErrorAlert';
import { errorMessage } from '../format';
import { deleteAll } from '../storage';
import { useTitle } from '../title';

/** Unlisted page that wipes every account, for resetting between classes. */
export default function DeleteAll() {
	useTitle(() => 'Suppression');
	const navigate = useNavigate();
	const [error, setError] = createSignal<string>();

	onMount(async () => {
		try {
			await deleteAll();
			navigate('/listusers', { replace: true });
		} catch (e) {
			setError(errorMessage(e));
		}
	});

	return (
		<Show when={error()} fallback={<p class="text-muted">Suppression des comptes…</p>}>
			<ErrorAlert message={error()} />
		</Show>
	);
}
