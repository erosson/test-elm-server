import App from '../dist/Main.elm.cjs'
import http from 'http'

const elm = App.Elm.Main.init({})
elm.ports.onResponse.subscribe(elmRes => {
    const { req, res } = elmRes.input
    res.headers += elmRes.headers
    res.end(elmRes.body)
})

const srv = http.createServer((req, res) => {
    const input = { req, res }
    elm.ports.onRequest.send(input)
})

const hostname = 'localhost'
const port = 3000
srv.listen(port, hostname, () => {
    console.log(`Elm server listening on port http://${hostname}:${port}`)
})