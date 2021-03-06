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
  MAX_PIXEL_COUNT: 1000000
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
    @dashboard = new Dashboard(this) if @config.dashboard and (window.location.hash isnt "#nodash")


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
  # We limit notional canvas size to a max number of pixels
  # to avoid performance issues on large screens with the
  # recursive render functions
  #
  pixi_init: (renderer_config)=>

    #secondary sprites and textures created for recursive renders will be indexed here for resizes.
    @sprites_to_resize = []
    @textures_to_resize = []

    @pixi = {}


    @pixi.r = new PIXI.WebGLRenderer(100, 100, renderer_config)

    @canvas = @pixi.r.view
    $('body').prepend @pixi.r.view

    @stage = new PIXI.Container()

    @resize()

    @document.on 'mouseleave', 'canvas', @on_mouseup
    @document.on 'mousedown', 'canvas', @on_mousedown
    @document.on 'mouseup', 'canvas', @on_mouseup
    $(window).on 'resize', @resize

    null


  #resizes the canvas and all the full-page sprites to the new screen
  # dimensions, respecting MAX_PIXEL_COUNT
  resize: () =>
    [@canvas_width, @canvas_height] = @get_canvas_dimensions()

    for i in @sprites_to_resize
      i.width = @canvas_width
      i.height = @canvas_height

    for i in @textures_to_resize
      i.resize @canvas_width, @canvas_height

    @pixi.r.resize @canvas_width, @canvas_height
    true



  #
  #
  # Returns the width/height of the window unless larger than MAX_CANVAS_WIDTH
  # in which case it is scaled down
  #

  get_canvas_dimensions: ()->
    ww = window.innerWidth
    wh = window.innerHeight
    pix = @MAX_PIXEL_COUNT / (ww * wh)
    if pix < 1
      @canvas_scale_factor = Math.sqrt(pix)
      @canvas_width = Math.round(ww * @canvas_scale_factor)
      @canvas_height = Math.round(wh * @canvas_scale_factor)
    else
      @canvas_scale_factor = 1.0
      @canvas_width = ww
      @canvas_height = wh

    [@canvas_width, @canvas_height]


  ###
    In order to do recursive filter effects, we have to use a round-robin rendering process, otherwise
    the chain of objects being rendered into the sprite contains the texture itself and throws a GL error.
    This function returns a function to be called in animate() that swaps the textures every other frame
    and renders. targetSprite can be a sprite or a container.
  ###
  create_recursive_render: (targetSprite, secondary_sprite_name, alpha_control_property, clearBeforeRendering, resolution) =>
    @recursive_id ?= 0
    resolution ?= 1.0
    #the recursive filter requires a base sprite to render into
    @[secondary_sprite_name] = new PIXI.Sprite()
    @sprites_to_resize.push @[secondary_sprite_name]

    @[secondary_sprite_name].width = @canvas_width
    @[secondary_sprite_name].height = @canvas_height
    targetSprite.addChild @[secondary_sprite_name]

    swapTexture1 = "swapTexture#{@recursive_id += 1}"
    swapTexture2 = "swapTexture#{@recursive_id += 1}"

    #these two RenderTextures will round-robin to enable the recursive filtering effects
    @[swapTexture1] = new PIXI.RenderTexture(@pixi.r, @canvas_width, @canvas_height, PIXI.SCALE_MODES.LINEAR, resolution)
    @[swapTexture2] = new PIXI.RenderTexture(@pixi.r, @canvas_width, @canvas_height, PIXI.SCALE_MODES.LINEAR, resolution)
    @textures_to_resize.push @[swapTexture1]
    @textures_to_resize.push @[swapTexture2]
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


