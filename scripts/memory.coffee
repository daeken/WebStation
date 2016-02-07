class MemBuffer
	constructor: (@cpu, @buf) ->
		@uint8Buf = new Uint8Array @buf
		@uint16Buf = new Uint16Array @buf
		@uint32Buf = new Uint32Array @buf

	uint8: (offset, val=null) ->
		if val == null
			@uint8Buf[offset]
		else
			@uint8Buf[offset] = val

	uint16: (offset, val=null) ->
		if val == null
			@uint16Buf[offset]
		else
			@uint16Buf[offset] = val

	uint32: (offset, val=null) ->
		if val == null
			@uint32Buf[offset >>> 2]
		else
			@uint32Buf[offset >>> 2] = val

class HWBuffer
	constructor: (@cpu) ->
		@ROM_SIZE = 0x13243F
		@RAM_SIZE = 0xB88
		@COM_DELAY = 0x00031125

		@EXP1_BASE = 0x1F000000
		@EXP1_SIZE = 0x0013243F
		@EXP2_BASE = 0x1F802000
		@EXP2_SIZE = 0x00070777
		@EXP3_SIZE = 0x00003022
		@SPU_DELAY = 0x200931e1
		@CDROM_DELAY = 0x00020843

		# Interrupt Control
		@I_STAT = 0
		@I_MASK = 0

		# SPU
		@MAIN_VOLUME = 0
		@REVERB_VOLUME = 0

	uint8: (offset, val=null) ->
		switch offset
			when 0x1f802041
				phex32 'Trace ' + val, @cpu.pc, 'from', @cpu.regs[REG_RA]
			else
				boff = (offset & 3) >>> 0
				coff = (offset & 0xFFFFFFFC) >>> 0
				if val == null
					switch boff
						when 0
							(@uint32(coff) & 0xFF) >>> 0
						when 1
							(@uint32(coff) & 0xFF00) >>> 8
						when 2
							(@uint32(coff) & 0xFF0000) >>> 16
						else
							@uint32(coff) >>> 24
				else
					reg = @uint32 coff
					switch boff
						when 0
							@uint32 coff, ((reg & 0xFFFFFF00) | val) >>> 0
						when 1
							@uint32 coff, ((reg & 0xFFFF00FF) | (val << 8)) >>> 0
						when 2
							@uint32 coff, ((reg & 0xFF00FFFF) | (val << 16)) >>> 0
						else
							@uint32 coff, ((reg & 0x00FFFFFF) | (val << 24)) >>> 0

	uint16: (offset, val=null) ->
		if val == null
			if ((offset & 2) >>> 0) == 0
				(@uint32(offset) & 0xFFFF) >>> 0
			else
				@uint32(offset & 0xFFFFFFFC) >>> 16
		else
			coff = (offset & 0xFFFFFFFC) >>> 0
			reg = @uint32 coff
			if ((offset & 2) >>> 0) == 0
				@uint32 coff, ((reg & 0xFFFF0000) | val) >>> 0
			else
				@uint32 coff, ((reg & 0xFFFF) | (val << 16)) >>> 0

	uint32: (offset, val=null) ->
		switch offset
			when 0x1f801000 # Expansion 1 Base Address (usually 1F000000h)
				if val == null
					@EXP1_BASE
				else
					@EXP1_BASE = val
			when 0x1f801004 # Expansion 2 Base Address (usually 1F802000h)
				if val == null
					@EXP2_BASE
				else
					@EXP2_BASE = val
			when 0x1f801008 # Expansion 1 Delay/Size (usually 0013243Fh; 512Kbytes 8bit-bus)
				if val == null
					@EXP1_SIZE
				else
					@EXP1_SIZE = val
			when 0x1f80100c # Expansion 3 Delay/Size (usually 00003022h; 1 byte)
				if val == null
					@EXP3_SIZE
				else
					@EXP3_SIZE = val
			when 0x1f801010 # BIOS ROM    Delay/Size (usually 0013243Fh; 512Kbytes 8bit-bus)
				if val == null
					@ROM_SIZE
				else
					@ROM_SIZE = val
			when 0x1f801014 # SPU_DELAY   Delay/Size (usually 200931E1h)
				if val == null
					@SPU_DELAY
				else
					@SPU_DELAY = val
			when 0x1f801018 # CDROM_DELAY Delay/Size (usually 00020843h or 00020943h)
				if val == null
					@CDROM_DELAY
				else
					@CDROM_DELAY = val
			when 0x1f80101c # Expansion 2 Delay/Size (usually 00070777h; 128-bytes 8bit-bus)
				if val == null
					@EXP2_SIZE
				else
					@EXP2_SIZE = val
			when 0x1f801020 # COM_DELAY / COMMON_DELAY (00031125h or 0000132Ch or 00001325h)
				if val == null
					@COM_DELAY
				else
					@COM_DELAY = val
			when 0x1f801060 # RAM_SIZE (usually 00000B88h; 2MB RAM mirrored in first 8MB)
				if val == null
					@RAM_SIZE
				else
					@RAM_SIZE = val

			when 0x1f801070 # I_STAT - Interrupt status register
				if val == null
					@I_STAT
				else
					@I_STAT = val
			when 0x1f801074 # I_MASK - Interrupt mask register
				if val == null
					@I_MASK
				else
					@I_MASK = val

			# SPU
			when 0x1f801d80 # Main Volume Left/Right
				if val == null
					@MAIN_VOLUME
				else
					@MAIN_VOLUME = val
			when 0x1f801d84 # Reverb Volume Left/Right
				if val == null
					@REVERB_VOLUME
				else
					@REVERB_VOLUME = val

			# Expansion Region 2 - Int/Dip/Post
			when 0x1F802040 # DTL-H2000: Bootmode "Dip switches" (R)
				0

			# Unknown
			when 0x1ffe0130 # Magic cache control register
				0

			else
				if val != null
					phex32 'Unknown HWReg write to', offset, '=', val
				else
					phex32 'Unknown HWReg read from', offset
				throw 'Fail'

class BlackholeBuffer
	uint8: (offset, val=null) ->

	uint16: (offset, val=null) ->

	uint32: (offset, val=null) ->


class Memory
	constructor: (@cpu, bios) ->
		@ram = new MemBuffer(@cpu, new ArrayBuffer 2*1024*1024)
		@scratchpad = new MemBuffer(@cpu, new ArrayBuffer 1024)
		@hwregs = new HWBuffer @cpu
		@bios = new MemBuffer @cpu, bios
		@tlb = ([0, 0, 0, false, false, false, false] for i in [0...64])
		# asid, vpn, pfn (<< 12 for efficiency), n, d, v, g
		@exp1 = new BlackholeBuffer

		@isolate = false		

	dump: (near) ->
		start = Math.max 0, (near & 0xFFFFFF00) >>> 0
		end = start + 256
		for i in [start...end] by 32
			phex32 (if i <= near < (i + 32) then '-->' else '   '), i, ':', (@uint32(j) for j in [i...i+32] by 4)...

	virt2phys: (addr, store) ->
		if (addr >>> 29) == 0
			return addr & 0x7FFFFFFF
		else
			return addr & 0x1FFFFFFF

		# DEAD
		asid = @cpu.asid
		seg = addr >>> 29
		# No special handling for kuseg or kseg2
		if seg == 4 # kseg0
			return addr & 0x1FFFFFFF
		else if seg == 5 # kseg1
			return addr & 0x1FFFFFFF
		vpn = addr >>> 12

		for [easid, evpn, epfn, en, ed, ev, eg] in @tlb
			if (
					(eg or asid == easid) and 
					evpn == vpn and 
					ev and
					(ed or not store)
				)
				return epfn | (addr & 0xFFF)

		console.log 'TLB miss!'
		throw 'Fail'


	phys2buf: (addr) ->
		if addr < 0x00200000
			[@ram, addr]
		else if 0x1f000000 <= addr < 0x1f080000
			[@exp1, addr - 0x1f000000]
		else if 0x1f800000 <= addr < 0x1f800400
			[@scratchpad, addr - 0x1f800000]
		else if 0x1f801000 <= addr < 0x1f803000
			[@hwregs, addr] # We want the raw address in the hwreg handler
		else if 0x1fc00000 <= addr < 0x1fc80000
			[@bios, addr - 0x1fc00000]
		else if addr == 0x1ffe0130 # Magic cache control something-or-other
			[@hwregs, addr]
		else
			phex32 'Unknown phys address:', addr
			throw 'Fail'

	uint8: (addr, val=null) ->
		return if @isolate and val != null
		[buf, offset] = @phys2buf @virt2phys(addr, val != null)
		buf.uint8 offset, val

	uint16: (addr, val=null) ->
		return if @isolate and val != null
		[buf, offset] = @phys2buf @virt2phys(addr, val != null)
		buf.uint16 offset, val

	uint32: (addr, val=null) ->
		return if @isolate and val != null
		[buf, offset] = @phys2buf @virt2phys(addr, val != null)
		buf.uint32 offset, val
