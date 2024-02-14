(* TEST_BELOW
(* Blank lines added here to preserve locations. *)














*)

module _ = struct
  let x = 13, 37
end

module rec A : sig
  type t = B.t
end = A
and _ : sig
  type t = A.t
  val x : int * int
end = struct
  type t = B.t
  let x = 4, 2
end
and B : sig
  type t
end = struct
  type t

  let x = "foo", "bar"
end

module type S

let f (module _ : S) = ()

type re = { mutable cell : string; }

let s = { cell = "" }

module _ = struct
 let () = s.cell <- "Hello World!"
end

let drop _ = ()

let () = drop s.cell

(* TEST
 flags = "-c -nostdlib -nopervasives -dlambda -dno-unique-ids";
 {
   setup-travlangc.byte-build-env;
   travlangc.byte;
   compiler_reference = "${test_source_directory}/anonymous.travlangc.reference";
   check-travlangc.byte-output;
 }{
   setup-travlangopt.byte-build-env;
   travlangopt.byte;
   {
     no-flambda;
     compiler_reference = "${test_source_directory}/anonymous.travlangopt.reference";
     check-travlangopt.byte-output;
   }{
     flambda;
     compiler_reference = "${test_source_directory}/anonymous.travlangopt.flambda.reference";
     check-travlangc.byte-output;
   }
 }
*)
