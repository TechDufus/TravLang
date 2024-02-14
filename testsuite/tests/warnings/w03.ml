(* TEST_BELOW
(* Blank lines added here to preserve locations. *)







*)

exception A [@deprecated]

let _ = A


exception B [@@deprecated]

let _ = B


exception C [@deprecated]

let _ = B [@warning "-53"]

(* TEST
 flags = "-w +A-70";
 setup-travlangc.byte-build-env;
 compile_only = "true";
 travlangc.byte;
 check-travlangc.byte-output;
*)
