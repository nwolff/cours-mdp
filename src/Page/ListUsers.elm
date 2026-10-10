module Page.ListUsers exposing (Model, Msg, init, leave, subscriptions, update, view)

import Format
import Html exposing (Html, div, h2, table, td, text, th, thead, tr)
import Html.Attributes exposing (class)
import Html.Keyed
import Json.Decode as Decode exposing (Value)
import Ports
import Strategy
import Time
import User exposing (User)
import View.Common exposing (errorAlert)


type alias Model =
    { users : Maybe (List User)
    , error : Maybe String
    }


type Msg
    = GotUsers Value
    | GotStorageError String


{-| Firestore pushes every change, so the table stays up to date without reloading.
-}
init : ( Model, Cmd Msg )
init =
    ( { users = Nothing, error = Nothing }, Ports.subscribeUsers () )


{-| To run when navigating away from the page.
-}
leave : Cmd msg
leave =
    Ports.unsubscribeUsers ()


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotUsers value ->
            case Decode.decodeValue (Decode.list User.decoder) value of
                Ok users ->
                    ( { model | users = Just users }, Cmd.none )

                Err error ->
                    ( { model | error = Just (Format.errorMessage (Decode.errorToString error)) }, Cmd.none )

        GotStorageError message ->
            ( { model | error = Just (Format.errorMessage message) }, Cmd.none )


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Ports.usersChanged GotUsers
        , Ports.storageError GotStorageError
        ]


view : Time.Zone -> Model -> { title : String, body : Html Msg }
view zone model =
    { title = "Comptes"
    , body =
        div []
            [ errorAlert model.error
            , case model.users of
                Just users ->
                    usersTable zone users

                Nothing ->
                    text ""
            ]
    }


usersTable : Time.Zone -> List User -> Html msg
usersTable zone users =
    let
        count =
            List.length users
    in
    div []
        [ h2 [] [ text (String.fromInt count ++ " Compte" ++ Format.pluralize count) ]
        , div [ class "table-responsive" ]
            [ table [ class "table table-striped table-hover" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Nom" ]
                        , th [] [ text "Mot de passe encodé" ]
                        , th [] [ text "Stratégie" ]
                        , th [] [ text "Date et heure de création" ]
                        ]
                    ]
                , Html.Keyed.node "tbody" [] (List.map (\user -> ( user.username, userRow zone user )) users)
                ]
            ]
        ]


userRow : Time.Zone -> User -> Html msg
userRow zone user =
    tr []
        [ td [] [ text user.username ]
        , td [] [ text user.password ]
        , td [] [ text (Strategy.name user.strategy) ]
        , td [] [ text (Format.dateTime zone user.createdAt) ]
        ]
