(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

(* Same example as in tests/typing-sigsubst/sigsubst.ml, but not as an
   expect test so we get the full error.  *)

module type Printable = sig
  type t
  val print : t -> unit
end

module type Comparable = sig
  type t
  val compare : t -> t -> int
end

module type PrintableComparable = sig
  include Printable
  include Comparable with type t = t
end

(* TEST
 flags = "-nostdlib -nopervasives";
 setup-travlangc.byte-build-env;
 travlangc_byte_exit_status = "2";
 travlangc.byte;
 check-travlangc.byte-output;
*)
