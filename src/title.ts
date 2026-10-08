import { createEffect } from 'solid-js';

export function useTitle(title: () => string): void {
	createEffect(() => {
		document.title = title();
	});
}
