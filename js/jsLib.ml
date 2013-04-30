(* The file system maps file name to javascript arrays of char.
   The channel system maps channel number to in_channel or out_channel 
   implementation. 
   in_channels are function from unit to char option.
   out_channels are function from char to unit to write and from unit -> unit to flush.
*)


type channels = 
 {inchannel :  (unit -> char option);
  outchannel : ((char -> unit) * (unit -> unit))}

let file_system : (string, char Js.js_array Js.t) Hashtbl.t = Hashtbl.create 17

let next_channel = ref 0
 
let channel_system : (int,channels) Hashtbl.t = Hashtbl.create 17

let create_empty_file name = 
  let a = jsnew Js.array_empty () in
  Hashtbl.replace file_system  name a;
  a
	
  

let _ = 
  ignore(create_empty_file "stdin")
 
(* alist of function to call when writing into a file, 
  with the name of the file being writen *)
let output_callbacks : (string * (unit -> unit)) list ref = ref [] 

let file_exists s =  Hashtbl.mem file_system s

let _ =   (Js.Unsafe.variable "caml_callbacks")##caml_sys_file_exists_ <- file_exists
 


let find_file_or_create_empty name = 
  if file_exists name then Hashtbl.find file_system name else 
    create_empty_file name

let open_file_in_out name  =
  let i = !next_channel in
  let file = find_file_or_create_empty name in
  next_channel := i + 1;
  Hashtbl.add channel_system i 
  (let pos = ref 0 in
   { inchannel = 
       (fun () -> 
	 let thePos = !pos in 
	 let c = Js.array_get file thePos in
	 pos := thePos + 1;
	 Js.Optdef.case c (fun () -> None) (fun x -> Some x));
   outchannel =   ((fun c -> ignore(file##push(c))), (fun () ->
       List.iter
	 (fun (s,f) -> if s = name then  f())  (!output_callbacks) ))});
  i
    
let _ = ignore(open_file_in_out "stdin")
(*
let open_file_out name = 
   let i = !next_channel in
   let file = create_empty_file name in
   next_channel := i + 1;
   Hashtbl.add channel_system i 
     (OutChannel 
     ((fun c -> ignore(file##push(c))), (fun () ->
       List.iter
	 (fun (s,f) -> if s = name then  f())  (!output_callbacks) ))); i
*)
let _ = 
  ignore(open_file_in_out "stdout");
  ignore(open_file_in_out "stderr")
  
    


let caml_ml_open_descriptor_out (i : int) =
  (Hashtbl.find channel_system i).outchannel

let _ = (Js.Unsafe.variable "caml_callbacks")##caml_ml_open_descriptor_out_ <- caml_ml_open_descriptor_out


let caml_ml_open_descriptor_in (i : int) =
  (Hashtbl.find channel_system i).inchannel



let _ = (Js.Unsafe.variable "caml_callbacks")##caml_ml_open_descriptor_in_ <- caml_ml_open_descriptor_in



let caml_sys_is_directory (d : string) = false


let _ = (Js.Unsafe.variable "caml_callbacks")##caml_sys_is_directory_ <- caml_sys_is_directory  



let caml_sys_open (d : string) (l : open_flag list) (_ : int) = 
  open_file_in_out d

  
let alert s =  (Js.Unsafe.variable "window")##alert(s)

let _ = (Js.Unsafe.variable "caml_callbacks")##caml_sys_open_ <- caml_sys_open

let _ = (Js.Unsafe.variable "caml_callbacks")##caml_ml_flush_ <-
  (fun x -> alert(x); (*f()*))

let _ = 
  (Js.Unsafe.variable "caml_callbacks")##caml_ml_out_channels_list_ <- 
    (fun () -> let l = ref [] in
	       Hashtbl.iter 
		 (fun _ ch ->
		    l := ch.outchannel :: (!l) ) channel_system ;
	        !l)
 
let caml_ml_output_char  =
  fun (s,_) c -> s c

let caml_ml_output  = 
  fun ch s off len ->
  for i = off to off + len - 1 do
    caml_ml_output_char ch (s.[i])
  done


let _ = 
  (Js.Unsafe.variable "caml_callbacks")##caml_ml_output_char_ <- caml_ml_output_char 


let _ = 
  (Js.Unsafe.variable "caml_callbacks")##caml_ml_output_ <- caml_ml_output


let caml_ml_close_channel = 
  function
  x -> (snd x.outchannel) ()

let _ =   (Js.Unsafe.variable "caml_callbacks")##caml_ml_close_channel_ <- caml_ml_close_channel



let caml_ml_input_char  ch = 
  fun ch ->
    match ch () with
      Some x -> x
    | None -> Char.chr 0

let caml_ml_input ch s off len =
  for i = off to off + len - 1 do
    match ch () with 
      Some(x) -> s.[i] <- x
    | None -> ()
  done

    

let _ =   (Js.Unsafe.variable "caml_callbacks")##caml_ml_input_char_ <-caml_ml_input_char
let _ =   (Js.Unsafe.variable "caml_callbacks")##caml_ml_input_ <-caml_ml_input


let file_content name = 
  let a =  Hashtbl.find file_system (Js.to_string name) in
  let str = String.create a##length in
  for i = 0 to a##length - 1 do
   Js.Optdef.case  (Js.array_get a i) (fun () -> ()) (fun x -> str.[i] <- x)
  done;
  Js.string str
    


let _ =  (Js.Unsafe.variable "caml_callbacks")##file_content_ <- file_content

let write_file_content name string = 
  let str = Js.to_string string in
  let name = Js.to_string name in
  let file = 
      create_empty_file name in
  for i = 0 to String.length str - 1 do
    ignore(file##push(str.[i]))
  done

let _ =  (Js.Unsafe.variable "caml_callbacks")##write_file_content_ <- write_file_content


let _ = Js.Unsafe.eval_string "caml_ml_open_descriptor_out = caml_callbacks.caml_ml_open_descriptor_out;
caml_ml_open_descriptor_in = caml_callbacks.caml_ml_open_descriptor_in;
caml_sys_is_directory = caml_callbacks.caml_sys_isdirectory;
caml_sys_open = caml_callbacks.caml_sys_open;
caml_ml_flush = caml_callbacks.caml_ml_flush;
caml_ml_out_channels_list = caml_callbacks.caml_ml_out_channels_list;
caml_ml_output_char = caml_callbacks.caml_ml_output_char;
caml_ml_output = caml_callbacks.caml_ml_output;
caml_ml_close_channel = caml_callbacks.caml_ml_close_channel;
caml_sys_file_exists = caml_callbacks.caml_sys_file_exists;
caml_ml_input_char = caml_callbacks.caml_ml_input_char;
caml_ml_input = caml_callbacks.caml_ml_input;"

let _ = write_file_content (Js.string "input") (Js.string "%agent: a(x~u~p)\n\
%agent: b(y~u~p)\n\
\n\
a(x), b(y) -> a(x!1), b(y!1) @1\n\
a(x!1), b(y!1) -> a(x), b(y) @1\n\
a(x!1), b(y~u!1) -> a(x!1), b(y~p!1) @1\n\
\n\
%init: 100000 a(x~u)\n\
%init: 200000 b(y~u)\n\
%obs: 'a phos' b(y~u)" )
