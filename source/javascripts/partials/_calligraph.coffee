class Calligraph

  constructor: () ->
    @m = new Mooog

  on_mousedown: (e) =>
    console.log 'calli mousedown'

  on_mouseup: (e) =>
    console.log 'calli mouseup'

  on_mousemove: (data) =>
    console.log 'calli mousemove'




window.Calligraph = Calligraph
