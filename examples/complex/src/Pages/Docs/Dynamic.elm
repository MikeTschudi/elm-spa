module Pages.Docs.Dynamic exposing (Model, Msg, page)

import Spa.Page
import Components.Hero
import Dict exposing (Dict)
import Element exposing (..)
import Element.Font as Font
import Generated.Docs.Params as Params
import Global
import Utils.Spa as Spa exposing (Page)


type alias Model =
    { slug : String
    }


type alias Msg =
    Never


page : Page Params.Dynamic Model Msg model msg appMsg
page =
    Spa.Page.sandbox
        { title = always "Dynamic"
        , init = always init
        , update = always update
        , view = always view
        }



-- INIT


init : Params.Dynamic -> Model
init { param1 } =
    { slug = param1
    }



-- UPDATE


update : Msg -> Model -> Model
update msg model =
    model



-- VIEW


view : Model -> Element Msg
view model =
    column
        [ width fill
        ]
        [ Components.Hero.view
            { title = "docs: " ++ model.slug
            , subtitle = text "\"it's not done until the docs are great.\""
            , buttons =
                [ { label = text "back to docs", action = Components.Hero.Link "/docs" }
                ]
            }
        ]
