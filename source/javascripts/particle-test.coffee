#
#
# Not sure why but removing the filter on the second stage made this work.
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
    STAGE_WIDTH = 500

    @pixi.r = PIXI.autoDetectRenderer(STAGE_WIDTH * 2, STAGE_HEIGHT, renderer_config)


    $(@canvas).replaceWith @pixi.r.view

    @stage = new PIXI.Container()



    # stage 1 is where stuff happens, left over from
    @stage1 = new PIXI.Container()
    @stage2 = new PIXI.Container()
    @stage1.height = STAGE_HEIGHT
    @stage2.height = STAGE_HEIGHT
    @stage1.blendMode = 'screen'
    @stage2.blendMode = 'screen'
    @stage1.width = STAGE_WIDTH
    @stage2.width = STAGE_WIDTH
    @stage2.position.x = STAGE_WIDTH
    @stage.addChild @stage1
    @stage.addChild @stage2

    @stage1.interactive = true
    @stage1.click = @moveSprite

    #capturing the clicks seems to require a sprite
    @capture = new PIXI.Sprite()
    @capture.width = STAGE_WIDTH
    @capture.height = STAGE_HEIGHT
    @stage1.addChild @capture


    @sp = new PIXI.Sprite()
    @sp.width=50
    @sp.height=50
    @sp.texture = new PIXI.Texture.fromImage("/images/imgres.jpg")
    @stage1.addChild @sp

    #define two renderTextures that will round-robin for a recursive texture effect
    @renderTexture1 = new PIXI.RenderTexture(@pixi.r,STAGE_WIDTH,STAGE_HEIGHT)
    @renderTexture2 = new PIXI.RenderTexture(@pixi.r,STAGE_WIDTH,STAGE_HEIGHT)
    currentTexture = @renderTexture1
    @capture.texture = currentTexture
    @capture.filters = [
      new PIXI.filters.BlurFilter(10)
    ]

    #this is controlled by a button
    $("#tran1").click @render_1_to_2

    #the bounceback will target @capture since that covers all of stage1
    $("#tran2").click @render_2_to_1

    #see the function
    $("#tran3").click ()=>
      console.log @white_pix_per @renderTexture1.getPixels()


#     window.filt = new PIXI.filters.BlurFilter()
#     window.filt.blur = 10
#     @stage1.filters = [window.filt]
#
#     window.filt2 = new PIXI.filters.BlurFilter()
#     window.filt2.blur = 10
    #@stage2.filters = [window.filt2]


    requestAnimationFrame @animate

  render_toggle: false

  moveSprite: (e) =>
    @sp.position = {x: e.data.global.x, y: e.data.global.y }

  render_1_to_2: ()=>
    @renderTexture2.render @stage1, false, true

  render_2_to_1: ()=>
    @renderTexture1.render @stage2

  scale = 1.0

  # flips @renderTexture1 and 2, re-renders 1 and makes it the texture of @capture
  render_round_robin: ()=>
    temp = @renderTexture1
    @renderTexture1 = @renderTexture2
    @renderTexture2 = temp
    @capture.scale.x = @capture.scale.y = 1.005
    @capture.alpha = 0.9
    @renderTexture1.render @stage, false, true
    @capture.scale.x = @capture.scale.y = 1.0
    @capture.alpha = 1.0
    @capture.texture = @renderTexture1


  animate: ()=>
    requestAnimationFrame @animate
    @render_round_robin()
#    if(render_toggle = !render_toggle)
#      @render_2_to_1()
#    else
#      @render_1_to_2()

    @pixi.r.render @stage

  white_pix_per: (pixdata) ->
    whites = 0
    whites += 1 for i in pixdata when i is 255
    whites



$(document).ready ()->
  window.FC = new FC()
