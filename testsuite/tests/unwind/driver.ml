(* TEST
 script = "sh ${test_source_directory}/check-linker-version.sh";
 readonly_files = "mylib.mli mylib.ml stack_walker.c";
 macos;
 script;
 setup-travlangopt.byte-build-env;
 flags = "-opaque";
 module = "mylib.mli";
 travlangopt.byte;
 module = "";
 flags = "-cclib -Wl,-keep_dwarf_unwind";
 all_modules = "mylib.ml driver.ml stack_walker.c";
 program = "${test_build_directory}/unwind_test";
 travlangopt.byte;
 output = "${test_build_directory}/program-output";
 stdout = "${output}";
 stderr = "${output}";
 run;
 reference = "${test_source_directory}/unwind_test.reference";
 check-program-output;
*)

let () =
  Mylib.foo1 Mylib.bar 1 2 3 4 5 6 7 8 9 10;
  Mylib.foo2 Mylib.baz 1 2 3 4 5 6 7 8 9 10

(* https://github.com/travlang-multicore/travlang-multicore/issues/274 *)
let () =
  Mylib.foo1 Mylib.bob 1 2 3 4 5 6 7 8 9 10
