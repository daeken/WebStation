class GPU
	constructor: (@cpu) ->

	write_gp0: (val) ->
		command = val >>> 24
		param = (val & 0xFFFFFF) >>> 0
		phex32 'GP0:', command, param

	write_gp1: (val) ->
		command = val >>> 24
		param = (val & 0xFFFFFF) >>> 0
		phex32 'GP1:', command, param

	read: ->
		console.log 'Gpuread'
		throw 1
		0

	stat: ->
		console.log 'Gpustat'
		0