class Calligraph extends CalligraphBase
  constructor: ()->
    super

  subinit: ()->
    #hello!
    console.log 'Recursive bloom proof of concept'


    #see CalligraphBase for the actual pixi_init function
    renderer_config = {
      "clearBeforeRender": true
      "preserveDrawingBuffer": true
    }
    @pixi_init renderer_config
    @pixi_begin()



    #the worst sound in the world. Temporarily.
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
#     @n.saw1.start()
#     @n.saw2.start()
#     @n.saw3.start()

  on_mouseup: (e) =>
    @emitter.emit = false
#     @n.saw1.stop()
#     @n.saw2.stop()
#     @n.saw3.stop()

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




#  Schematic for applying pixelation effects, which need to be on their own container
#   (pixelation should not feed back
#    +----------+
#    |C:Emitter |
#    +-+--------+
#      |
#      |                            +-----------+
#      |        +-------+RT+-------^+ S:capture |
#      |        |                   +-----------+
#      |        |                       F:Blur
#      |        | +------------+        F:Bloom
#      |        | |            |          +
#      ^        | ^            +----------+
#     ++--------+-++
#     | C:feedback |
#     +--+---------+
#        |
#        +--------+
#                +v-----v+
#                | Stage |
#                +-------+




    # N.B. Filters defined here may or may not be used.
    blur = new PIXI.filters.BlurFilter()
    blur.blur = 5
    bloom = new PIXI.filters.BloomFilter()
    bloom.blur = 1
#     noise = new PIXI.filters.NoiseFilter()
#     noise.noise = -0.1
#     rgbsplit = new PIXI.filters.RGBSplitFilter()
#     @pxl8 = new PIXI.filters.PixelateFilter()
#     @pxl8.size = {x:5,y:5}
#     edge = new PIXI.filters.ConvolutionFilter([
#       -1, -1, -1
#       -1,  8, -1
#       -1, -1, -1
#     ], window.innerWidth, window.innerHeight  )
#     white_surrounded = new PIXI.filters.ConvolutionFilter([
#       0.125, 0.125, 0.125
#       0.125,  0, 0.125
#       0.125, 0.125, 0.125
#     ], window.innerWidth, window.innerHeight  )
#
#     brightness_to_alpha = new PIXI.filters.ColorMatrixFilter()
#     brightness_to_alpha.matrix = [
#       1, 0, 0, 0, 0
#       0, 0, 0, 0, 0
#       0, 0, 0, 0, 0
#       0, 0, 0, 0, -255
#     ]
#
#     blue = new PIXI.filters.ColorMatrixFilter()
#     blue.matrix = [
#       0, 0, 0, 0, 0
#       0, 0, 0, 0, 0
#       0, 0, 1, 0, 0
#       0, 0, 0, 0, 0
#     ]
#     # this filter isolates pure white
#     thresh = new PIXI.filters.ColorMatrixFilter()
#     thresh.matrix = [
#       100, 100, 100, 0, -299
#       100, 100, 100, 0, -299
#       100, 100, 100, 0, -299
#       0, 0, 0, 1, 0
#     ]
#     colorstep = new PIXI.filters.ColorStepFilter()
#     colorstep.step = 1




    #Sprite for the pixelation halo effect
    #@halo = new PIXI.Sprite()
    #@halo.width = @canvas_width
    #@halo.height = @canvas_height
    #@halo.filters = [ brightness_to_alpha ]
    #@haloTexture = new PIXI.RenderTexture(@pixi.r, @canvas_width, @canvas_height)
    #@halo.texture = @haloTexture
    #
    #
    #
    #@haloContainer = new PIXI.Container()
    #@haloContainer.addChild @halo
    #@haloContainer.position = {x: 0, y: 0}
    #@haloContainer.filters = [ @pxl8 ]

    #testing doing reflections experimental reflection setup
    #for x in [2..6]
    #  @["halo#{x}"] = new PIXI.Sprite()
    #  @["halo#{x}"].width = @canvas_width
    #  @["halo#{x}"].height = @canvas_height
    #  #@["halo#{x}"].filters = [ thresh ] #[  edge ]
    #  @["halo#{x}"].texture = @haloTexture
    #  @["halo#{x}"].rotation = 60 * x
    #  @["halo#{x}"].anchor = {x: 0.5, y: 0.5}
    #  @haloContainer.addChild @["halo#{x}"]

    #container hold the capture sprite and be used as the render source for the recursive filter
    @feedback = new PIXI.Container()
    @stage.addChild @feedback

    # Create the recursive filter round robin function for @feedback
    @render_recursive_stage = @create_recursive_render @feedback, 'capture', 'capture_alpha',  true
    @r1 = 0.6
    #@render_recursive_halo = @create_recursive_render @halo, 'capture2', 'r1', true








    @capture.filters = [
      blur
      bloom
    ]

    #@stage.filters = [  edge, bloom, @pxl8]





    #collect the textures, now that they are all loaded


    art = [
      { framerate: "matchLife"
      loop: true
      textures: [
        "images/spark_40x40.png"
        "images/spark_40x40_m.png"
        "images/spark_40x40_s.png"
      ]}
    ]




    @emitterContainer = new PIXI.Container()
    @feedback.addChild @emitterContainer



    @emitter = new cloudkid.Emitter @emitterContainer, art, particle_config
    @emitter.particleConstructor = cloudkid.AnimatedParticle

    @dashboard?.add_keydown @white_pix_per, 109

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
    @white_pix_per.call this unless( @total_frames++ % 5 )
    @last_timeval = timeval
    #@render_round_robin()
    @render_recursive_stage()
    #@render_recursive_halo()
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



  #
  #
  # Calculates the percentage of the canvas that is white (from the bloom)
  #
  #
  white_pix_per: () ->
    _then = performance.now()
    skip = 512
    pixdata = @capture.texture.getPixels()
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




window.Calligraph = Calligraph
