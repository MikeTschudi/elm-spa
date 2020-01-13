module Spa.Page exposing
    ( static
    , sandbox
    , element
    , component, send
    , layout
    , recipe
    , keep
    )

{-|


## Pick the simplest page for the job!

1.  [`static`](#static) - a page without state

2.  [`sandbox`](#sandbox) - a page without side-effects

3.  [`element`](#element) - a page _with_ side-effects

4.  [`component`](#component) - a page that can change the global state


### **heads up:** `always` incoming!

You may notice the examples below use the function `always`.

    Page.static
        { title = always "Hello"
        , view = always view
        }

This is to **opt-out** each function from accessing data like [`PageContext`](./Spa-Types#PageContext)

If you decide you need access to the `Route`, query parameters, or `Global.Model`:
Remove the `always` from `title`, `init`, `update`, `view`, or
`subscriptions` functions.


# static

@docs static


# sandbox

@docs sandbox


# element

@docs element


# component

@docs component, send


# manually composing pages?

The rest of this module contains types and functions that
are automatically generated with the [CLI companion tool](https://github.com/ryannhg/elm-spa/tree/master/cli)!

If you'd rather type this stuff manually, these docs are for you!


## layout

@docs layout


## recipe

@docs recipe


## wait... what's a "bundle"?

We can "bundle" the `title`,`view`, and `subscriptions` functions together,
because they only need access to the current `model`.

So _instead_ of typing out all this:

    title bigModel =
        case bigModel of
            FooModel model ->
                foo.title model

            BarModel model ->
                bar.title model

            BazModel model ->
                baz.title model

    view bigModel =
        case bigModel of
            FooModel model ->
                foo.view model

            BarModel model ->
                bar.view model

            BazModel model ->
                baz.view model

    subscriptions bigModel =
        case bigModel of
            FooModel model ->
                foo.subscriptions model

            BarModel model ->
                bar.subscriptions model

            BazModel model ->
                baz.subscriptions model

You only create **one** case expression: (woohoo, less typing!)

    bundle bigModel =
        case bigModel of
            FooModel model ->
                foo.bundle model

            BarModel model ->
                bar.bundle model

            BazModel model ->
                baz.bundle model


## update helpers

@docs keep

-}

import Internals.Page exposing (..)
import Internals.Path as Path exposing (Path)
import Internals.Transition as Transition exposing (Transition)
import Internals.Utils as Utils


type alias PageContext route globalModel =
    Internals.Page.PageContext route globalModel


type alias Page route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    Internals.Page.Page route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg


{-| Implementing the `init`, `update` and `bundle` functions is much easier
when you turn a `Page` type into a `Recipe`.

A `Recipe` is just an Elm record waiting for its page specific data.

  - `init`: just needs a `route`

  - `upgrade` : just needs a `msg` and `model`

  - `bundle` (`view`/`subscriptions`) : just needs a `model`

        import Utils.Spa as Spa

        recipes : Recipes msg
        recipes =
            { top =
                Spa.recipe
                    { page = Top.page
                    , toModel = TopModel
                    , toMsg = TopMsg
                    }
            , counter =
                Spa.recipe
                    { page = Counter.page
                    , toModel = CounterModel
                    , toMsg = CounterMsg
                    }

            -- ...
            }

-}
recipe :
    ((pageMsg -> layoutMsg) -> ui_pageMsg -> ui_layoutMsg)
    -> Upgrade route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
    -> Recipe route pageParams pageModel pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
recipe =
    Internals.Page.upgrade


{-| If the `update` function receives a `msg` that doesn't
match up its `model`, we use `keep` to leave the page as-is.

    update : Msg -> Model -> Spa.Update Model Msg
    update bigMsg bigModel =
        case ( bigMsg, bigModel ) of
            ( TopMsg msg, TopModel model ) ->
                top.update msg model

            ( CounterMsg msg, CounterModel model ) ->
                counter.update msg model

            ( NotFoundMsg msg, NotFoundModel model ) ->
                notFound.update msg model

            _ ->
                Page.keep bigModel

-}
keep :
    layoutModel
    -> Update route layoutModel layoutMsg globalModel globalMsg
keep model =
    always ( model, Cmd.none, Cmd.none )


{-|


## an example

    page =
        Page.static
            { title = always title
            , view = always view
            }

    title : String
    title =
        "Example"

    view : Html Never
    view =
        h1 [ class "title" ] [ text "Example" ]

-}
static :
    { title : { global : globalModel } -> String
    , view : PageContext route globalModel -> ui_pageMsg
    }
    -> Page route pageParams () Never ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
static page =
    Page
        (\{ toModel, toMsg, map } ->
            { init = \_ _ -> ( toModel (), Cmd.none, Cmd.none )
            , update = \_ model _ -> ( toModel model, Cmd.none, Cmd.none )
            , bundle =
                \_ private context ->
                    { title =
                        page.title
                            { global = context.global
                            }
                    , view =
                        page.view
                            context
                            |> map toMsg
                            |> private.map private.fromPageMsg
                    , subscriptions = Sub.none
                    }
            }
        )



-- SANDBOX


{-|


## an example

    page =
        Page.sandbox
            { title = always title
            , init = always init
            , update = always update
            , view = always view
            }

    title : String
    title =
        "Counter"

    type alias Model =
        Int

    init : Model
    init =
        0

    type Msg
        = Increment
        | Decrement

    update : Msg -> Model -> Model
    update msg model =
        case msg of
            Increment ->
                model + 1

            Decrement ->
                model - 1

    view : Model -> Html Msg
    view model =
        div []
            [ button [ Events.onClick Increment ] [ text "+" ]
            , text (String.fromInt model)
            , button [ Events.onClick Decrement ] [ text "-" ]
            ]

-}
sandbox :
    { title : { global : globalModel, model : pageModel } -> String
    , init : PageContext route globalModel -> pageParams -> pageModel
    , update : PageContext route globalModel -> pageMsg -> pageModel -> pageModel
    , view : PageContext route globalModel -> pageModel -> ui_pageMsg
    }
    -> Page route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
sandbox page =
    Page
        (\{ toModel, toMsg, map } ->
            { init =
                \pageParams context ->
                    ( toModel (page.init context pageParams)
                    , Cmd.none
                    , Cmd.none
                    )
            , update =
                \msg model context ->
                    ( page.update context msg model
                        |> toModel
                    , Cmd.none
                    , Cmd.none
                    )
            , bundle =
                \model private context ->
                    { title =
                        page.title
                            { global = context.global
                            , model = model
                            }
                    , view =
                        page.view context model
                            |> map toMsg
                            |> private.map private.fromPageMsg
                    , subscriptions = Sub.none
                    }
            }
        )



-- ELEMENT


{-|


## an example

    page =
        Page.element
            { title = always title
            , init = always init
            , update = always update
            , subscriptions = always subscriptions
            , view = always view
            }

    title : String
    title =
        "Cat Gifs"

    init : ( Model, Cmd.none )
    init =
        -- ...

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        -- ...

    subscriptions : Model -> Sub Msg
    subscriptions model =
        -- ...

    view : Model -> Html Msg
    view model =
        -- ...

-}
element :
    { title : { global : globalModel, model : pageModel } -> String
    , init : PageContext route globalModel -> pageParams -> ( pageModel, Cmd pageMsg )
    , update : PageContext route globalModel -> pageMsg -> pageModel -> ( pageModel, Cmd pageMsg )
    , view : PageContext route globalModel -> pageModel -> ui_pageMsg
    , subscriptions : PageContext route globalModel -> pageModel -> Sub pageMsg
    }
    -> Page route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
element page =
    Page
        (\{ toModel, toMsg, map } ->
            { init =
                \pageParams context ->
                    page.init context pageParams
                        |> tuple toModel toMsg
            , update =
                \msg model context ->
                    page.update context msg model
                        |> tuple toModel toMsg
            , bundle =
                \model private context ->
                    { title =
                        page.title
                            { global = context.global
                            , model = model
                            }
                    , view =
                        page.view context model
                            |> map toMsg
                            |> private.map private.fromPageMsg
                    , subscriptions =
                        page.subscriptions context model
                            |> Sub.map (toMsg >> private.fromPageMsg)
                    }
            }
        )



-- COMPONENT


{-|


## an example

    page =
        Page.component
            { title = always title
            , init = always init
            , update = always update
            , subscriptions = always subscriptions
            , view = view -- no always used here, so view
                          -- has access to `PageContext`
            }

    title : String
    title =
        "Sign in"

    init : Params.SignIn -> ( Model, Cmd Msg, Cmd Global.Msg )
    init params =
        -- ...

    update : Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )
    update msg model =
        -- ...

    subscriptions : Model -> Sub Msg
    subscriptions model =
        -- ...

    view : Spa.PageContext -> Model -> Html Msg
    view { global } model =
        case global.user of
            SignedIn user ->
                viewSignOutForm user model

            SignedOut ->
                viewSignInForm model

-}
component :
    { title : { global : globalModel, model : pageModel } -> String
    , init : PageContext route globalModel -> pageParams -> ( pageModel, Cmd pageMsg, Cmd globalMsg )
    , update : PageContext route globalModel -> pageMsg -> pageModel -> ( pageModel, Cmd pageMsg, Cmd globalMsg )
    , view : PageContext route globalModel -> pageModel -> ui_pageMsg
    , subscriptions : PageContext route globalModel -> pageModel -> Sub pageMsg
    }
    -> Page route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
component page =
    Page
        (\{ toModel, toMsg, map } ->
            { init =
                \pageParams context ->
                    page.init context pageParams
                        |> truple toModel toMsg
            , update =
                \msg model context ->
                    page.update context msg model
                        |> truple toModel toMsg
            , bundle =
                \model private context ->
                    { title =
                        page.title
                            { global = context.global
                            , model = model
                            }
                    , view =
                        page.view context model
                            |> map toMsg
                            |> private.map private.fromPageMsg
                    , subscriptions =
                        page.subscriptions context model
                            |> Sub.map (toMsg >> private.fromPageMsg)
                    }
            }
        )


{-| A utility for sending `Global.Msg` commands from your `Page.component`

    init : Params.SignIn -> ( Model, Cmd Msg, Cmd Global.Msg )
    init params =
        ( model
        , Cmd.none
        , Page.send (Global.NavigateTo routes.dashboard)
        )

-}
send : msg -> Cmd msg
send =
    Utils.send



-- LAYOUT


{-| In practice, we wrap `layout` in `Utils/Spa.elm` so we only have to provide `Html.map` or `Element.map` once)

    import Utils.Spa as Spa

    page =
        Spa.layout
            { layout = Layout.view
            , pages =
                { init = init
                , update = update
                , bundle = bundle
                }
            }

-}
layout :
    ((pageMsg -> msg) -> ui_pageMsg -> ui_msg)
    -> Layout route pageParams pageModel pageMsg ui_pageMsg globalModel globalMsg msg ui_msg
    -> Page route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
layout map options =
    Page
        (\{ toModel, toMsg } ->
            { init =
                \pageParams global ->
                    options.recipe.init pageParams global
                        |> truple toModel toMsg
            , update =
                \msg model global ->
                    options.recipe.update msg model global
                        |> truple toModel toMsg
            , bundle =
                \model private context ->
                    let
                        viewLayout page =
                            options.view
                                { page = page
                                , global = context.global
                                , fromGlobalMsg = private.fromGlobalMsg
                                , route = context.route
                                }

                        myLayoutsVisibility : Transition.Visibility
                        myLayoutsVisibility =
                            if private.path == options.path then
                                private.visibility

                            else
                                Transition.visible

                        bundle : { title : String, view : ui_msg, subscriptions : Sub msg }
                        bundle =
                            options.recipe.bundle
                                model
                                { fromGlobalMsg = private.fromGlobalMsg
                                , fromPageMsg = toMsg >> private.fromPageMsg
                                , map = map
                                , path = private.path
                                , transitions = private.transitions
                                , visibility = private.visibility
                                }
                                context

                        lookupTransitionFrom :
                            Path
                            -> List { path : Path, transition : Transition ui_msg }
                            -> Transition ui_msg
                        lookupTransitionFrom path list =
                            list
                                |> List.filter (.path >> (==) path)
                                |> List.map .transition
                                |> List.head
                                |> Maybe.withDefault Transition.optOut
                    in
                    { title = bundle.title
                    , view =
                        viewLayout <|
                            Transition.view
                                (lookupTransitionFrom options.path private.transitions)
                                myLayoutsVisibility
                                bundle.view
                    , subscriptions = bundle.subscriptions
                    }
            }
        )



-- UTILS


tuple :
    (model -> bigModel)
    -> (msg -> bigMsg)
    -> ( model, Cmd msg )
    -> ( bigModel, Cmd bigMsg, Cmd a )
tuple toModel toMsg ( model, cmd ) =
    ( toModel model
    , Cmd.map toMsg cmd
    , Cmd.none
    )


truple :
    (model -> bigModel)
    -> (msg -> bigMsg)
    -> ( model, Cmd msg, Cmd a )
    -> ( bigModel, Cmd bigMsg, Cmd a )
truple toModel toMsg ( a, b, c ) =
    ( toModel a, Cmd.map toMsg b, c )
