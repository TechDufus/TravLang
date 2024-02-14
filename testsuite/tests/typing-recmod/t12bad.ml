(* TEST_BELOW
(* Blank lines added here to preserve locations. *)




*)

(* Bad (not regular) *)
module rec M :
    sig
      class ['a] c : 'a -> object
        method map : ('a -> 'b) -> 'b M.c
      end
    end
  = struct
      class ['a] c (x : 'a) = object
        method map : 'b. ('a -> 'b) -> 'b M.c
          = fun f -> new M.c (f x)
      end
    end;;

(* TEST
 flags = " -w -a ";
 travlangc_byte_exit_status = "2";
 setup-travlangc.byte-build-env;
 travlangc.byte;
 check-travlangc.byte-output;
*)
