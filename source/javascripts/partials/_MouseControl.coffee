class MouseControl

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
      lastVelX: 0
      lastVelY: 0
      velX_dX: 0
      velY_dX: 0
    @cgraph =
      on_mousedown : $.noop
      on_mouseup : $.noop
      on_mousemove : $.noop
    $(document).ready( @init )

  init: () =>
    $(document).on 'mouseenter', 'div.canvas', @mouseenter
    $(document).on 'mouseleave', 'div.canvas', @mouseleave
    $(document).on 'mousedown', 'div.canvas', @mdown
    $(document).on 'mouseup', 'div.canvas', @mup
    $(document).on 'mousemove', 'div.canvas', @throttle(@update_position, 50)

    @display =
      velX: $("#display #velX span.contain span")
      velY: $("#display #velY span.contain span")
      xPos: $("#display #xPos span.val")
      yPos: $("#display #yPos span.val")
      velX_dX: $("#display #velX_dX span.contain span")
      velY_dX: $("#display #velY_dX span.contain span")
      mouseactive: $("#display #mouseactive span.val")
      mousedown: $("#display #mousedown span.val")
    @display_interval = setInterval(@update_display, 50)
    @update_interval = setInterval(@update, 25)

  mouseenter: (e) =>
    @last_action = new Date().getTime()
    @mouseactive = true

  mouseleave: (e) =>
    @mouseactive = false
    if @mousedown
      @cgraph.on_mouseup(e)
      @mousedown = false

  mdown: (e) =>
    @mousedown = true
    @cgraph.on_mousedown(e)

  mup: (e) =>
    @mousedown = false
    @cgraph.on_mouseup(e)

  update: () =>
    m = @mousedata
    if @mouseactive and @mousedown
      now = new Date().getTime()
      elapsed = (now - m.last_action)
      deltaX = Math.abs m.lastSampleX - m.lastX
      deltaY = Math.abs m.lastSampleY - m.lastY
      m.velX = deltaX/elapsed
      m.velY = deltaY/elapsed
      m.velX_dX = m.velX - m.last_velX
      m.velY_dX = m.velY - m.last_velY
      m.last_action = now
      m.last_velX = m.velX
      m.last_velY = m.velY
      @cgraph.on_mousemove(m)
    m.lastSampleX = m.lastX
    m.lastSampleY = m.lastY
    null

  update_position: (e) =>
    @mousedata.lastX = e.offsetX
    @mousedata.lastY = e.offsetY



  update_display: () =>
    d = @display
    m = @mousedata
    d.velX.height(@scale_perc m.velX, 2)
    d.velY.height(@scale_perc m.velY, 2)
    d.velX_dX.height(@scale_perc m.velX_dX, 3)
    d.velY_dX.height(@scale_perc m.velY_dX, 3)
    d.xPos.text(@round_sig2 m.lastX)
    d.yPos.text(@round_sig2 m.lastY)
    d.mousedown.text(if @mousedown then 'true' else false)
    d.mouseactive.text(if @mouseactive then 'true' else false)

  round_sig2: (n) ->
    Math.round(n * 100) / 100

  scale_perc: (x, max) ->
    ((x / max) * 100) + "%"

  start_calligraph: (calligraph) ->
    @cgraph = calligraph

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


window.MouseControl = MouseControl
