if (!!navigator?.serviceWorker) {
    navigator.serviceWorker.register("/serviceWorker.js")
}

fetch('/fake').then(r => r.text()).then(b => console.log('/fake', b))