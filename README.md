# Application stockage de mot de passe

https://mdp.nwolff.info/

Students create accounts with different password strategies (plaintext → rot13 → md5 →
salted_md5) and compare what ends up stored.

A static [Elm](https://elm-lang.org/) app, hosted on GitHub Pages. The browser reads and
writes [Cloud Firestore](https://firebase.google.com/docs/firestore) directly: there is no
server.

Elm has no Firestore SDK, so Firestore stays in TypeScript ([src/storage.ts](src/storage.ts)).
[src/main.ts](src/main.ts) connects it to the ports declared in [src/Ports.elm](src/Ports.elm);
everything else (pages, routing, password strategies) is Elm, starting at
[src/Main.elm](src/Main.elm).
See [ELM.md](ELM.md) for how the two halves fit together.

## Pages

- **`/#/register`**: create an account. Re-registering an existing name overwrites it (see
  [CLAUDE.md](CLAUDE.md)). Shows a live preview of the encoded password.
- **`/#/login`**: compares the encoded attempt with the stored password.
- **`/#/listusers`**: every stored account, updated live via Firestore's `onSnapshot`.
- **`/#/_delete`**: unlisted; deletes every account, then shows the (empty) list.

Hashing and the login check run in the browser. That is fine for this demo, and a good
discussion point: in a real application, they must happen on a server.

## Developing locally

    npm install
    npm run dev        # http://localhost:5173
    npm test           # elm-test: strategies and totem
    npm run check      # type-check the TypeScript
    npm run format     # prettier and elm-format

The Elm compiler, elm-test and elm-format come from `npm install` (see package.json), so no
global Elm install is needed.

The dev server talks to the production Firestore database.

## Firebase

- Project `cours-mdp-407714`, Firestore database `cours-mdp`, collection `users`
  (document id = username; fields `password`, `strategy`, `createdAt`).
- The web config in [src/firebase.ts](src/firebase.ts) contains public client identifiers,
  not secrets.
- Since the browser talks to Firestore directly, [firestore.rules](firestore.rules) are the
  only gatekeeper. They are open by design for the course, but enforce the shape of an
  account. Deploy them after changing them:

        npx firebase-tools login
        npx firebase-tools deploy --only firestore:rules

## Deployment

Pushing to `main` triggers [.github/workflows/deploy.yml](.github/workflows/deploy.yml),
which type-checks, tests, builds and publishes to GitHub Pages.

One-time setup on GitHub: **Settings → Pages → Build and deployment → Source: GitHub
Actions**, and **Custom domain: mdp.nwolff.info**.
