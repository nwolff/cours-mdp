module Page.DeleteAll exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation as Nav
import Format
import Html exposing (Html, p, text)
import Html.Attributes exposing (class)
import Ports
import Route
import View.Common exposing (errorAlert)


{-| Unlisted page that wipes every account, for resetting between classes.
-}
type alias Model =
    { key : Nav.Key
    , error : Maybe String
    }


type Msg
    = Deleted ()
    | GotStorageError String


init : Nav.Key -> ( Model, Cmd Msg )
init key =
    ( { key = key, error = Nothing }, Ports.deleteAllUsers () )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Deleted () ->
            ( model, Nav.replaceUrl model.key (Route.toUrl Route.ListUsers) )

        GotStorageError message ->
            ( { model | error = Just (Format.errorMessage message) }, Cmd.none )


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Ports.allUsersDeleted Deleted
        , Ports.storageError GotStorageError
        ]


view : Model -> { title : String, body : Html Msg }
view model =
    { title = "Suppression"
    , body =
        case model.error of
            Just _ ->
                errorAlert model.error

            Nothing ->
                p [ class "text-muted" ] [ text "Suppression des comptes…" ]
    }
