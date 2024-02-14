(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

(* Bad - PR 4261 *)

module PR_4261 = struct
  module type S =
  sig
    type t
  end

  module type T =
  sig
    module D : S
    type t = D.t
  end

  module rec U : T with type D.t = U'.t = U
  and U' : S with type t = U'.t = U
end;;

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
