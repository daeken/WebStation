$(document).ready ->
	loadBlob 'bios.bin', (bios) ->
		console.log 'Starting'
		cpu = new Cpu bios
		#debug = new Debugger cpu
		blocks = []
		iv = interval 1, ->
			if blocks.indexOf(cpu.pc) == -1
				phex32 'Block at', cpu.pc
				blocks.push cpu.pc
			[success, pc, func] = cpu.decompile_block cpu.pc
			if not success
				phex32 'Failed to decompile at', pc
				clearInterval iv
				return
			func cpu
