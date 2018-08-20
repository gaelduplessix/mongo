build:
	dune build

test:
	dune runtest

doc: build
	ocaml setup.ml -doc
	cp -r _build/src/mongo.docdir/ doc
	cp -r _build/lwt/mongo_lwt.docdir/ doc_lwt

all: build

install:
	dune install

uninstall: setup.data
	dune uninstall

clean:
	dune clean

.PHONY: build doc test all install uninstall clean
