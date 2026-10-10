module Page.Home exposing (view)

import Html exposing (Html, a, div, h1, h2, p, small, text)
import Html.Attributes exposing (class, href)
import QRCode
import Svg.Attributes


{-| `siteUrl` is the site's address without the #/route part, so the QR code
opens the home page.
-}
view : String -> { title : String, body : Html msg }
view siteUrl =
    { title = "Bienvenue"
    , body =
        div []
            [ h1 [] [ text "Bienvenue." ]
            , link "MD5 decrypt" "https://md5decrypt.net/"
            , link "Have I been pwned" "https://haveibeenpwned.com/"
            , h2 [] [ text "Pour aller plus loin" ]
            , link "MD5" "https://fr.wikipedia.org/wiki/MD5"
            , h2 [] [ text "Accès rapide depuis un mobile" ]
            , div [ class "d-inline-block p-3 bg-white border rounded" ] [ qrCode siteUrl ]
            , p [ class "text-muted mt-2" ] [ small [] [ text siteUrl ] ]
            ]
    }


link : String -> String -> Html msg
link label url =
    p [] [ text (label ++ " : "), a [ href url ] [ text url ] ]


qrCode : String -> Html msg
qrCode url =
    case QRCode.fromStringWith QRCode.Low url of
        Ok code ->
            let
                -- A version N code is 17 + 4N modules wide, drawn here at 6 px each.
                -- The box's white padding acts as the quiet zone.
                size =
                    String.fromInt (6 * (17 + 4 * QRCode.version code))
            in
            QRCode.toSvgWithoutQuietZone [ Svg.Attributes.width size, Svg.Attributes.height size ] code

        Err _ ->
            text ""
