all: KaSim.js

KaSim.js: jsWorkerProtocol.js main.js
	cat js/runtime.js js/header.js _build/js/jsWorkerProtocol.js js/spliceCallbacks.js _build/main/main.js > KaSim.js


jsWorkerProtocol.js : 
	ocamlbuild -use-ocamlfind js/jsWorkerProtocol.byte
	js_of_ocaml -noruntime  _build/js/jsWorkerProtocol.byte
main.js : 
	ocamlbuild -use-ocamlfind main/main.byte
	js_of_ocaml -noruntime  _build/main/main.byte
