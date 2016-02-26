#= require Proton/build/proton-1.0.0.js

class Calligraph extends CalligraphBase
  constructor: ()->
    super

  subinit: ()->
    #hello!
    console.log 'Calligraph "Emitters II" init'


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
    @_mousedown = true
    i.emit() for i in @sub_emitters
    @attractionBehaviour.reset(@emitter.p, 10, 1200)
    #@n.kalimba.start()
#     @n.saw2.start()
#     @n.saw3.start()

  on_mouseup: (e) =>
    @_mousedown = false
    i.stopEmit() for i in @sub_emitters
    @attractionBehaviour.reset(@emitter.p , 0, 0)

    #@testnode.stop()
    #@n.kalimba.stop()
#     @n.saw2.stop()
#     @n.saw3.stop()

  on_mousemove: (m)->
    @velocity = Math.min(@velocity + m.vel, @velocity_max)
    @emitter.p.x = m.curX
    @emitter.p.y = m.curY




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


    @chimes.master_out.connect @n.verb_track._nodes[0]
    @chimes.master_out.connect @n.del_track1._nodes[0]



    @velocity = 0
    @velocity_loss = 0.01
    @velocity_max = 4



    null



  ###
  #
  # Set up PIXI and Proton
  #
  ###


  pixi_begin: () ->



#     @halo = new PIXI.Sprite()
#     @halo.width = @canvas_width
#     @halo.height = @canvas_height
#
#     @haloTexture = new PIXI.RenderTexture(@pixi.r, @canvas_width, @canvas_height)
#     @halo.texture = @haloTexture
#
#
#
#
#     @haloContainer = new PIXI.Container()
#     @haloContainer.addChild @halo
#     @haloContainer.position = {x: 0, y: 0}



    #container to hold the capture sprite and be used as the render source for the recursive filter
    @feedback = new PIXI.Container()
    @stage.addChild @feedback

    # Create the recursive filter round robin function for @feedback
    @render_recursive_stage = @create_recursive_render @feedback, 'capture', 'capture_alpha',  true, 0.03






    @proton = new Proton()
    @emitter = new Proton.BehaviourEmitter()
    #@emitter.rate = new Proton.Rate(new Proton.Span(15, 30), new Proton.Span(0.2, 0.5))
    @emitter.rate = new Proton.Rate(100)

    @emitter.addInitialize(new Proton.Mass(1))
    @emitter.addInitialize(new Proton.Velocity(1.5, new Proton.Span(0,359), 'polar'))
    @emitter.addBehaviour(new Proton.Color('random'))
    @attractionBehaviour = new Proton.Attraction( @emitter.p , 0, 0)
    @crossZoneBehaviour = new Proton.CrossZone(new Proton.RectZone(0, 0, @canvas_width, @canvas_height), 'cross')
    $(window).on 'resize', ()=>
      @crossZoneBehaviour.reset(new Proton.RectZone(0, 0, @canvas_width, @canvas_height), 'cross')
    @emitter.addBehaviour(@attractionBehaviour, @crossZoneBehaviour)


    #@emitter.addInitialize(new Proton.Life(1,1))
    #@emitter.addBehaviour(new Proton.Gravity(1))
    #@emitter.addBehaviour(new Proton.Scale(new Proton.Span(1, 3), 0.3))
    #@emitter.addBehaviour(new Proton.Alpha(1, 0.5))
    #@emitter.addBehaviour(new Proton.Rotate(0, Proton.getSpan(-8, 9), 'add'))

    #unsure about selfBehavior
    #@emitter.addSelfBehaviour(new Proton.Gravity(5))
    #@emitter.addSelfBehaviour(new Proton.RandomDrift(10, 10, 0))
    #@emitter.addSelfBehaviour(new Proton.CrossZone(new Proton.RectZone(50, 0, 953, 610), 'bound'))


    @emitter.p.x = @canvas_width / 2
    @emitter.p.y = @canvas_height / 2


    @emitter.emit('once')



    @proton.addEmitter(@emitter)

    @sub_emitters = []

    @proton_renderer = new Proton.Renderer('other', @proton)

    @proton_renderer.onProtonUpdate = ()->


    single_white_pixel = PIXI.Texture.fromImage("images/single_white_pixel.png")
    @proton_renderer.onParticleCreated = (particle,b,c) =>
      tint = parseInt(particle.color.substr(1),16)
      graphics = new PIXI.Graphics()
      graphics.tint = tint
      circle = new PIXI.Sprite()
      circle.texture = single_white_pixel
      circle.tint = tint
      particle.graphics = graphics
      particle.circle = circle
      @feedback.addChild(particle.graphics)
      @feedback.addChild(particle.circle)
      graphics.moveTo(particle.p.x, particle.p.y)
      circle.position = {x: particle.p.x, y: particle.p.y}


      #make a sub-emitter
      if particle.parent.id is "emitter_0"
        sub = new Proton.BehaviourEmitter()
        sub.rate = new Proton.Rate(new Proton.Span(3), new Proton.Span(1.5,3))
        sub.addInitialize(new Proton.Velocity(0.5, new Proton.Span(0,359), 'polar'))
        sub.addInitialize(new Proton.Life(0.5,2))
        sub.addBehaviour(new Proton.Color(particle.color))
        sub.addBehaviour(new Proton.Alpha(0.5,0))
        @sub_emitters.push sub
        @proton.addEmitter sub
        particle.sub_emitter = sub
        particle.sub_emitter.p = particle.p
        particle.sub_emitter.v = particle.v



    @proton_renderer.onParticleUpdate = (particle) =>

      #both main and sub


      #console.log particle.color.substr(1) unless( @total_frames % 60 )
      #tint = parseInt(particle.color.substr(1),16)
      particle.graphics.clear()
      particle.graphics.lineStyle(1.5, 0xFFFFFF, 1)
      #particle.graphics.tint = tint
      particle.graphics.alpha = particle.alpha
      #console.log particle.v.x
      #console.log "y is #{particle.p.y} oldy is #{particle.old.p.y} delta is #{Math.abs(particle.old.p.y - particle.p.y)} canvas height is #{@canvas_height}"
      if(
        Math.sign(particle.old.p.x) isnt -1 and
        particle.old.p.x <= @canvas_width and
        Math.sign(particle.old.p.y) isnt -1 and
        particle.old.p.y <= @canvas_height
      )
        particle.graphics.lineTo(particle.p.x, particle.p.y)
      else
        particle.graphics.moveTo(particle.p.x, particle.p.y)


      #particle.circle.tint = tint
      particle.circle.position = {x: particle.p.x, y: particle.p.y}




    @proton_renderer.onParticleDead = (particle) =>
      @feedback.removeChild(particle.graphics)
      @feedback.removeChild(particle.circle)

    @proton_renderer.start();
    @emitter._listeners.partilcleUpdate.push (a) ->
      #console.log a.particle.p



    blur = new PIXI.filters.BlurFilter()
    blur.blur = 4
    blur.passes = 2
    bloom = new PIXI.filters.BloomFilter()
    bloom.blur = 1





    @capture.filters = [
      blur
    ]



    @dashboard?.add_keydown @white_pix_per, 109


    #clean this experiment
    @framerate_val = $("#framerate .val")
    @capture_alpha_val = $("#capture_alpha .val")
    @capture_alpha = 0.95
    @capture_alpha_val.text( @capture_alpha )
    @total_frames = 0 #ticker for white pixel eval
    setInterval @framerate_update, 1000
    requestAnimationFrame @animate



  framerate_update: ()=>
    return unless @dashboard?
    @this_time = performance.now()
    if(!@last_time?)
      @last_time = @this_time
      return
    @framerate_val.text Math.round( @frames_since_last / ((@this_time - @last_time) / 1000) )
    @last_time = @this_time
    @frames_since_last = 0

  animate: (timeval) =>
    @frames_since_last += 1
    requestAnimationFrame @animate
    @render_recursive_stage()
    elapsed = timeval - @last_timeval
    @total_frames += 1
    #@white_pix_per.call this unless( @total_frames % 5 )
    @last_timeval = timeval
    @velocity = Math.max(0, @velocity - (@velocity_loss * elapsed))





    #@pointer.rotation += 0.01


    mousedata = @mousedata
    duration = performance.now() - @last_click

    pulse = Math.sin((Math.PI * (duration/500)) + (Math.PI/4))



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




    @proton.update() #unless (@total_frames % 10)
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
