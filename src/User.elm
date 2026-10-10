module User exposing (AccountResult, Outcome(..), User, decoder, outcomeTitle)

import Json.Decode as Decode exposing (Decoder)
import Strategy exposing (Strategy)
import Time


type alias User =
    { username : String
    , password : String
    , strategy : Strategy
    , createdAt : Time.Posix
    }


{-| What src/main.ts sends through the ports (createdAt in milliseconds).
-}
decoder : Decoder User
decoder =
    Decode.map4 User
        (Decode.field "username" Decode.string)
        (Decode.field "password" Decode.string)
        (Decode.field "strategy" strategyDecoder)
        (Decode.field "createdAt" (Decode.map Time.millisToPosix Decode.int))


strategyDecoder : Decoder Strategy
strategyDecoder =
    Decode.string
        |> Decode.andThen
            (\storedName ->
                case Strategy.fromName storedName of
                    Just strategy ->
                        Decode.succeed strategy

                    Nothing ->
                        Decode.fail ("Stratégie inconnue : " ++ storedName)
            )



-- AFTER REGISTERING OR LOGGING IN


type Outcome
    = Created
    | Replaced
    | LoggedIn { encodedAttempt : String }


type alias AccountResult =
    { outcome : Outcome
    , user : User
    }


outcomeTitle : Outcome -> String
outcomeTitle outcome =
    case outcome of
        Created ->
            "Compte créé"

        Replaced ->
            "Compte remplacé"

        LoggedIn _ ->
            "Connecté"
