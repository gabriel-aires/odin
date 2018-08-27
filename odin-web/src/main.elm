module Odin exposing (..)

import Browser as Bsr
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (id, class, classList, rel, href, src, hidden)
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
    { navigation    : Navigation
    , input         : String
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

setCurrentPage target navigation =
    {navigation | currentPage = target}

changeCurrentCategory category navigation =
    if category /= navigation.currentCategory then
        {navigation | currentCategory = category, buttonClicked = True, linksVisible = True}
    else
        {navigation | currentCategory = "", linksVisible = False}

toggleMenu navigation =
    if navigation.buttonClicked then {navigation | buttonClicked = False, currentCategory = ""} else {navigation | buttonClicked = True}

newNavigation model navigation =
    {model | navigation = navigation}

update msg model =
    case msg of
        Input str ->
            ({ model | input = str }, Cmd.none)
        Menu ->
            (
                (model.navigation
                    |> toggleMenu
                    |> newNavigation model
                )
                , Cmd.none
            )
        Dropdown category ->
            (
                (model.navigation
                    |> changeCurrentCategory category
                    |> newNavigation model
                )
                , Cmd.none
            )
        PageLoad target ->
            (
                (model.navigation
                    |> setCurrentPage target
                    |> newNavigation model
                )
                , Cmd.none
            )
        PageRequest request ->
            case request of
                Bsr.Internal target ->
                    (model, Nav.pushUrl model.navigation.key (Url.toString target))
                Bsr.External target ->
                    (model, Nav.load target)          

-- VIEW

menuPages category model =
    let
        isVisible =
            ((model.navigation.linksVisible) && (category.name == model.navigation.currentCategory))
        route =
            model.navigation.context ++ "/" ++ model.navigation.currentCategory ++ "/"
    in
    List.map
        (\pg ->
            li
                [ class "pure-menu-item"
                , hidden (not isVisible)
                , classList
                    [
                        ( "pure-menu-selected"
                        , (model.navigation.currentPage.path == (route ++ pg))
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

        ) model.navigation.categories

menuButton model =
    div [ id "toggle-menu", Ev.onClick Menu ]
        [ div [ class "shape-backslash" ] []
        , div [ class "shape-slash" ] []
        ]

menu model =
    let
        logo =
            li [ class "pure-menu-heading" ]
                [ a [ href model.navigation.context ]
                    [ img [ class "pure-img-responsive", src "assets/img/logo-white.png" ][] ]
                ]
        entries =
            List.concat (menuCategories model)
    in
    ul [ class "pure-menu-list" ] (logo :: hr [] [] :: entries)

view model =
    { title =
        model.navigation.context ++ String.dropLeft (String.length model.navigation.context) model.navigation.currentPage.path
    , body = 
        [ node "link" [ rel "stylesheet", href "assets/css/pure-css-1.0/pure-min.css" ] []
        , node "link" [ rel "stylesheet", href "assets/css/pure-css-1.0/pure-responsive-grid.css" ] []
        , node "link" [ rel "stylesheet", href "assets/css/main.css" ] []        
        , aside 
            [ id "sidebar", classList 
                [ ("menu-hidden", (not model.navigation.buttonClicked))
                , ("menu-visible", model.navigation.buttonClicked)
                ]
            ]
            [ div [ class "pure-menu" ]
                [ (menu model)
                , (menuButton model)
                ]
            ]
        , section [ id "content" ] [ text "teste" ]
        ]
    }