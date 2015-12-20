###

  Calligraph common module

  Responsibilities:
    Hold DOM references
    Initialize Mooog
    Keep mousedata object updated
    Call subclass init
    Provide utility functions

###
class Calligraph

  constructor: () ->

    #DOM
    @document = $(document)
    @canvas = $("#canvas")
    @canvas_width = @canvas.width()
    @canvas_height = @canvas.height()


    # initialize libraries
    @m = new Mooog


    #Initialize mouse information
    @mousedata =
      lastX: 0
      lastY: 0
      curX: 0
      curY: 0
      velX: 0
      velY: 0
      vel: 0
      last_velX: 0
      last_velY: 0
      last_vel: 0
      #velX_dX: 0
    @last_timeval = performance.now()
    @last_mouse_update = performance.now()

    # for now, set up dashboard automatically
    @dashboard = new Dashboard(@)



    @document.on 'mousemove', @update_mousedata

    # The subclass-specific init function
    @init()

    #requestAnimationFrame @animate


  # constrains val to within inmin < val < inmax and then scales it to the interval outmin-outmax
  clamp: (val, inmin, inmax, outmin, outmax) ->
    val = inmin if val < inmin
    val = inmax if val > inmax
    ((val - inmin) / (inmax - inmin)) * (outmax - outmin) + outmin



  update_mousedata: (e) =>
    now = performance.now()
    elapsed = now - @last_mouse_update
    @last_mouse_update = now
    @mousedata.curX = e.offsetX
    @mousedata.curY = e.offsetY
    deltaX = @mousedata.curX - @mousedata.lastX
    deltaY = @mousedata.curY - @mousedata.lastY
    @mousedata.velX = deltaX / elapsed
    @mousedata.velY = deltaY / elapsed
    @mousedata.last_vel = @mousedata.vel
    @mousedata.vel = Math.sqrt(Math.pow(@mousedata.velX,2) + Math.pow(@mousedata.velY,2))
    @mousedata.lastX = e.offsetX
    @mousedata.lastY = e.offsetY

    #supplied by subclass
    @on_mousemove(@mousedata)

    null


  null



class TC extends Calligraph
  constructor: ()->
    super

  init: ()->
    console.log 'Calligraph "Test" init'
    @m.node
      id: 'saw1'
      node_type: 'Oscillator'
      type: 'sawtooth'
      frequency: 100
    @m.node
      id: 'saw2'
      node_type: 'Oscillator'
      type: 'sawtooth'
      frequency: 100
    @m.node
      id: 'saw3'
      node_type: 'Oscillator'
      type: 'sawtooth'
      frequency: 100
    @m.node
      id: 'comp'
      node_type: 'DynamicsCompressor'
      threshold: -50
      knee: 40
      ratio: 12
      reduction: -20
      attack: 0
      release: 0.25
    @m.node
      id: 'verb'
      node_type: 'Convolver'
      buffer_source_file: 'sound/impulse-responses/st-andrews-church-ortf-shaped.wav'
    @m.node
      id: 'master'
      node_type: 'Gain'
      gain: 0
    @m.node
      id: 'delay1'
      node_type: 'Delay'
      delayTime: 0.5
      feedback: 0.25

    @n = @m._nodes

    @n.saw1.chain(@n.master)
    @n.saw2.chain(@n.master)
    @n.saw3.chain(@n.master)
    @n.master.connect(@n.verb)
    #@n.comp.chain(@n.master)


    @pixi_init()

    @velocity = 0
    @velocity_loss = 0.01
    @velocity_max = 4



    null



  on_mousedown: (e) =>
    @last_click = performance.now()
    @emitter.emit = true
    @n.saw1.start()
    @n.saw2.start()
    @n.saw3.start()

  on_mouseup: (e) =>
    @emitter.emit = false
    @n.saw1.stop()
    @n.saw2.stop()
    @n.saw3.stop()

  on_mousemove: (m)->
    @velocity = Math.min(@velocity + m.vel, @velocity_max)

  on_animate: (data, elapsed) =>

    duration = performance.now() - @last_click
    @emitter.maxLifetime = Math.min(8, @velocity)
    #looks like alpha is actually on a modulo
    @emitter.startAlpha = (@velocity + 0.0001) / 0.5
    r = @clamp((@canvas_height * 0.8) - data.lastY, 0, @canvas_height, 70, 255)
    g = @clamp(0, (@canvas_height * 0.8) - data.lastY, @canvas_height, 70, 255)

    @emitter.startColor = [r, g, 150]

    @emitter.updateOwnerPos(data.curX,data.curY)
    #@pixi.line_emitter.update(elapsed * 0.001);
    #console.log "gain #{data.vel} to "+ (@clamp(data.vel, 0, 0.1, 0, 1))
    @n.master.param
      #gain: 0.2 + @clamp(data.velX, -2, 2, -0.3, 0.3)
      gain: @clamp(@velocity, 0, 5, 0, 1)
      ramp:'expo'
      at: 0.1
      from_now: true

    @n.saw1.param
      frequency: @clamp(@canvas_height - data.lastY, 0, @canvas_height, 50, 250)
      ramp:'expo'
      at: 0.1
      from_now: true
    @n.saw2.param
      frequency: @clamp(@canvas_height - data.lastY, 0, @canvas_height, 50, 250)
      ramp:'expo'
      at: 0.5
      from_now: true
    @n.saw3.param
      frequency: @clamp(@canvas_height - data.lastY, 0, @canvas_height, 50, 250)
      ramp:'expo'
      at: 1
      from_now: true

    #@pointer.position.x = data.lastX
    #@pointer.position.y = data.lastY

  pixi_init: () ->
    @pixi = {}
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
      	"start": "FF0000"
      	"end": "000000"
      "speed":
      	"start": 200
      	"end": 0
      "startRotation":
      	"min": 0
      	"max": 360
      "rotationSpeed":
      	"min": 0
      	"max": 1
      "lifetime":
      	"min": 0.1
      	"max": 1.75
      "blendMode": "normal"
      "frequency": 0.01
      "emitterLifetime": 0
      "maxParticles": 1000
      "pos":
      	"x": 0
      	"y": 0
      "addAtBack": false
      "spawnType": "circle"
      "spawnCircle":
        x: 0
        y: 0
        r: 10

    }


    canvas = document.getElementById("canvas");

    ### var preMultAlpha = !!options.preMultAlpha;
    		if(rendererOptions.transparent && !preMultAlpha)
    			rendererOptions.transparent = "notMultiplied"; ###

    @stage = new PIXI.Container()
    @pixi.r = PIXI.autoDetectRenderer(canvas.width, canvas.height)
    $(canvas).replaceWith @pixi.r.view
    @canvas_height = $("canvas").height()
    @canvas_width = $("canvas").width()



    @document.on 'mouseleave','canvas',@on_mouseup
    @document.on 'mousedown','canvas',@on_mousedown
    @document.on 'mouseup','canvas',@on_mouseup

    window.onresize = (event) =>
    	canvas.width = window.innerWidth
    	canvas.height = window.innerHeight
    	@pixi.r.resize canvas.width, canvas.height
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
      @emitterContainer = new PIXI.Container()


    @stage.addChild @emitterContainer
    @emitter = new cloudkid.Emitter @emitterContainer, art, config

    console.log @emitter

    #Center on the stage
    @emitter.updateOwnerPos(window.innerWidth / 2, window.innerHeight / 2)

    requestAnimationFrame @animate



  animate: (timeval) =>
    elapsed = timeval - @last_timeval
    @last_timeval = timeval
    #console.log "loss is #{@velocity_loss * elapsed}"

    #console.log "vel was #{@velocity}"
    @velocity = Math.max(0, @velocity - (@velocity_loss * elapsed))

    #console.log "vel is now #{@velocity}"
    #check that mouse has moved in last n milliseconds, if not,
    #trigger a fake mouse event so vel is zero

#     if (Date.now() - @mousedata.last_timestamp) > 300
#       #console.log "zeroing", @mousedata.last_timestamp
#       @update_mousedata
#         timeStamp: Date.now()
#         offsetX: @mousedata.lastX
#         offsetY: @mousedata.lastY



    @emitter.update(elapsed * 0.001)






    #@pointer.rotation += 0.01
    @pixi.r.render @stage
    @on_animate(@mousedata, elapsed)
    requestAnimationFrame @animate
    null



window.Calligraphs =
  TC: TC

