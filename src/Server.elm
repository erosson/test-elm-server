module Server exposing (..)

import Dict exposing (Dict)
import Json.Decode as D
import Url exposing (Url)


type alias RequestJson =
    D.Value


type alias Request =
    { url : Url
    , headers : Dict String String
    }


type Response amodel amsg
    = ResponsePending ( amodel, Cmd amsg )
    | ResponseDone String


type alias Server amodel amsg =
    { initRequest : Request -> Response amodel amsg
    , update : Request -> amsg -> amodel -> Response amodel amsg
    }


server : ((D.Value -> Msg amsg) -> Sub (Msg amsg)) -> (ResponseJson -> Cmd (Msg amsg)) -> Server amodel amsg -> Program flags (Model amodel) (Msg amsg)
server onRequest onResponse srv =
    Platform.worker
        { init = \flags -> init
        , update = update onResponse srv
        , subscriptions = \model -> onRequest OnRequest
        }


init : ( Model amodel, Cmd (Msg amsg) )
init =
    ( { nextConnId = 1
      , conn = Dict.empty
      }
    , Cmd.none
    )


update : (ResponseJson -> Cmd (Msg amsg)) -> Server amodel amsg -> Msg amsg -> Model amodel -> ( Model amodel, Cmd (Msg amsg) )
update onResponse srv msg model =
    case msg of
        OnRequest input ->
            case D.decodeValue decodeRequest input of
                Err err ->
                    ( model, onResponse { input = input, headers = [], body = D.errorToString err } )

                Ok req ->
                    case srv.initRequest req of
                        ResponsePending ( st, cmd ) ->
                            let
                                conn : Connection amodel
                                conn =
                                    { id = model.nextConnId
                                    , input = input
                                    , req = req
                                    , state = st
                                    }
                            in
                            ( { model
                                | conn = model.conn |> Dict.insert conn.id conn
                                , nextConnId = model.nextConnId + 1
                              }
                            , cmd |> Cmd.map (OnAppMsg conn.id)
                            )

                        ResponseDone body ->
                            ( model
                            , onResponse { input = input, headers = [], body = body }
                            )

        OnAppMsg connId amsg ->
            case Dict.get connId model.conn of
                Nothing ->
                    ( model, Cmd.none )

                Just conn ->
                    case srv.update conn.req amsg conn.state of
                        ResponsePending ( st, cmd ) ->
                            ( { model | conn = model.conn |> Dict.insert conn.id { conn | state = st } }
                            , cmd |> Cmd.map (OnAppMsg conn.id)
                            )

                        ResponseDone body ->
                            ( { model | conn = model.conn |> Dict.remove conn.id }
                            , onResponse
                                { input = conn.input
                                , headers = []
                                , body = body
                                }
                            )


type alias Model amodel =
    { nextConnId : Int
    , conn : Dict Int (Connection amodel)
    }


type alias Connection amodel =
    { id : Int
    , input : RequestJson
    , req : Request
    , state : amodel
    }


type Msg amsg
    = OnRequest RequestJson
    | OnAppMsg Int amsg


type alias ResponseJson =
    { input : RequestJson
    , headers : List ( String, String )
    , body : String
    }


decodeRequest : D.Decoder Request
decodeRequest =
    D.map2 Request
        (D.at [ "url", "href" ] decodeUrl)
        (D.at [ "req", "headers" ] <| D.dict D.string)


decodeUrl : D.Decoder Url
decodeUrl =
    D.string
        |> D.andThen
            (\s ->
                case Url.fromString s of
                    Just url ->
                        D.succeed url

                    Nothing ->
                        D.fail ("not a url: " ++ s)
            )
