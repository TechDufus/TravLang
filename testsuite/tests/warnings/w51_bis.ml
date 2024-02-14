(* TEST_BELOW
(* Blank lines added here to preserve locations. *)







*)

let rec foldl op acc = function
    [] -> acc
    | x :: xs ->
        try (foldl [@tailcall]) op (op x acc) xs
        with Not_found -> assert false

(* TEST
 flags = "-w +A-70";
 setup-travlangc.byte-build-env;
 compile_only = "true";
 travlangc.byte;
 check-travlangc.byte-output;
*)
