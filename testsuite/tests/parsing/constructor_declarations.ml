(* TEST_BELOW
(* Blank lines added here to preserve locations. *)



*)

(* Allowed. *)
type t =
    A of int
  | B of bool

(* Allowed. *)
type u =
  | A of int
  | B of bool

(* Allowed. *)
type v = |

(* Disallowed, but was allowed in 4.07. *)
type w =
  |
  | A of int
  | B of bool

(* TEST
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
