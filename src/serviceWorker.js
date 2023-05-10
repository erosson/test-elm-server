console.log('hello from sw')

self.addEventListener('fetch', event => {
    const url = new URL(event.request.url)
    console.log('sw fetch', url.pathname, event)
    if (url.pathname === '/fake') {
        console.log('sw replaced /fake with /real!')
        return event.respondWith(fetch('/real'))
    }
})