(* TEST_BELOW
(* Blank lines added here to preserve locations. *)








*)

module Submodule = struct

  type t = unit

  let value = ()

  let pp (fmt : Format.formatter) (_ : t) : unit =
    Format.fprintf fmt "DEBUG: Aux.Submodule.pp"

end

let debug () =
  let value = Submodule.value in
  ignore value

;;

debug ();

(* TEST
 flags += " -g ";
 travlangdebug_script = "${test_source_directory}/input_script";
 debugger;
 shared-libraries;
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
 travlangdebug;
 check-program-output;
*)
