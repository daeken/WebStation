import coffeescript
import os.path
from flask import Flask

print 'Starting'

app = Flask(__name__)
app.debug = True

@app.route('/')
def root():
	return app.send_static_file('index.html')

@app.route('/<fn>.js')
def js(fn):
	if fn in ('interp', 'disasm'):
		ud = max(map(os.path.getmtime, ('generator.py', 'insts.td')))
		if os.path.getmtime('scripts/' + fn + '.js') <= ud:
			print 'Loading tables...'
			import generator
			reload(generator)
			generator.build()
	return file('scripts/' + fn + '.js', 'r').read()

@app.route('/<fn>.coffee')
def coffee(fn):
	return coffeescript.compile(file('scripts/' + fn + '.coffee', 'r').read(), bare=True)

@app.route('/<fn>.exe')
def exe(fn):
	return app.send_static_file(fn + '.exe')
@app.route('/<fn>.bin')
def bin(fn):
	return app.send_static_file(fn + '.bin')

if __name__=='__main__':
	app.run(host='')
