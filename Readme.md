Installation
============

While WebStation can be built for offline runs (as it's purely client-side), you probably don't want to do this.  Instead, there's a simple Python web app (built with Flask) to compile and host the emulator.

Dependencies
------------

	pip install coffeescript flask PyTableGen

Flask is only needed if you plan to run the development server.

BIOS
----

WebStation does not include its own BIOS.  You will need to provide your own and place it in `static/bios.bin`.  The only tested BIOS thus far is SCPH1001, but others should work equally well (read: barely).

Running (Development)
---------------------

If you plan on developing for WebStation, I recommend you run the server.  This will provide real-time updates and all that jazz.

	python serve.py

Then just browse to [http://localhost:23109](http://localhost:23109)

Running (Static)
----------------

To build a static, offline version (which still needs to be hosted on HTTP due to file access security), run:

	python build.py

The `build/` directory then contains a runnable instance of the application.  For quick testing, `python -m SimpleHTTPServer someporthere` to run a local webserver.  But you probably want to just run the actual dev server.

License
=======

WebStation is licensed under CC0, making it public domain.  Do whatever you want with it, just don't sue me if your browser catches fire.

Credits
=======

All code by myself, Cody Brocious (Daeken).  But I couldn't have done any of this without the amazing docs out there, or without reading Ruststation (https://github.com/simias/rustation/) source when I got stuck.

I've compiled all the docs I've used into the `docs/` directory of this repo.  They are owned by their respective authors and the license **does not** apply to them.
