all: jsLibs.js main.js

jsLibs.js : 
	ocamlbuild -use-ocamlfind js/jsLib.byte
	js_of_ocaml -noruntime  _build/js/jsLib.byte
main.js : 
	ocamlbuild -use-ocamlfind main/main.byte
	js_of_ocaml -noruntime  _build/main/main.byte
