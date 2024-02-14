(* TEST
 flags = "-g";
 travlangrunparam += ",b=1";
 travlangopt_flags = "-inline 0";
 exit_status = "2";
*)

let f () = raise
  Exit [@@inline never]

let () =
  f ()
