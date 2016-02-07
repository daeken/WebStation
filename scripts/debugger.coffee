insns_per = 10000
bptypes = ['Execute']

class Debugger
	constructor: (@cpu) ->
		@running = false
		@iv = null
		@breakpoints = {}
		@update()
		$('#reset').click =>
			@cpu.reset()
			@update()
		$('#go-stop').click =>
			@running = not @running
			@update()
			if @running
				@start()
		$('#step').click =>
			return if @running
			ret = @cpu.execute_one()
			@update()
			throw ret if ret != null
		$('#new-bp').click =>
			return if $('#new-bp-addr').val() == ''
			addr = parseInt $('#new-bp-addr').val(), 16
			type = parseInt $('#new-bp-type').val()

			return if @breakpoints[addr] != undefined

			@breakpoints[addr] = type
			$('#breakpoints').append $('<tr><td>' + hexify(addr, 8) + '</td><td>' + bptypes[type] + '</td></tr>')
			$('#new-bp-addr').val ''
			$('#new-bp-type').val 0

	start: ->
		return if @iv != null
		@iv = interval 1, =>
			for i in [0...insns_per]
				ret = @cpu.execute_one()
				@running = false if @breakpoints[@cpu.pc] == 0
				break if not @running or ret != null
			@update()
			if not @running or ret != null
				clearInterval @iv
				@iv = null
				throw ret if ret != null

	update: ->
		if @running
			$('#go-stop').text 'Break'
		else
			$('#go-stop').text 'Continue'

		for i in [0...32]
			$('#r' + i).text hexify(@cpu.regs[i] >>> 0, 8)

		$('#pc').text hexify(@cpu.pc >>> 0, 8)
		$('#hi').text hexify(@cpu.hi >>> 0, 8)
		$('#lo').text hexify(@cpu.lo >>> 0, 8)

		start = Math.max (@cpu.pc - 32), 0
		end = start + 64

		text = ''
		for i in [start...end] by 4
			try
				inst = @cpu.mem.uint32 i
			catch
				continue

			if i == @cpu.pc
				text += '> '
			else
				text += '  '

			text += hexify(i, 8) + '  '

			text += disassemble i, inst
			text += '\n'
		$('#disassembly').text text
