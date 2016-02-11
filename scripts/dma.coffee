class DMA
	constructor: (@cpu) ->
		@mem = @cpu.mem
		@_dpcr = 0
		@_dicr = 0
		@channels = [
			[0, 0, 0], 
			[0, 0, 0], 
			[0, 0, 0], 
			[0, 0, 0], 
			[0, 0, 0], 
			[0, 0, 0], 
			[0, 0, 0]
		]

	dpcr: (val=null) ->
		if val == null
			@_dpcr
		else
			@_dpcr = val

	dicr: (val=null) ->
		if val == null
			@_dicr
		else
			@_dicr = val

	madr: (channel, val=null) ->
		if val == null
			@channels[channel][0]
		else
			@channels[channel][0] = val

	bcr: (channel, val=null) ->
		if val == null
			@channels[channel][1]
		else
			@channels[channel][1] = val

	chcr: (channel, val=null) ->
		if val == null
			@channels[channel][2]
		else
			@channels[channel][2] = val
