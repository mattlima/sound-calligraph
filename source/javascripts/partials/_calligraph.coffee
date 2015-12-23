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

    #retain useful DOM refs
    @document = $(document)


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
    @dashboard = new Dashboard(this)

    # keep mousedata current for inheriting classes
    @document.on 'mousemove', @update_mousedata

    # The init function is supplied by the inheriting class
    @init()


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


  #
  #
  # The stage is always used so it is managed here to take care of resizes, etc.
  #
  #
  pixi_init: (renderer_config)=>
    @pixi = {}
    @pixi.r = PIXI.autoDetectRenderer(@get_canvas_width(), @get_canvas_height(), renderer_config)
    @canvas = @pixi.r.view
    $('body').prepend @pixi.r.view


    @stage = new PIXI.Container()


    @document.on 'mouseleave', 'canvas', @on_mouseup
    @document.on 'mousedown', 'canvas', @on_mousedown
    @document.on 'mouseup', 'canvas', @on_mouseup

    window.onresize = (event) =>
      #canvas.width = window.innerWidth
      #canvas.height = window.innerHeight
      @pixi.r.resize @get_canvas_width(), @get_canvas_height()
      @canvas_height = @get_canvas_height()
      @canvas_width = @get_canvas_width()
      true

    window.onresize()
    null

  #
  #
  # Todo: move constants, add check for presence of dash
  #
  #
  get_canvas_height: ()->
    DASH_HEIGHT = 120
    window.innerHeight - DASH_HEIGHT

  get_canvas_width: ()->
    window.innerWidth


  null



class TC extends Calligraph
  constructor: ()->
    super

  init: ()->
    #hello!
    console.log 'Calligraph "Test" init'


    #see Calligraph for the actual pixi_init function
    renderer_config = {
      "clearBeforeRender": true
      "preserveDrawingBuffer": true
    }
    @pixi_init renderer_config

    @pixi_begin()

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
    @emitter.startAlpha = (@velocity + 0.0001) / 3.5
    r = @clamp((@canvas_height * 0.8) - data.lastY, 0, @canvas_height, 70, 255)
    g = @clamp(0, (@canvas_height * 0.8) - data.lastY, @canvas_height, 70, 255)

    @emitter.startColor = [r, g, 150]
    @emitter.endColor = [r, g, 150]

    @emitter.updateOwnerPos(data.curX,data.curY)
    #@pixi.line_emitter.update(elapsed * 0.001);
    #console.log "gain #{data.vel} to "+ (@clamp(data.vel, 0, 0.1, 0, 1))
    @n.master.param
      #gain: 0.2 + @clamp(data.velX, -2, 2, -0.3, 0.3)
      gain: @clamp(@velocity, 0, 5, 0, 0.5)
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

  pixi_begin: () ->

    imagePaths = ["images/small-white-line.png"]
    useParticleContainer = false

    particle_config = {
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
      #"blendMode": "SCREEN"
      "frequency": 0.005
      "emitterLifetime": 0
      "maxParticles": 2000
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



    #the recursive filter requires a base sprite to render into
    @capture = new PIXI.Sprite()
    @capture.width = @canvas_width
    @capture.height = @canvas_height
    @stage.addChild @capture

    #these two RenderTextures will round-robin to enable the recursive filtering effects
    @renderTexture1 = new PIXI.RenderTexture(@pixi.r, @canvas_width, @canvas_height)
    @renderTexture2 = new PIXI.RenderTexture(@pixi.r, @canvas_width, @canvas_height)
    currentTexture = @renderTexture1
    @capture.texture = currentTexture
    blur = new PIXI.filters.BlurFilter()
    blur.blur = 5
    bloom = new PIXI.filters.BloomFilter()
    bloom.blur = 1
    noise = new PIXI.filters.NoiseFilter()
    noise.noise = -0.1
    #bd = new PIXI.filters.BlurDirFilter(0,15)
    #bd.passes = 4
    @capture.filters = [
      #new PIXI.filters.BloomFilter()
      #new PIXI.filters.ConvolutionFilter([0,0,0,0,1.1,0,0,0,0], window.innerWidth, window.innerHeight  )
      blur
      #noise
      #bd
      bloom
    ]




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

    #@graphics = new PIXI.Graphics()
    #@graphics.beginFill(0x000000, 0.001)
    #@graphics.drawRect(0, 0, window.innerWidth, window.innerHeight)
    #
    #@stage.addChild @graphics

    @renderTexture = new PIXI.RenderTexture(@pixi.r, window.innerWidth, window.innerHeight)
    @t_sprite = new PIXI.Sprite()
    @t_sprite.width = 200
    @t_sprite.height = 200
    #@t_sprite.texture = new PIXI.Texture.fromImage('/images/imgres.jpg')

    @stage.addChild @t_sprite

    #window.blurFilter = new PIXI.filters.ConvolutionFilter([1.1, 2.1, 0.1, 1.1, 0.1, 0.1, 0.1, 0.1, 1.1], window.innerWidth, window.innerHeight  )

    #window.blurFilter = new PIXI.filters.BloomFilter()


    @emitter = new cloudkid.Emitter @emitterContainer, art, particle_config

    console.log @emitter
    @dashboard.add_key @white_pix_per, 109

    #Center on the stage
    @emitter.updateOwnerPos(window.innerWidth / 2, window.innerHeight / 2)

    #@on_mouseup()

    #clean this experiment
    @framerate_val = $("#framerate .val")
    @capture_alpha_val = $("#capture_alpha .val")
    @capture_alpha = 0.7
    @capture_alpha_val.text( @capture_alpha )
    @total_frames = 0 #ticker for white pixel eval
    requestAnimationFrame @animate



  animate: (timeval) =>
    elapsed = timeval - @last_timeval
    @framerate_val.text( Math.round( 1000 / elapsed ) )
    @white_pix_per.call this unless( @total_frames++ % 15 )
    @last_timeval = timeval
    @render_round_robin()
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


  # flips @renderTexture1 and 2, re-renders 1 and makes it the texture of @capture, which is then scaled up
  # todo: incorporate into Calligraph class
  render_round_robin: ()=>
    temp = @renderTexture1
    @renderTexture1 = @renderTexture2
    @renderTexture2 = temp
    #@capture.scale.x = @capture.scale.y = 1.005
    @capture.alpha = @capture_alpha
    @renderTexture1.render @stage, false, true
    #@capture.scale.x = @capture.scale.y = 1.0
    @capture.alpha = 1.0
    @capture.texture = @renderTexture1


  #
  #
  # Calculates the percentage of the canvas that is white (from the bloom)
  #
  #
  white_pix_per: () ->
    _then = performance.now()
    skip = 256
    pixdata = @renderTexture1.getPixels()
    whites = 0
    calls = 0
    for i in [0..pixdata.length] by (4 * skip)
      whites += 1 if pixdata[i] is 255 and pixdata[i+1] is 255 and pixdata[i+2] is 255
      calls += 1
    ratio = whites/calls
    perc = Math.round( ratio * 100 )
    @capture_alpha = 6.75 - (ratio * 2)
    @capture_alpha_val.text( @capture_alpha )
    $("#white_pix .val").text( "#{perc}%")




window.Calligraphs =
  TC: TC

