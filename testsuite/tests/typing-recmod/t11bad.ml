(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

(* Bad (not regular) *)
module rec A : sig type 'a t = 'a list B.t end
             = struct type 'a t = 'a list B.t end
       and B : sig type 'a t = <m: 'a array B.t> end
             = struct type 'a t = <m: 'a array B.t> end;;

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
