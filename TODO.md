# Idées

## Suppression de compte par l'élève (angle RGPD)

Permettre à un élève connecté de supprimer son propre compte, comme prétexte
pour aborder le « droit à l'oubli » et les obligations RGPD :

- bouton « Supprimer mon compte » sur la page userinfo
- confirmation avant suppression
- discussion en classe : que reste-t-il dans les logs, les backups, etc.

## Rewrite en javascript

don't implement anything but I want to know what you think about rewriting the whole thing to a javascript only app (no server side apart from firestore)
I know svelte and elm
I'm curious about other frameworks such as solid

A few honest thoughts:

On the rewrite itself: for this app size it's a clean fit — Firestore JS SDK gives you real-time listeners for free (the SSE bridge disappears), and all four strategies are trivial in JS (15-line MD5, 1-line rot13). You'd lose: the server-side encoding endpoint as a teaching artifact (round-trips to a Python backend doing real work has its own pedagogical value), the import storage.sqlite offline-dev swap, and the escape hatch for any future server-only feature (proper auth, admin reset, audit). Biggest new concern: Firestore security rules. With Flask, you can trust the source; client-only means anyone with the URL can write directly unless you configure rules carefully.

On framework choice:

Svelte (Svelte 5 / SvelteKit): lowest friction, mature Firestore patterns, you already know it. Boring-good.
Elm: pedagogically beautiful but Firestore-via-ports is painful for what's gained on an app this small.

Solid: a good size to learn on — signals will click fast coming from Svelte, JSX coming from any React-like. Smaller ecosystem than Svelte, but for this app you barely touch the ecosystem.

My take: if the goal is to learn Solid, this is a perfect-sized sandbox — go for it. If the goal is "simplify ops", Svelte is the obviously correct boring choice. Stay on Flask only if you can name a future server-side feature you actually want.
