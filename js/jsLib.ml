(* The file system maps file name to javascript arrays of char.
   The channel system maps channel number to in_channel or out_channel 
   implementation. 
   in_channels are function from unit to char option.
   out_channels are function from char to unit to write and from unit -> unit to flush.
*)


type channels = 
  InChannel of (unit -> char option)
 |OutChannel of ((char -> unit) * (unit -> unit))

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
let output_callbacks : (string* (unit -> unit)) list ref = ref [] 

let open_file_in name  =
  let i = !next_channel in
  let file = Hashtbl.find file_system name in
  next_channel := i + 1;
  Hashtbl.add channel_system i 
  (let pos = ref 0 in
   InChannel 
	      (fun () -> 
		let thePos = !pos in 
		let c = Js.array_get file thePos in
		pos := thePos + 1;
		Js.Optdef.case c (fun () -> None) (fun x -> Some x)));
  i
    
let _ = ignore(open_file_in "stdin")

let open_file_out name = 
   let i = !next_channel in
   let file = create_empty_file name in
   next_channel := i + 1;
   Hashtbl.add channel_system i 
     (OutChannel 
     ((fun c -> ignore(file##push(c))), (fun () ->
       List.iter
	 (fun (s,f) -> if s = name then  f())  (!output_callbacks) ))); i

let _ = 
  ignore(open_file_in "stdout");
  ignore(open_file_in "stderr")
  
    


let caml_ml_open_descriptor_out (i : int) =
  match  Hashtbl.find channel_system i with
    OutChannel ch -> ch
  | _ -> assert false

let _ = (Js.Unsafe.variable "caml_callbacks")##caml_ml_open_descriptor_out <- caml_ml_open_descriptor_out


let caml_ml_open_descriptor_in (i : int) =
  match  Hashtbl.find channel_system i with
    InChannel ch -> ch
  | _ -> assert false


let _ = (Js.Unsafe.variable "caml_callbacks")##caml_ml_open_descriptor_in <- caml_ml_open_descriptor_in



let caml_sys_is_directory (d : string) = false


let _ = (Js.Unsafe.variable "caml_callbacks")##caml_sys_is_directory <- caml_sys_is_directory  



let caml_sys_open (d : string) (l : open_flag list) (_ : int) = 
  if List.mem Open_wronly l then
    open_file_in d
  else open_file_out d
  

let _ = (Js.Unsafe.variable "caml_callbacks")##caml_sys_open <- caml_sys_open

let _ = (Js.Unsafe.variable "caml_callbacks")##caml_ml_flush <-
  (fun (_,f) -> f())

let _ = 
  (Js.Unsafe.variable "caml_callbacks")##caml_ml_out_channels_list <- 
    (fun () -> let l = ref [] in
	       Hashtbl.iter 
		 (fun _ ch ->
		   match ch with 
		     OutChannel ch -> l := ch :: (!l) 
		   | _ -> ()) channel_system ;
	        !l)
 
let caml_ml_output_char  =
  fun (s,_) c -> s c

let caml_ml_output  = 
  fun ch s off len ->
  for i = off to off + len - 1 do
    caml_ml_output_char ch (s.[i])
  done


let _ = 
  (Js.Unsafe.variable "caml_callbacks")##caml_ml_output_char <- caml_ml_output_char 


let _ = 
  (Js.Unsafe.variable "caml_callbacks")##caml_ml_output <- caml_ml_output


let caml_ml_close_channel = 
  function
   InChannel ch -> ()
  | OutChannel (_,f) -> f()

let _ =   (Js.Unsafe.variable "caml_callbacks")##caml_ml_close_channel <- caml_ml_close_channel

let _ =   (Js.Unsafe.variable "caml_callbacks")##caml_sys_file_exists <-
  (fun s -> Hashtbl.mem file_system s)


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

    

let _ =   (Js.Unsafe.variable "caml_callbacks")##caml_ml_input_char <-caml_ml_input_char
let _ =   (Js.Unsafe.variable "caml_callbacks")##caml_ml_input <-caml_ml_input

