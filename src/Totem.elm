module Totem exposing (adjectives, animals, totem)

import Array exposing (Array)
import MD5


{-| Deterministic French totem ("Lion Fragile") derived from an MD5 hash.

The same seed always yields the same totem; pairs are drawn from
32 animals × 32 adjectives = 1024 combinations.

-}
totem : String -> String
totem seed =
    case MD5.bytes seed of
        first :: second :: _ ->
            capitalize (pick first animals) ++ " " ++ capitalize (pick second adjectives)

        _ ->
            -- An MD5 digest is always 16 bytes.
            ""


pick : Int -> Array String -> String
pick byte words =
    Array.get (modBy (Array.length words) byte) words
        |> Maybe.withDefault ""


capitalize : String -> String
capitalize word =
    String.toUpper (String.left 1 word) ++ String.dropLeft 1 word


animals : Array String
animals =
    Array.fromList
        [ "abeille"
        , "aigle"
        , "âne"
        , "araignée"
        , "baleine"
        , "biche"
        , "cerf"
        , "cigogne"
        , "corbeau"
        , "dauphin"
        , "écureuil"
        , "éléphant"
        , "faucon"
        , "gazelle"
        , "girafe"
        , "hibou"
        , "hirondelle"
        , "lion"
        , "loutre"
        , "lynx"
        , "mésange"
        , "ours"
        , "panda"
        , "panthère"
        , "pélican"
        , "raton"
        , "renard"
        , "requin"
        , "salamandre"
        , "tigre"
        , "tortue"
        , "zèbre"
        ]


{-| Invariant adjectives (same form in masculine / feminine) so they agree with
any animal in the list without further inflection.
-}
adjectives : Array String
adjectives =
    Array.fromList
        [ "agile"
        , "aimable"
        , "brave"
        , "calme"
        , "célèbre"
        , "drôle"
        , "écarlate"
        , "fidèle"
        , "fragile"
        , "habile"
        , "honnête"
        , "humble"
        , "intrépide"
        , "jeune"
        , "libre"
        , "lyrique"
        , "magnifique"
        , "mince"
        , "noble"
        , "paisible"
        , "propre"
        , "rapide"
        , "robuste"
        , "rouge"
        , "sage"
        , "sauvage"
        , "sincère"
        , "solide"
        , "sombre"
        , "splendide"
        , "tenace"
        , "tranquille"
        ]
