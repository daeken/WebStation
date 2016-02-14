printable = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_+=[]{}()`!@#$%^&*\\|;:\'",./<>?'
printify = (c) ->
	c = String.fromCharCode c
	if printable.indexOf(c) != -1
		c
	else
		'.'

chr = (x) ->
	if x == 0
		''
	else
		String.fromCharCode x

insns_per = 50000
recompile = true
bptypes = ['Execute']

build_expr = (expr) ->
	code = '(function(cpu) {\n'

	for name, i in regnames
		code += 'var ' + name + ' = cpu.regs[' + i + '];\n'
	code += 'var $pc = (cpu.delay == null) ? cpu.pc : cpu.delay;\n'
	code += 'var $hi = cpu.hi;\n'
	code += 'var $lo = cpu.lo;\n'

	code += 'with(cpu.mem) return ' + expr + ';\n'
	eval(code + '})')

class Debugger
	constructor: (@cpu) ->
		@cpu.debugger = @

		log = ''
		@logel = $('#log')[0]
		console.old_log = console.log
		console.log = =>
			for elem in arguments
				log += elem + ' '
			if log.length > 1000
				log = log.substring(Math.max(log.length - 1000, 0))
			log += '\n'
			@logel.innerHTML = log

		@ttybuf = ''
		@running = false
		@iv = null
		@breakpoints = {}
		@exprs = {}
		@exprid = 0
		@center = @cpu.pc
		@updating = false
		@update true

		@logbranches = false

		$('#reset').click =>
			log = ''
			@ttybuf = ''
			@cpu.reset()
			@center = @cpu.pc
			@update true

		$('#go-stop').click =>
			@running = not @running
			@update true
			if @running
				@start()

		$('#step').click =>
			return if @running
			ret = @run_one()
			@center = if @cpu.delay == null then @cpu.pc else @cpu.delay
			@update true
			throw ret if ret != null

		$('#add-bp').click =>
			return if $('#new-bp-addr').val() == ''
			addr = parseInt $('#new-bp-addr').val(), 16
			type = parseInt $('#new-bp-type').val()

			return if @breakpoints[addr] != undefined

			remove = =>
				delete @breakpoints[addr]
				row.remove()

			@breakpoints[addr] = type
			row = $('<tr><td>' + hexify(addr, 8) + '</td><td>' + bptypes[type] + '</td></tr>')
			row.append($('<td>Remove</td>').click(remove))
			$('#breakpoints').append row
			$('#new-bp-addr').val ''
			$('#new-bp-type').val 0

		$('#add-expr').click =>
			expr = $('#new-expr').val()
			return if expr == ''
			
			id = @exprid++
			remove = =>
				delete @exprs[id]
				row.remove()

			@exprs[id] = [expr, build_expr expr]
			row = $('<tr><td></td></tr>')
			row.children('td').text expr
			row.append($('<td>Remove</td>').click(remove))
			$('#exprs').append row
			$('#new-expr').val ''

		$('.value').dblclick (e) =>
			return if @running
			@center = parseInt($(e.target).text(), 16)
			@update()

		$('#up').click =>
			return if @running
			@center -= 0x10
			@update true

		$('#down').click =>
			@center += 0x10
			@update true

		$('#log-branches').change =>
			@logbranches = $('#log-branches').is(':checked')

		$('#update-debug').change =>
			@updating = $('#update-debug').is(':checked')

	branch: (from, to) ->
		phex32 'Branch from', from, 'to', to if @logbranches

	run_one: ->
		cpc = if @cpu.delay != null then @cpu.delay else @cpu.pc
		if cpc == 0x2C94 and @cpu.regs[REG_A0] == 1
			@ttybuf += [chr(@cpu.mem.uint8(@cpu.regs[REG_A1] + i)) for i in [0...@cpu.regs[REG_A2]]].join ''
			while true
				pos = @ttybuf.indexOf '\n'
				if pos == -1
					break
				line = @ttybuf.substring(0, pos - 1)
				if line != ''
					console.log 'TTY:', line
				@ttybuf = @ttybuf.substring pos + 1
		if recompile
			func = @cpu.decompile_block cpc
			if func == false
				throw 'Failed compilation'
			func @cpu
		else
			@cpu.execute_one()

	start: ->
		return if @iv != null
		@iv = interval 1, =>
			try
				for i in [0...insns_per]
					@run_one()
					if @cpu.delay == null and @breakpoints[@cpu.pc] == 0
						@running = false
						phex 'Hit breakpoint @', @cpu.pc
					for _, [expr, func] of @exprs
						if func(@cpu) == true
							@running = false
							console.log 'Hit expr breakpoint', expr
							break
					break if not @running
				@center = if @cpu.delay != null then @cpu.delay else @cpu.pc
				@update()
				if not @running
					clearInterval @iv
					@iv = null
			catch e
				if e instanceof Exception
					return
				clearInterval @iv if @iv != null
				console.old_log e
				throw e

	update: (first=false) ->
		@logel.scrollTop = @logel.scrollHeight

		if @running
			$('#go-stop').text 'Break'
		else
			$('#go-stop').text 'Continue'

		if not @updating and not first
			return

		for i in [0...32]
			$('#r' + i).text hexify(@cpu.regs[i] >>> 0, 8)

		$('#pc').text hexify(@cpu.pc >>> 0, 8)
		$('#hi').text hexify(@cpu.hi >>> 0, 8)
		$('#lo').text hexify(@cpu.lo >>> 0, 8)

		start = Math.max (@center - 32), 0
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

		memstart = Math.max ((@center & 0xFFFFFFF0) >>> 0) - 0x40, 0
		memend = memstart + 0x80

		text = ''
		for i in [memstart...memend] by 16
			try
				@cpu.mem.uint8 i
			catch
				continue
			bytes = ''
			chars = ''
			for j in [0...16]
				if j == 8
					bytes += ' '
					chars += ' '
				x = @cpu.mem.uint8 i + j
				bytes += ' ' + hexify(x, 2)
				chars += printify(x)
			if i == ((@cpu.pc & 0xFFFFFFF0) >>> 0)
				text += '> '
			else
				text += '  '
			text += hexify(i, 8) + bytes + ' |' + chars + '\n'
		$('#memory').text text
