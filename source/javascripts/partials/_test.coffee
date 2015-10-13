class Calligraph
	
	constructor: () ->
		@init()
		
	init: () ->
		$(document).on 'mousemove', 'div.canvas', @mm
	
	mm: (e) =>
		console.log e

window.C = new Calligraph