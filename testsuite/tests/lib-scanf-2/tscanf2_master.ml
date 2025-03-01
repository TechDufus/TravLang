(* TEST
 modules = "tscanf2_io.ml";
 include unix;
 readonly_files = "tscanf2_worker.ml";
 reference = "${test_source_directory}/tscanf2.reference";
 hasunix;
 {
   (* The bytecode test *)
   program = "${test_build_directory}/master.byte";
   setup-travlangc.byte-build-env;
   travlangc.byte; (* Compiles the master *)
   all_modules = "tscanf2_io.cmo tscanf2_worker.ml";
   program = "${test_build_directory}/worker.byte";
   travlangc.byte; (* Compiles the worker *)
   check-travlangc.byte-output;
   program = "${test_build_directory}/master.byte";
   arguments = "${test_build_directory}/worker.byte";
   run;
   check-program-output;
 }{
   (* The native test *)
   program = "${test_build_directory}/master.opt";
   setup-travlangopt.byte-build-env;
   travlangopt.byte; (* Compiles the master *)
   all_modules = "tscanf2_io.cmx tscanf2_worker.ml";
   program = "${test_build_directory}/worker.opt";
   travlangopt.byte; (* Compiles the worker *)
   check-travlangopt.byte-output;
   program = "${test_build_directory}/master.opt";
   arguments = "${test_build_directory}/worker.opt";
   run;
   check-program-output;
 }
*)

(* A very simple master:
   - first launch a worker process,
   - then repeat a random number of times:
     + print the string " Ping" on stderr,
     + send it to the worker,
     + and wait for its answer "-pong",
   - finally send the string "stop" to the worker
     and wait for its answer "OK, bye!"
     and die.

   Use the communication module Tscanf2_io.

   Usage: test_master <worker_name> *)

open Tscanf2_io;;

let worker = Sys.argv.(1);;
let ic, oc = Unix.open_process worker;;
let ib = Scanf.Scanning.from_channel ic;;
let ob = Buffer.create 1024;;

let send_string_ping ob = send_string ob oc " Ping";;
let send_string_stop ob = send_string ob oc "stop";;

let interact i =
  Printf.eprintf " Ping"; flush stderr;
  send_string_ping ob;
  let s = receive_string ib in
  if s <> "-pong" then failwith ("Master: unbound string " ^ s)
;;

begin
(*
  Random.self_init ();
  let n = max (Random.int 8) 1 in
*)
  let n = 8 in
  let rec loop i =
    if i > 0 then (interact i; loop (i - 1)) in
  loop n
end
;;

begin
  send_string_stop ob;
  let ack = receive_string ib in
  if ack = "OK, bye!"
  then (print_endline "Test OK."; exit 0)
  else (print_endline "Test Failed!"; exit 2)
end
;;
