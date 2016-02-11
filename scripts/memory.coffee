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
		@gpu = new GPU @cpu

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

		# DMA
		@DPCR = 0
		@DICR = 0

		# Timers
		@CNT0_VAL = 0
		@CNT0_MODE = 0
		@CNT0_TARGET = 0
		@CNT1_VAL = 0
		@CNT1_MODE = 0
		@CNT1_TARGET = 0
		@CNT2_VAL = 0
		@CNT2_MODE = 0
		@CNT2_TARGET = 0

		# SPU
		@MAIN_VOLUME = 0
		@REVERB_VOLUME = 0
		@CD_VOLUME = 0
		@EXTERN_VOLUME = 0
		@SRAM_DTC = 0

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
		assign = (name) ->
			if val == null
				@[name]
			else
				@[name] = val

		# Special cases first
		if 0x1f801c00 <= offset < 0x1f801d80
			voice = (offset - 0x1f801c00) >> 2
			switch offset & 0xF
				when 0 # Voice Volume Left/Right
					0
				when 4 # Voice ADPCM Sample Rate | ADPCM Start Address
					0
				when 8 # Voice ADSR Attack/Decay/Sustain/Release
					0
				when 12 # Voice ADSR Current Volume | ADPCM Repeat Address
					0
		else
			switch offset
				when 0x1f801000 # Expansion 1 Base Address (usually 1F000000h)
					assign 'EXP1_BASE'
				when 0x1f801004 # Expansion 2 Base Address (usually 1F802000h)
					assign 'EXP2_BASE'
				when 0x1f801008 # Expansion 1 Delay/Size (usually 0013243Fh; 512Kbytes 8bit-bus)
					assign 'EXP1_SIZE'
				when 0x1f80100c # Expansion 3 Delay/Size (usually 00003022h; 1 byte)
					assign 'EXP3_SIZE'
				when 0x1f801010 # BIOS ROM    Delay/Size (usually 0013243Fh; 512Kbytes 8bit-bus)
					assign 'ROM_SIZE'
				when 0x1f801014 # SPU_DELAY   Delay/Size (usually 200931E1h)
					assign 'SPU_DELAY'
				when 0x1f801018 # CDROM_DELAY Delay/Size (usually 00020843h or 00020943h)
					assign 'CDROM_DELAY'
				when 0x1f80101c # Expansion 2 Delay/Size (usually 00070777h; 128-bytes 8bit-bus)
					assign 'EXP2_SIZE'
				when 0x1f801020 # COM_DELAY / COMMON_DELAY (00031125h or 0000132Ch or 00001325h)
					assign 'COM_DELAY'
				when 0x1f801060 # RAM_SIZE (usually 00000B88h; 2MB RAM mirrored in first 8MB)
					assign 'RAM_SIZE'

				# Interrupt Control
				when 0x1f801070 # I_STAT - Interrupt status register
					assign 'I_STAT'
				when 0x1f801074 # I_MASK - Interrupt mask register
					assign 'I_MASK'

				# DMA
				when 0x1f8010f0 # DPCR - DMA Control register
					assign 'DPCR'
				#when 0x1f8010f4 # DICR - DMA Interrupt register
				#	assign 'DICR'

				# Timers
				when 0x1f801100 # Counter 0 value
					assign 'CNT0_VAL'
				when 0x1f801104 # Counter 0 mode
					assign 'CNT0_MODE'
				when 0x1f801108 # Counter 0 target
					assign 'CNT0_TARGET'

				when 0x1f801110 # Counter 1 value
					assign 'CNT1_VAL'
				when 0x1f801114 # Counter 1 mode
					assign 'CNT1_MODE'
				when 0x1f801118 # Counter 1 target
					assign 'CNT1_TARGET'

				when 0x1f801120 # Counter 2 value
					assign 'CNT2_VAL'
				when 0x1f801124 # Counter 2 mode
					assign 'CNT2_MODE'
				when 0x1f801128 # Counter 2 target
					assign 'CNT2_TARGET'

				# GPU
				when 0x1f801810
					if val == null
						@gpu.read()
					else
						@gpu.write_gp0 val
				when 0x1f801814
					if val == null
						@gpu.stat()
					else
						@gpu.write_gp1 val

				# SPU
				when 0x1f801d80 # Main Volume Left/Right
					assign 'MAIN_VOLUME'
				when 0x1f801d84 # Reverb Volume Left/Right
					assign 'REVERB_VOLUME'
				when 0x1f801da0 # Unknown? (R) or (W) | Sound RAM Reverb Work Area Start Address
					0
				when 0x1f801da4 # Sound RAM IRQ Address (IRQ9)
					0
				when 0x1f801da8 # Sound RAM Data Transfer Fifo
					#phex32 'SPU data fifo =', val
					0
				when 0x1f801dac # Sound RAM Data Transfer Control
					assign 'SRAM_DTC'
				when 0x1f801db0 # CD Volume Left/Right
					assign 'CD_VOLUME'
				when 0x1f801db4 # Extern Volume Left/Right
					assign 'EXTERN_VOLUME'

				# SPU Voice Flags
				when 0x1f801d88 # Voice 0..23 Key ON (Start Attack/Decay/Sustain) (W)
					0
				when 0x1f801d8c # Voice 0..23 Key OFF (Start Release) (KOFF) (W)
					0
				when 0x1f801d90 # Voice 0..23 Channel FM (pitch lfo) mode (R/W)
					0
				when 0x1f801d94 # Voice 0..23 Channel Noise mode (R/W)
					0
				when 0x1f801d98 # Voice 0..23 Channel Reverb mode (R/W)
					0

				# SPU Reverb Configuration
				when 0x1f801dc0 # dAPF1/2  Reverb APF Offset 1 | 2
					0
				when 0x1f801dc4 # vIIR   Reverb Reflection Volume 1 | vCOMB1 Reverb Comb Volume 1
					0
				when 0x1f801dc8 # vCOMB2/3 Reverb Comb Volume 2 | 3
					0
				when 0x1f801dcc # vCOMB4 Reverb Comb Volume 4 | vWALL  Reverb Reflection Volume 2
					0
				when 0x1f801dd0 # vAPF1/2  Reverb APF Volume 1 | 2
					0
				when 0x1f801dd4 # mSAME  Reverb Same Side Reflection Address 1 Left/Right
					0
				when 0x1f801dd8 # mCOMB1 Reverb Comb Address 1 Left/Right
					0
				when 0x1f801ddc # mCOMB2 Reverb Comb Address 2 Left/Right
					0
				when 0x1f801de0 # dSAME  Reverb Same Side Reflection Address 2 Left/Right
					0
				when 0x1f801de4 # mDIFF  Reverb Different Side Reflection Address 1 Left/Right
					0
				when 0x1f801de8 # mCOMB3 Reverb Comb Address 3 Left/Right
					0
				when 0x1f801dec # mCOMB4 Reverb Comb Address 4 Left/Right
					0
				when 0x1f801df0 # dDIFF  Reverb Different Side Reflection Address 2 Left/Right
					0
				when 0x1f801df4 # mAPF1  Reverb APF Address 1 Left/Right
					0
				when 0x1f801df8 # mAPF2  Reverb APF Address 2 Left/Right
					0
				when 0x1f801dfc # vIN    Reverb Input Volume Left/Right
					0


				# Expansion Region 2 - Int/Dip/Post
				when 0x1F802040 # DTL-H2000: Bootmode "Dip switches" (R)
					0xFFFFFFFF

				# Unknown
				when 0x1ffe0130 # Magic cache control register
					0

				else
					if val != null
						phex32 'Unknown HWReg write to', offset, '=', val
					else
						phex32 'Unknown HWReg read from', offset
					throw 'Unknown HWReg'

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
