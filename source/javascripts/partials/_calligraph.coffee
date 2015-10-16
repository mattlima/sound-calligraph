class Calligraph

  constructor: () ->
    @inertias =
      vel1: 0
      vel2: 0
    @m = new Mooog
    @init()

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
      id: 'master'
      node_type: 'Gain'
      gain: 0
    @m.node
      id: 'delay1'
      node_type: 'Delay'
      delayTime: 0.5
      feedback: 0.25
    @n = @m._nodes

    @n.saw1.chain(@n.master).connect(@n.delay1)


  on_mousedown: (e) =>
    console.log 'calli mousedown'
    @n.saw1.start()

  on_mouseup: (e) =>
    console.log 'calli mouseup'
    @n.saw1.stop()

  on_mousemove: (data) =>
    #console.log "gain #{data.vel} to "+ @clamp(data.vel, 0, 3, 0, 1)
    @n.master.param
      #gain: 0.2 + @clamp(data.velX, -2, 2, -0.3, 0.3)
      gain: @inertia(@clamp(data.vel, 0, 3, 0, 1))
      ramp:'expo'
      at: 0.1
      from_now: true



window.Calligraphs =
  TC: TC
