###

  Calligraph common module

  Responsibilities:
    Hold DOM references
    Initialize Mooog
    Keep mousedata object updated
    Call subclass init
    Provide utility functions

###
class CalligraphBase

  constructor: () ->

    #retain useful DOM refs
    @document = $(document)


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
    @dashboard = new Dashboard(this)

    # keep mousedata current for inheriting classes
    @document.on 'mousemove', @update_mousedata

    # The init function is supplied by the inheriting class
    @init()


  # constrains val to within inmin < val < inmax and then scales it to the interval outmin-outmax
  clamp: (val, inmin, inmax, outmin, outmax) ->
    val = inmin if val < inmin
    val = inmax if val > inmax
    ((val - inmin) / (inmax - inmin)) * (outmax - outmin) + outmin



  update_mousedata: (e) =>
    now = performance.now()
    elapsed = now - @last_mouse_update
    @last_mouse_update = now
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
  # The stage is always used so it is managed here to take care of resizes, etc.
  #
  #
  pixi_init: (renderer_config)=>
    @pixi = {}
    @pixi.r = PIXI.autoDetectRenderer(@get_canvas_width(), @get_canvas_height(), renderer_config)
    @canvas = @pixi.r.view
    $('body').prepend @pixi.r.view


    @stage = new PIXI.Container()


    @document.on 'mouseleave', 'canvas', @on_mouseup
    @document.on 'mousedown', 'canvas', @on_mousedown
    @document.on 'mouseup', 'canvas', @on_mouseup

    window.onresize = (event) =>
      @pixi.r.resize @get_canvas_width(), @get_canvas_height()
      @canvas_height = @get_canvas_height()
      @canvas_width = @get_canvas_width()
      true

    window.onresize()
    null

  #
  #
  # Todo: move constants, add check for presence of dash
  #
  #
  get_canvas_height: ()->
    DASH_HEIGHT = 120
    window.innerHeight - DASH_HEIGHT

  get_canvas_width: ()->
    window.innerWidth



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


