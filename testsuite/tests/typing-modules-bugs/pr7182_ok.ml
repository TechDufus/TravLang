(* TEST
 flags = " -w -a ";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)

module rec M
    : sig external f : int -> int = "%identity" end
    = struct external f : int -> int = "%identity" end
