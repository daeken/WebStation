String.prototype.zeropad = (n) -> ('0000000000000000' + @).slice -n
hexify = (n, pad=null) ->
	if n < 0 and pad != null
		'-' + ((-n).toString(16).zeropad(pad))
	else if pad == null
		n.toString(16)
	else
		n.toString(16).zeropad(pad)
phex = (ns...) -> console.log (hexify n for n in ns)...
phex32 = (ns...) ->
	console.log ((if typeof n == 'number' then hexify(n).zeropad(8) else n) for n in ns)...

signext = (size, x) ->
	if (x >>> (size - 1)) == 1
		x - (1 << size)
	else
		x

zeroext = (size, x) -> x >>> 0

i = 0
REG_ZERO = i++
REG_AT = i++
REG_V0 = i++
REG_V1 = i++
REG_A0 = i++
REG_A1 = i++
REG_A2 = i++
REG_A3 = i++
REG_T0 = i++
REG_T1 = i++
REG_T2 = i++
REG_T3 = i++
REG_T4 = i++
REG_T5 = i++
REG_T6 = i++
REG_T7 = i++
REG_S0 = i++
REG_S1 = i++
REG_S2 = i++
REG_S3 = i++
REG_S4 = i++
REG_S5 = i++
REG_S6 = i++
REG_S7 = i++
REG_T8 = i++
REG_T9 = i++
REG_K0 = i++
REG_K1 = i++
REG_GP = i++
REG_SP = i++
REG_FP = i++
REG_RA = i++

COP0_SR = 12

regnames = [
	'$zero', '$at', 
	'$v0', '$v1', 
	'$a0', '$a1', '$a2', '$a3', 
	'$t0', '$t1', '$t2', '$t3', '$t4', '$t5', '$t6', '$t7',
	'$s0', '$s1', '$s2', '$s3', '$s4', '$s5', '$s6', '$s7', 
	'$t8', '$t9', 
	'$k0', '$k1', 
	'$gp', '$sp', '$fp', '$ra'
]
regname = (reg) ->
	regnames[reg]

loadBlob = (fn, cb) ->
	req = new XMLHttpRequest
	req.open 'GET', fn, true
	req.responseType = 'arraybuffer'
	req.onload = (e) ->
		cb req.response
	req.send()

ArrayBuffer.prototype.set = (buf, offset=0) ->
	view = new Uint8Array @, offset
	view.set buf

interval = (delay, fn) ->
	setInterval fn, delay

overflow = (n) ->
	((n >>> 0) & 0xFFFFFFFF00000000) != 0
