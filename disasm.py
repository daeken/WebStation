# XXX: This is woefully out of date.  No longer matches the table format!

import struct
from tblgen import interpret, Dag, TableGenBits

def dag2expr(dag):
	def clean(value):
		if isinstance(value, tuple) and len(value) == 2 and value[0] == 'defref':
			return value[1]
		return value
	def sep((name, value)):
		if name is None:
			return clean(value)
		return name
	if isinstance(dag, Dag):
		return [dag2expr(sep(elem)) for elem in dag.elements]
	else:
		return dag

insts = interpret('insts.td').deriving('BaseInst')
ops = []
for name, (bases, data) in insts:
	ops.append((name, bases[1], data['Opcode'][1], data['Function'][1] if 'Function' in data else None, data['Disasm'][1], dag2expr(data['Eval'][1])))

def disasm(base, data):
	pc = base
	off = 0

	while off < len(data):
		insn = struct.unpack('<I', data[off:off+4])[0]
		opcd = insn >> 26
		match = False
		for (name, type, op, funct, dasm, expr) in ops:
			if op != opcd:
				continue
			if type == 'IType':
				rs = (insn >> 21) & 0x1F
				rt = (insn >> 16) & 0x1F
				imm = insn & 0xFFFF
			elif type == 'RIType':
				rs = (insn >> 21) & 0x1F
				tfunct = (insn >> 16) & 0x1F
				imm = insn & 0xFFFF
				if tfunct != funct:
					continue
			elif type == 'JType':
				imm = insn & 0x03FFFFFF
			elif type == 'RType':
				rs = (insn >> 21) & 0x1F
				rt = (insn >> 16) & 0x1F
				rd = (insn >> 11) & 0x1F
				shamt = (insn >> 6) & 0x1F
				tfunct = insn & 0x1F
				if tfunct != funct:
					continue
			elif type == 'SType':
				code = (insn >> 6) & 0x0FFFFF
				tfunct = insn & 0x1F
				if tfunct != funct:
					continue
			match = True
			print name, type, op, funct, dasm, expr
			break
		if not match:
			print 'Unknown at %x' % pc
			break
		off += 4
		pc += 4

disasm(0xBFC00000, file('static/bios.bin', 'rb').read())
