import re, struct
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

toplevel = {}

for name, type, op, funct, dasm, dag in ops:
	if funct is None:
		assert op not in toplevel
		toplevel[op] = name, type, dasm, dag
	else:
		if op not in toplevel:
			toplevel[op] = [type, {}]
		toplevel[op][1][funct] = name, type, dasm, dag

def generate(gfunc):
	switch = []
	for op, body in toplevel.items():
		if isinstance(body, list):
			type, body = body
			subswitch = []
			for funct, sub in body.items():
				subswitch.append(('case', funct, gfunc(sub)))
			if type == 'CFType':
				when = ('&', ('>>>', 'inst', 21), 0x1F)
			elif type == 'RIType':
				when = ('&', ('>>>', 'inst', 16), 0x1F)
			else:
				when = ('&', 'inst', 0x3F)
			switch.append(('case', op, ('switch', when, subswitch)))
		else:
			switch.append(('case', op, gfunc(body)))
	return ('switch', ('>>>', 'inst', 26), switch)

def indent(str, single=True):
	if single and '\n' not in str:
		return ' %s ' % str
	else:
		return '\n%s\n' % '\n'.join('\t' + x for x in str.split('\n'))

def output(expr, top=True):
	if isinstance(expr, list):
		return '\n'.join(output(x, top=top) for x in expr)
	elif isinstance(expr, int) or isinstance(expr, long):
		return '0x%x' % expr
	elif isinstance(expr, str) or isinstance(expr, unicode):
		return expr

	op = expr[0]
	if op == 'switch':
		return 'switch(%s) {%s}' % (output(expr[1]), indent(output(expr[2])))
	elif op == 'case':
		return 'case %s: {%s\tbreak;\n}' % (output(expr[1]), indent(output(expr[2]), single=False))
	elif op in ('+', '-', '*', '/', '%', '<<', '>>', '>>>', '&', '|', '^', '==', '!=', '<', '<=', '>', '>='):
		return '(%s) %s (%s)' % (output(expr[1], top=False), op, output(expr[2], top=False))
	elif op == '!':
		return '!(%s)' % output(expr[1], top=False)
	elif op == '=':
		return '%s %s %s;' % (output(expr[1], top=False), op, output(expr[2], top=False))
	elif op == 'if':
		return 'if(%s) {%s} else {%s}' % (output(expr[1], top=False), indent(output(expr[2]), single=False), indent(output(expr[3]), single=False))
	elif op == 'when':
		return 'if(%s) {%s}' % (output(expr[1], top=False), indent(output(expr[2])))
	elif op == 'comment':
		return '/*%s*/' % indent(output(expr[1]))
	elif op == 'str':
		return `str(expr[1])`
	elif op == 'index':
		return '(%s)[%s]' % (output(expr[1], top=False), output(expr[2], top=False))
	else:
		return '%s(%s)%s' % (op, ', '.join(output(x, top=False) for x in expr[1:]), ';' if top else '')

gops = {
	'add' : lambda a, b: ('+', a, b), 
	'sub' : lambda a, b: ('-', a, b), 
	'and' : lambda a, b: ('>>>', ('&', a, b), 0), 
	'or' : lambda a, b: ('>>>', ('|', a, b), 0), 
	'nor' : lambda a, b: ('>>>', ('~', ('|', a, b)), 0), 
	'xor' : lambda a, b: ('>>>', ('^', a, b), 0), 
	'mul' : lambda a, b: ('*', a, b), # XXX: This needs to be a 64-bit mul!
	'div' : lambda a, b: ('>>>', ('/', a, b), 0), 
	'mod' : lambda a, b: ('>>>', ('%', a, b), 0), 
	'shl' : lambda a, b: ('>>>', ('<<', a, b), 0), 
	'shra' : lambda a, b: ('>>', a, b), 
	'shrl' : lambda a, b: ('>>>', a, b), 

	'eq' : lambda a, b: ('==', a, b), 
	'ge' : lambda a, b: ('>=', a, b), 
	'gt' : lambda a, b: ('>', a, b), 
	'le' : lambda a, b: ('<=', a, b), 
	'lt' : lambda a, b: ('<', a, b), 
	'neq' : lambda a, b: ('!=', a, b), 
}

def cleansexp(sexp):
	if isinstance(sexp, list):
		return [cleansexp(x) for x in sexp if x != []]
	elif isinstance(sexp, tuple):
		return tuple([cleansexp(x) for x in sexp if x != []])
	else:
		return sexp

def decoder(code, vars, type):
	if type == 'IType' or type == 'RIType':
		vars += ['$rs', '$rt', '$imm']
		code.append(('=', '$rs', ('&', ('>>>', 'inst', 21), 0x1F)))
		code.append(('=', '$rt', ('&', ('>>>', 'inst', 16), 0x1F)))
		code.append(('=', '$imm', ('&', 'inst', 0xFFFF)))
	elif type == 'JType':
		vars += ['$imm']
		code.append(('=', '$imm', ('&', 'inst', 0x3FFFFFF)))
	elif type == 'RType':
		vars += ['$rs', '$rt', '$rd', '$shamt']
		code.append(('=', '$rs', ('&', ('>>>', 'inst', 21), 0x1F)))
		code.append(('=', '$rt', ('&', ('>>>', 'inst', 16), 0x1F)))
		code.append(('=', '$rd', ('&', ('>>>', 'inst', 11), 0x1F)))
		code.append(('=', '$shamt', ('&', ('>>>', 'inst', 6), 0x1F)))
	elif type == 'SType':
		vars += ['$code']
		code.append(('=', '$code', ('&', ('>>>', 'inst', 6), 0x0FFFFF)))
	elif type == 'CFType':
		vars += ['$cop', '$rt', '$rd', '$cofun']
		code.append(('=', '$cop', ('&', ('>>>', 'inst', 26), 3)))
		code.append(('=', '$rt', ('&', ('>>>', 'inst', 16), 0x1F)))
		code.append(('=', '$rd', ('&', ('>>>', 'inst', 11), 0x1F)))
		code.append(('=', '$cofun', ('&', 'inst', 0x01FFFFFF)))
	else:
		print 'Unknown instruction type:', type
		assert False

def genDisasm((name, type, dasm, dag)):
	code = [('comment', name)]
	vars = []
	decoder(code, vars, type)

	def subgen(dag):
		if isinstance(dag, str) or isinstance(dag, unicode):
			return dag
		elif isinstance(dag, int) or isinstance(dag, long):
			return dag
		elif not isinstance(dag, list):
			print 'Fail', `dag`
			assert False
		op = dag[0]
		if op == 'let':
			# Ignore any leading underscore vars
			if dag[1].startswith('$_'):
				return []
			if dag[1] not in vars:
				vars.append(dag[1])
			return [('=', dag[1], subgen(dag[2]))] + subgen(dag[3])
		elif op in ('branch', 'break', 'copfun', 'raise', 'set', 'store', 'syscall'): # Catch toplevel exprs
			return []
		elif op == 'if':
			return list(map(subgen, dag[2:]))
		elif op == 'when':
			return list(map(subgen, dag[2:]))
		elif op in gops:
			return gops[op](subgen(dag[1]), subgen(dag[2]))
		elif op in ('signext', 'zeroext'):
			return (op, dag[1], subgen(dag[2]))
		elif op in ('pc', 'hi', 'lo'):
			return [op]
		elif op == 'pcd':
			return ('+', 'pc', 4) # Return the delay slot position
		elif op == 'gpr':
			return ('gpr', subgen(dag[1]))
		elif op == 'copreg':
			return ('copreg', subgen(dag[1]), subgen(dag[2]))
		elif op == 'copcreg':
			return ('copcreg', subgen(dag[1]), subgen(dag[2]))
		elif op == 'block':
			return list(map(subgen, dag[1:]))
		elif op == 'unsigned':
			return ('>>>', subgen(dag[1]), 0)
		else:
			print 'Unknown op:', op
			return []

	code += cleansexp(subgen(dag))

	def format(dasm):
		shortest = (len(dasm), None)
		for var in vars:
			match = re.match(r'^(.*?)' + var.replace('$', '\\$') + '([^a-zA-Z0-9_].*$|$)', dasm)
			if match:
				match = match.groups()
				if len(match[0]) < shortest[0]:
					shortest = len(match[0]), var
		if shortest[1] is None:
			return ('str', dasm)
		
		var = shortest[1]
		match = re.match(r'^(.*?)(%?)' + var.replace('$', '\\$') + '([^a-zA-Z0-9_].*$|$)', dasm).groups()
		if match[1] == '%':
			out = ('regname', var)
		else:
			out = ('+', ('str', '0x'), ('hexify', var))
		if match[0]:
			out = ('+', ('str', match[0]), out)
		if match[2]:
			out = ('+', out, format(match[2]))
		return out
	
	code.append(('return', format(dasm)))

	return code

debug = False
def dlog(dag, code, pos):
	if dag[0] == 'gpr':
		name = ('regname', dag[1])
	elif dag[0] == 'copreg':
		name = '+', ('+', ('+', ('str', 'cop'), dag[1]), ('str', ' reg ')), dag[2]
	elif dag[0] == 'copcreg':
		name = '+', ('+', ('+', ('str', 'cop'), dag[1]), ('str', ' control reg ')), dag[2]
	elif dag[0] in ('hi', 'lo', 'pc'):
		name = dag[0]
	elif dag[0] == 'store':
		name = '>>>', dag[1], 0
	else:
		print 'Unknown dag to dlog:', dag
	
	return ('phex32', name, ('str', pos + ':'), code, ('str', 'uint:'), ('>>>', code, 0))

def genInterp((name, type, dasm, dag)):
	code = [('comment', name)]
	vars = []
	decoder(code, vars, type)

	def subgen(dag):
		if isinstance(dag, str) or isinstance(dag, unicode):
			return dag
		elif isinstance(dag, int) or isinstance(dag, long):
			return dag
		elif not isinstance(dag, list):
			print 'Fail', dag
			assert False
		op = dag[0]
		if op == 'let':
			if dag[1] not in vars:
				vars.append(dag[1])
			return [('=', dag[1], subgen(dag[2]))] + subgen(['block'] + dag[3:])
		elif op == 'set':
			left = dag[1]
			if left[0] == 'copreg':
				ret = [('state.copreg', subgen(left[1]), subgen(left[2]), subgen(dag[2]))]
				if debug:
					val = 'state.copreg', subgen(left[1]), subgen(left[2])
					tdag = 'copreg', subgen(left[1]), subgen(left[2])
					ret = [dlog(tdag, val, 'before')] + ret + [dlog(tdag, val, 'after')]
			elif left[0] == 'copcreg':
				ret = [('state.copcreg', subgen(left[1]), subgen(left[2]), subgen(dag[2]))]
				if debug:
					val = 'state.copcreg', subgen(left[1]), subgen(left[2])
					tdag = 'copcreg', subgen(left[1]), subgen(left[2])
					ret = [dlog(tdag, val, 'before')] + ret + [dlog(tdag, val, 'after')]
			else:
				leftjs = subgen(left)
				ret = [('=', leftjs, subgen(dag[2]))]
				if debug:
					ret = [dlog(left, leftjs, 'before')] + ret + [dlog(left, leftjs, 'after')]
				if left[0] == 'gpr':
					ret = [('when', ('!=', left[1], 0), ret)]
			return ret
		elif op == 'if':
			return [('if', subgen(dag[1]), subgen(dag[2]), subgen(dag[3]))]
		elif op == 'when':
			return [('when', subgen(dag[1]), subgen(dag[2]))]
		elif op in gops:
			return gops[op](subgen(dag[1]), subgen(dag[2]))
		elif op in ('signext', 'zeroext'):
			return (op, dag[1], subgen(dag[2]))
		elif op == 'pc':
			return ['pc']
		elif op in ('hi', 'lo'):
			return ['state.' + op]
		elif op == 'pcd':
			return [('+', 'pc', 4)] # Return the delay slot position
		elif op == 'gpr':
			return ('index', 'state.regs', subgen(dag[1]))
		elif op == 'copreg':
			return ('state.copreg', subgen(dag[1]), subgen(dag[2]))
		elif op == 'copcreg':
			return ('state.copcreg', subgen(dag[1]), subgen(dag[2]))
		elif op == 'block':
			return list(map(subgen, dag[1:]))
		elif op == 'unsigned':
			return ('>>>', subgen(dag[1]), 0)
		elif op == 'signed':
			return ('|', subgen(dag[1]), 0)
		elif op == 'overflow':
			return [('overflow', subgen(dag[1]))]
		elif op == 'raise':
			return [('state.raise', dag[1])]
		elif op == 'break':
			return [('state.break_', dag[1])]
		elif op == 'syscall':
			return [('state.syscall', dag[1])]
		elif op == 'branch':
			return [('state.branch', subgen(dag[1]))]
		elif op == 'load':
			return [('state.mem.uint%i' % dag[1], subgen(dag[2]))]
		elif op == 'store':
			ret = [('state.mem.uint%i' % dag[1], subgen(dag[2]), subgen(dag[3]))]
			if debug:
				addr = subgen(dag[2])
				val = 'state.mem.uint%i' % dag[1], addr
				tdag = 'store', addr
				ret = [dlog(tdag, val, 'before')] + ret + [dlog(tdag, val, 'after')]
			return ret
		elif op == 'copfun':
			return [('state.copfun', subgen(dag[1]), subgen(dag[2]))]
		else:
			print 'Unknown op:', op
			return []

	code += cleansexp(subgen(dag))
	code.append(('return', 'true'))

	return code

def build():
	print 'Rebuilding from tables'
	with file('scripts/disasm.js', 'w') as fp:
		print >>fp, '/* Autogenerated from insts.td. DO NOT EDIT */'
		print >>fp, 'function disassemble(pc, inst) {%s\treturn "Unknown instruction. Op=0b" + ((inst >>> 26).toString(2).zeropad(6)) + " (Funct=0b" + ((inst & 0x3f).toString(2).zeropad(6)) + ", Cofunct=0b" + ((inst >>> 0x15) & 0x1f).toString(2).zeropad(5) + ")";\n}' % indent(output(generate(genDisasm)))
	with file('scripts/interp.js', 'w') as fp:
		print >>fp, '/* Autogenerated from insts.td. DO NOT EDIT */'
		print >>fp, 'function interpret(pc, inst, state) {%s\treturn false;\n}' % indent(output(generate(genInterp)))

if __name__=='__main__':
	build()
