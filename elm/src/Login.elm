module Login exposing (..)

import Browser
import Browser.Navigation as Nav
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Html exposing (..)
import Debug exposing (..)
import Url
import Http
import Json.Encode as Encode

-- MAIN

main = 
        Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }


-- MODEL

type alias Credentials = { username: String, password: String }

encodeLogin: Credentials -> String
encodeLogin credentials = "username:"++credentials.username++";password:"++credentials.password

type PageState = LoginPage | LoginFailure

type ResponseState = Waiting | Success | Failure

type alias Model = { page: PageState, credentials: Credentials}

init: () -> (Model, Cmd Msg)
init _ = (Model LoginPage (Credentials "" ""), Cmd.none)


-- UPDATE

type Msg = DisplayLogin
         | UpdateUsername String
         | UpdatePassword String
         | SubmitLogin Credentials
         | LoginResponse (Result Http.Error String)

update: Msg -> Model -> (Model, Cmd Msg)
update msg model = 
        case msg of
                DisplayLogin ->
                        (Model LoginPage (Credentials "" ""), Cmd.none)
                UpdateUsername name ->
                        let 
                            oldCreds = model.credentials
                            newCreds = { oldCreds | username = name }
                        in
                        ( { model | credentials = newCreds }, Cmd.none )
                UpdatePassword pass ->
                        let 
                            oldCreds = model.credentials
                            newCreds = { oldCreds | password = pass }
                        in
                        ( { model | credentials = newCreds }, Cmd.none )
                SubmitLogin credentials ->
                        (Model LoginPage credentials, (loginAttempt credentials))
                LoginResponse res ->
                        case res of
                                Ok response ->
                                        if response == "incorrect" then (Model LoginFailure (Credentials "" ""), Cmd.none) else (Model LoginPage (Credentials "" ""), (Nav.load "http://localhost:8080/index.php"))
                                Err err ->
                                        let
                                            _ = Debug.log "Error: " err
                                        in
                                        (Model LoginFailure (Credentials "" ""), Cmd.none)

-- SUBSCRIPTIONS

subscriptions: Model -> Sub Msg
subscriptions model =
        Sub.none


-- VIEW

loginView: Model -> ResponseState -> Html Msg
loginView model rstate =
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
                ] [ text "Login" ],
                div [ style "display" "flex", style "flex-direction" "column" ] [
                        label [ for "username", style "font-size" "20px", style "margin" "3px" ] [ text "Username" ],
                        input [ placeholder "Username", id "username", value model.credentials.username, onInput UpdateUsername,
                                style "border-radius" "5px",
                                style "margin-bottom" "10px",
                                style "font-size" "15px",
                                style "padding" "10px",
                                style "width" "20vw",
                                style "border" "1px solid lightgrey"
                        ] [  ],
                        label [ for "password", style "font-size" "20px", style "margin" "3px" ] [ text "Password" ],
                        input [ type_ "password", placeholder "Password", id "password", value model.credentials.password, onInput UpdatePassword,
                                style "border-radius" "5px",
                                style "margin-bottom" "10px",
                                style "font-size" "15px",
                                style "padding" "10px",
                                style "width" "20vw",
                                style "border" "1px solid lightgrey"
                        ] [  ],
                        case rstate of
                                Waiting -> text ""
                                Success -> text ""
                                Failure ->  div [ style "color" "red" ] [ text "Incorrect username or password" ]
                ],
                button [ 
                        onClick (SubmitLogin model.credentials),
                        style "background-color" "#f2ae00",
                        style "color" "white",
                        style "border" "0px none",
                        style "border-radius" "5px",
                        style "font-size" "15px",
                        style "padding" "10px",
                        style "font-weight" "600",
                        style "margin-top" "10px"
                ] [ text "Submit" ]
        ]

view: Model -> Html Msg
view model = 
        case model.page of
                LoginPage -> loginView model Waiting
                LoginFailure -> loginView model Failure
-- HTTP

loginAttempt: Credentials -> Cmd Msg
loginAttempt cred = 
        Http.post
              { 
                url = "http://localhost:8080/api/login.php",
                body = Http.stringBody "text/plain" (encodeLogin cred),
                expect = Http.expectString LoginResponse
              }
