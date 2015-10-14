class Calligraph

  constructor: () ->
    @mouseactive = false
    @mousedown = false
    @mousedata =
      last_action: new Date().getTime()
      lastX: 0
      lastSampleX: 0
      lastY: 0
      lastSampleY: 0
      velX: 0
      velY: 0
    $(document).ready( @init )

  init: () =>
    $(document).on 'mouseenter', 'div.canvas', @mouseenter
    $(document).on 'mouseleave', 'div.canvas', @mouseleave
    $(document).on 'mousedown', 'div.canvas', @mdown
    $(document).on 'mouseup', 'div.canvas', @mup
    $(document).on 'mousemove', 'div.canvas', @throttle(@update_position, 50)

    @display =
      velX: $("#display #velX span.val")
      velY: $("#display #velY span.val")
      xPos: $("#display #xPos span.val")
      yPos: $("#display #yPos span.val")
      mouseactive: $("#display #mouseactive span.val")
      mousedown: $("#display #mousedown span.val")
    @display_interval = setInterval(@update_display, 500)
    @update_interval = setInterval(@update, 50)

  mouseenter: (e) =>
    @last_action = new Date().getTime()
    @mouseactive = true

  mouseleave: (e) =>
    @mouseactive = false
    @mousedown = false

  mdown: (e) =>
    @mousedown = true

  mup: (e) =>
    @mousedown = false

  update: () =>
    m = @mousedata
    if @mouseactive and @mousedown
      now = new Date().getTime()
      elapsed = (now - m.last_action)
      deltaX = m.lastSampleX - m.lastX
      deltaY = m.lastSampleY - m.lastY
      m.velX = deltaX/elapsed
      m.velY = deltaY/elapsed
      m.last_action = now
    m.lastSampleX = m.lastX
    m.lastSampleY = m.lastY
    null

  update_position: (e) =>
    @mousedata.lastX = e.offsetX
    @mousedata.lastY = e.offsetY



  update_display: () =>
    d = @display
    m = @mousedata
    d.velX.text(@round_sig2 m.velX)
    d.velY.text(@round_sig2 m.velY)
    d.xPos.text(@round_sig2 m.lastX)
    d.yPos.text(@round_sig2 m.lastY)
    d.mousedown.text(if @mousedown then 'true' else false)
    d.mouseactive.text(if @mouseactive then 'true' else false)

  round_sig2: (n) ->
    Math.round(n * 100) / 100

  throttle: (func, delay) ->
    o =
      throt_timeout: false
      dofun: ()->
        @throt_timeout = false
        func.apply(this, arguments[0])
      setup:() ->
        if !@throt_timeout
          @throt_timeout = setTimeout(@dofun.bind(this, arguments), delay)
    o.setup.bind o


window.C = new Calligraph
