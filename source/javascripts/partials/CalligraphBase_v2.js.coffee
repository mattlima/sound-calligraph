###

  Calligraph common module v2

  Responsibilities:
    Hold DOM references
    Initialize Mooog
    Keep mousedata object updated
    Call subclass init
    Provide utility functions

  Work in v2 is dedicated the mouse tracking code.
  Mouse events come at unpredictable times and can
  cause huge deltas in derived variables so we add
  a smoothing algo


###
class CalligraphBase

  constructor: (config) ->
    config ?= {}
    config?.dashboard ?= true
    @config = config

    #retain useful DOM refs
    @document = $(document)



  #for now, we're dealing with performance issues by using resolution scaling on
  #larger screens. Mouse coordinates will need to be adjusted by the scaling
  #factor as well.
  MAX_CANVAS_WIDTH: 1200
  DASHBOARD_HEIGHT: 120

  init: ()->

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
    @dashboard = new Dashboard(this) if @config.dashboard


    # keep mousedata current for inheriting classes
    @document.on 'mousemove', 'canvas', @update_mousedata

    # The subinit function is supplied by the inheriting class
    @subinit()


  # constrains val to within inmin < val < inmax and then scales it to the interval outmin-outmax
  clamp: (val, inmin, inmax, outmin, outmax) ->
    val = inmin if val < inmin
    val = inmax if val > inmax
    ((val - inmin) / (inmax - inmin)) * (outmax - outmin) + outmin



  update_mousedata: (e) =>
    now = performance.now()
    elapsed = now - @last_mouse_update
    @last_mouse_update = now
    e.offsetX *= @canvas_scale_factor
    e.offsetY *= @canvas_scale_factor
    @mousedata.curX = e.offsetX
    @mousedata.curY = e.offsetY
    deltaX = @mousedata.curX - @mousedata.lastX
    deltaY = @mousedata.curY - @mousedata.lastY
    @mousedata.velX = deltaX / elapsed
    @mousedata.velY = deltaY / elapsed
    @mousedata.last_vel = @mousedata.vel
    @mousedata.vel = Math.sqrt( @mousedata.velX * @mousedata.velX + @mousedata.velY * @mousedata.velY )
    @mousedata.lastX = e.offsetX
    @mousedata.lastY = e.offsetY

    #supplied by subclass
    @on_mousemove(@mousedata)

    null


  #
  #
  # The stage is always used so it is managed here.
  # Because the dimensions of the stage are incorporated into
  # the sprites made by the recursive setup functions
  # we can't allow resizes... sorry!
  #
  #
  pixi_init: (renderer_config)=>


    @pixi = {}

    @canvas_width = @get_canvas_width()
    @canvas_height = @get_canvas_height()

    @pixi.r = new PIXI.WebGLRenderer(@canvas_width, @canvas_height, renderer_config)

    @canvas = @pixi.r.view
    $('body').prepend @pixi.r.view


    @stage = new PIXI.Container()


    @document.on 'mouseleave', 'canvas', @on_mouseup
    @document.on 'mousedown', 'canvas', @on_mousedown
    @document.on 'mouseup', 'canvas', @on_mouseup


    null


  #
  #
  # Returns the width/height of the window unless larger than MAX_CANVAS_WIDTH
  # in which case it is scaled down
  #

  get_canvas_width: ()->
    ww = window.innerWidth
    if ww <= @MAX_CANVAS_WIDTH
      @canvas_scale_factor = 1
      return ww
    @canvas_scale_factor = (@MAX_CANVAS_WIDTH / ww)
    @MAX_CANVAS_WIDTH


  get_canvas_height: ()->
    DASH_HEIGHT = if @dashboard? then @DASHBOARD_HEIGHT else 0
    @canvas_scale_factor * (window.innerHeight - DASH_HEIGHT)
    (window.innerHeight - DASH_HEIGHT)

  ###
    In order to do recursive filter effects, we have to use a round-robin rendering process, otherwise
    the chain of objects being rendered into the sprite contains the texture itself and throws a GL error.
    This function returns a function to be called in animate() that swaps the textures every other frame
    and renders. targetSprite can be a sprite or a container.
  ###
  create_recursive_render: (targetSprite, secondary_sprite_name, alpha_control_property, clearBeforeRendering) =>
    @recursive_id ?= 0
    #the recursive filter requires a base sprite to render into
    @[secondary_sprite_name] = new PIXI.Sprite()
    @[secondary_sprite_name].width = @canvas_width
    @[secondary_sprite_name].height = @canvas_height
    targetSprite.addChild @[secondary_sprite_name]

    swapTexture1 = "swapTexture#{@recursive_id += 1}"
    swapTexture2 = "swapTexture#{@recursive_id += 1}"

    #these two RenderTextures will round-robin to enable the recursive filtering effects
    @[swapTexture1] = new PIXI.RenderTexture(@pixi.r, @canvas_width, @canvas_height)
    @[swapTexture2] = new PIXI.RenderTexture(@pixi.r, @canvas_width, @canvas_height)
    currentTexture = @[swapTexture1]
    @[secondary_sprite_name].texture = currentTexture
    # function that is returned
    # flips @renderTexture1 and 2, re-renders 1 and makes it the texture of the secondary sprite, which is then scaled up
    ()=>
      temp = @[swapTexture1]
      @[swapTexture1] = @[swapTexture2]
      @[swapTexture2] = temp
      #@capture.scale.x = @capture.scale.y = 1.005
      @[secondary_sprite_name].alpha = @[alpha_control_property] if @[alpha_control_property]?
      @[swapTexture1].render targetSprite, false, clearBeforeRendering
      #@capture.scale.x = @capture.scale.y = 1.0
      @[secondary_sprite_name].alpha = 1.0
      @[secondary_sprite_name].texture = @[swapTexture1]


  null

window.CalligraphBase = CalligraphBase


