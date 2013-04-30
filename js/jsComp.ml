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

(*type in_channel = string
type out_channel = char -> unit

let close_out (o : out_channel) = ()
let open_out (s : string)  : out_channel = fun c -> ()
let open_out_bin (s : string) : out_channel = fun c -> ()
let open_in_bin (s : string) : in_channel = "   "

let open_in (s : string) : in_channel = "empty"
let close_in (i : in_channel) = ()
let write_string (o : out_channel) (s : string) = s
let output_char (d : out_channel) c : unit = d c
let output_string (d : out_channel) s : unit = 
  for i = 0 to String.length s - 1 do
    output_char d s.[i]
      done

module Pervasives = struct 
  let close_in = close_in
end
*)
(*
module Lexing = struct 
  include Lexing
  let from_channel (d : in_channel) = from_string d
    
end
let stdin = (fun () -> 'y')
let stderr = (fun c -> ())
let stdout = (fun c -> ())


let print_string = output_string stdout
let print_char = output_char stdout
let print_newline () = output_char stdout '\n'
module Printf = struct
  include Printf
    
  let fprintf (d : out_channel) f = ksprintf (output_string d) f
  let eprintf f = fprintf stderr f
end


let flush (x : out_channel) = ()



module Stream = struct
  include Stream
  let of_channel g = Stream.from (fun i -> Some(g ()))
end
*)
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


let argv = [||]

module Arg = struct 
  include Arg
  let parse = parse_argv argv
  let usage a b  = output_string stderr (usage_string a b)
end
