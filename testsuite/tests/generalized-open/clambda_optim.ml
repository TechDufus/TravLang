(* TEST
 compile_only = "true";
 no-flambda;
 setup-travlangopt.byte-build-env;
 travlangopt.byte;
 check-travlangopt.byte-output;
*)

module Stable = struct
  open struct module V0 = struct module U = struct end end end
  module V0 = V0.U
end
