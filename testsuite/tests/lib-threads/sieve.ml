(* TEST
 script = "sh ${test_source_directory}/test-runtime-cleanup.sh";
 include systhreads;
 hassysthreads;
 script;
 {
   output = "${test_build_directory}/program-output";
   stdout = "${output}";
   bytecode;
 }{
   output = "${test_build_directory}/program-output";
   stdout = "${output}";
   native;
 }
*)

(* This test is skipped in "runtime cleanup at exit" mode
   (travlangRUNPARAM contains c=1) because the cleanup in the main thread
   destroys condition variables that are waited for by other threads,
   causing a deadlock on some systems. *)

let sieve primes =
  Event.sync (Event.send primes 2);
  let integers = Event.new_channel () in
  let rec enumerate n =
    Event.sync (Event.send integers n);
    enumerate (n + 2)
  and filter input =
    let n = Event.sync (Event.receive input)
    and output = Event.new_channel () in
    Event.sync (Event.send primes n);
    ignore(Thread.create filter output);
    (* We remove from the output the multiples of n *)
    while true do
        let m = Event.sync (Event.receive input) in
        (* print_int n; print_string ": "; print_int m; print_newline(); *)
        if m mod n <> 0 then Event.sync (Event.send output m)
      done in
  ignore(Thread.create filter integers);
  ignore(Thread.create enumerate 3)

let primes = Event.new_channel ()

let _ =
  ignore(Thread.create sieve primes);
  for i = 1 to 50 do
    let n = Event.sync (Event.receive primes) in
    print_int n; print_newline()
  done
