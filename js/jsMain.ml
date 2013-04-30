open JsComp

let main a = 
  let n = a##length in
  argv := Array.init n (fun i -> Js.to_str (Optdef.case  (Js.array_get a i) (fun () -> assert false) (fun x -> x)))
  Main.main()
