module Odin exposing (..)

import Style exposing (stylesheet)
import Browser as Bsr
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (id, class, classList, rel, href, src, hidden, style, srcdoc)
import Html.Events as Ev
import Url

-- MAIN

main =
    Bsr.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = PageLoad
        , onUrlRequest = PageRequest
        }


-- MODEL

type alias Category =
    { name  : String
    , pages : List String
    }

type alias Navigation =
    { title             : String
    , context           : String
    , key               : Nav.Key
    , buttonClicked     : Bool
    , linksVisible      : Bool
    , currentCategory   : String
    , currentPage       : Url.Url
    , categories        : List Category
    }

type alias Model =
    { nav   : Navigation
    , input : String
    }

type alias Document msg =
    { title     : String
    , body      : List (Html msg)
    }

init () url key =
    (Model
        (Navigation
            "Odin"
            "/odin"
            key
            False
            False
            ""
            url
            [ Category "admin"      ["users", "groups", "agents", "apps" ]
            , Category "search"     ["history", "advanced"]
            , Category "tasks"      ["src", "pkg"]
            , Category "logs"       ["deploy", "apps"]
            , Category "help"       ["faq", "manuals"]
            , Category "account"    ["access","profile"]
            ]
        )
        ""
    , Cmd.none
    )

type Msg
    = Input String
    | Menu
    | Dropdown String
    | PageLoad Url.Url
    | PageRequest Bsr.UrlRequest

-- SUBSCRIPTIONS

subscriptions _ =
    Sub.none

-- UPDATE

setCurrentPage target nav =
    {nav | currentPage = target}

changeCurrentCategory category nav =
    if category /= nav.currentCategory then
        {nav | currentCategory = category, buttonClicked = True, linksVisible = True}
    else
        {nav | currentCategory = "", linksVisible = False}

toggleMenu nav =
    if nav.buttonClicked then {nav | buttonClicked = False, currentCategory = ""} else {nav | buttonClicked = True}

newNavigation model nav =
    {model | nav = nav}

update msg model =
    case msg of
        Input str ->
            ({ model | input = str }, Cmd.none)
        Menu ->
            (
                (model.nav
                    |> toggleMenu
                    |> newNavigation model
                )
                , Cmd.none
            )
        Dropdown category ->
            (
                (model.nav
                    |> changeCurrentCategory category
                    |> newNavigation model
                )
                , Cmd.none
            )
        PageLoad target ->
            (
                (model.nav
                    |> setCurrentPage target
                    |> newNavigation model
                )
                , Cmd.none
            )
        PageRequest request ->
            case request of
                Bsr.Internal target ->
                    (model, Nav.pushUrl model.nav.key (Url.toString target))
                Bsr.External target ->
                    (model, Nav.load target)

-- VIEW

menuPages category model =
    let
        isVisible =
            ((model.nav.linksVisible) && (category.name == model.nav.currentCategory))
        route =
            model.nav.context ++ "/" ++ model.nav.currentCategory ++ "/"
    in
    List.map
        (\pg ->
            li
                [ class "pure-menu-item"
                , hidden (not isVisible)
                , classList
                    [
                        ( "pure-menu-selected"
                        , (model.nav.currentPage.path == (route ++ pg))
                        )
                    ]
                ]
                [ a [ class "pure-menu-link", href (route ++ pg) ]
                    [ text pg ]
                ]
        ) category.pages

menuCategories model =
    List.map
        (\cat ->
            li [ class "pure-menu-heading", Ev.onClick (Dropdown cat.name) ]
                [ text cat.name ] :: (menuPages cat model)

        ) model.nav.categories

menuButton model =
    div [ id "toggle-menu", Ev.onClick Menu ]
        [ div [ class "shape-backslash" ] []
        , div [ class "shape-slash" ] []
        ]

menu model =
    let
        logo =
            li [ class "pure-menu-heading" ]
                [ a [ href model.nav.context ]
                    [ img [ class "pure-img-responsive", src "assets/logo_white.png" ] [] ]
                ]
        entries =
            List.concat (menuCategories model)
    in
    ul [ class "pure-menu-list" ] (logo :: hr [] [] :: entries)

view model =
    { title =
        model.nav.context ++ String.dropLeft (String.length model.nav.context) model.nav.currentPage.path
    , body =
        [ stylesheet
        , aside
            [ id "sidebar", classList
                [ ("menu-hidden", (not model.nav.buttonClicked))
                , ("menu-visible", model.nav.buttonClicked)
                ]
            ]
            [ div [ class "pure-menu" ]
                [ (menu model)
                , (menuButton model)
                ]
            ]
        , section [ id "content" ]
            [ iframe [ srcdoc "<input type='file'>", style "overflow" "hidden", style "border" "none", style "width" "70%" ]
                [ text "Your browser does not support iframes" ]
            ]
        ]
    }
