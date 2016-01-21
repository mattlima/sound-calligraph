#
#
# This scratch file has nothing to do with testing particles
#
#
#
#


class FC
  constructor: ()->
    @canvas = $("#canvas")
    @pixi = {}
    renderer_config = {
      "clearBeforeRender": true
      "preserveDrawingBuffer": true
    }
    STAGE_HEIGHT = 500
    STAGE_WIDTH = 1000

    @pixi.r = PIXI.autoDetectRenderer(STAGE_WIDTH, STAGE_HEIGHT, renderer_config)


    $(@canvas).replaceWith @pixi.r.view

    @stage = new PIXI.Container()



#     # stage 1 is where stuff happens, left over from
#     @stage1 = new PIXI.Container()
#     @stage2 = new PIXI.Container()
#     @stage1.height = STAGE_HEIGHT
#     @stage2.height = STAGE_HEIGHT
#     @stage1.blendMode = 'screen'
#     @stage2.blendMode = 'screen'
#     @stage1.width = STAGE_WIDTH
#     @stage2.width = STAGE_WIDTH
#     @stage2.position.x = STAGE_WIDTH
#     @stage.addChild @stage1
#     @stage.addChild @stage2

    @stage.interactive = true
    @stage.click = @moveSprite

    #capturing the clicks seems to require a sprite
    @capture = new PIXI.Sprite()
    @capture.width = STAGE_WIDTH
    @capture.height = STAGE_HEIGHT
    @stage.addChild @capture


    @fire = new PIXI.Sprite()
    @fire.width=STAGE_WIDTH
    @fire.height=STAGE_HEIGHT
    @fire.texture = new PIXI.Texture.fromImage("/images/fire.jpg")
    @fire.texture = new PIXI.Texture.fromImage("/images/4colorpattern_orig.png")
    @stage.addChild @fire


    @forest = new PIXI.Sprite()
    @forest.width=STAGE_WIDTH
    @forest.height=STAGE_HEIGHT
    @forest.texture = new PIXI.Texture.fromImage("/images/forest.jpg")
    @stage.addChild @forest

    blur = new PIXI.filters.BlurFilter()
    blur.blur = 5
    blue = new PIXI.filters.ColorMatrixFilter()
    blue.matrix = [
      1, 0, 0, 0, 0
      0, 1, 0, 0, 0
      0, 0, 1, 0, 0
      1, 1, 1, 0, 0
    ]
    @forest.filters = [ blue ]
    @forest.blendMode = PIXI.BLEND_MODES.NORMAL
    window.f = @forest

    requestAnimationFrame @animate


  moveSprite: (e) =>
    @fire.position = {x: e.data.global.x, y: e.data.global.y }


  animate: ()=>
    requestAnimationFrame @animate


    @pixi.r.render @stage

  white_pix_per: (pixdata) ->
    whites = 0
    whites += 1 for i in pixdata when i is 255
    whites



$(document).ready ()->
  window.FC = new FC()
