(* TEST_BELOW
(* Blank lines added here to preserve locations. *)








*)

let f : string A.t -> unit = function
    A.X s -> print_endline s

(* It is important that the line below is the last line of the file
   (see Makefile) *)
let () = f A.y

(* TEST
 readonly_files = "a.ml";
 setup-travlangc.byte-build-env;
 module = "a.ml";
 travlangc.byte;
 module = "b_bad.ml";
 flags = "-warn-error +8";
 travlangc_byte_exit_status = "2";
 travlangc.byte;
 check-travlangc.byte-output;
*)
