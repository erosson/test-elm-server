A demonstration of Elm as the brain of a node http server.

`Server` is a framework for generic http servers. The URL is sent as a parameter. You provide `initRequest` and `update`, which should return `Server.RequestPending` if the page is still loading (if `Cmd`s are still pending) or `Server.RequestDone` when the page is ready.

Haven't demonstrated HTML output here, but string output is required - you'll want something like https://package.elm-lang.org/packages/zwilias/elm-html-string/latest/

Unrelated to Elm, I also tried out service worker capabilities here. Visit `/fake`, and if a service worker's been loaded it'll respond as if it's `/real`.

related work:

* elm-pages v3 (built on lamdera) has first class support for this: https://elm-pages-v3.netlify.app/. lamdera is capable of it: https://lamdera.com/. requires lamdera's nonstandard compiler, vendor lock-in, no ports/no custom typescript
* spades says it renders on the server before switching to client rendering. https://github.com/rogeriochaves/spades haven't yet tried it, but that sounds very fancy and I'd like plain old SSR for now.
