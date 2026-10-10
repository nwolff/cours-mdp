module Route exposing (Route(..), fromUrl, href, isWithin, toUrl)

import Html exposing (Attribute)
import Html.Attributes
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s)


type Route
    = Home
    | Register
    | RegisterDone
    | Login
    | LoginDone
    | ListUsers
    | DeleteAll


{-| Hash routing (/#/register): GitHub Pages only serves static files, so the
route has to live in the part of the URL the server never sees.
-}
fromUrl : Url -> Maybe Route
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, query = Nothing, fragment = Nothing }
        |> Parser.parse parser


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Register (s "register")
        , Parser.map RegisterDone (s "register" </> s "done")
        , Parser.map Login (s "login")
        , Parser.map LoginDone (s "login" </> s "done")
        , Parser.map ListUsers (s "listusers")
        , Parser.map DeleteAll (s "_delete")
        ]


href : Route -> Attribute msg
href route =
    Html.Attributes.href (toUrl route)


{-| Relative, so it keeps the page's path (/cours-mdp/ on nwolff.github.io).
-}
toUrl : Route -> String
toUrl route =
    "#" ++ toPath route


{-| True for /register/done within /register: the menu link stays highlighted.
-}
isWithin : Route -> Route -> Bool
isWithin section route =
    route == section || String.startsWith (toPath section ++ "/") (toPath route)


toPath : Route -> String
toPath route =
    case route of
        Home ->
            "/"

        Register ->
            "/register"

        RegisterDone ->
            "/register/done"

        Login ->
            "/login"

        LoginDone ->
            "/login/done"

        ListUsers ->
            "/listusers"

        DeleteAll ->
            "/_delete"
