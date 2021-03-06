module Layouts.Settings exposing (view)

import Global
import Html exposing (..)
import Html.Attributes exposing (href, style)


view : { page : Html msg, global : Global.Model } -> Html msg
view { page } =
    div
        [ style "display" "flex", style "margin-top" "-1.25rem" ]
        [ viewSidebar
        , div
            [ style "flex" "1 1 auto", style "padding-top" "0.45rem" ]
            [ page ]
        ]


viewSidebar : Html msg
viewSidebar =
    div
        [ style "padding-right" "2rem"
        , style "margin-right" "2rem"
        ]
        [ h1 [] [ text "Settings" ]
        , p [] <|
            List.map (viewLink >> List.singleton >> p [])
                [ ( "Account", "account" )
                , ( "Notifications", "notifications" )
                , ( "User", "user" )
                ]
        ]


viewLink : ( String, String ) -> Html msg
viewLink ( label, slug ) =
    a
        [ style "margin-right" "1rem"
        , href ("/settings/" ++ slug)
        ]
        [ text label
        ]
