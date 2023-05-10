import App from '../dist/Main.elm.cjs'
import http from 'http'
import fs from 'fs/promises'
import { fileURLToPath } from 'url'
import { dirname } from 'path'

const elm = App.Elm.Main.init({})
elm.ports.onResponse.subscribe(elmRes => {
    const { req, res } = elmRes.input
    res.headers += elmRes.headers
    res.end(elmRes.body)
})

const srv = http.createServer(async (req, res) => {
    // https://nodejs.org/api/http.html#messageurl
    const url = new URL(req.url, `http://${req.headers.host}`)
    // quick hack for static files
    if (url.pathname.match(/\/\w+\.js$/)) {
        // replace __dirname; https://stackoverflow.com/questions/46745014/alternative-for-dirname-in-node-js-when-using-es6-modules
        const dir = dirname(fileURLToPath(import.meta.url))
        try {
            const f = await fs.readFile(`${dir}${url.pathname}`)
            res.setHeader('content-type', 'text/javascript')
            return res.end(f.toString())
        }
        catch (e) {
            res.statusCode = 404
            return res.end('not found')
        }
    }
    const input = { req, res, url }
    elm.ports.onRequest.send(input)
})

const hostname = 'localhost'
const port = 3000
srv.listen(port, hostname, () => {
    console.log(`Elm server listening on port http://${hostname}:${port}`)
})