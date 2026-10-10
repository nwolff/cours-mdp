module View.Common exposing (credentialFields, credentialsAreValid, errorAlert)

import Html exposing (Html, div, input, label, text)
import Html.Attributes exposing (attribute, class, for, id, minlength, placeholder, required, spellcheck, type_, value)
import Html.Events exposing (onInput)


{-| Both for the username and password (also in firestore.rules).
-}
minChars : Int
minChars =
    3


credentialsAreValid : { username : String, password : String } -> Bool
credentialsAreValid { username, password } =
    min (String.length username) (String.length password) >= minChars


{-| The name and password inputs shared by the registration and login forms.
The pages focus `#username` when they open.
-}
credentialFields :
    { username : String
    , onUsername : String -> msg
    , password : String
    , onPassword : String -> msg
    }
    -> Html msg
credentialFields fields =
    div []
        [ floatingField "username"
            "Nom"
            [ type_ "text"
            , attribute "autocapitalize" "off"
            , attribute "autocorrect" "off"
            , spellcheck False
            , value fields.username
            , onInput fields.onUsername
            ]
        , floatingField "password"
            "Mot de passe"
            [ type_ "password"
            , value fields.password
            , onInput fields.onPassword
            ]
        ]


floatingField : String -> String -> List (Html.Attribute msg) -> Html msg
floatingField fieldId caption attributes =
    div [ class "mb-3" ]
        [ div [ class "form-floating" ]
            [ input
                ([ id fieldId
                 , placeholder caption
                 , class "form-control"
                 , required True
                 , minlength minChars
                 ]
                    ++ attributes
                )
                []
            , label [ for fieldId ] [ text caption ]
            ]
        , div [ class "form-text" ] [ text ("Minimum " ++ String.fromInt minChars ++ " caractères") ]
        ]


errorAlert : Maybe String -> Html msg
errorAlert maybeMessage =
    case maybeMessage of
        Just message ->
            div [ class "alert alert-danger", attribute "role" "alert" ] [ text message ]

        Nothing ->
            text ""
