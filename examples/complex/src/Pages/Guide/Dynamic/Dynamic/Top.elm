module Pages.Guide.Dynamic.Dynamic.Top exposing (Model, Msg, page)

import Spa.Page
import Components.Hero
import Element exposing (..)
import Generated.Guide.Dynamic.Dynamic.Params as Params
import Utils.Spa exposing (Page)


type alias Model =
    { folder : String
    , me : String
    }


type alias Msg =
    Never


page : Page Params.Top Model Msg model msg appMsg
page =
    Spa.Page.sandbox
        { title = always "Guide.Dynamic.Top"
        , init = always init
        , update = always update
        , view = always view
        }


init : Params.Top -> Model
init { param1, param2 } =
    { folder = param1
    , me = param2
    }


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
            { title = model.me ++ " in " ++ model.folder
            , subtitle = text "oh boi"
            , buttons = []
            }
        ]
