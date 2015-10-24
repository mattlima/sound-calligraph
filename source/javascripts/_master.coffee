$(document).ready ()->
  window.__c = new Calligraphs.TC





###
Calligraph class creates PIXI canvas
--> PIXI.js canvas object dispatches mousedown, mousemove, mouseup, mouseupoutside
--> Calligraph class mouseData is updated on these events
--> Calligraph subclass performs sound param updates via requestAnimationFrame
###
