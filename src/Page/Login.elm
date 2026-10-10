module Page.Login exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Dom as Dom
import Format
import Html exposing (Html, a, button, div, form, h3, p, text)
import Html.Attributes exposing (attribute, class, disabled, style, type_)
import Html.Events exposing (onSubmit)
import Json.Decode as Decode exposing (Value)
import Ports
import Route
import Strategy
import Task
import User exposing (AccountResult, Outcome(..))
import View.Common exposing (credentialFields, credentialsAreValid, errorAlert)


type alias Model =
    { username : String
    , password : String
    , checking : Bool
    , error : Maybe String
    }


type Msg
    = UsernameChanged String
    | PasswordChanged String
    | Submitted
    | GotUser Value
    | GotStorageError String
    | Focused


init : ( Model, Cmd Msg )
init =
    ( { username = "", password = "", checking = False, error = Nothing }
    , Task.attempt (always Focused) (Dom.focus "username")
    )


{-| The third value is set once the password is found correct.
-}
update : Msg -> Model -> ( Model, Cmd Msg, Maybe AccountResult )
update msg model =
    case msg of
        UsernameChanged username ->
            ( { model | username = username }, Cmd.none, Nothing )

        PasswordChanged password ->
            ( { model | password = password }, Cmd.none, Nothing )

        Submitted ->
            if canSubmit model then
                ( { model | checking = True, error = Nothing }, Ports.fetchUser model.username, Nothing )

            else
                ( model, Cmd.none, Nothing )

        GotUser value ->
            if model.checking then
                case Decode.decodeValue (Decode.nullable User.decoder) value of
                    Ok (Just user) ->
                        if Strategy.matches user.strategy model.password user.password then
                            ( { model | checking = False }
                            , Cmd.none
                            , Just
                                { outcome = LoggedIn { encodedAttempt = Strategy.encodeLike user.strategy model.password user.password }
                                , user = user
                                }
                            )

                        else
                            failed "Mot de passe incorrect" model

                    Ok Nothing ->
                        failed "Utilisateur inconnu" model

                    Err error ->
                        failed (Format.errorMessage (Decode.errorToString error)) model

            else
                ( model, Cmd.none, Nothing )

        GotStorageError message ->
            failed (Format.errorMessage message) model

        Focused ->
            ( model, Cmd.none, Nothing )


failed : String -> Model -> ( Model, Cmd Msg, Maybe AccountResult )
failed error model =
    ( { model | checking = False, error = Just error }, Cmd.none, Nothing )


canSubmit : Model -> Bool
canSubmit model =
    credentialsAreValid { username = model.username, password = model.password } && not model.checking


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Ports.userFetched GotUser
        , Ports.storageError GotStorageError
        ]


view : Model -> { title : String, body : Html Msg }
view model =
    { title = "Se connecter"
    , body =
        div [ class "container d-flex justify-content-center align-items-center" ]
            [ div [ class "card p-4 shadow", style "width" "100%", style "max-width" "380px" ]
                [ div [ class "card-body" ]
                    [ h3 [ class "card-title text-center mb-4" ] [ text "Se connecter" ]
                    , errorAlert model.error
                    , form [ onSubmit Submitted, attribute "autocomplete" "off" ]
                        [ credentialFields
                            { username = model.username
                            , onUsername = UsernameChanged
                            , password = model.password
                            , onPassword = PasswordChanged
                            }
                        , div [ class "d-grid" ]
                            [ button [ type_ "submit", class "btn btn-primary", disabled (not (canSubmit model)) ]
                                [ text "Se connecter" ]
                            ]
                        ]
                    , p [ class "text-center small mt-3 mb-0" ]
                        [ text "Pas encore de compte ? "
                        , a [ Route.href Route.Register ] [ text "Créer un compte" ]
                        ]
                    ]
                ]
            ]
    }
