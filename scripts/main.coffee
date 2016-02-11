$(document).ready ->
	loadBlob 'bios.bin', (bios) ->
		console.log 'Starting'
		cpu = new Cpu bios
		debug = new Debugger cpu
		return
		iv = interval 1, ->
			for i in [0...insns_per]
				ret = cpu.execute_one()
				break if ret != null

			if ret != null
				clearInterval iv
				console.log 'Executed', cpu.inscount, 'instructions'
				phex32 'PC=', cpu.pc
				throw ret
