# Application stockage de mot de passe

https://mdp.nwolff.info/

Students create accounts with different password strategies (plaintext → rot13 → md5 →
salted_md5) and compare what ends up stored.

A static [Solid](https://www.solidjs.com/) + TypeScript app, hosted on GitHub Pages. The
browser reads and writes [Cloud Firestore](https://firebase.google.com/docs/firestore)
directly: there is no server.

## Pages

- **`/#/register`**: create an account. Re-registering an existing name overwrites it (see
  [CLAUDE.md](CLAUDE.md)). Shows a live preview of the encoded password.
- **`/#/login`**: compares the encoded attempt with the stored password.
- **`/#/listusers`**: every stored account, updated live via Firestore's `onSnapshot`.
- **`/#/_delete`**: unlisted; deletes every account, then shows the (empty) list.
- **`/#/about`**: unlisted; build date, repository and commit hash of the deployed build.

Hashing and the login check run in the browser. That is fine for this demo, and a good
discussion point: in a real application, they must happen on a server.

## Developing locally

    npm install
    npm run dev        # http://localhost:5173
    npm test           # strategies and totem
    npm run check      # type-check
    npm run format     # prettier

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

# Possible enhancements

## Suppression de compte par l'élève (angle RGPD)

Permettre à un élève connecté de supprimer son propre compte, comme prétexte
pour aborder le « droit à l'oubli » et les obligations RGPD :

- bouton « Supprimer mon compte » sur la page userinfo
- confirmation avant suppression
- discussion en classe : que reste-t-il dans les logs, les backups, etc.
