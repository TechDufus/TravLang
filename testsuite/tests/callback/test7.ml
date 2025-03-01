(* TEST
 modules = "test7_.c";
*)

(* Tests nested calls from C (main C) to travlang (main travlang) to C (caml_to_c) to
 * travlang (c_to_caml) to C (printf functions). Effect E is performed in the
 * callback, which does not have a handler. *)

open Effect
open Effect.Deep

type _ t += E : unit t

let printf = Printf.printf

let c_to_caml () =
  printf "[Caml] Enter c_to_caml\n%!";
  printf "[Caml] c_to_caml: perform effect\n%!";
  perform E

let _ = Callback.register "c_to_caml" c_to_caml

external caml_to_c : unit -> unit = "caml_to_c"

let _ =
  try_with (fun () ->
    printf "[Caml] Call caml_to_c\n%!";
    begin try
      caml_to_c ()
    with Effect.Unhandled E ->
      (printf "[Caml] Caught Effect.Unhandled, perform effect\n%!";
       perform E)
    end;
    printf "[Caml] Return from caml_to_c\n%!") ()
  { effc = fun (type a) (e : a t) ->
      match e with
      | E -> Some (fun k -> printf "[Caml] Caught effect\n%!")
      | _ -> None }
