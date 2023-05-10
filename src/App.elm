module App exposing (..)

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


update : Request -> Msg -> Model -> Response Model Msg
update req msg model =
    case msg of
        OnNow now ->
            "elm.app response at "
                ++ (now |> Time.posixToMillis |> String.fromInt)
                ++ ", "
                ++ req.url.path
                |> ResponseDone
