class Calligraph

  constructor: () ->
    #DOM
    @document = $(document)

    # initialize libraries
    @m = new Mooog
    # holder for pixi-related stuff
    @pixi = {}
    @pixi_init()
    @last_timeval = 0
    @telapsed = 0

    @vel1 = 0
    @vel2 = 0

    # The subclass-specific init function
    @init()

    #Initialize mouse information
    @mousedata =
      last_timestamp: Date.now()
      timeStamp: Date.now()
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

    @document.on 'mousemove', @update_mousedata

    @last_timeval = performance.now()
    requestAnimationFrame @animate

  # constrains val to within inmin < val < inmax and then scales it to the interval outmin-outmax
  clamp: (val, inmin, inmax, outmin, outmax) ->
    val = inmin if val < inmin
    val = inmax if val > inmax
    ((val - inmin) / (inmax - inmin)) * (outmax - outmin) + outmin


  inertia: (val) ->
    r = (val + @vel1 + @vel2) / 3
    @vel2 = @vel1
    @vel1 = val
    r

  pixi_init: () ->
    @pixi.s = new PIXI.Container()

    window_width = $(window).width()
    @canvas_height =  0.66 * window_width
    @canvas_width = window_width
    canvas = document.getElementById("canvas");
    @pixi.r = PIXI.autoDetectRenderer(@canvas_width, @canvas_height, {view: canvas})


    texture = PIXI.Texture.fromImage("/images/imgres.jpg")
    #@pointer = new PIXI.Sprite(texture)
    @pointer = new PIXI.Container()


#     @pointer.anchor.x = 0.5
#     @pointer.anchor.y = 0.5

    @pointer.position.x = 200
    @pointer.position.y = 150

    @pixi.s.addChild(@pointer)


    @pixi.s.interactive = true
    @pixi.s.mousedown = @on_mousedown
    @pixi.s.mouseup = @on_mouseup
    @document.on 'mouseleave','canvas',@on_mouseup

  update_mousedata: (e) =>
    elapsed = e.timeStamp - @mousedata.last_timestamp
    @mousedata.curX = e.offsetX
    @mousedata.curY = e.offsetY
    deltaX = @mousedata.curX - @mousedata.lastX
    deltaY = @mousedata.curY - @mousedata.lastY
    @mousedata.velX = deltaX / elapsed
    @mousedata.velY = deltaY / elapsed
    @mousedata.last_vel = @mousedata.vel
    @mousedata.vel = Math.sqrt(Math.pow(@mousedata.velX,2) + Math.pow(@mousedata.velY,2))
    if @mousedata.velX_dX < 5
      @mousedata.velX_dX += Math.abs(@mousedata.vel - @mousedata.last_vel)


    @mousedata.lastX = e.offsetX
    @mousedata.lastY = e.offsetY
    @mousedata.last_timestamp = e.timeStamp
    null


  animate: (timeval) =>
    elapsed = timeval - @last_timeval
    #check that mouse has moved in last n milliseconds, if not,
    #trigger a fake mouse event so vel is zero

    if (Date.now() - @mousedata.last_timestamp) > 300
      #console.log "zeroing", @mousedata.last_timestamp
      @update_mousedata
        timeStamp: Date.now()
        offsetX: @mousedata.lastX
        offsetY: @mousedata.lastY




    #@pointer.rotation += 0.01
    @pixi.r.render @pixi.s
    @on_mousemove(@mousedata, elapsed)
    requestAnimationFrame @animate
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
      type: 'square'
      frequency: 100
    @m.node
      id: 'saw2'
      node_type: 'Oscillator'
      type: 'square'
      frequency: 100
    @m.node
      id: 'saw3'
      node_type: 'Oscillator'
      type: 'square'
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
      id: 'master'
      node_type: 'Gain'
      gain: 0
    @m.node
      id: 'delay1'
      node_type: 'Delay'
      delayTime: 0.5
      feedback: 0.25
    @n = @m._nodes

    #@n.saw1.chain(@n.master)
    #@n.saw2.chain(@n.master)
    #@n.saw3.chain(@n.master)
    #@n.comp.chain(@n.master)


    @pixi.line_emitter = new cloudkid.Emitter(
      @pointer
      [PIXI.Texture.fromImage('/images/small-white-line.png')]
      {
        "alpha": {
          "start": 0.8,
          "end": 0.1
        },
        "scale": {
          "start": 1,
          "end": 0.3
        },
        "color": {
          "start": "fb1010",
          "end": "f5b830"
        },
        "speed": {
          "start": 200,
          "end": 100
        },
        "startRotation": {
          "min": 0,
          "max": 360
        },
        "rotationSpeed": {
          "min": 0,
          "max": 0
        },
        "lifetime": {
          "min": 0.5,
          "max": 0.5
        },
        "frequency": 0.008,
        "emitterLifetime": 0.31,
        "maxParticles": 1000,
        "pos": {
          "x": 0,
          "y": 0
        },
        "addAtBack": false,
        "spawnType": "circle",
        "spawnCircle":
          "x": 0,
          "y": 0,
          "r": 10
      })
    @pixi.line_emitter.emit = true
    @pixi.line_emitter.resetPositionTracking()
    null



  on_mousedown: (e) =>
    console.log 'start'
    @n.saw1.start()
    @n.saw2.start()
#     @n.saw3.start()

  on_mouseup: (e) =>
    @n.saw1.stop()
    @n.saw2.stop()
#     @n.saw3.stop()

  on_mousemove: (data, elapsed) =>


    @pixi.line_emitter.update(elapsed * 0.001);
    #console.log "gain #{data.vel} to "+ @inertia(@clamp(data.vel, 0, 3, 0, 1))
    @n.master.param
      #gain: 0.2 + @clamp(data.velX, -2, 2, -0.3, 0.3)
      gain: @inertia(@clamp(data.vel, 0, 0.1, 0, 1))
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
    @pointer.position.x = data.lastX
    @pointer.position.y = data.lastY



window.Calligraphs =
  TC: TC
