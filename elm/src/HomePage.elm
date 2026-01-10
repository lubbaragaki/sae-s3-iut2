module HomePage exposing (..)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import Http
import Json.Decode exposing (Decoder, map2, field, bool, string, list)
import Debug exposing (..)


-- MAIN

main = 
        Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }


-- MODEL

type alias Test = 
        {
                name: String,
                passed: Bool
        }

type alias PhpFix =
        {
                fixed: Bool,
                last_commit: String
        }

type alias JsonData = { tests: List Test, php_fix: PhpFix }

type Model
        = Failure
        | Loading
        | Success JsonData

type Msg 
        = Reload
        | GotData (Result Http.Error JsonData)


init: () -> (Model, Cmd Msg)
init _ =
  ( Loading, getData )


-- UPDATE

update: Msg -> Model -> (Model, Cmd Msg)
update msg model = 
        case msg of
                Reload ->
                        (Loading, getData)
                GotData result ->
                        case result of
                                Ok jsonData ->
                                        (Success jsonData, Cmd.none)
                                Err err ->
                                        let 
                                                _ = Debug.log "Error: " err 
                                        in
                                        (Failure, Cmd.none)


-- SUBSCRIPTIONS

subscriptions: Model -> Sub Msg
subscriptions model =
        Sub.none


-- VIEW

passedPill: Html Msg
passedPill =
        span [ 
                style "background-color" "green",
                style "color" "white",
                style "border-radius" "15px",
                style "margin" "10px",
                style "padding" "5px",
                style "font-size" "12px"
        ] [ text "Passed" ]

failedPill: Html Msg
failedPill =
        span [ 
                style "background-color" "red",
                style "color" "white",
                style "border-radius" "15px",
                style "margin" "10px",
                style "padding" "5px",
                style "font-size" "12px"
        ] [ text "Failed" ]

generateLi: Test -> Html Msg
generateLi test =
        li [ style "list-style-type" "none", style "margin-bottom" "10px" ]
        [ text test.name,  (if test.passed then passedPill else failedPill) ]

viewTests: JsonData -> Html Msg
viewTests jsonData =
        ul [
                style "padding" "0px"
        ] (List.map generateLi jsonData.tests)

view: Model -> Html Msg
view model = 
        case model of
                Failure ->
                        text "An error occured"
                Loading ->
                        text "Loading..."
                Success jsonData ->
                        div [ 
                                style "font-family" "Arial, Helvetica, sans-serif",
                                style "padding" "10px"
                        ]
                        [
                                h1 [ 
                                        style "color" "white",
                                        style "background-color" "#2d3f75",
                                        style "margin" "0px",
                                        style "margin-bottom" "15px",
                                        style "padding" "15px",
                                        style "border-radius" "5px"
                                ] [ text "Admin panel" ],
                                div [] 
                                [ 
                                        h3 [ style "border-bottom" "1px solid orange" ] [ text "Php fix status" ],
                                        if jsonData.php_fix.fixed == True then
                                                div [] [ (text "All good") ]
                                        else
                                                div [] [
                                                (text "Commit "),
                                                (code [] [ text jsonData.php_fix.last_commit ]),
                                                (text " does not follow coding style conventions") ]
                                ],
                                div []
                                [
                                        h3 [ style "border-bottom" "1px solid orange" ] [ text "Tests status" ],
                                        viewTests jsonData 
                                ],
                                button [
                                        onClick Reload,
                                        style "background-color" "#f2ae00",
                                        style "color" "white",
                                        style "border" "0px none",
                                        style "border-radius" "5px",
                                        style "font-size" "15px",
                                        style "padding" "10px",
                                        style "font-weight" "600"
                                ] [ text "Reload" ]
                        ]


-- HTTP

getData: Cmd Msg
getData = 
        Http.get
              { 
                url = "http://152.77.90.133:80/api/data.php",
                expect = Http.expectJson GotData dataDecoder
              }

phpFixDecoder: Decoder PhpFix
phpFixDecoder =
        map2 PhpFix
                (field "status" bool)
                (field "last_commit" string)

testDecoder: Decoder Test
testDecoder =
        map2 Test
                (field "name" string)
                (field "passed" bool)

dataDecoder: Decoder JsonData
dataDecoder =
        map2 JsonData
                (field "tests" (Json.Decode.list testDecoder))
                (field "php_fix" phpFixDecoder)
