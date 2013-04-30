jsLibs.js : 
	ocamlbuild -use-ocamlfind js/jsLib.byte
	js_of_ocaml _build/js/jsLib.byte
	cp _build/js/jsLib.js .
