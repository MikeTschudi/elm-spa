module Pages.NotFound exposing (Model, Msg, page)

import Spa.Page
import Components.Hero
import Element exposing (..)
import Generated.Params as Params
import Utils.Spa exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Params.NotFound Model Msg model msg appMsg
page =
    Spa.Page.static
        { title = always "NotFound"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    column [ width fill ]
        [ Components.Hero.view
            { title = "page not found"
            , subtitle = text "but i'm not even mad about it."
            , buttons =
                [ { label = text "back home", action = Components.Hero.Link "/" }
                ]
            }
        ]
