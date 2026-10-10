port module Ports exposing
    ( subscribeUsers, unsubscribeUsers, fetchUser, saveUser, deleteAllUsers
    , usersChanged, userFetched, userSaved, allUsersDeleted, storageError
    )

{-| Elm has no Firestore SDK: these ports reach src/storage.ts through
src/main.ts. Each request is answered on the matching incoming port, or on
`storageError`.

@docs subscribeUsers, unsubscribeUsers, fetchUser, saveUser, deleteAllUsers
@docs usersChanged, userFetched, userSaved, allUsersDeleted, storageError

-}

import Json.Decode exposing (Value)



-- ELM → FIRESTORE


{-| `usersChanged` then fires now and on every change, until `unsubscribeUsers`.
-}
port subscribeUsers : () -> Cmd msg


port unsubscribeUsers : () -> Cmd msg


{-| Answered by `userFetched`.
-}
port fetchUser : String -> Cmd msg


{-| Creates or overwrites the account. Answered by `userSaved`.
-}
port saveUser : { username : String, password : String, strategy : String } -> Cmd msg


{-| Answered by `allUsersDeleted`.
-}
port deleteAllUsers : () -> Cmd msg



-- FIRESTORE → ELM (users are decoded with User.decoder)


{-| Every user, most recently created first.
-}
port usersChanged : (Value -> msg) -> Sub msg


{-| The user, or null if there is no account with that name.
-}
port userFetched : (Value -> msg) -> Sub msg


{-| The account as stored, including the creation time Firestore assigned.
-}
port userSaved : (Value -> msg) -> Sub msg


port allUsersDeleted : (() -> msg) -> Sub msg


port storageError : (String -> msg) -> Sub msg
