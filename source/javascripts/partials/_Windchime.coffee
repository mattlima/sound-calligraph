###
#
# A sort of particle-generator effect for Mooog. Sets up a pool of buffers and triggers them
#
###

class Windchime

	constructor: (mooogInstance, sourceFileList)->

  	@availableBuffers = []
  	@buffers = []
  	@count = 0
	  @m = mooogInstance
	  @master_out = @m.node
      id: "master_out"
      node_type: 'DynamicsCompressor'
      threshold: -50
      knee: 40
      ratio: 12
      reduction: -20
      attack: 0
      release: 0.25

	  for file, index in sourceFileList

      curr_track = @m.track "buffer_track_#{index}",
        @m.node
          id: "buffer_source_#{index}"
          node_type: "AudioBufferSource"
          buffer_source_file: file, loop: false
        @m.node
          id: "buffer_filt_#{index}"
          node_type: 'BiquadFilter'
          type: 'highpass'
          frequency: 3500
          Q: 5.0
#         @m.node
#           id: "buffer_comp_#{index}"
#           node_type: 'DynamicsCompressor'
#           threshold: -50
#           knee: 40
#           ratio: 3
#           reduction: -20
#           attack: 0
#           release: 0.25


      curr_track.chain @master_out

      chime = this
      (() ->
        buffer = this._nodes[0]
        chime.buffers.push buffer
        chime.availableBuffers.push buffer
        buffer.onended = ()->
          buffer.stop()
          chime.availableBuffers.push buffer
      ).call @m.node "buffer_track_#{index}"

    @nodes = @m._nodes

  trigger_play: ()->
    return if @availableBuffers.length is 0
    node = @availableBuffers.pop()
    detval = Math.round( Math.random() * 30 )
    node.param( 'detune', detval )
    node.param( {detune: detval + Math.random() * 5 , at: 1, ramp: 'linear' } ).start()
    node._nodes[1].param( 'gain', 1 )
    node._nodes[1].param( {gain: 0 , at: 4.5, ramp: 'expo' } )

  addToAvailable: (buffer) =>
    @availableBuffers.push buffer



window.Windchime = Windchime
