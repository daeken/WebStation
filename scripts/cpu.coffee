class Cpu
	constructor: (@bios) ->
		@debugger = null
		@reset()

	reset: ->
		@inscount = 0 # Number of instructions executed
		@mem = new Memory @, @bios
		@regs = [
			0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0
		]
		@hi = @lo = 0
		@pc = 0xbfc00000
		@delay = null # Delay slot for execution

		@cop0reg = [
			0, 0, 0, 0, 0, 0, 0, 0, 
			0, 0, 0, 0, 0, 0, 0, 0, 
			0, 0, 0, 0, 0, 0, 0, 0, 
			0, 0, 0, 0, 0, 0, 0, 0
		]

		@code_cache = {}
		@invalidation = []
		for i in [0...16384]
			@invalidation.push undefined

	add_block: (addr, func) ->
		@code_cache[addr] = func
		page = (addr & 0x3fffffff) >>> 12
		if not @invalidation[page]
			@invalidation[page] = []
		@invalidation[page].push addr

	invalidate: (addr) ->
		page = (addr & 0x3fffffff) >>> 12
		if @invalidation[page]
			for elem in @invalidation[page]
				delete @code_cache[elem]
			@invalidation[page] = undefined

	execute_one: ->
		@inscount++
		@delayed = @delay
		cpc = if @delayed != null then @delay else @pc
		@delay = null
		if interpret(cpc, @mem.uint32(cpc), @) == false
			inst = @mem.uint32 cpc
			phex32 cpc, inst, disassemble(cpc, inst)
			throw 'Unknown instruction'
		
		@pc += 4 if @delayed == null

	decompile_block: (ipc) ->
		if @code_cache[ipc]
			return @code_cache[ipc]

		pc = ipc
		code = ''
		emit = (snippet) -> code += snippet + '\n'
		branched = false
		branch = -> branched = true
		while true
			inst = @mem.uint32 pc
			if not decompile pc, inst, emit, branch
				return false
			pc += 4
			if branched
				inst = @mem.uint32 pc
				if not decompile pc, inst, emit, branch
					return false
				pc += 4
				break

		total = '(function(state) {\nstate.delayed = null;\nstate.branch_to = null;\n' + code + '\nif(state.branch_to != null) state.pc = state.branch_to;\n})'
		func = eval(total)
		@code_cache[ipc] = func
		func

	branch: (pc, recompiled=false) ->
		if recompiled
			@branch_to = pc
		else
			@debugger.branch @pc, pc if @debugger != null
			@delay = @pc + 4
			@pc = pc - 4 # Compensate for PC push

	raise: (cause) ->
		phex32 'Exception', cause, 'at', @pc
		bev = ((@cop0reg[COP0_SR] >> 22) & 1) == 1

		switch cause
			when 0 # Reset
				handler = 0xbfc00000
			when 2, 3 # TLB should not exist and thus this shouldn't either...
				handler = if bev then 0xbfc00100 else 0x80000000
			else
				handler = if bev then 0xbfc00180 else 0x80000080

		cr = (cause << 2)
		if @delayed != null
			@cop0reg[COP0_EPC] = @delayed - 4
			cr |= 1 << 31
		else
			@cop0reg[COP0_EPC] = @pc
		@cop0reg[COP0_CAUSE] = cr >>> 0

		@delay = null
		@pc = handler

		throw new Exception

	syscall: (num) ->
		@raise Syscall

	copreg: (cop, reg, val=null) ->
		if cop == 0
			if val == null
				@cop0reg[reg]
			else
				@cop0reg[reg] = val
				if reg == COP0_SR
					@mem.isolate = ((val >>> 16) & 1) == 1 # Isolate Cache
		else
			console.log 'Unknown copreg access', cop, reg, val
			throw 'Fail'

	copfun: (cop, cofun) ->
		if cop == 0
			switch cofun
				when 16 # RFE
					sr = @cop0reg[COP0_SR]
					bottom = (sr >>> 2) & 0xF
					top = sr >>> 4
					@cop0reg[COP0_SR] = (bottom | top) >>> 0
				else
					console.log 'Unknown cop0 function:', cofun
					throw 'Fail'
		else
			console.log 'Unknown cop' + cop, 'function', cofun
			throw 'Fail'

