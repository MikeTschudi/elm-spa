module Pages.Guide.ElmSpa exposing (Model, Msg, page)

import Spa.Page
import Components.Hero
import Element exposing (..)
import Generated.Guide.Params as Params
import Utils.Spa exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Params.ElmSpa Model Msg model msg appMsg
page =
    Spa.Page.static
        { title = always "Guide.ElmSpa"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    column [ width fill ]
        [ Components.Hero.view
            { title = "intro to elm-spa"
            , subtitle = text "\"you're gonna be great.\""
            , buttons = []
            }
        ]
