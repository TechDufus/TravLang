(* TEST
 travlang_script_as_argument = "true";
 travlang_exit_status = "2";
 setup-travlang-build-env;
 travlang;
 check-travlang-output;
*)

#1 "pr9701.ml"
Printexc.record_backtrace true;;

let f () = failwith "test";;
let proc () = f ();;
let () = proc ();;
