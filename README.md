A demonstration of Elm as the brain of a node http server.

`Server` is a framework for generic http servers. The URL is sent as a parameter. You provide `initRequest` and `update`, which should return `Server.RequestPending` if the page is still loading (if `Cmd`s are still pending) or `Server.RequestDone` when the page is ready.

Haven't demonstrated HTML output here, but string output is required - you'll want something like https://package.elm-lang.org/packages/zwilias/elm-html-string/latest/