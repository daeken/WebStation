DMA_OFF = 0
DMA_FIFO = 1
DMA_CPU2GPU = 2
DMA_GPU2CPU = 3

class GPU
	constructor: (@cpu) ->
		@renderer = new Renderer
		@reset()

	reset: ->
		@tex_base_x = 0
		@tex_base_y = 0
		@tex_flip_x = 0
		@tex_flip_y = 0
		@semi_trans = 0 # 0=B/2+F/2, 1=B+F, 2=B-F, 3=B+F/4
		@tex_color_depth = 4
		@dither = false
		@draw = true
		@set_mask = false
		@follow_mask = false
		@tex_disable = false
		@hres = 320
		@vres = 240
		@pal = false
		@display_color_depth = 24
		@interlace = false
		@display = false
		@irq = false
		@dma_direction = DMA_OFF

		@display_x_start = 0
		@display_y_start = 0

	write_gp0: (val) ->
		command = val >>> 24
		param = (val & 0xFFFFFF) >>> 0
		switch command
			when 0x00 then # NOP

			when 0xE1 # Draw Mode setting (aka "Texpage")
				@tex_base_x = param & 0xF
				@tex_base_y = (param >> 4) & 1
				@semi_trans = (param >> 5) & 3
				v = (param >> 7) & 3
				@tex_color_depth = switch v
					when 0 then 4
					when 1 then 8
					when 2 then 15
					else
						throw 'Unknown bit depth for texture: ' + v
				@dither = !!((param >> 9) & 1)
				@draw = !!((param >> 10) & 1)
				@tex_disable = !!((param >> 11) & 1)
				@tex_flip_x = !!((param >> 12) & 1)
				@tex_flip_y = !!((param >> 13) & 1)
			else
				phex 'Unknown GP0:', command, param
				throw 'Unhandled GP0'

	write_gp1: (val) ->
		command = val >>> 24
		param = (val & 0xFFFFFF) >>> 0
		switch command
			when 0x00 then # Reset GPU

			when 0x03 # Display Enable
				@display = !!param

			when 0x04 # DMA Direction / Data Request
				@dma_direction = param & 3

			when 0x05 # Start of Display area (in VRAM)
				@display_x_start = param & 0x3FF
				@display_y_start = (param >> 10) & 0x1FF

			when 0x06 # Horizontal Display range (on Screen)
				x1 = param & 0xFFF
				x2 = param >> 12
				# XXX: Do something with this

			when 0x07 # Vertical Display range (on Screen)
				y1 = param & 0x3FF
				y2 = (param >> 10) & 0x3FF
				# XXX: Do something with this

			when 0x08 # GP1(08h) - Display mode
				@hres = 
					if !!((param >> 6) & 1)
						368
					else
						switch param & 3
							when 0 then 256
							when 1 then 320
							when 2 then 512
							when 3 then 640
				@vres = if ((param >> 2) & 1) == 0 then 240 else 480
				@pal = !!((param >> 3) & 1)
				@display_color_depth = if !!((param >> 4) & 1) then 15 else 14
				@interlace = !!((param >> 5) & 1)
				@renderer.mode = [@hres, @vres, @interlace]
			else
				phex 'Unknown GP1:', command, param
				throw 'Unhandled GP1'

	read: ->
		console.log 'Gpuread'
		throw 1
		0

	stat: ->
		#console.log 'Gpustat'

		tex_depth = switch @tex_color_depth
			when 4 then 0
			when 8 then 1
			when 15 then 2
			else throw 'Unknown tex color depth'

		hres = switch @hres
			when 256 then 0
			when 320 then 2
			when 512 then 4
			when 640 then 6
			when 368 then 1

		vres = if @vres == 240 then 0 else 1

		(
			@tex_base_x | 
			(@tex_base_y << 4) | 
			(@semi_trans << 5) | 
			(tex_depth << 7) | 
			(@dither << 9) | 
			(@draw << 10) | 
			(@set_mask << 11) | 
			(@follow_mask << 12) |
			(1 << 13) | 
			(@tex_disable << 15) | 
			(hres << 16) | 
			(vres << 19) | 
			(@pal << 20) | 
			(@color_depth << 21) | 
			(@interlace << 22) | 
			(@display << 23) | 
			(@irq << 24) | 
			((switch @dma_direction
				when DMA_OFF then 0
				when DMA_FIFO then 1
				when DMA_CPU2GPU then 1
				when DMA_GPU2CPU then 1
			 ) << 25) |
			(1 << 26) | 
			(1 << 27) | 
			(1 << 28) | 
			(@dma_direction << 29)
		)