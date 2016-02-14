Installation
============

While WebStation can be built for offline runs (as it's purely client-side), there's no facility to do this.  Instead, there's a simple Python web app (built with Flask) to compile and host the emulator.

Dependencies
------------

	pip install coffeescript flask

BIOS
----

WebStation does not include its own BIOS.  You will need to provide your own and place it in `static/bios.bin`.  The only tested BIOS thus far is SCPH1001, but others should work equally well (read: barely).

Running
-------

	python serve.py

Then just browse to http://localhost:23109

Credits
=======

All code by myself, Cody Brocious (Daeken).  But I couldn't have done any of this without the amazing docs out there, or without reading Ruststation (https://github.com/simias/rustation/) source when I got stuck.
