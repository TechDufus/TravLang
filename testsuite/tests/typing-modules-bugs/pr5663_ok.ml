(* TEST
 flags = " -w -a ";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)

module F (M : sig
    type 'a t
    type 'a u = string
    val f : unit -> _ u t
  end) = struct
    let t = M.f ()
  end
