import coffeescript, generator, glob, os, os.path, shutil

if not os.path.exists('build'):
	os.makedirs('build')
generator.build()

for fn in glob.glob('scripts/*.js'):
	bn = os.path.basename(fn)
	shutil.copyfile(fn, 'build/' + bn)

for fn in glob.glob('scripts/*.coffee'):
	bn = os.path.basename(fn)
	with file('build/' + bn, 'w') as fp:
		fp.write(coffeescript.compile(file(fn, 'r').read(), bare=True))

for fn in glob.glob('static/*'):
	bn = os.path.basename(fn)
	shutil.copyfile(fn, 'build/' + bn)
