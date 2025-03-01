(* TEST
 readonly_files = "cmdline_prog.ml";
 hasunix;
 {
   program = "${test_build_directory}/test_unix_cmdline.byte";
   setup-travlangc.byte-build-env;
   program = "${test_build_directory}/cmdline_prog.exe";
   all_modules = "cmdline_prog.ml";
   travlangc.byte;
   include unix;
   program = "${test_build_directory}/test_unix_cmdline.byte";
   all_modules = "test_unix_cmdline.ml";
   travlangc.byte;
   check-travlangc.byte-output;
   run;
   check-program-output;
 }{
   program = "${test_build_directory}/test_unix_cmdline.opt";
   setup-travlangopt.byte-build-env;
   program = "${test_build_directory}/cmdline_prog.exe";
   all_modules = "cmdline_prog.ml";
   travlangc.byte;
   include unix;
   program = "${test_build_directory}/test_unix_cmdline.opt";
   all_modules = "test_unix_cmdline.ml";
   travlangopt.byte;
   check-travlangopt.byte-output;
   run;
   check-program-output;
 }
*)

let prog_name = "cmdline_prog.exe"

let run args =
  let out, inp = Unix.pipe () in
  let in_chan = Unix.in_channel_of_descr out in
  set_binary_mode_in in_chan false;
  let pid =
    Unix.create_process ("./" ^ prog_name) (Array.of_list (prog_name :: args))
      Unix.stdin inp Unix.stderr in
  List.iter (fun arg ->
      let s = input_line in_chan in
      Printf.printf "%S -> %S [%s]\n" arg s (if s = arg then "OK" else "FAIL")
    ) args;
  close_in in_chan;
  let _, exit = Unix.waitpid [] pid in
  assert (exit = Unix.WEXITED 0)

let exec args =
  Unix.execv ("./" ^ prog_name) (Array.of_list (prog_name :: args))

let () =
  List.iter run
    [
      [""; ""; "\t \011"];
      ["a"; "b"; "c.txt@!"];
      ["\""];
      [" "; " a "; "  \" \\\" "];
      [" \\ \\ \\\\\\"];
      [" \"hola \""];
      ["a\tb"];
    ];
  Printf.printf "-- execv\n%!";
  exec [
     "";
     "a"; "b"; "c.txt@!";
     "\"";
     " "; " a "; "  \" \\\" ";
     " \\ \\ \\\\\\";
     " \"hola \"";
     "a\tb"
  ]
