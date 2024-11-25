all: bin/ocli.d

bin/ocli.d: bin/
	odin build . -debug -out:bin/ocli.d -o:none -sanitize:address -lld 

bin/:
	mkdir bin/
