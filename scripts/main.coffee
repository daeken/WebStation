document.addEventListener 'DOMContentLoaded', ->
	loadBlob 'bios.bin', (bios) ->
		console.log 'Starting'
		cpu = new Cpu bios
		cpu.pc = 0xbfc00000
		iv = interval 1, ->
			ret = cpu.run()
			if ret != true
				clearInterval iv
				console.log 'Executed', cpu.inscount, 'instructions'
				phex32 'PC=', cpu.pc
				throw ret
