(* TEST
 modules = "test2_.c";
*)

(* Tests nested calls from C (main C) to travlang (main travlang) to C (caml_to_c) to
 * travlang (c_to_caml) to C (printf functions). *)

let printf = Printf.printf

let c_to_caml () =
  printf "[Caml] Enter c_to_caml\n%!";
  printf "[Caml] Leave c_to_caml\n%!"

let _ = Callback.register "c_to_caml" c_to_caml

external caml_to_c : unit -> unit = "caml_to_c"

let _ =
    printf "[Caml] Call caml_to_c\n%!";
    caml_to_c ();
    printf "[Caml] Return from caml_to_c\n%!"
