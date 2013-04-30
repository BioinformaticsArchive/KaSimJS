jsLibs.js : 
	ocamlbuild -use-ocamlfind js/jsLib.byte
	js_of_ocaml -noruntime -pretty _build/js/jsLib.byte

