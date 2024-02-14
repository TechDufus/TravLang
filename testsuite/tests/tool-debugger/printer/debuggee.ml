(* TEST_BELOW
(* Blank lines added here to preserve locations. *)












*)

let f x =
  for _i = 0 to x do
    print_endline "..."
  done

let () = f 3

(* TEST
 flags += " -g ";
 travlangdebug_script = "${test_source_directory}/input_script";
 readonly_files = "printer.ml";
 include debugger;
 debugger;
 shared-libraries;
 setup-travlangc.byte-build-env;
 {
   module = "printer.ml";
   travlangc.byte;
 }{
   travlangc.byte;
   check-travlangc.byte-output;
   travlangdebug;
   check-program-output;
 }
*)
