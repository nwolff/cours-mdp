module Page.Register exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Dom as Dom
import Format
import Html exposing (Html, a, button, code, div, form, h3, input, label, p, span, text)
import Html.Attributes exposing (attribute, checked, class, disabled, for, id, name, required, style, type_, value)
import Html.Events exposing (onCheck, onSubmit)
import Json.Decode as Decode exposing (Value)
import Ports
import Random
import Route
import Strategy exposing (Salt, Strategy)
import Task
import User exposing (AccountResult, Outcome(..))
import View.Common exposing (credentialFields, credentialsAreValid, errorAlert)


type alias Model =
    { username : String
    , password : String
    , strategy : Maybe Strategy
    , salt : Salt
    , status : Status
    , error : Maybe String
    }


{-| Registering takes two round trips to Firestore: first to learn whether the
name is taken (to say "créé" or "remplacé"), then to write the account.
-}
type Status
    = Editing
    | CheckingName
    | Saving { existed : Bool }


type Msg
    = UsernameChanged String
    | PasswordChanged String
    | StrategyChosen Strategy
    | GotSalt Salt
    | Submitted
    | GotExistingUser Value
    | GotSavedUser Value
    | GotStorageError String
    | Focused


init : ( Model, Cmd Msg )
init =
    ( { username = ""
      , password = ""
      , strategy = Nothing
      , salt = ""
      , status = Editing
      , error = Nothing
      }
    , Cmd.batch
        [ Random.generate GotSalt Strategy.saltGenerator
        , Task.attempt (always Focused) (Dom.focus "username")
        ]
    )


{-| The third value is set once the account is saved.
-}
update : Msg -> Model -> ( Model, Cmd Msg, Maybe AccountResult )
update msg model =
    case msg of
        UsernameChanged username ->
            ( { model | username = username }, Cmd.none, Nothing )

        PasswordChanged password ->
            ( { model | password = password }, Cmd.none, Nothing )

        StrategyChosen strategy ->
            ( { model | strategy = Just strategy }, Cmd.none, Nothing )

        GotSalt salt ->
            ( { model | salt = salt }, Cmd.none, Nothing )

        Submitted ->
            if canSubmit model then
                ( { model | status = CheckingName, error = Nothing }, Ports.fetchUser model.username, Nothing )

            else
                ( model, Cmd.none, Nothing )

        GotExistingUser value ->
            case ( model.status, model.strategy, Decode.decodeValue (Decode.nullable User.decoder) value ) of
                ( CheckingName, Just strategy, Ok existing ) ->
                    ( { model | status = Saving { existed = existing /= Nothing } }
                    , Ports.saveUser
                        { username = model.username
                        , password = Strategy.encode model.salt strategy model.password
                        , strategy = Strategy.name strategy
                        }
                    , Nothing
                    )

                ( CheckingName, _, Err error ) ->
                    failed (Decode.errorToString error) model

                _ ->
                    ( model, Cmd.none, Nothing )

        GotSavedUser value ->
            case model.status of
                Saving { existed } ->
                    case Decode.decodeValue User.decoder value of
                        Ok user ->
                            ( { model | status = Editing }
                            , Cmd.none
                            , Just
                                { outcome =
                                    if existed then
                                        Replaced

                                    else
                                        Created
                                , user = user
                                }
                            )

                        Err error ->
                            failed (Decode.errorToString error) model

                _ ->
                    ( model, Cmd.none, Nothing )

        GotStorageError message ->
            failed message model

        Focused ->
            ( model, Cmd.none, Nothing )


failed : String -> Model -> ( Model, Cmd Msg, Maybe AccountResult )
failed message model =
    ( { model | status = Editing, error = Just (Format.errorMessage message) }, Cmd.none, Nothing )


canSubmit : Model -> Bool
canSubmit model =
    credentialsAreValid { username = model.username, password = model.password }
        && (model.strategy /= Nothing)
        && (model.status == Editing)


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Ports.userFetched GotExistingUser
        , Ports.userSaved GotSavedUser
        , Ports.storageError GotStorageError
        ]



-- VIEW


view : Model -> { title : String, body : Html Msg }
view model =
    { title = "Créer un compte"
    , body =
        div [ class "container d-flex justify-content-center align-items-center" ]
            [ div [ class "card p-4 shadow", style "width" "100%", style "max-width" "500px" ]
                [ div [ class "card-body" ]
                    [ h3 [ class "card-title text-center mb-4" ] [ text "Créer un compte" ]
                    , errorAlert model.error
                    , form [ onSubmit Submitted, attribute "autocomplete" "off" ]
                        [ credentialFields
                            { username = model.username
                            , onUsername = UsernameChanged
                            , password = model.password
                            , onPassword = PasswordChanged
                            }
                        , strategyPicker model.strategy
                        , preview model
                        , div [ class "d-grid" ]
                            [ button [ type_ "submit", class "btn btn-primary", disabled (not (canSubmit model)) ]
                                [ text "Créer" ]
                            ]
                        ]
                    , p [ class "text-center small mt-3 mb-0" ]
                        [ text "Déjà un compte ? "
                        , a [ Route.href Route.Login ] [ text "Se connecter" ]
                        ]
                    ]
                ]
            ]
    }


strategyPicker : Maybe Strategy -> Html Msg
strategyPicker chosen =
    div [ class "mb-3" ]
        [ label [ class "form-label d-block" ] [ text "Stratégie" ]
        , div [ class "d-flex flex-wrap gap-2", attribute "role" "group" ]
            (List.concatMap (strategyButton chosen) Strategy.all)
        , div [ class "form-text" ] [ text "Choisir une stratégie" ]
        ]


strategyButton : Maybe Strategy -> Strategy -> List (Html Msg)
strategyButton chosen strategy =
    let
        buttonId =
            "strategy_" ++ Strategy.name strategy
    in
    [ input
        [ type_ "radio"
        , class "btn-check"
        , name "strategy_name"
        , id buttonId
        , value (Strategy.name strategy)
        , attribute "autocomplete" "off"
        , required True
        , checked (chosen == Just strategy)
        , onCheck (always (StrategyChosen strategy))
        ]
        []
    , label [ class "btn btn-outline-secondary", for buttonId ] [ text (Strategy.name strategy) ]
    ]


{-| Exactly what will be stored: the salt is drawn once when the page opens.
-}
preview : Model -> Html Msg
preview model =
    div [ class "mb-3" ]
        [ label [ class "form-label small text-muted mb-1" ] [ text "Aperçu du mot de passe encodé" ]
        , code [ class "d-block p-2 bg-light border rounded text-break", style "min-height" "2.4em" ]
            [ case ( model.strategy, model.password ) of
                ( Just strategy, password ) ->
                    if String.isEmpty password then
                        previewPlaceholder

                    else
                        text (Strategy.encode model.salt strategy password)

                ( Nothing, _ ) ->
                    previewPlaceholder
            ]
        ]


previewPlaceholder : Html msg
previewPlaceholder =
    span [ class "text-muted fst-italic" ] [ text "(saisir un mot de passe et choisir une stratégie)" ]
