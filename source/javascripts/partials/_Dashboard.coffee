class Dashboard

  constructor: () ->
    @mouseactive = false
    @mousedown = false
#     @mousedata =
#       last_timestamp: Date.now()
#       timestamp: Date.now()
#       lastX: 0
#       lastY: 0
#       curX: 0
#       curY: 0
#       velX: 0
#       velY: 0
#       vel: 0
#       last_velX: 0
#       last_velY: 0
#       last_vel: 0
#       velX_dX: 0
    @dX_decay = 1
    @cgraph =
      on_mousedown : $.noop
      on_mouseup : $.noop
      on_mousemove : $.noop
    $(document).ready( @init )

  init: () =>
    $(document).on 'mouseenter', 'canvas', @mouseenter
    $(document).on 'mouseleave', 'canvas', @mouseleave
    $(document).on 'mousedown', 'canvas', @mdown
    $(document).on 'mouseup', 'canvas', @mup
    $(document).on 'mousemove', 'canvas', @update_mousedata

    @display =
      velX: $("#display #velX span.contain span")
      velY: $("#display #velY span.contain span")
      vel: $("#display #vel span.contain span")
      xPos: $("#display #xPos span.val")
      yPos: $("#display #yPos span.val")
      velX_dX: $("#display #velX_dX span.contain span")
      velY_dX: $("#display #velY_dX span.contain span")
      mouseactive: $("#display #mouseactive span.val")
      mousedown: $("#display #mousedown span.val")
    @display_interval = setInterval(@update_display, 50)
    @update_interval = setInterval(@update, 10)

  mouseenter: (e) =>
    @update_mousedata(e)
    @mouseactive = true

  mouseleave: (e) =>
    @update_mousedata(e)
    @mouseactive = false
    if @mousedown
      @cgraph.on_mouseup(e)
      @mousedown = false

  mdown: (e) =>
    @update_mousedata(e)
    @mousedown = true
    @cgraph.on_mousedown(e)

  mup: (e) =>
    @update_mousedata(e)
    @mousedown = false
    @cgraph.on_mouseup(e)

  update: () =>
    @mousedata.velX_dX -= @dX_decay
    @mousedata.velX_dX = 0 unless @mousedata.velX_dX >= 0
    if @mouseactive and @mousedown
      @cgraph.on_mousemove(@mousedata)
    null

  update_mousedata: (e) =>
    @mousedata.timestamp = Date.now()
    elapsed = @mousedata.timestamp - @mousedata.last_timestamp
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
    @mousedata.last_timestamp = @mousedata.timestamp
    null


  update_display: () =>
    d = @display
    m = @mousedata
    d.velX.height(@scale_perc m.velX, 2)
    d.velY.height(@scale_perc m.velY, 2)
    d.vel.height(@scale_perc m.vel, 2)
    d.velX_dX.height(@scale_perc m.velX_dX, 5)
    d.velY_dX.height(@scale_perc m.velY_dX, 5)
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


window.Dashboard = Dashboard
