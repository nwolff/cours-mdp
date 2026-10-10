module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, nav, span, text, ul)
import Html.Attributes exposing (attribute, class, classList, id, type_)
import Html.Events exposing (onClick)
import Page.Account
import Page.DeleteAll
import Page.Home
import Page.ListUsers
import Page.Login
import Page.Register
import Route exposing (Route)
import Svg
import Svg.Attributes
import Task
import Time
import TimeZone
import Url exposing (Url)
import User exposing (AccountResult)


type alias Flags =
    { siteUrl : String }


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , siteUrl : String
    , zone : Time.Zone
    , route : Maybe Route
    , page : Page
    , menuOpen : Bool

    -- What /register/done and /login/done show. Nothing if the URL is opened directly.
    , lastResult : Maybe AccountResult
    }


type Page
    = Redirecting
    | Home
    | Register Page.Register.Model
    | Login Page.Login.Model
    | Account AccountResult
    | ListUsers Page.ListUsers.Model
    | DeleteAll Page.DeleteAll.Model


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( model, cmd ) =
            changeRouteTo (Route.fromUrl url)
                { key = key
                , siteUrl = flags.siteUrl
                , zone = Time.utc
                , route = Nothing
                , page = Redirecting
                , menuOpen = False
                , lastResult = Nothing
                }
    in
    ( model, Cmd.batch [ cmd, Task.attempt GotZone TimeZone.getZone ] )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | GotZone (Result TimeZone.Error ( String, Time.Zone ))
    | GotLocalZone Time.Zone
    | MenuToggled
    | RegisterMsg Page.Register.Msg
    | LoginMsg Page.Login.Msg
    | ListUsersMsg Page.ListUsers.Msg
    | DeleteAllMsg Page.DeleteAll.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( LinkClicked (Browser.Internal url), _ ) ->
            ( model, Nav.pushUrl model.key (Url.toString url) )

        ( LinkClicked (Browser.External href), _ ) ->
            ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( GotZone (Ok ( _, zone )), _ ) ->
            ( { model | zone = zone }, Cmd.none )

        ( GotZone (Err _), _ ) ->
            -- Unknown zone name: fall back to today's offset (wrong across a DST change)
            ( model, Task.perform GotLocalZone Time.here )

        ( GotLocalZone zone, _ ) ->
            ( { model | zone = zone }, Cmd.none )

        ( MenuToggled, _ ) ->
            ( { model | menuOpen = not model.menuOpen }, Cmd.none )

        ( RegisterMsg pageMsg, Register page ) ->
            Page.Register.update pageMsg page
                |> withAccountResult Register RegisterMsg Route.RegisterDone model

        ( LoginMsg pageMsg, Login page ) ->
            Page.Login.update pageMsg page
                |> withAccountResult Login LoginMsg Route.LoginDone model

        ( ListUsersMsg pageMsg, ListUsers page ) ->
            Page.ListUsers.update pageMsg page
                |> updateWith ListUsers ListUsersMsg model

        ( DeleteAllMsg pageMsg, DeleteAll page ) ->
            Page.DeleteAll.update pageMsg page
                |> updateWith DeleteAll DeleteAllMsg model

        _ ->
            -- A message for a page that is no longer shown
            ( model, Cmd.none )


updateWith : (pageModel -> Page) -> (pageMsg -> Msg) -> Model -> ( pageModel, Cmd pageMsg ) -> ( Model, Cmd Msg )
updateWith toPage toMsg model ( pageModel, cmd ) =
    ( { model | page = toPage pageModel }, Cmd.map toMsg cmd )


{-| Once Register or Login has a result, keep it and show it on the "done" route.
-}
withAccountResult :
    (pageModel -> Page)
    -> (pageMsg -> Msg)
    -> Route
    -> Model
    -> ( pageModel, Cmd pageMsg, Maybe AccountResult )
    -> ( Model, Cmd Msg )
withAccountResult toPage toMsg doneRoute model ( pageModel, cmd, maybeResult ) =
    case maybeResult of
        Just result ->
            ( { model | page = toPage pageModel, lastResult = Just result }
            , Cmd.batch [ Cmd.map toMsg cmd, Nav.pushUrl model.key (Route.toUrl doneRoute) ]
            )

        Nothing ->
            updateWith toPage toMsg model ( pageModel, cmd )


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        leaving =
            case model.page of
                ListUsers _ ->
                    Page.ListUsers.leave

                _ ->
                    Cmd.none

        ( newModel, cmd ) =
            showPage maybeRoute { model | route = maybeRoute, menuOpen = False }
    in
    ( newModel, Cmd.batch [ leaving, cmd ] )


showPage : Maybe Route -> Model -> ( Model, Cmd Msg )
showPage maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = Redirecting }, Nav.replaceUrl model.key (Route.toUrl Route.Home) )

        Just Route.Home ->
            ( { model | page = Home }, Cmd.none )

        Just Route.Register ->
            updateWith Register RegisterMsg model Page.Register.init

        Just Route.Login ->
            updateWith Login LoginMsg model Page.Login.init

        Just Route.RegisterDone ->
            showAccount model

        Just Route.LoginDone ->
            showAccount model

        Just Route.ListUsers ->
            updateWith ListUsers ListUsersMsg model Page.ListUsers.init

        Just Route.DeleteAll ->
            updateWith DeleteAll DeleteAllMsg model (Page.DeleteAll.init model.key)


showAccount : Model -> ( Model, Cmd Msg )
showAccount model =
    case model.lastResult of
        Just result ->
            ( { model | page = Account result }, Cmd.none )

        Nothing ->
            showPage Nothing model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        Register _ ->
            Sub.map RegisterMsg Page.Register.subscriptions

        Login _ ->
            Sub.map LoginMsg Page.Login.subscriptions

        ListUsers _ ->
            Sub.map ListUsersMsg Page.ListUsers.subscriptions

        DeleteAll _ ->
            Sub.map DeleteAllMsg Page.DeleteAll.subscriptions

        _ ->
            Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        { title, body } =
            viewPage model
    in
    { title = title
    , body =
        [ navbar model
        , div [ id "content", class "container pt-5" ] [ body ]
        ]
    }


viewPage : Model -> { title : String, body : Html Msg }
viewPage model =
    case model.page of
        Redirecting ->
            { title = "", body = text "" }

        Home ->
            Page.Home.view model.siteUrl

        Register page ->
            mapPage RegisterMsg (Page.Register.view page)

        Login page ->
            mapPage LoginMsg (Page.Login.view page)

        Account result ->
            Page.Account.view model.zone result

        ListUsers page ->
            mapPage ListUsersMsg (Page.ListUsers.view model.zone page)

        DeleteAll page ->
            mapPage DeleteAllMsg (Page.DeleteAll.view page)


mapPage : (pageMsg -> Msg) -> { title : String, body : Html pageMsg } -> { title : String, body : Html Msg }
mapPage toMsg { title, body } =
    { title = title, body = Html.map toMsg body }


navbar : Model -> Html Msg
navbar model =
    nav [ class "navbar navbar-expand-sm bg-dark navbar-dark" ]
        [ div [ class "container-fluid" ]
            [ a [ class "navbar-brand d-flex align-items-center", Route.href Route.Home, attribute "aria-label" "Accueil" ]
                [ homeIcon ]
            , button
                [ class "navbar-toggler"
                , type_ "button"
                , attribute "aria-controls" "navContent"
                , attribute "aria-expanded"
                    (if model.menuOpen then
                        "true"

                     else
                        "false"
                    )
                , attribute "aria-label" "Menu"
                , onClick MenuToggled
                ]
                [ span [ class "navbar-toggler-icon" ] [] ]
            , div [ class "collapse navbar-collapse", classList [ ( "show", model.menuOpen ) ], id "navContent" ]
                [ ul [ class "navbar-nav" ]
                    [ navLink model.route Route.Register "Créer un compte"
                    , navLink model.route Route.Login "Se connecter"
                    , navLink model.route Route.ListUsers "Liste des comptes"
                    ]
                ]
            ]
        ]


{-| Stays highlighted on /register/done and /login/done.
-}
navLink : Maybe Route -> Route -> String -> Html msg
navLink current section label =
    a
        [ class "nav-item nav-link mx-2"
        , classList [ ( "active", Maybe.map (Route.isWithin section) current == Just True ) ]
        , Route.href section
        ]
        [ text label ]


homeIcon : Html msg
homeIcon =
    Svg.svg
        [ Svg.Attributes.width "24"
        , Svg.Attributes.height "24"
        , Svg.Attributes.fill "currentColor"
        , Svg.Attributes.viewBox "0 0 16 16"
        , attribute "aria-hidden" "true"
        ]
        [ Svg.path [ Svg.Attributes.d "M8.354 1.146a.5.5 0 0 0-.708 0l-6 6A.5.5 0 0 0 1.5 7.5v7a.5.5 0 0 0 .5.5h4.5a.5.5 0 0 0 .5-.5v-4h2v4a.5.5 0 0 0 .5.5H14a.5.5 0 0 0 .5-.5v-7a.5.5 0 0 0-.146-.354L13 5.793V2.5a.5.5 0 0 0-.5-.5h-1a.5.5 0 0 0-.5.5v1.293L8.354 1.146z" ] [] ]
