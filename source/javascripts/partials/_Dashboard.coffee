class Dashboard

  constructor: (calli) ->
    @calli = calli
    @mousedata = calli.mousedata
    @mouseactive = false
    @mousedown = false
    @key_callbacks = {}
    $(document).ready( @init )

  init: () =>
    $(document).on 'mouseenter', 'canvas', @mouseenter
    $(document).on 'mouseleave', 'canvas', @mouseleave
    $(document).on 'mousedown', 'canvas', @mdown
    $(document).on 'mouseup', 'canvas', @mup
    $(document).on 'keypress', @key

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
      padded_vel: $("#display #padded_vel span.val")
    @display_interval = setInterval(@update_display, 200)

  key: (e) =>
    switch e.which
      when 113 #q
        @calli.pixi.r.destroy()
      else
        @key_callbacks[e.which]() if @key_callbacks[e.which]?

  add_key: (f, k) ->
    @key_callbacks[k] = f.bind @calli


  mouseenter: (e) =>
    @mouseactive = true

  mouseleave: (e) =>
    @mouseactive = false
    if @mousedown
      @mousedown = false

  mdown: (e) =>
    @mousedown = true


  mup: (e) =>
    @mousedown = false


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
    d.padded_vel.text(@round_sig2 @calli.velocity)

  round_sig2: (n) ->
    Math.round(n * 100) / 100

  scale_perc: (x, max) ->
    ((x / max) * 100) + "%"


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
