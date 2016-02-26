class Calligraph extends CalligraphBase
  constructor: ()->
    super

  subinit: ()->
    #hello!
    console.log 'Calligraph "Animated Particles" init'


    #see CalligraphBase for the actual pixi_init function
    renderer_config = {
      "clearBeforeRender": true
      "preserveDrawingBuffer": true
      "transparent": true
    }
    @pixi_init renderer_config
    @moog_init()
    @pixi_begin()



  ###
  #
  # Respond to mouse events
  #
  ###

  on_mousedown: (e) =>
    @last_click = performance.now()
    @chime_active = true
    @chimes.trigger_play()
    @emitter.emit = true
    #@n.kalimba.start()
#     @n.saw2.start()
#     @n.saw3.start()

  on_mouseup: (e) =>
    @emitter.emit = false
    @chime_active = false
    #@testnode.stop()
    #@n.kalimba.stop()
#     @n.saw2.stop()
#     @n.saw3.stop()

  on_mousemove: (m)->
    @velocity = Math.min(@velocity + m.vel, @velocity_max)





  ###
  #
  # Set up Mooog
  #
  ###

  moog_init: ()->

    @m.track 'saw_track',
      @m.node
        id: "kalimba"
        node_type: "AudioBufferSource"
        buffer_source_file: "sound/fake-glock-res-F.wav", loop: true
#       @m.node
#         id: 'saw1'
#         node_type: 'Oscillator'
#         type: 'sawtooth'
#         frequency: 100
      @m.node
        id: 'filt'
        node_type: 'BiquadFilter'
        type: 'highpass'
        frequency: 100
        Q: 1.0
      @m.node
        id: 'comp'
        node_type: 'DynamicsCompressor'
        threshold: -50
        knee: 40
        ratio: 12
        reduction: -20
        attack: 0
        release: 0.25

    @m.track 'verb_track',
      @m.node
        id: 'verb'
        node_type: 'Convolver'
        buffer_source_file: 'sound/impulse-responses/st-andrews-church-ortf-shaped.wav'
    .param('gain',1)

    @m.track 'del_track1',
      @m.node
        id: 'del1'
        node_type: 'Delay'
        delayTime: 0.03
        feedback: 0.0
      @m.node
        id: 'del1_filt'
        node_type: 'BiquadFilter'
        type: 'lowpass'
        frequency: 1200
        Q: 5.0
    .param('gain',0.5)



#     @m.node
#       id: 'master'
#       node_type: 'Gain'
#       gain: 0
#     @m.node
#       id: 'delay1'
#       node_type: 'Delay'
#       delayTime: 0.5
#       feedback: 0.25
    @n = @m._nodes
    @n.saw_track.send 'rev_send', @n.verb_track, 'pre'
    @n.saw_track.send 'del1_send', @n.del_track1, 'pre'
    @n.saw_track.send 'del1_send', @n.verb_track, 'post'

    @chimes = new Windchime(@m, [
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
      "sound/fake-glock-res-F.mp3"
    ])

    console.log @n.verb_track
    @chimes.master_out.connect @n.verb_track._nodes[0]
    @chimes.master_out.connect @n.del_track1._nodes[0]









#     @n.saw1.chain(@n.master)
#     @n.master.connect(@n.verb)
    #@n.comp.chain(@n.master)



    @velocity = 0
    @velocity_loss = 0.01
    @velocity_max = 4



    null



  ###
  #
  # Set up PIXI stuff particular to this page
  #
  ###


  pixi_begin: () ->

    imagePaths = ["images/small-white-line.png"]

    particle_config = {
      "alpha":
      	"start": 0.62
      	"end": 0
      "scale":
      	"start": 1
      	"end": 1
      "color":
      	"start": "FF0000"
      	"end": "000000"
      "speed":
      	"start": 100
      	"end": 0
      "startRotation":
      	"min": 0
      	"max": 360
      "rotationSpeed":
      	"min": 0
      	"max": 1
      "lifetime":
      	"min": 1
      	"max": 1
      "frequency": 0.003
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







    # N.B. Filters defined here may or may not be used.
    blur = new PIXI.filters.BlurFilter()
    blur.blur = 5
    blur2 = new PIXI.filters.BlurFilter()
    blur2.blur = 2
    bloom = new PIXI.filters.BloomFilter()
    bloom.blur = 1
    #noise = new PIXI.filters.NoiseFilter()
    #noise.noise = -0.1
    #rgbsplit = new PIXI.filters.RGBSplitFilter()
    #@pxl8 = new PIXI.filters.PixelateFilter()
    #@pxl8.size = {x:5,y:5}
    #edge = new PIXI.filters.ConvolutionFilter([
    #  -1, -1, -1
    #  -1,  8, -1
    #  -1, -1, -1
    #], window.innerWidth, window.innerHeight  )
    white_surrounded = new PIXI.filters.ConvolutionFilter([
      0.125, 0.125, 0.125
      0.125,  0, 0.125
      0.125, 0.125, 0.125
    ], window.innerWidth, window.innerHeight  )

    #brightness_to_alpha = new PIXI.filters.ColorMatrixFilter()
    #brightness_to_alpha.matrix = [
    #  1, 0, 0, 0, 0
    #  0, 1, 0, 0, 0
    #  0, 0, 1, 0, 0
    #  1, 1, 1, 0, 0
    #]
    #
    #blue = new PIXI.filters.ColorMatrixFilter()
    #blue.matrix = [
    #  0, 0, 0, 0, 0
    #  0, 0, 0, 0, 0
    #  0, 0, 1, 0, 0
    #  0, 0, 0, 0, 0
    #]
    # this filter isolates pure white
    thresh = new PIXI.filters.ColorMatrixFilter()
    thresh.matrix = [
      100, 100, 100, 0, -299
      100, 100, 100, 0, -299
      100, 100, 100, 0, -299
      100, 100, 100, 0, -299
    ]
    #colorstep = new PIXI.filters.ColorStepFilter()
    #colorstep.step = 1




    #Sprite for the text reveal effect
    @halo = new PIXI.Sprite()
    @halo.width = @canvas_width
    @halo.height = @canvas_height
    @halo.filters = [ thresh ]
    @haloTexture = new PIXI.RenderTexture(@pixi.r, @canvas_width, @canvas_height)
    @halo.texture = @haloTexture


    @text_sprite = new PIXI.Text 'This knife is as long as my wife in the pool\n
    and I am as dark as the sun\n
    The silence from the moon is as dark when we sleep\n\n
    I always bring my captives here\n
    and let the grapevines choke them',
      font: "#{Math.floor(window.innerWidth*@canvas_scale_factor/40)}px Noto Serif"
      fill: 0x7E9EA8
      align: 'left'
      wordWrap: false

    # The pixelate filter produces nothing when used at the end of a filter chain on halo, for some reason.
    # For example [ edge, bloom, @pxl8] doesn't work but [edge, bloom] does.
    # Maddeningly, the pixelate filter produces the desired effect when used on stage on its own.

    @haloContainer = new PIXI.Container()
    @haloContainer.addChild @halo
    @haloContainer.position = {x: 0, y: 0}
    #@haloContainer.filters = [ thresh ]
    #@stage.addChild @text_sprite
    #@text_sprite.position = { x: 300 / @canvas_scale_factor, y:  250 / @canvas_scale_factor}
    #@text_sprite.filters = [blur2]


    #@r1 = 0.0
    #@render_recursive_halo = @create_recursive_render @haloContainer, 'capture2', 'r1', false
    #@text_sprite.mask = @capture2
    #@haloContainer.alpha = 0.9

    #@render_recursive_halo = ()->
    #  null
    #@stage.addChild @haloContainer


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

    #container to hold the capture sprite and be used as the render source for the recursive filter
    @feedback = new PIXI.Container()
    @stage.addChild @feedback

    # Create the recursive filter round robin function for @feedback
    @render_recursive_stage = @create_recursive_render @feedback, 'capture', 'capture_alpha',  true


#
#
#     @capture.filters = [
#       blur
#       #@pxl8
#       #bd
#       bloom
#     ]


    randomTexture = (textures, times)->
      ret = []
      for i in [1..times]
        textures.shuffle()
        ret.push
          texture: textures[0]
          count: Math.round(Math.random() * 10)
      ret



    art = [
      { framerate: "matchLife"
      loop: false
      textures: randomTexture([
        "images/spark_40x40.png"
        "images/spark_40x40_m.png"
        "images/spark_40x40_s.png"
        ], 30)
      }
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

    requestAnimationFrame @animate

    elapsed = timeval - @last_timeval
    @framerate_val.text( Math.round( 1000 / elapsed ) )
    #@white_pix_per.call this unless( @total_frames++ % 5 )
    @last_timeval = timeval
    @velocity = Math.max(0, @velocity - (@velocity_loss * elapsed))





    #@pointer.rotation += 0.01


    mousedata = @mousedata
    duration = performance.now() - @last_click

    pulse = Math.sin((Math.PI * (duration/500)) + (Math.PI/4))
    if @chime_active
      if(Math.random() < ((pulse * 0.15) + 0 ))
        @chimes.trigger_play()
    @emitter.maxLifetime = pulse * 4
    #looks like alpha is actually on a modulo
    @emitter.startAlpha = pulse
    r = @clamp((@canvas_height * 0.8) - mousedata.lastY, 0, @canvas_height, 70, 255)
    g = @clamp(0, (@canvas_height * 0.8) - mousedata.lastY, @canvas_height, 70, 255)
    @emitter.startColor = [r, g, 150]
    @emitter.endColor = [r, g, 150]
    @emitter.updateOwnerPos(mousedata.curX,mousedata.curY)
    @emitter.update(elapsed * 0.001)


    #console.log "gain #{mousedata.vel} to "+ (@clamp(mousedata.vel, 0, 0.1, 0, 1))
    @n.saw_track.param(
      #gain: 0.2 + @clamp(mousedata.velX, -2, 2, -0.3, 0.3)
      { gain: 1 - Math.abs @clamp(mousedata.lastX, 0, @canvas_width, -1.0, 1.0)
      ramp:'expo'
      at: 0.1
      from_now: true }
      ).param(
      { pan: @clamp(mousedata.lastX, 0, @canvas_width, -1.0, 1.0)
      ramp:'linear'
      at: 0.1
      from_now: true }
      )
    @n.filt.param(
      { frequency: Math.abs @clamp(mousedata.lastX, 0, @canvas_width, -1000, 1000)
      ramp:'linear'
      at: 0.1
      from_now: true }
      )




    @pixi.r.render @stage
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
