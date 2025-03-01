(* TEST_BELOW
(* Blank lines added here to preserve locations. *)


*)

(* https://github.com/travlang-multicore/travlang-multicore/issues/498 *)
external stubbed_raise : unit -> unit = "caml_498_raise"

let raise_exn () = failwith "exn"

let () = Callback.register "test_raise_exn" raise_exn

let () =
  try
    stubbed_raise ()
  with
  | exn ->
    Printexc.to_string exn |> print_endline;
    Printexc.print_backtrace stdout

(* TEST
 modules = "backtrace_c_exn_.c";
 flags = "-g";
 travlangrunparam += ",b=1";
*)
