TO_MEM = 0
FROM_MEM = 1

FORWARD = 0
BACKWARD = 1

SYNC_ALL = 0 # Start immediately and transfer all at once (used for CDROM, OTC)
SYNC_BLOCKS = 1 # Sync blocks to DMA requests   (used for MDEC, SPU, and GPU-data)
SYNC_LL = 2 # Linked-List mode              (used for GPU-command-lists)

class DMAChannel
	constructor: (@cpu) ->
		@mem = @cpu.mem

		@address = 0

		@direction = TO_MEM
		@step_dir = FORWARD
		@chopping = 0 # Ignored
		@syncmode = SYNC_ALL
		@chop_dma = 0 # Ignored
		@chop_cpu = 0 # Ignored

		@numwords = 0 # BCR when SYNC_ALL

		@blocksize = 0 # BCR when SYNC_BLOCKS
		@numblocks = 0

	start: ->
		console.log 'Starting DMA!'

class DMA
	constructor: (@cpu) ->
		@mem = @cpu.mem
		@_dpcr = 0x07654321
		@_dicr = 0
		@channels = [
			new DMAChannel(@cpu), 
			new DMAChannel(@cpu), 
			new DMAChannel(@cpu), 
			new DMAChannel(@cpu), 
			new DMAChannel(@cpu), 
			new DMAChannel(@cpu), 
			new DMAChannel(@cpu)
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
		channel = @channels[channel]
		if val == null
			channel.address
		else
			channel.address = val

	bcr: (channel, val=null) ->
		channel = @channels[channel]
		if val == null
			switch channel.syncmode
				when SYNC_ALL
					channel.numwords
				when SYNC_BLOCKS
					((channel.numblocks << 16) | channel.blocksize) >>> 0
				else
					0
		else
			switch channel.syncmode
				when SYNC_ALL
					channel.numwords = val & 0xFFFF
				when SYNC_BLOCKS
					channel.blocksize = val & 0xFFFF
					channel.numblocks = val >>> 16

	chcr: (channel, val=null) ->
		channel = @channels[channel]
		if val == null
			(
				channel.direction | 
				(channel.step_dir << 1) | 
				(channel.chopping << 8) | 
				(channel.syncmode << 9) | 
				(channel.chop_dma << 16) | 
				(channel.chop_cpu << 20)
			)
		else
			channel.direction = val & 1
			channel.step_dir = (val >> 1) & 1
			channel.chopping = (val >> 8) & 1
			channel.syncmode = (val >> 9) & 3
			channel.chop_dma = (val >> 16) & 7
			channel.chop_cpu = (val >> 20) & 7

			start = (val >> 28) & 1
			if start == 1
				channel.start()
