port module Main exposing (main)

import Json.Decode as D
import Json.Encode as E



--import Dict exposing (Dict)
--
--
--type alias Model s =
--    { connections : Dict String (Connection s)
--    , nextId : Int
--    }
--
--
--type Mg msg
--    = AppMsg msg
--    | OnRequest Request
--
--
--type alias Connection s =
--    { id : String
--    , request : Request
--    , state : s
--    }
--
--
--type alias Request =
--    { url : String
--    , headers : List ( String, String )
--    }
--
--
--type ResponseState s
--    = Pending s
--    | Done ResponseDone
--
--
--type alias ResponseDone =
--    { status : Int
--    , headers : List ( String, String )
--    , body : String
--    }
--
--
--type alias Server s msg =
--    { init : Request -> ( s, Cmd msg )
--    , update : Request -> msg -> s -> ( ResponseState s, Cmd msg )
--    }
--
--
--server : Server s msg -> Platform.Program {} (Model s) (Msg msg)
--server app =
--    Platform.worker
--        { init = \flags_ -> app.init
--        }


type alias Flags =
    ()


type alias Model =
    ()


type Msg
    = OnRequest Request


type alias Request =
    RequestJson


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( (), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnRequest req ->
            ( model
            , onResponse
                { input = req
                , headers = []
                , body = "elm response"
                }
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    onRequest OnRequest


type alias RequestJson =
    { req : D.Value
    , res : D.Value
    }


type alias ResponseJson =
    { input : RequestJson
    , headers : List ( String, String )
    , body : String
    }


port onRequest : (RequestJson -> msg) -> Sub msg


port onResponse : ResponseJson -> Cmd msg
