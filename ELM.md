# The Elm version

This branch rewrites the app's interface in [Elm](https://elm-lang.org/). The earlier version
used [Solid](https://www.solidjs.com/) + TypeScript and is still on `main`. The two versions
behave the same and share the same Firestore database and rules, so `git diff main` compares
them directly.

## What is Elm, what stays TypeScript

Elm has no Firestore SDK. Firestore therefore stays in TypeScript, and everything else is Elm.

| Part                                       | Language   | Files                                                                                                  |
| ------------------------------------------ | ---------- | ------------------------------------------------------------------------------------------------------ |
| Pages, navigation bar, routing             | Elm        | [src/Main.elm](src/Main.elm), [src/Route.elm](src/Route.elm), `src/Page/`                              |
| Password strategies, totem, formatting     | Elm        | [src/Strategy.elm](src/Strategy.elm), [src/Totem.elm](src/Totem.elm), [src/Format.elm](src/Format.elm) |
| The `User` type and its JSON decoder       | Elm        | [src/User.elm](src/User.elm)                                                                           |
| Port declarations (Elm side of the bridge) | Elm        | [src/Ports.elm](src/Ports.elm)                                                                         |
| Starting Elm, wiring ports to Firestore    | TypeScript | [src/main.ts](src/main.ts), typed by [src/elm.d.ts](src/elm.d.ts)                                      |
| Firestore operations                       | TypeScript | [src/storage.ts](src/storage.ts)                                                                       |
| Connection to the Firebase project         | TypeScript | [src/firebase.ts](src/firebase.ts)                                                                     |
| Tests                                      | Elm        | [tests/StrategyTests.elm](tests/StrategyTests.elm), [tests/TotemTests.elm](tests/TotemTests.elm)       |

### Which files make up the ports layer?

Only [main.ts](src/main.ts) deals with ports. Each of the three TypeScript files has one job:

| File                           | Role                                                                                                                                         | Knows about Elm?                                                              |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| [firebase.ts](src/firebase.ts) | Connects to the project and exports `db`                                                                                                     | No                                                                            |
| [storage.ts](src/storage.ts)   | The Firestore operations: `subscribeToUsers`, `userForName`, `createOrUpdateUser`, `deleteAll`. Converts between stored documents and `User` | No. It's the same file as in the Solid version, apart from `strategy: string` |
| [main.ts](src/main.ts)         | Starts Elm and wires each port to a `storage.ts` function                                                                                    | Yes. This is the ports layer on the JS side                                   |

The rest of the bridge:

- [Ports.elm](src/Ports.elm) is the Elm side. It declares each port's name and type.
- [elm.d.ts](src/elm.d.ts) repeats those port types for TypeScript. Without it, `app.ports`
  would be untyped in `main.ts`.

A request travels like this:

```
Page/Login.elm  ──Ports.fetchUser──▶  main.ts  ──userForName()──▶  storage.ts  ──▶  firebase.ts / Firestore
Page/Login.elm  ◀──Ports.userFetched──  main.ts  ◀──────── User ────────
```

That split is why `storage.ts` came over from the Solid version almost untouched. Only
`main.ts` would change if the interface framework were swapped again.

## The ports

A port is a named, typed channel between Elm and JavaScript. Elm sends on outgoing ports (they
return a `Cmd`) and listens on incoming ones (they return a `Sub`). Every request is answered on
its matching incoming port, or on `storageError` if Firestore fails.

| Elm sends             | JavaScript does                          | Elm receives                                |
| --------------------- | ---------------------------------------- | ------------------------------------------- |
| `subscribeUsers ()`   | starts `onSnapshot` on the collection    | `usersChanged` now, then after every change |
| `unsubscribeUsers ()` | stops that listener                      | nothing                                     |
| `fetchUser name`      | `userForName`                            | `userFetched`: the user, or `null`          |
| `saveUser {…}`        | `createOrUpdateUser`, then reads it back | `userSaved`: the account as stored          |
| `deleteAllUsers ()`   | `deleteAll`                              | `allUsersDeleted`                           |

Values crossing a port must be JSON. Users therefore travel with `createdAt` in milliseconds
(`toElm` in `main.ts`), and Elm turns it back into a `Time.Posix`.

Elm checks everything it receives. Pages decode incoming users with `User.decoder`. A malformed
value, such as an unknown strategy name, shows an error message instead of crashing the app.

## How the pieces fit together

### Pages

Every page in `src/Page/` follows the same shape: a `Model`, a `Msg` type, `init`, `update`,
`view`, and `subscriptions` if it talks to Firestore. [Main.elm](src/Main.elm) holds the current
page in a `Page` type with one variant per page. It forwards each message to the page it belongs
to and drops messages for a page that is no longer shown.

`Home` and `Account` have no state: they are only `view` functions.

### The "done" pages

After registering or logging in, the Solid version passed the result to `/register/done` through
the router's history state. Elm has no history state. Instead, `Register.update` and
`Login.update` return a third value, `Maybe AccountResult`. When it is set, `Main` stores it in
`lastResult` and navigates to the "done" route, which shows it. Opening `/#/register/done` directly
finds no result and redirects to the home page.

### Registering takes two steps

Registering needs two round trips to Firestore. The first checks whether the name is taken, so
the page can say "créé" or "remplacé". The second writes the account. Elm makes the states
explicit (`Status` in [Page/Register.elm](src/Page/Register.elm)):

```elm
type Status
    = Editing
    | CheckingName
    | Saving { existed : Bool }
```

Each answer is used only in the state that expects it. A late answer arriving in another state is
ignored. The "Créer" button is disabled except in `Editing`.

### Salt and randomness

Elm functions are pure: the same arguments always give the same result. So
`Strategy.encode` cannot draw a random salt itself. Instead, the registration page asks the runtime
for one when it opens (`Random.generate GotSalt Strategy.saltGenerator`) and passes it to
`encode`.

As a result, the preview shows exactly what gets stored. The Solid version was changed to work
the same way: `Register.tsx` draws the salt once with `newSalt()` and passes it to `encode`.
Before that, its salt changed on every keystroke, and saving drew yet another one.

### Dates and time zones

Dates are shown in the viewer's time zone. `Time.here` only gives the current UTC offset, which
would show dates an hour off across a daylight-saving change. The app therefore asks the browser
for its zone name and uses the zone rules from
[justinmimbs/timezone-data](https://package.elm-lang.org/packages/justinmimbs/timezone-data/latest/).
If the zone name is unknown, it falls back to `Time.here`.

### Routing

Routes live after the `#` (`/#/register`), because GitHub Pages only serves static files and
never sees that part of the URL. [Route.elm](src/Route.elm) parses the fragment as if it were a
path. `Route.toUrl` builds relative links (`#/register`), so the same build works under
`nwolff.github.io/cours-mdp/` and on `mdp.nwolff.info`.

## How live update works

Elm can't hold a Firestore listener itself. It can only send messages out through a port (a
`Cmd`) and listen for messages coming in (a `Sub`). Live update uses both, in five steps.

**1. Opening the page starts the Firestore listener.** `init` in
[Page/ListUsers.elm](src/Page/ListUsers.elm) returns a command that sends on the
`subscribeUsers` port:

```elm
init = ( { users = Nothing, error = Nothing }, Ports.subscribeUsers () )
```

On the JS side, `main.ts` receives it and calls `subscribeToUsers` from `storage.ts`, which is
Firestore's `onSnapshot`.

**2. Firestore pushes, and JS forwards into Elm.** `onSnapshot` calls back once right away, then
again on every change in the collection, from any browser. Each time, `main.ts` sends the whole
list into the `usersChanged` port.

**3. Elm listens only while the page is shown.** In Elm, `subscriptions` is a function of the
model, and the runtime re-evaluates it after every update. `subscriptions` in
[Main.elm](src/Main.elm) returns the list page's subscriptions only while that page is displayed:

```elm
ListUsers _ ->
    Sub.map ListUsersMsg Page.ListUsers.subscriptions   -- Ports.usersChanged GotUsers
```

On any other page, a `usersChanged` message would have nobody listening.

**4. Each push becomes an ordinary message.** `GotUsers value` decodes the JSON into `List User`.
It doesn't trust what JS sent: if decoding fails, the page shows an error instead of crashing.
The new list goes into the model, and Elm redraws the table. `Html.Keyed` keys the rows by
username, so when a new account appears at the top, the existing rows are reused instead of all
being rebuilt.

**5. Leaving the page stops the listener.** Elm stopping listening isn't enough, because the
Firestore listener would keep running in JS. So on every route change, `changeRouteTo` in
`Main.elm` checks whether the page being left is the list. If so, it sends `unsubscribeUsers`
(`Page.ListUsers.leave`), and `main.ts` calls the unsubscribe function `onSnapshot` returned.

The Solid version did the same thing in one component: `subscribeToUsers(...)` with
`onCleanup(unsubscribe)`. Elm splits it into an explicit start (`init`), an explicit stop
(`leave`), and the listening in between (`subscriptions`). It's more code, but each step can be
read on its own. The data also enters at exactly one point, `GotUsers`, and is checked there.

## Tooling

The Elm compiler, `elm-test` and `elm-format` are npm dev dependencies, so `npm install` is
enough and CI uses the same versions as the developer.

    npm run dev        # http://localhost:5173 (the API key only accepts this port locally)
    npm test           # elm-test
    npm run check      # type-check the TypeScript (main.ts, storage.ts, firebase.ts)
    npm run lint       # prettier and elm-format --validate
    npm run format     # prettier and elm-format
    npm run build      # vite-plugin-elm compiles Elm with --optimize

- **Elm version.** Pinned to 0.19.2 in [elm.json](elm.json) and package.json (`elm` 0.19.2-0,
  `elm-test` 0.19.2-1), the same version as Homebrew's `elm`, so the global and the project's
  compilers agree. Moving to a newer Elm means updating all three together: `elm-test` 0.19.3
  refuses to run with an Elm other than 0.19.3.
- **Packages.** `elm/*` (core, browser, html, json, url, time, random, svg),
  `truqu/elm-md5` (MD5 for the strategies, totem and avatar),
  `pablohirafuji/elm-qrcode` (the home page QR code) and `justinmimbs/timezone-data`.
- **Tests.** The Elm tests are ports of the earlier TypeScript tests. They include known values:
  fixed inputs with their expected outputs (md5, rot13, salted md5, and totems such as
  "Élodie"), so a change in any of the algorithms shows up.
- **Tests that drive a browser.** Elm redraws on the next animation frame, not immediately after
  an input. A test script typing into the page must wait for the page to update, for example by
  waiting for `document.title`. Otherwise it can type into the previous page's `#username` field
  just before it is replaced.

## Compared with the Solid version

- **Lines of code.** About 1,840 lines of Elm against 940 of Solid TypeScript. Much of the
  difference is `elm-format`'s style: each list item and each `case` branch gets its own line. The
  rest is the explicit message and state types, such as the registration `Status`.
- **Bundle size.** The app's JavaScript is 50 kB gzipped, on top of Firebase's 145 kB. Most of
  the app's share is the time zone data.
- **Errors.** No runtime exceptions from the Elm side. Everything that can fail (Firestore
  answers, decoding, navigation) is a value the code has to handle.
- **The salt.** Elm's purity forced the caller to draw the salt, which turned out to be the
  better design, so the Solid version now does the same. See
  [Salt and randomness](#salt-and-randomness).

## Known weak points

- **[elm.d.ts](src/elm.d.ts) is written by hand.** Nothing stops it drifting from
  [Ports.elm](src/Ports.elm). If a port is renamed or its type changes in Elm, TypeScript won't
  notice. The app would then fail at runtime, either because `app.ports.x` is undefined or
  because Elm rejects the value it receives. [elm-ts-interop](https://elm-ts-interop.com/)
  generates these types from the Elm code, but it adds a tool and a different way of writing
  ports. For ten ports that rarely change, the hand-written file is probably fine.
- **Port answers are matched by type, not by request.** Only one request is in flight at a time:
  the buttons are disabled while waiting, and only the visible page listens. This is simpler than
  tagging requests with ids, but would need revisiting if a page ever sent two requests of the
  same kind at once.
