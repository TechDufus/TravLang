(* TEST
 include unix;
 hasunix;
 not-windows;
 {
   bytecode;
 }{
   native;
 }
*)

(* this test checks that the domain lock is properly reinitialized
   in the child process after fork.
   See: https://github.com/travlang-multicore/travlang-multicore/issues/471 *)

let () =
  let fd = Unix.dup Unix.stdout in
  let ret = Unix.fork () in
  if ret = 0 then
    Unix.close fd
  else
    print_endline "OK"
