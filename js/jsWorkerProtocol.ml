open JsLib


let message_back = 
  let split_space s = 
    Regexp.split (Regexp.regexp " ") s in
  let array_of_list f l =
    let l = List.map f l in
    let a = jsnew Js.array_empty() in
    List.iter (fun s ->  
      ignore(a##push(Js.string s))) l;
    a in
  let parse_species_names s = 
    let l = split_space s in
    match l with 
    | "#"::"time"::l ->
      array_of_list  
	(fun s -> 
	  let n = String.length s in
	  let buf = String.create (n - 2) in
	  String.blit s 1 buf 0 (n - 2);
	  buf
	) l 
    | _ -> assert false in
  let species_sent = ref false in
  let empty_array = jsnew Js.array_empty() in
  let parseFloat s = 
    Js.Unsafe.fun_call (Js.Unsafe.variable "parseFloat") [|Js.Unsafe.inject s|] in
  let species = ref None in
  fun s -> 
    match !species with
      None -> species := Some (parse_species_names s)
    | Some a -> 
     	let species_array = if !species_sent then empty_array
	  else (species_sent := true;  a) in
	let l = split_space s in
	match l with 
	  "" :: time :: spec ->
	    let open Js.Unsafe in
	    let msg = 
	      obj [|("time", inject (parseFloat (Js.string time)));
		    ("newSpec", inject species_array);
		    ("newData", inject (array_of_list parseFloat spec));
		    ("isComplete", inject false)|] in
	   ignore(fun_call  (variable "processMessageCallback") [|msg|])
	| _ -> assert false
let _ = line_callback "output" message_back



let _ = write_file_content (Js.string "input") (Js.Unsafe.variable "inputFile")
