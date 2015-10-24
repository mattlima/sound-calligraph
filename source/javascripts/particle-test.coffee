
imagePaths = ["images/small-white-line.png"]
useParticleContainer = false
config = {
  "alpha":
  	"start": 0.62
  	"end": 0
  "scale":
  	"start": 0.25
  	"end": 0.75
  "color":
  	"start": "fff191"
  	"end": "ff622c"
  "speed":
  	"start": 200
  	"end": 0
  "startRotation":
  	"min": 265
  	"max": 275
  "rotationSpeed":
  	"min": -100
  	"max": 150
  "lifetime":
  	"min": 0.1
  	"max": 1.75
  "blendMode": "normal"
  "frequency": 0.1
  "emitterLifetime": 0
  "maxParticles": 1000
  "pos":
  	"x": 0
  	"y": 0
  "addAtBack": false
  "spawnType": "circle"
  "spawnCircle":
  	"x": 0
  	"y": 0
  	"r": 100
}


canvas = document.getElementById("stage");


rendererOptions =
  view: canvas

### var preMultAlpha = !!options.preMultAlpha;
		if(rendererOptions.transparent && !preMultAlpha)
			rendererOptions.transparent = "notMultiplied"; ###

stage = new PIXI.Container()
emitter = null
renderer = PIXI.autoDetectRenderer(canvas.width, canvas.height, rendererOptions)






window.onresize = (event) ->
	canvas.width = window.innerWidth
	canvas.height = window.innerHeight
	renderer.resize canvas.width, canvas.height
	true

window.onresize()



urls = imagePaths.slice()
makeTextures = true



###
			bg = new PIXI.Sprite(PIXI.Texture.fromImage("images/bg.png"));
			//bg is a 1px by 1px image
			bg.scale.x = canvas.width;
			bg.scale.y = canvas.height;
			bg.tint = 0x000000;
			stage.addChild(bg);
###

#collect the textures, now that they are all loaded

art = []
art.push(PIXI.Texture.fromImage(imagePaths[i])) for path, i in imagePaths


if useParticleContainer
  emitterContainer = new PIXI.ParticleContainer()
  emitterContainer.setProperties
    scale: true
    position: true
    rotation: true
    uvs: true
    alpha: true
else
  emitterContainer = new PIXI.Container()


stage.addChild emitterContainer
emitter = new cloudkid.Emitter emitterContainer, art, config

###
			if(type == "path")
				emitter.particleConstructor = cloudkid.PathParticle;
			else if(type == "anim")
				emitter.particleConstructor = cloudkid.AnimatedParticle;
###

#Center on the stage
emitter.updateOwnerPos(window.innerWidth / 2, window.innerHeight / 2)

#Click on the canvas to trigger
###
			canvas.addEventListener('mouseup', function(e){
				if(!emitter) return;
				emitter.emit = true;
				emitter.resetPositionTracking();
				emitter.updateOwnerPos(e.offsetX || e.layerX, e.offsetY || e.layerY);
			});
###



elapsed = Date.now()
updateId = 0


update = () ->

  #Update the next frame
  updateId = requestAnimationFrame(update);

  now = Date.now()

  emitter.update((now - elapsed) * 0.001)

  elapsed = now

  renderer.render stage


update()

###
			window.destroyEmitter = function()
			{
				emitter.destroy();
				emitter = null;
				window.destroyEmitter = null;
				cancelAnimationFrame(updateId);

				renderer.render(stage);
			};
###




