module Page.Account exposing (view)

import Format
import Html exposing (Html, code, dd, div, dl, dt, h2, h4, img, p, text)
import Html.Attributes exposing (alt, attribute, class, height, src, style, width)
import Strategy
import Time
import Totem exposing (totem)
import User exposing (AccountResult, Outcome(..))


{-| Shown after registering or logging in.
-}
view : Time.Zone -> AccountResult -> { title : String, body : Html msg }
view zone { outcome, user } =
    { title = User.outcomeTitle outcome
    , body =
        div [ class "mx-auto", style "max-width" "520px" ]
            [ banner outcome
            , div [ class "card shadow" ]
                [ div [ class "card-body text-center p-3 p-sm-4" ]
                    ([ img
                        [ src (Format.avatarUrl user.username)
                        , alt ("Avatar de " ++ user.username)
                        , class "rounded-circle border bg-light mb-3"
                        , width 180
                        , height 180
                        ]
                        []
                     , h2 [ class "card-title mb-1" ] [ text user.username ]
                     , p [ class "fst-italic mb-1" ] [ text ("« " ++ totem user.username ++ " »") ]
                     , p [ class "text-muted small mb-4" ] [ text ("Compte créé le " ++ Format.dateTime zone user.createdAt) ]

                     -- Labels above full-width values: hashes fit on one line, and stacked encodings line up for comparison
                     , dl [ class "text-start mb-0" ]
                        ([ dt [ class "small text-muted fw-normal" ] [ text "Stratégie" ]
                         , dd [ class "mb-3" ] [ text (Strategy.name user.strategy) ]
                         , dt [ class "small text-muted fw-normal" ] [ text "Mot de passe stocké" ]
                         , dd [ class "mb-3" ] [ encoded user.password ]
                         ]
                            ++ attemptDetails outcome
                        )
                     ]
                        ++ attemptVerdict outcome
                    )
                ]
            ]
    }


banner : Outcome -> Html msg
banner outcome =
    let
        alert style_ heading message =
            div [ class ("alert alert-" ++ style_), attribute "role" "status" ]
                [ h4 [ class "alert-heading mb-1" ] [ text heading ]
                , p [ class "mb-0" ] [ text message ]
                ]
    in
    case outcome of
        Created ->
            alert "success" "Le compte a été créé" "Vous pouvez maintenant vous connecter avec ce nom et ce mot de passe."

        Replaced ->
            alert "warning" "Le compte a été remplacé" "Un compte portant ce nom existait déjà : son mot de passe a été écrasé."

        LoggedIn _ ->
            alert "primary" "Content de vous revoir\u{00A0}!" "Connexion réussie : le mot de passe saisi correspond à celui enregistré."


attemptDetails : Outcome -> List (Html msg)
attemptDetails outcome =
    case outcome of
        LoggedIn { encodedAttempt } ->
            [ dt [ class "small text-muted fw-normal" ] [ text "Saisie encodée" ]
            , dd [ class "mb-0" ] [ encoded encodedAttempt ]
            ]

        _ ->
            []


attemptVerdict : Outcome -> List (Html msg)
attemptVerdict outcome =
    case outcome of
        LoggedIn _ ->
            [ p [ class "text-success small mt-2 mb-0" ] [ text "✓ Identiques : le mot de passe est correct" ] ]

        _ ->
            []


encoded : String -> Html msg
encoded value =
    code [ class "encoded d-block p-2 bg-light border rounded text-break" ] [ text value ]
