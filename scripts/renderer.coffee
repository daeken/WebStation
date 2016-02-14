class Renderer
	constructor: ->
		@cvs = $('#cvs')[0]
		@ctx = @cvs.getContext 'webgl'

		@width = @cvs.width
		@height = @cvs.height
		@interlace = false

	@setter 'mode', ([@width, @height, @interlace]) ->
		@cvs.width = @width
		@cvs.height = @height
