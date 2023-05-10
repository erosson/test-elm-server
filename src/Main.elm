port module Main exposing (main)

import App
import Server


type alias Flags =
    ()


main : Program Flags (Server.Model App.Model) (Server.Msg App.Msg)
main =
    Server.server
        onRequest
        onResponse
        { initRequest = App.initRequest
        , update = App.update
        }


port onRequest : (Server.RequestJson -> msg) -> Sub msg


port onResponse : Server.ResponseJson -> Cmd msg
