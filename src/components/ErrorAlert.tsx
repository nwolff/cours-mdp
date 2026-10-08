import { Show } from 'solid-js';

export default function ErrorAlert(props: { message: string | undefined }) {
	return (
		<Show when={props.message}>
			<div class="alert alert-danger" role="alert">
				{props.message}
			</div>
		</Show>
	);
}
