(* TEST
 readonly_files = "a.ml api.ml b.ml bug.ml c.ml factorial.c pack_client.ml \
  packed1.ml plugin2.ml plugin4.ml plugin_ext.ml \
  plugin_high_arity.ml plugin.ml plugin.mli plugin_ref.ml plugin_simple.ml \
  plugin_thread.ml";
 subdirectories = "sub";
 include systhreads;
 include dynlink;
 hassysthreads;
 libraries = ""; (* We will add them manually where appropriated *)
 native-dynlink;
 travlangopt_default_flags = "";(* Removes the -ccopt -no-pie on ised on OpenBSD *)
 setup-travlangopt.byte-build-env;
 module = "api.ml";
 travlangopt.byte;
 flags = "-opaque";
 module = "plugin.mli";
 travlangopt.byte;
 flags = "";
 module = "plugin.ml";
 travlangopt.byte;
 module = "";
 flags = "-shared";
 program = "plugin.so";
 all_modules = "plugin.cmx";
 travlangopt.byte;
 script = "mv plugin.cmx plugin.cmx.bak";
 script;
 flags = "";
 module = "plugin2.ml";
 travlangopt.byte;
 script = "mv plugin.cmx.bak plugin.cmx";
 script;
 module = "";
 flags = "-shared";
 program = "plugin2.so";
 all_modules = "plugin2.cmx";
 travlangopt.byte;
 flags = "";
 module = "sub/plugin.ml";
 travlangopt.byte;
 module = "";
 flags = "-shared";
 program = "sub/plugin.so";
 all_modules = "sub/plugin.cmx";
 travlangopt.byte;
 cwd = "sub";
 cd;
 module = "api.mli";
 flags = "-opaque";
 travlangopt.byte;
 flags = "";
 module = "api.ml";
 travlangopt.byte;
 script = "mv api.cmx api.cmx.bak";
 script;
 module = "plugin3.ml";
 travlangopt.byte;
 script = "mv api.cmx.bak api.cmx";
 script;
 cwd = "..";
 cd;
 module = "";
 flags = "-shared";
 program = "sub/plugin3.so";
 all_modules = "sub/plugin3.cmx";
 travlangopt.byte;
 flags = "";
 module = "plugin4.ml";
 travlangopt.byte;
 module = "";
 flags = "-shared";
 program = "plugin4.so";
 all_modules = "plugin4.cmx";
 travlangopt.byte;
 module = "packed1.ml";
 flags = "-for-pack Mypack";
 travlangopt.byte;
 flags = "-S -pack";
 module = "";
 program = "mypack.cmx";
 all_modules = "packed1.cmx";
 travlangopt.byte;
 program = "mypack.so";
 flags = "-shared";
 all_modules = "mypack.cmx";
 travlangopt.byte;
 program = "packed1.so";
 flags = "-shared";
 all_modules = "packed1.cmx";
 travlangopt.byte;
 flags = "";
 module = "pack_client.ml";
 travlangopt.byte;
 module = "";
 program = "pack_client.so";
 flags = "-shared";
 all_modules = "pack_client.cmx";
 travlangopt.byte;
 flags = "";
 module = "plugin_ref.ml";
 travlangopt.byte;
 module = "";
 program = "plugin_ref.so";
 flags = "-shared";
 all_modules = "plugin_ref.cmx";
 travlangopt.byte;
 flags = "";
 module = "plugin_high_arity.ml";
 travlangopt.byte;
 module = "";
 program = "plugin_high_arity.so";
 flags = "-shared";
 all_modules = "plugin_high_arity.cmx";
 travlangopt.byte;
 flags = "-ccopt ${shared_library_cflags}";
 module = "factorial.c";
 travlangopt.byte;
 flags = "";
 module = "plugin_ext.ml";
 travlangopt.byte;
 module = "";
 program = "plugin_ext.so";
 flags = "-shared";
 all_modules = "factorial.${objext} plugin_ext.cmx";
 travlangopt.byte;
 module = "plugin_simple.ml";
 flags = "";
 travlangopt.byte;
 {
   module = "";
   program = "plugin_simple.so";
   flags = "-shared";
   all_modules = "plugin_simple.cmx";
   travlangopt.byte;
 }{
   module = "bug.ml";
   flags = "";
   travlangopt.byte;
   {
     module = "";
     program = "bug.so";
     flags = "-shared";
     all_modules = "bug.cmx";
     travlangopt.byte;
   }{
     module = "plugin_thread.ml";
     flags = "";
     travlangopt.byte;
     module = "";
     program = "plugin_thread.so";
     flags = "-shared";
     all_modules = "plugin_thread.cmx";
     travlangopt.byte;
     program = "plugin4_unix.so";
     all_modules = "unix.cmxa plugin4.cmx";
     travlangopt.byte;
     flags = "";
     compile_only = "true";
     all_modules = "a.ml b.ml c.ml main.ml";
     travlangopt.byte;
     module = "";
     compile_only = "false";
     flags = "-shared";
     program = "a.so";
     all_modules = "a.cmx";
     travlangopt.byte;
     program = "b.so";
     all_modules = "b.cmx";
     travlangopt.byte;
     program = "c.so";
     all_modules = "c.cmx";
     travlangopt.byte;
     program = "mylib.cmxa";
     flags = "-a";
     all_modules = "plugin.cmx plugin2.cmx";
     travlangopt.byte;
     program = "mylib.so";
     flags = "-shared -linkall";
     all_modules = "mylib.cmxa";
     travlangopt.byte;
     program = "${test_build_directory}/main.exe";
     libraries = "unix threads dynlink";
     flags = "-linkall";
     all_modules = "api.cmx main.cmx";
     travlangopt.byte;
 (*
 On OpenBSD, the compiler produces warnings like
 /usr/bin/ld: warning: creating a DT_TEXTREL in a shared object.
 So the compiler output is not empty on OpenBSD so an emptiness check
 would fail on this platform.

 We thus do not check compiler output. This was not done either before the
 test was ported to travlangtest.
 *)

     arguments = "plugin.so plugin2.so plugin_thread.so";
     run;
     check-program-output;
   }
 }
*)

let () =
  Api.add_cb (fun () -> print_endline "Callback from main")

let ()  =
  Dynlink.allow_unsafe_modules true;
  for i = 1 to Array.length Sys.argv - 1 do
    let name = Sys.argv.(i) in
    Printf.printf "Loading %s\n" name; flush stdout;
    try
      if name.[0] = '-'
      then Dynlink.loadfile_private
        (String.sub name 1 (String.length name - 1))
      else Dynlink.loadfile name
    with
      | Dynlink.Error err ->
          Printf.printf "Dynlink error: %s\n"
            (Dynlink.error_message err)
      | exn ->
          Printf.printf "Error: %s\n" (Printexc.to_string exn)
  done;
  flush stdout;
  try
    let oc = open_out_bin "marshal.data" in
    Marshal.to_channel oc !Api.cbs [Marshal.Closures];
    close_out oc;
    let ic = open_in_bin "marshal.data" in
    let l = (Marshal.from_channel ic : (unit -> unit) list) in
    close_in ic;
    List.iter (fun f -> f()) l
  with Failure s ->
    Printf.printf "Failure: %s\n" s
