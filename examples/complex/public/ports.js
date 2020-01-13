// On load, listen to Elm!
window.addEventListener('load', _ => {
  window.ports = {
    init: app =>
      app.ports.outgoing.subscribe(({ action, data }) =>
        actions[action]
          ? actions[action](data)
          : console.warn(`I didn't recognize action "${action}".`)
      )
  }
})

// maps actions to functions!
const actions = {
  'ALERT': message =>
      window.alert(message),
  'SCROLL_TO': id =>
    document.getElementById(id) &&
      window.scrollTo({
        top: document.getElementById(id).offsetTop,
        left: 0,
        behavior: 'smooth'
      })
}
