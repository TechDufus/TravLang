(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

let t =
  (function `A | `B -> () : 'a) (`A : [`A]);
  (failwith "dummy" : 'a) (* to know how 'a is unified *)

(* TEST
 flags = "-i";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
