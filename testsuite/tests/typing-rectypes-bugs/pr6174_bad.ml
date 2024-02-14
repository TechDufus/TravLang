(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

type _ t = C : ((('a -> 'o) -> 'o) -> ('b -> 'o) -> 'o) t
let f : type a o. ((a -> o) -> o) t -> (a -> o) -> o =
 fun C k -> k (fun x -> x);;

(* TEST
 flags = " -w -a -rectypes ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
