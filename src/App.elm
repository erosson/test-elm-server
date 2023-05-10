module App exposing (..)

import Html.String as H exposing (Html, text)
import Html.String.Attributes exposing (src)
import Server exposing (Request, Response(..))
import Task
import Time exposing (Posix)


type alias Model =
    ()


type Msg
    = OnNow Posix


initRequest : Request -> Response Model Msg
initRequest req =
    ( (), Time.now |> Task.perform OnNow )
        |> ResponsePending


htmlString : List (Html msg) -> String
htmlString =
    List.map (H.toString 2)
        >> String.join "\n  "
        >> (++) "<!doctype html>"


update : Request -> Msg -> Model -> Response Model Msg
update req msg model =
    case msg of
        OnNow now ->
            [ H.node "body"
                []
                [ "elm.app response at "
                    ++ (now |> Time.posixToMillis |> String.fromInt)
                    ++ ", "
                    ++ req.url.path
                    |> text
                ]
            , H.node "script" [ src "/client.js" ] []
            ]
                |> htmlString
                |> ResponseDone
