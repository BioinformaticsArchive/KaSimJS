module Gc = struct

type control = {
  dummy : int;
  	mutable space_overhead : int}


let set (t : control)  = ()

let get () = {dummy = 0 ; space_overhead = -1}

end
let exit_value = ref 0

module Sys = struct
  include Sys
  let set_signal (i : int) (f : signal_behavior)  = ()  
  let exit (i : int)  = 
    exit_value := i;
    raise (Exit)
end
let exit (i : int) =Sys.exit i

module Marshal = struct 
  include Marshal
  let to_channel (type t) (d : out_channel) ( v : t) flags : unit =
    output_string d (Marshal.to_string v flags)
  let from_channel (d : in_channel) =
    let buffer = String.create header_size in
    ignore(input d buffer 0 header_size);
    let size = data_size buffer 0 in
    let big_buffer = String.create (header_size + size) in
    String.blit buffer 0 big_buffer 0 header_size;
    ignore(input d big_buffer header_size size);
    Marshal.from_string big_buffer 0
end


module Printexc = struct
  include Printexc
  let record_backtrace (b : bool) = ()
end



let argv = ref [||]

let _ =
  argv :=
    
    let open Js.Unsafe in
    let basicArgsStr = "KaSimJS -i input -o output" in
    let customArgsStr = Js.to_string (Js.Unsafe.variable "customArgs") in
    let argsStr = basicArgsStr ^ " " ^ customArgsStr in
    let argsLst = Regexp.split (Regexp.regexp " ") argsStr in
    let argsNELst = List.filter (fun s -> s <> "") argsLst in
    Array.of_list argsNELst

module Arg = struct 
  include Arg
  let parse = parse_argv !argv
  let usage a b  = output_string stderr (usage_string a b)
end
