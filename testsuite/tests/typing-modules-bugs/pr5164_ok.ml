(* TEST
 flags = " -w -a ";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)

module type INCLUDING = sig
  include module type of List
  include module type of ListLabels
end

module Including_typed: INCLUDING = struct
  include List
  include ListLabels
end
