(* TEST_BELOW
(* Blank lines added here to preserve locations. *)



*)

let why : unit -> unit = fun () -> raise Exit [@@inline never]
let f () =
  for i = 1 to 10 do
    why @@ ();
  done;
  ignore (3 + 2);
  () [@@inline never]

let () =
  f ()

(* TEST
 flags = "-g";
 travlangrunparam += ",b=1";
 travlangopt_flags = "-inline 0";
 exit_status = "2";
*)
