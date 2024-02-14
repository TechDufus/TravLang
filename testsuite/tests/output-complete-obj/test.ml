(* TEST
 no-tsan; (* option -output-complete-obj is not supported with tsan *)
 readonly_files = "test.ml_stub.c";
 {
   setup-travlangc.byte-build-env;
   flags = "-w -a -output-complete-obj";
   program = "test.ml.bc.${objext}";
   travlangc.byte;
   script = "${cc} ${cppflags} ${cflags} -I${travlangsrcdir}/runtime -c test.ml_stub.c";
   script;
   script = "${mkexe} -I${travlangsrcdir}/runtime -o test.ml_bc_stub.exe test.ml.bc.${objext} ${bytecc_libs} test.ml_stub.${objext}";
   output = "${compiler_output}";
   script;
   program = "./test.ml_bc_stub.exe";
   stdout = "program-output";
   stderr = "program-output";
   run;
 }{
   setup-travlangopt.byte-build-env;
   flags = "-w -a -output-complete-obj";
   program = "test.ml.exe.${objext}";
   travlangopt.byte;
   script = "${cc} ${cppflags} ${cflags} -I${travlangsrcdir}/runtime -c test.ml_stub.c";
   script;
   script = "${mkexe} -I${travlangsrcdir}/runtime -o test.ml_stub.exe test.ml.exe.${objext} ${nativecc_libs} test.ml_stub.${objext}";
   output = "${compiler_output}";
   script;
   program = "./test.ml_stub.exe";
   stdout = "program-output";
   stderr = "program-output";
   run;
 }
*)

let () = Printf.printf "Test!!\n%!"
