import { Navigate, useLocation } from '@solidjs/router';
import { Show } from 'solid-js';

import UserInfo, { OUTCOME_TITLES, type AccountResult } from '../components/UserInfo';
import { useTitle } from '../title';

/** Shown after registering or logging in, with the result passed as router state. */
export default function Account() {
	const location = useLocation();
	// Set by Register / Login when they navigate here; absent if the URL is opened directly.
	const result = () => location.state as AccountResult | undefined;
	useTitle(() => {
		const r = result();
		return r ? OUTCOME_TITLES[r.outcome] : '';
	});

	return (
		<Show when={result()} fallback={<Navigate href="/" />}>
			{(r) => <UserInfo result={r()} />}
		</Show>
	);
}
