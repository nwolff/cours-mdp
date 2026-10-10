module Strategy exposing
    ( Strategy(..), all, name, fromName
    , Salt, saltGenerator
    , encode, encodeLike, matches, hashWithSalt
    )

{-| The ways a password can be stored, from worst to least bad.

@docs Strategy, all, name, fromName
@docs Salt, saltGenerator
@docs encode, encodeLike, matches, hashWithSalt

-}

import MD5
import Random


type Strategy
    = Plaintext
    | Rot13
    | Md5
    | SaltedMd5


{-| In the order shown on the registration page.
-}
all : List Strategy
all =
    [ Plaintext, Rot13, Md5, SaltedMd5 ]


{-| What gets stored in Firestore (and checked by firestore.rules).
-}
name : Strategy -> String
name strategy =
    case strategy of
        Plaintext ->
            "plaintext"

        Rot13 ->
            "rot13"

        Md5 ->
            "md5"

        SaltedMd5 ->
            "salted_md5"


fromName : String -> Maybe Strategy
fromName storedName =
    List.filter (\strategy -> name strategy == storedName) all
        |> List.head



-- SALT


{-| 6 hex characters. Only `SaltedMd5` uses it, but Elm functions cannot draw
random numbers themselves: the caller generates the salt and passes it in.
-}
type alias Salt =
    String


saltGenerator : Random.Generator Salt
saltGenerator =
    Random.list 3 (Random.int 0 255)
        |> Random.map (List.map byteToHex >> String.concat)


byteToHex : Int -> String
byteToHex byte =
    hexDigit (byte // 16) ++ hexDigit (modBy 16 byte)


hexDigit : Int -> String
hexDigit n =
    String.slice n (n + 1) "0123456789abcdef"



-- ENCODING


encode : Salt -> Strategy -> String -> String
encode salt strategy password =
    case strategy of
        Plaintext ->
            password

        Rot13 ->
            rot13 password

        Md5 ->
            MD5.hex password

        SaltedMd5 ->
            salt ++ "$" ++ hashWithSalt salt password


{-| Encodes an attempt so it can be compared with the stored password
(reusing its salt, if any: otherwise the result could never be equal).
-}
encodeLike : Strategy -> String -> String -> String
encodeLike strategy password storedPassword =
    encode (saltOf storedPassword) strategy password


matches : Strategy -> String -> String -> Bool
matches strategy password storedPassword =
    encodeLike strategy password storedPassword == storedPassword


hashWithSalt : Salt -> String -> String
hashWithSalt salt password =
    MD5.hex (salt ++ password)


{-| "abc123$5d41…" → "abc123". Strategies without a salt ignore it.
-}
saltOf : String -> Salt
saltOf storedPassword =
    String.split "$" storedPassword
        |> List.head
        |> Maybe.withDefault ""


{-| Only the 26 latin letters rotate; digits, accents and symbols stay as they are.
Rotating by 13 twice goes all the way round the alphabet, so this also decodes.
-}
rot13 : String -> String
rot13 =
    String.map
        (\char ->
            if Char.isUpper char then
                rotate 'A' char

            else if Char.isLower char then
                rotate 'a' char

            else
                char
        )


rotate : Char -> Char -> Char
rotate first char =
    Char.fromCode (Char.toCode first + modBy 26 (Char.toCode char - Char.toCode first + 13))
