(* TEST
 modules = "stub_test.c";
*)

external failwith_from_travlang : string -> 'a = "caml_failwith_value"

external dynamic_invalid_argument : unit -> 'a = "dynamic_invalid_argument"

let () =
  try failwith_from_travlang ("fo" ^ "o")
  with Failure foo -> print_endline foo

let () =
  try dynamic_invalid_argument ()
  with Invalid_argument bar -> print_endline bar
