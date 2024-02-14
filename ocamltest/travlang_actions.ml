(**************************************************************************)
(*                                                                        *)
(*                                 travlang                                  *)
(*                                                                        *)
(*             Sebastien Hinderer, projet Gallium, INRIA Paris            *)
(*                                                                        *)
(*   Copyright 2017 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* Actions specific to the travlang compilers *)

open travlangtest_stdlib
open Actions

(* Extracting information from environment *)

let no_native_compilers _log env =
  (Result.skip_with_reason "native compilers disabled", env)

let native_action a =
  if travlangtest_config.native_compiler then a
  else (Actions.update a no_native_compilers)

let get_backend_value_from_env env bytecode_var native_var =
  travlang_backends.make_backend_function
    (Environments.safe_lookup bytecode_var env)
    (Environments.safe_lookup native_var env)

let modules env =
  Actions_helpers.words_of_variable env travlang_variables.modules

let plugins env =
  Actions_helpers.words_of_variable env travlang_variables.plugins

let directories env =
  Actions_helpers.words_of_variable env travlang_variables.directories

let directory_flags env =
  let f dir = ("-I " ^ dir) in
  let l = List.map f (directories env) in
  String.concat " " l

let flags env = Environments.safe_lookup travlang_variables.flags env

let last_flags env = Environments.safe_lookup travlang_variables.last_flags env

let travlanglex_flags env =
  Environments.safe_lookup travlang_variables.travlanglex_flags env

let travlangyacc_flags env =
  Environments.safe_lookup travlang_variables.travlangyacc_flags env

let filelist env variable extension =
  let value = Environments.safe_lookup variable env in
  let filenames = String.words value in
  let add_extension filename = Filename.make_filename filename extension in
  String.concat " " (List.map add_extension filenames)

let libraries backend env =
  let extension = travlang_backends.library_extension backend in
  filelist env travlang_variables.libraries extension

let binary_modules backend env =
  let extension = travlang_backends.module_extension backend in
  filelist env travlang_variables.binary_modules extension

let backend_default_flags env =
  get_backend_value_from_env env
    travlang_variables.travlangc_default_flags
    travlang_variables.travlangopt_default_flags

let backend_flags env =
  get_backend_value_from_env env
    travlang_variables.travlangc_flags
    travlang_variables.travlangopt_flags

let env_setting env_reader default_setting =
  Printf.sprintf "%s=%s"
    env_reader.Clflags.env_var
    (env_reader.Clflags.print default_setting)

let default_travlang_env = [|
  "TERM=dumb";
  env_setting Clflags.color_reader Misc.Color.default_setting;
  env_setting Clflags.error_style_reader Misc.Error_style.default_setting;
|]

type module_generator = {
  description : string;
  command : string;
  flags : Environments.t -> string;
  generated_compilation_units :
    string -> (string * travlang_filetypes.t) list
}

let travlanglex =
{
  description = "lexer";
  command = travlang_commands.travlangrun_travlanglex;
  flags = travlanglex_flags;
  generated_compilation_units =
    fun lexer_name -> [(lexer_name, travlang_filetypes.Implementation)]
}

let travlangyacc =
{
  description = "parser";
  command = travlang_files.travlangyacc;
  flags = travlangyacc_flags;
  generated_compilation_units =
    fun parser_name ->
      [
        (parser_name, travlang_filetypes.Interface);
        (parser_name, travlang_filetypes.Implementation)
      ]
}

let generate_module generator output_variable input log env =
  let basename = fst input in
  let input_file = travlang_filetypes.make_filename input in
  let what =
    Printf.sprintf "Generating %s module from %s"
    generator.description input_file
  in
  Printf.fprintf log "%s\n%!" what;
  let commandline =
  [
    generator.command;
    generator.flags env;
    input_file
  ] in
  let expected_exit_status = 0 in
  let exit_status =
    Actions_helpers.run_cmd
      ~environment:default_travlang_env
      ~stdin_variable: travlang_variables.compiler_stdin
      ~stdout_variable:output_variable
      ~stderr_variable:output_variable
      ~append:true
      log env commandline in
  if exit_status=expected_exit_status
  then generator.generated_compilation_units basename
  else begin
    let reason =
      (Actions_helpers.mkreason
        what (String.concat " " commandline) exit_status) in
    Printf.fprintf log "%s\n%!" reason;
    []
  end

let generate_lexer = generate_module travlanglex

let generate_parser = generate_module travlangyacc

exception Cannot_compile_file_type of string

let prepare_module output_variable log env input =
  let input_type = snd input in
  let open travlang_filetypes in
  match input_type with
    | Implementation | Interface | C | Obj -> [input]
    | Binary_interface -> [input]
    | Backend_specific _ -> [input]
    | Lexer ->
      generate_lexer output_variable input log env
    | Grammar ->
      generate_parser output_variable input log env
    | Text | C_minus_minus | Other _ ->
      raise (Cannot_compile_file_type (string_of_filetype input_type))

let get_program_file backend env =
  let testfile = Actions_helpers.testfile env in
  let testfile_basename = Filename.chop_extension testfile in
  let program_filename =
    Filename.mkexe
      (Filename.make_filename
        testfile_basename (travlang_backends.executable_extension backend)) in
  let test_build_directory =
    Actions_helpers.test_build_directory env in
  Filename.make_path [test_build_directory; program_filename]

let is_c_file (_filename, filetype) = filetype=travlang_filetypes.C

let cmas_need_dynamic_loading directories libraries =
  let loads_c_code library =
    let library = Misc.find_in_path directories library in
    let ic = open_in_bin library in
    try
      let len_magic_number = String.length Config.cma_magic_number in
      let magic_number = really_input_string ic len_magic_number in
      if magic_number = Config.cma_magic_number then
        let toc_pos = input_binary_int ic in
        seek_in ic toc_pos;
        let toc = (input_value ic : Cmo_format.library) in
        close_in ic;
        if toc.Cmo_format.lib_dllibs <> [] then Some (Ok ()) else None
      else
        raise End_of_file
    with End_of_file
       | Sys_error _ ->
         begin try close_in ic with Sys_error _ -> () end;
         Some (Error ("Corrupt or non-CMA file: " ^ library))
  in
  List.find_map loads_c_code (String.words libraries)

let compile_program (compiler : travlang_compilers.compiler) log env =
  let program_variable = compiler#program_variable in
  let program_file = Environments.safe_lookup program_variable env in
  let all_modules =
    Actions_helpers.words_of_variable env travlang_variables.all_modules in
  let output_variable = compiler#output_variable in
  let prepare = prepare_module output_variable log env in
  let modules =
    List.concatmap prepare (List.map travlang_filetypes.filetype all_modules) in
  let has_c_file = List.exists is_c_file modules in
  let c_headers_flags =
    if has_c_file then travlang_flags.c_includes else "" in
  let expected_exit_status =
    travlang_tools.expected_exit_status env (compiler :> travlang_tools.tool) in
  let module_names =
    (binary_modules compiler#target env) ^ " " ^
    (String.concat " " (List.map travlang_filetypes.make_filename modules)) in
  let what = Printf.sprintf "Compiling program %s from modules %s"
    program_file module_names in
  Printf.fprintf log "%s\n%!" what;
  let compile_only =
    Environments.lookup_as_bool travlang_variables.compile_only env = Some true
  in
  let compile_flags =
    if compile_only then " -c " else ""
  in
  let output = if compile_only then "" else "-o " ^ program_file in
  let libraries = libraries compiler#target env in
  let cmas_need_dynamic_loading =
    if not Config.supports_shared_libraries &&
       compiler#target = travlang_backends.Bytecode then
      cmas_need_dynamic_loading (directories env) libraries
    else
      None
  in
  match cmas_need_dynamic_loading with
    | Some (Error reason) ->
        (Result.fail_with_reason reason, env)
    | _ ->
      let bytecode_links_c_code = (cmas_need_dynamic_loading = Some (Ok ())) in
      let commandline =
      [
        compiler#name;
        travlang_flags.runtime_flags env compiler#target
                                  (has_c_file || bytecode_links_c_code);
        c_headers_flags;
        travlang_flags.stdlib;
        directory_flags env;
        flags env;
        libraries;
        backend_default_flags env compiler#target;
        backend_flags env compiler#target;
        compile_flags;
        output;
        (Environments.safe_lookup travlang_variables.travlang_filetype_flag env);
        module_names;
        last_flags env
      ] in
      let exit_status =
        Actions_helpers.run_cmd
          ~environment:default_travlang_env
          ~stdin_variable: travlang_variables.compiler_stdin
          ~stdout_variable:compiler#output_variable
          ~stderr_variable:compiler#output_variable
          ~append:true
          log env commandline in
      if exit_status=expected_exit_status
      then (Result.pass, env)
      else begin
        let reason =
          (Actions_helpers.mkreason
            what (String.concat " " commandline) exit_status) in
        (Result.fail_with_reason reason, env)
      end

let compile_module compiler module_ log env =
  let expected_exit_status =
    travlang_tools.expected_exit_status env (compiler :> travlang_tools.tool) in
  let what = Printf.sprintf "Compiling module %s" module_ in
  Printf.fprintf log "%s\n%!" what;
  let module_with_filetype = travlang_filetypes.filetype module_ in
  let is_c = is_c_file module_with_filetype in
  let c_headers_flags =
    if is_c then travlang_flags.c_includes else "" in
  let commandline =
  [
    compiler#name;
    travlang_flags.stdlib;
    c_headers_flags;
    directory_flags env;
    flags env;
    libraries compiler#target env;
    backend_default_flags env compiler#target;
    backend_flags env compiler#target;
    "-c " ^ module_;
  ] in
  let exit_status =
    Actions_helpers.run_cmd
      ~environment:default_travlang_env
      ~stdin_variable: travlang_variables.compiler_stdin
      ~stdout_variable:compiler#output_variable
      ~stderr_variable:compiler#output_variable
      ~append:true
      log env commandline in
  if exit_status=expected_exit_status
  then (Result.pass, env)
  else begin
    let reason =
      (Actions_helpers.mkreason
        what (String.concat " " commandline) exit_status) in
    (Result.fail_with_reason reason, env)
  end

let module_has_interface directory module_name =
  let interface_name =
    travlang_filetypes.make_filename (module_name, travlang_filetypes.Interface) in
  let interface_fullpath = Filename.make_path [directory;interface_name] in
  Sys.file_exists interface_fullpath

let add_module_interface directory module_description =
  match module_description with
    | (filename, travlang_filetypes.Implementation) when
      module_has_interface directory filename ->
        [(filename, travlang_filetypes.Interface); module_description]
  | _ -> [module_description]

let print_module_names log description modules =
  Printf.fprintf log "%s modules: %s\n%!"
    description
    (String.concat " " (List.map travlang_filetypes.make_filename modules))

let find_source_modules log env =
  let source_directory = Actions_helpers.test_source_directory env in
  let specified_modules =
    List.map travlang_filetypes.filetype
      ((plugins env) @ (modules env) @ [(Actions_helpers.testfile env)]) in
  print_module_names log "Specified" specified_modules;
  let source_modules =
    List.concatmap
      (add_module_interface source_directory)
      specified_modules in
  print_module_names log "Source" source_modules;
  Environments.add
    travlang_variables.all_modules
    (String.concat " " (List.map travlang_filetypes.make_filename source_modules))
    env

let setup_tool_build_env tool log env =
  let source_directory = Actions_helpers.test_source_directory env in
  let testfile = Actions_helpers.testfile env in
  let testfile_basename = Filename.chop_extension testfile in
  let tool_reference_variable =
    tool#reference_variable in
  let tool_reference_prefix =
    Filename.make_path [source_directory; testfile_basename] in
  let tool_reference_file =
    tool#reference_file env tool_reference_prefix
  in
  let env =
    Environments.add_if_undefined
      tool_reference_variable
      tool_reference_file env
  in
  let source_modules =
    Actions_helpers.words_of_variable env travlang_variables.all_modules in
  let tool_directory_suffix =
    Environments.safe_lookup travlang_variables.compiler_directory_suffix env in
  let tool_directory_name =
    tool#directory ^ tool_directory_suffix in
  let build_dir = Filename.concat
    (Environments.safe_lookup
      Builtin_variables.test_build_directory_prefix env)
    tool_directory_name in
  let tool_output_variable = tool#output_variable in
  let tool_output_filename =
    Filename.make_filename tool#directory "output" in
  let tool_output_file =
    Filename.make_path [build_dir; tool_output_filename]
  in
  let env =
    Environments.add_if_undefined
      tool_output_variable
      tool_output_file env
  in
  Sys.force_remove tool_output_file;
  let env =
    Environments.add Builtin_variables.test_build_directory build_dir env in
  Actions_helpers.setup_build_env false source_modules log env

let setup_compiler_build_env (compiler : travlang_compilers.compiler) log env =
  let (r, env) = setup_tool_build_env compiler log env in
  if Result.is_pass r then
  begin
    let prog_var = compiler#program_variable in
    let prog_output_var = compiler#program_output_variable in
    let default_prog_file = get_program_file compiler#target env in
    let env = Environments.add_if_undefined prog_var default_prog_file env in
    let prog_file = Environments.safe_lookup prog_var env in
    let prog_output_file = prog_file ^ ".output" in
    let env = match prog_output_var with
      | None -> env
      | Some outputvar ->
        Environments.add_if_undefined outputvar prog_output_file env
    in
    (r, env)
  end else (r, env)

let setup_toplevel_build_env (toplevel : travlang_toplevels.toplevel) log env =
  setup_tool_build_env toplevel log env

let mk_compiler_env_setup name (compiler : travlang_compilers.compiler) =
  Actions.make ~name ~description:(Printf.sprintf "Setup build env (%s)" name)
    (setup_compiler_build_env compiler)

let mk_toplevel_env_setup name (toplevel : travlang_toplevels.toplevel) =
  Actions.make ~name
    ~description:(Printf.sprintf "Setup toplevel env (%s)" name)
    (setup_toplevel_build_env toplevel)

let setup_travlangc_byte_build_env =
  mk_compiler_env_setup
    "setup-travlangc.byte-build-env"
    travlang_compilers.travlangc_byte

let setup_travlangc_opt_build_env =
  native_action
    (mk_compiler_env_setup
      "setup-travlangc.opt-build-env"
      travlang_compilers.travlangc_opt)

let setup_travlangopt_byte_build_env =
  native_action
    (mk_compiler_env_setup
      "setup-travlangopt.byte-build-env"
      travlang_compilers.travlangopt_byte)

let setup_travlangopt_opt_build_env =
  native_action
    (mk_compiler_env_setup
      "setup-travlangopt.opt-build-env"
      travlang_compilers.travlangopt_opt)

let setup_travlang_build_env =
  mk_toplevel_env_setup
    "setup-travlang-build-env"
    travlang_toplevels.travlang

let setup_travlangnat_build_env =
  native_action
    (mk_toplevel_env_setup
      "setup-travlangnat-build-env"
      travlang_toplevels.travlangnat)

let compile (compiler : travlang_compilers.compiler) log env =
  match Environments.lookup_nonempty Builtin_variables.commandline env with
  | None ->
    begin
      match Environments.lookup_nonempty travlang_variables.module_ env with
      | None -> compile_program compiler log env
      | Some module_ -> compile_module compiler module_ log env
    end
  | Some cmdline ->
    let expected_exit_status =
      travlang_tools.expected_exit_status env (compiler :> travlang_tools.tool) in
    let what = Printf.sprintf "Compiling using commandline %s" cmdline in
    Printf.fprintf log "%s\n%!" what;
    let commandline = [compiler#name; cmdline] in
    let exit_status =
      Actions_helpers.run_cmd
        ~environment:default_travlang_env
        ~stdin_variable: travlang_variables.compiler_stdin
        ~stdout_variable:compiler#output_variable
        ~stderr_variable:compiler#output_variable
        ~append:true
        log env commandline in
    if exit_status=expected_exit_status
    then (Result.pass, env)
    else begin
      let reason =
        (Actions_helpers.mkreason
          what (String.concat " " commandline) exit_status) in
      (Result.fail_with_reason reason, env)
    end

(* Compile actions *)

let travlangc_byte =
  Actions.make
    ~name:"travlangc.byte"
    ~description:"Compile the program using travlangc.byte"
    (compile travlang_compilers.travlangc_byte)

let travlangc_opt =
  native_action
    (Actions.make
      ~name:"travlangc.opt"
      ~description:"Compile the program using travlangc.opt"
      (compile travlang_compilers.travlangc_opt))

let travlangopt_byte =
  native_action
    (Actions.make
      ~name:"travlangopt.byte"
      ~description:"Compile the program using travlangopt.byte"
      (compile travlang_compilers.travlangopt_byte))

let travlangopt_opt =
  native_action
    (Actions.make
      ~name:"travlangopt.opt"
      ~description:"Compile the program using travlangopt.opt"
      (compile travlang_compilers.travlangopt_opt))

let env_with_lib_unix env =
  let libunixdir = travlang_directories.libunix in
  let newlibs =
    match Environments.lookup travlang_variables.caml_ld_library_path env with
    | None -> libunixdir
    | Some libs -> libunixdir ^ " " ^ libs
  in
  Environments.add travlang_variables.caml_ld_library_path newlibs env

let debug log env =
  let program = Environments.safe_lookup Builtin_variables.program env in
  let what = Printf.sprintf "Debugging program %s" program in
  Printf.fprintf log "%s\n%!" what;
  let commandline =
  [
    travlang_commands.travlangrun_travlangdebug;
    travlang_flags.travlangdebug_default_flags;
    program
  ] in
  let systemenv =
    Environments.append_to_system_env
      default_travlang_env
      (env_with_lib_unix env)
  in
  let expected_exit_status = 0 in
  let exit_status =
    Actions_helpers.run_cmd
      ~environment:systemenv
      ~stdin_variable: travlang_variables.travlangdebug_script
      ~stdout_variable:Builtin_variables.output
      ~stderr_variable:Builtin_variables.output
      ~append:true
      log (env_with_lib_unix env) commandline in
  if exit_status=expected_exit_status
  then (Result.pass, env)
  else begin
    let reason =
      (Actions_helpers.mkreason
        what (String.concat " " commandline) exit_status) in
    (Result.fail_with_reason reason, env)
  end

let travlangdebug =
  Actions.make ~name:"travlangdebug" ~description:"Run travlangdebug on the program"
    debug

let objinfo log env =
  let tools_directory = travlang_directories.tools in
  let program = Environments.safe_lookup Builtin_variables.program env in
  let what = Printf.sprintf "Running travlangobjinfo on %s" program in
  Printf.fprintf log "%s\n%!" what;
  let commandline =
  [
    travlang_commands.travlangrun_travlangobjinfo;
    travlang_flags.travlangobjinfo_default_flags;
    program
  ] in
  let travlanglib = [| (Printf.sprintf "travlangLIB=%s" tools_directory) |] in
  let systemenv =
    Environments.append_to_system_env
      (Array.concat
       [
         default_travlang_env;
         travlanglib;
       ])
      (env_with_lib_unix env)
  in
  let expected_exit_status = 0 in
  let exit_status =
    Actions_helpers.run_cmd
      ~environment:systemenv
      ~stdout_variable:Builtin_variables.output
      ~stderr_variable:Builtin_variables.output
      ~append:true
      log (env_with_lib_unix env) commandline in
  if exit_status=expected_exit_status
  then (Result.pass, env)
  else begin
    let reason =
      (Actions_helpers.mkreason
        what (String.concat " " commandline) exit_status) in
    (Result.fail_with_reason reason, env)
  end

let travlangobjinfo =
  Actions.make ~name:"travlangobjinfo"
    ~description:"Run travlangobjinfo on the program" objinfo

let mklib log env =
  let program = Environments.safe_lookup Builtin_variables.program env in
  let what = Printf.sprintf "Running travlangmklib to produce %s" program in
  Printf.fprintf log "%s\n%!" what;
  let travlangc_command =
    String.concat " "
    [
      travlang_commands.travlangrun_travlangc;
      travlang_flags.stdlib;
    ]
  in
  let commandline =
  [
    travlang_commands.travlangrun_travlangmklib;
    "-travlangc '" ^ travlangc_command ^ "'";
    "-o " ^ program
  ] @ modules env in
  let expected_exit_status = 0 in
  let exit_status =
    Actions_helpers.run_cmd
      ~environment:default_travlang_env
      ~stdout_variable:travlang_variables.compiler_output
      ~stderr_variable:travlang_variables.compiler_output
      ~append:true
      log env commandline in
  if exit_status=expected_exit_status
  then (Result.pass, env)
  else begin
    let reason =
      (Actions_helpers.mkreason
        what (String.concat " " commandline) exit_status) in
    (Result.fail_with_reason reason, env)
  end

let travlangmklib =
  Actions.make ~name:"travlangmklib"
    ~description:"Run travlangmklib to produce the program" mklib

let finalise_codegen_cc test_basename _log env =
  let test_module =
    Filename.make_filename test_basename "s"
  in
  let archmod = travlang_files.asmgen_archmod in
  let modules = test_module ^ " " ^ archmod in
  let program = Filename.make_filename test_basename "out" in
  let env = Environments.add_bindings
  [
    travlang_variables.modules, modules;
    Builtin_variables.program, program;
  ] env in
  (Result.pass, env)

let finalise_codegen_msvc test_basename log env =
  let obj = Filename.make_filename test_basename travlangtest_config.objext in
  let src = Filename.make_filename test_basename "s" in
  let what = "Running Microsoft assembler" in
  Printf.fprintf log "%s\n%!" what;
  let commandline = [travlangtest_config.asm; obj; src] in
  let expected_exit_status = 0 in
  let exit_status =
    Actions_helpers.run_cmd
      ~environment:default_travlang_env
      ~stdout_variable:travlang_variables.compiler_output
      ~stderr_variable:travlang_variables.compiler_output
      ~append:true
      log env commandline in
  if exit_status=expected_exit_status
  then begin
    let archmod = travlang_files.asmgen_archmod in
    let modules = obj ^ " " ^ archmod in
    let program = Filename.make_filename test_basename "out" in
    let env = Environments.add_bindings
    [
      travlang_variables.modules, modules;
      Builtin_variables.program, program;
    ] env in
    (Result.pass, env)
  end else begin
    let reason =
      (Actions_helpers.mkreason
        what (String.concat " " commandline) exit_status) in
    (Result.fail_with_reason reason, env)
  end

let run_codegen log env =
  let testfile = Actions_helpers.testfile env in
  let testfile_basename = Filename.chop_extension testfile in
  let what = Printf.sprintf "Running codegen on %s" testfile in
  Printf.fprintf log "%s\n%!" what;
  let test_build_directory =
    Actions_helpers.test_build_directory env in
  let compiler_output =
    Filename.make_path [test_build_directory; "compiler-output"]
  in
  let env =
    Environments.add_if_undefined
      travlang_variables.compiler_output
      compiler_output
      env
  in
  let output_file = Filename.make_filename testfile_basename "output" in
  let output = Filename.make_path [test_build_directory; output_file] in
  let env = Environments.add Builtin_variables.output output env in
  let commandline =
  [
    travlang_commands.travlangrun_codegen;
    flags env;
    "-S " ^ testfile
  ] in
  let expected_exit_status =
    Actions_helpers.exit_status_of_variable env
      travlang_variables.codegen_exit_status
  in
  let exit_status =
    Actions_helpers.run_cmd
      ~environment:default_travlang_env
      ~stdout_variable:travlang_variables.compiler_output
      ~stderr_variable:travlang_variables.compiler_output
      ~append:true
      log env commandline in
  if exit_status=expected_exit_status
  then begin
    if exit_status=0
    then begin
      let finalise =
        if travlangtest_config.ccomptype="msvc"
        then finalise_codegen_msvc
        else finalise_codegen_cc
      in
      finalise testfile_basename log env
    end else (Result.pass, env)
  end else begin
    let reason =
      (Actions_helpers.mkreason
        what (String.concat " " commandline) exit_status) in
    (Result.fail_with_reason reason, env)
  end

let codegen =
  Actions.make ~name:"codegen" ~description:"Run codegen on the test file"
    run_codegen

let run_cc log env =
  let program = Environments.safe_lookup Builtin_variables.program env in
  let what = Printf.sprintf "Running C compiler to build %s" program in
  Printf.fprintf log "%s\n%!" what;
  let output_exe =
    if travlangtest_config.ccomptype="msvc" then "/Fe" else "-o "
  in
  let commandline =
  [
    travlangtest_config.cc;
    travlangtest_config.cflags;
    "-I" ^ travlang_directories.runtime;
    output_exe ^ program;
    Environments.safe_lookup Builtin_variables.arguments env;
  ] @ modules env in
  let expected_exit_status = 0 in
  let exit_status =
    Actions_helpers.run_cmd
      ~environment:default_travlang_env
      ~stdout_variable:travlang_variables.compiler_output
      ~stderr_variable:travlang_variables.compiler_output
      ~append:true
      log env commandline in
  if exit_status=expected_exit_status
  then (Result.pass, env)
  else begin
    let reason =
      (Actions_helpers.mkreason
        what (String.concat " " commandline) exit_status) in
    (Result.fail_with_reason reason, env)
  end

let cc =
  Actions.make ~name:"cc" ~description:"Run C compiler to build the program"
    run_cc

let run_expect_once input_file principal log env =
  let expect_flags = Sys.safe_getenv "EXPECT_FLAGS" in
  let repo_root = "-repo-root " ^ travlang_directories.srcdir in
  let principal_flag = if principal then "-principal" else "" in
  let commandline =
  [
    travlang_commands.travlangrun_expect;
    expect_flags;
    flags env;
    repo_root;
    principal_flag;
    input_file
  ] in
  let exit_status =
    Actions_helpers.run_cmd ~environment:default_travlang_env log env commandline
  in
  if exit_status=0 then (Result.pass, env)
  else begin
    let reason = (Actions_helpers.mkreason
      "expect" (String.concat " " commandline) exit_status) in
    (Result.fail_with_reason reason, env)
  end

let run_expect_twice input_file log env =
  let corrected filename = Filename.make_filename filename "corrected" in
  let (result1, env1) = run_expect_once input_file false log env in
  if Result.is_pass result1 then begin
    let intermediate_file = corrected input_file in
    let (result2, env2) =
      run_expect_once intermediate_file true log env1 in
    if Result.is_pass result2 then begin
      let output_file = corrected intermediate_file in
      let output_env = Environments.add_bindings
      [
        Builtin_variables.reference, input_file;
        Builtin_variables.output, output_file
      ] env2 in
      (Result.pass, output_env)
    end else (result2, env2)
  end else (result1, env1)

let run_expect log env =
  let input_file = Actions_helpers.testfile env in
  run_expect_twice input_file log env

let run_expect =
  Actions.make ~name:"run-expect" ~description:"Run expect test" run_expect

let make_check_tool_output name tool = Actions.make
  ~name
  ~description:(Printf.sprintf "Check tool output (%s)" name)
  (Actions_helpers.check_output
    tool#family
    tool#output_variable
    tool#reference_variable)

let check_travlangc_byte_output = make_check_tool_output
  "check-travlangc.byte-output" travlang_compilers.travlangc_byte

let check_travlangc_opt_output =
  native_action
    (make_check_tool_output
      "check-travlangc.opt-output" travlang_compilers.travlangc_opt)

let check_travlangopt_byte_output =
  native_action
    (make_check_tool_output
      "check-travlangopt.byte-output" travlang_compilers.travlangopt_byte)

let check_travlangopt_opt_output =
  native_action
    (make_check_tool_output
      "check-travlangopt.opt-output" travlang_compilers.travlangopt_opt)

let really_compare_programs backend comparison_tool log env =
  let program = Environments.safe_lookup Builtin_variables.program env in
  let program2 = Environments.safe_lookup Builtin_variables.program2 env in
  let what = Printf.sprintf "Comparing %s programs %s and %s"
    (travlang_backends.string_of_backend backend) program program2 in
  Printf.fprintf log "%s\n%!" what;
  let files = {
    Filecompare.filetype = Filecompare.Binary;
    Filecompare.reference_filename = program;
    Filecompare.output_filename = program2
  } in
  match Filecompare.compare_files ~tool:comparison_tool files with
  | Filecompare.Same -> (Result.pass, env)
  | Filecompare.Different ->
    let reason = Printf.sprintf "Files %s and %s are different"
      program program2 in
    (Result.fail_with_reason reason, env)
  | Filecompare.Unexpected_output -> assert false
  | Filecompare.Error (commandline, exitcode) ->
    let reason = Actions_helpers.mkreason what commandline exitcode in
    (Result.fail_with_reason reason, env)

let compare_programs backend comparison_tool log env =
  let compare_programs =
    Environments.lookup_as_bool travlang_variables.compare_programs env in
  if compare_programs = Some false then begin
    let reason = "program comparison disabled" in
    (Result.pass_with_reason reason, env)
  end else really_compare_programs backend comparison_tool log env

let make_bytecode_programs_comparison_tool =
  let travlangrun = travlang_files.travlangrun in
  let cmpbyt = travlang_files.cmpbyt in
  let tool_name = travlangrun ^ " " ^ cmpbyt in
  Filecompare.make_comparison_tool tool_name ""

let native_programs_comparison_tool = Filecompare.default_comparison_tool

let compare_bytecode_programs_code log env =
  let bytecode_programs_comparison_tool =
    make_bytecode_programs_comparison_tool in
  compare_programs
    travlang_backends.Bytecode bytecode_programs_comparison_tool log env

let compare_bytecode_programs =
  native_action
    (Actions.make
      ~name:"compare-bytecode-programs"
      ~description:"Compare the bytecode programs generated by travlangc.byte and \
        travlangc.opt"
      compare_bytecode_programs_code)

let compare_binary_files =
  native_action
    (Actions.make
      ~name:"compare-binary-files"
      ~description:"Compare the native programs generated by travlangopt.byte and \
        travlangopt.opt"
      (compare_programs travlang_backends.Native native_programs_comparison_tool))

let compile_module compiler compilername compileroutput log env
  (module_basename, module_filetype) =
  let backend = compiler#target in
  let filename =
    travlang_filetypes.make_filename (module_basename, module_filetype) in
  let expected_exit_status =
    travlang_tools.expected_exit_status env (compiler :> travlang_tools.tool) in
  let what = Printf.sprintf "%s for file %s (expected exit status: %d)"
    (travlang_filetypes.action_of_filetype module_filetype) filename
      (expected_exit_status) in
  let compile_commandline input_file output_file optional_flags =
    let compile = "-c " ^ input_file in
    let output = match output_file with
      | None -> ""
      | Some file -> "-o " ^ file in
    [
      compilername;
      travlang_flags.stdlib;
      flags env;
      backend_flags env backend;
      optional_flags;
      compile;
      output;
    ] in
  let exec commandline =
    Printf.fprintf log "%s\n%!" what;
    let exit_status =
      Actions_helpers.run_cmd
        ~stdin_variable: travlang_variables.compiler_stdin
        ~stdout_variable:compileroutput
        ~stderr_variable:compileroutput
        ~append:true log env commandline in
    if exit_status=expected_exit_status
    then (Result.pass, env)
    else begin
      let reason =
        (Actions_helpers.mkreason
          what (String.concat " " commandline) exit_status) in
      (Result.fail_with_reason reason, env)
    end in
  match module_filetype with
    | travlang_filetypes.Interface ->
      let interface_name =
        travlang_filetypes.make_filename
          (module_basename, travlang_filetypes.Interface) in
      let commandline = compile_commandline interface_name None "" in
      exec commandline
    | travlang_filetypes.Implementation ->
      let module_extension = travlang_backends.module_extension backend in
      let module_output_name =
        Filename.make_filename module_basename module_extension in
      let commandline =
        compile_commandline filename (Some module_output_name) "" in
      exec commandline
    | travlang_filetypes.C ->
      let object_extension = Config.ext_obj in
      let _object_filename = module_basename ^ object_extension in
      let commandline =
        compile_commandline filename None
          travlang_flags.c_includes in
      exec commandline
    | _ ->
      let reason = Printf.sprintf "File %s of type %s not supported yet"
        filename (travlang_filetypes.string_of_filetype module_filetype) in
      (Result.fail_with_reason reason, env)

let compile_modules compiler compilername compileroutput
    modules_with_filetypes log initial_env
  =
  let compile_mod env mod_ =
    compile_module compiler compilername compileroutput
    log env mod_ in
  let rec compile_mods env = function
    | [] -> (Result.pass, env)
    | m::ms ->
      (let (result, newenv) = compile_mod env m in
      if Result.is_pass result then (compile_mods newenv ms)
      else (result, newenv)) in
  compile_mods initial_env modules_with_filetypes

let run_test_program_in_toplevel (toplevel : travlang_toplevels.toplevel) log env =
  let backend = toplevel#backend in
  let libraries = libraries backend env in
  (* This is a sub-optimal check - skip the test if any libraries requiring
     C stubs are loaded. It would be better at this point to build a custom
     toplevel. *)
  let toplevel_supports_dynamic_loading =
    Config.supports_shared_libraries || backend <> travlang_backends.Bytecode
  in
  match cmas_need_dynamic_loading (directories env) libraries with
    | Some (Error reason) ->
      (Result.fail_with_reason reason, env)
    | Some (Ok ()) when not toplevel_supports_dynamic_loading ->
      (Result.skip, env)
    | _ ->
      let testfile = Actions_helpers.testfile env in
      let expected_exit_status =
        travlang_tools.expected_exit_status env (toplevel :> travlang_tools.tool) in
      let compiler_output_variable = toplevel#output_variable in
      let compiler = toplevel#compiler in
      let compiler_name = compiler#name in
      let modules_with_filetypes =
        List.map travlang_filetypes.filetype (modules env) in
      let (result, env) = compile_modules
        compiler compiler_name compiler_output_variable
        modules_with_filetypes log env in
      if Result.is_pass result then begin
        let what =
          Printf.sprintf "Running %s in %s toplevel \
                          (expected exit status: %d)"
          testfile
          (travlang_backends.string_of_backend backend)
          expected_exit_status in
        Printf.fprintf log "%s\n%!" what;
        let toplevel_name = toplevel#name in
        let travlang_script_as_argument =
          match
            Environments.lookup_as_bool
              travlang_variables.travlang_script_as_argument env
          with
          | None -> false
          | Some b -> b
        in
        let commandline =
        [
          toplevel_name;
          travlang_flags.toplevel_default_flags;
          toplevel#flags;
          travlang_flags.stdlib;
          directory_flags env;
          travlang_flags.include_toplevel_directory;
          flags env;
          libraries;
          binary_modules backend env;
          if travlang_script_as_argument then testfile else "";
          Environments.safe_lookup Builtin_variables.arguments env
        ] in
        let exit_status =
          if travlang_script_as_argument
          then Actions_helpers.run_cmd
            ~environment:default_travlang_env
            ~stdout_variable:compiler_output_variable
            ~stderr_variable:compiler_output_variable
            log env commandline
          else Actions_helpers.run_cmd
            ~environment:default_travlang_env
            ~stdin_variable:Builtin_variables.test_file
            ~stdout_variable:compiler_output_variable
            ~stderr_variable:compiler_output_variable
            log env commandline
        in
        if exit_status=expected_exit_status
        then (Result.pass, env)
        else begin
          let reason =
            (Actions_helpers.mkreason
              what (String.concat " " commandline) exit_status) in
          (Result.fail_with_reason reason, env)
        end
      end else (result, env)

let travlang = Actions.make
  ~name:"travlang"
  ~description:"Run the test program in the toplevel"
  (run_test_program_in_toplevel travlang_toplevels.travlang)

let travlangnat =
  native_action
    (Actions.make
      ~name:"travlangnat"
      ~description:"Run the test program in the native toplevel travlangnat"
      (run_test_program_in_toplevel travlang_toplevels.travlangnat))

let check_travlang_output = make_check_tool_output
  "check-travlang-output" travlang_toplevels.travlang

let check_travlangnat_output =
  native_action
    (make_check_tool_output
      "check-travlangnat-output" travlang_toplevels.travlangnat)

let config_variables _log env =
  Environments.add_bindings
  [
    travlang_variables.arch, travlangtest_config.arch;
    travlang_variables.travlangrun, travlang_files.travlangrun;
    travlang_variables.travlangc_byte, travlang_files.travlangc;
    travlang_variables.travlangopt_byte, travlang_files.travlangopt;
    travlang_variables.bytecc_libs, travlangtest_config.bytecc_libs;
    travlang_variables.nativecc_libs, travlangtest_config.nativecc_libs;
    travlang_variables.mkdll, travlangtest_config.mkdll;
    travlang_variables.mkexe, travlangtest_config.mkexe;
    travlang_variables.cpp, travlangtest_config.cpp;
    travlang_variables.cppflags, travlangtest_config.cppflags;
    travlang_variables.cc, travlangtest_config.cc;
    travlang_variables.cflags, travlangtest_config.cflags;
    travlang_variables.csc, travlangtest_config.csc;
    travlang_variables.csc_flags, travlangtest_config.csc_flags;
    travlang_variables.shared_library_cflags,
      travlangtest_config.shared_library_cflags;
    travlang_variables.objext, travlangtest_config.objext;
    travlang_variables.libext, travlangtest_config.libext;
    travlang_variables.asmext, travlangtest_config.asmext;
    travlang_variables.sharedobjext, travlangtest_config.sharedobjext;
    travlang_variables.travlangc_default_flags,
      travlangtest_config.travlangc_default_flags;
    travlang_variables.travlangopt_default_flags,
      travlangtest_config.travlangopt_default_flags;
    travlang_variables.travlangrunparam, Sys.safe_getenv "travlangRUNPARAM";
    travlang_variables.travlangsrcdir, travlang_directories.srcdir;
    travlang_variables.os_type, Sys.os_type;
  ] env

let flat_float_array = Actions.make
  ~name:"flat-float-array"
  ~description:"Passes if the compiler is configured with \
    --enable-flat-float-array"
  (Actions_helpers.pass_or_skip travlangtest_config.flat_float_array
    "compiler configured with --enable-flat-float-array"
    "compiler configured with --disable-flat-float-array")

let no_flat_float_array = make
  ~name:"no-flat-float-array"
  ~description:"Passes if the compiler is configured with \
    --disable-flat-float-array"
  (Actions_helpers.pass_or_skip (not travlangtest_config.flat_float_array)
    "compiler configured with --disable-flat-float-array"
    "compiler configured with --enable-flat-float")

let flambda = Actions.make
  ~name:"flambda"
  ~description:"Passes if the compiler is configured with flambda enabled"
  (Actions_helpers.pass_or_skip travlangtest_config.flambda
    "support for flambda enabled"
    "support for flambda disabled")

let no_flambda = make
  ~name:"no-flambda"
  ~description:"Passes if the compiler is NOT configured with flambda enabled"
  (Actions_helpers.pass_or_skip (not travlangtest_config.flambda)
    "support for flambda disabled"
    "support for flambda enabled")

let shared_libraries = Actions.make
  ~name:"shared-libraries"
  ~description:"Passes if shared libraries are supported"
  (Actions_helpers.pass_or_skip travlangtest_config.shared_libraries
    "Shared libraries are supported."
    "Shared libraries are not supported.")

let no_shared_libraries = Actions.make
  ~name:"no-shared-libraries"
  ~description:"Passes if shared libraries are NOT supported"
  (Actions_helpers.pass_or_skip (not travlangtest_config.shared_libraries)
    "Shared libraries are not supported."
    "Shared libraries are supported.")

let native_compiler = Actions.make
  ~name:"native-compiler"
  ~description:"Passes if the native compiler is available"
  (Actions_helpers.pass_or_skip travlangtest_config.native_compiler
    "native compiler available"
    "native compiler not available")

let native_dynlink = Actions.make
  ~name:"native-dynlink"
  ~description:"Passes if native dynlink support is available"
  (Actions_helpers.pass_or_skip (travlangtest_config.native_dynlink)
    "native dynlink support available"
    "native dynlink support not available")

let debugger = Actions.make
  ~name:"debugger"
  ~description:"Passes if the debugger is available"
  (Actions_helpers.pass_or_skip travlangtest_config.travlangdebug
     "debugger available"
     "debugger not available")

let instrumented_runtime = make
  ~name:"instrumented-runtime"
  ~description:"Passes if the instrumented runtime is available"
  (Actions_helpers.pass_or_skip (travlangtest_config.instrumented_runtime)
    "instrumented runtime available"
    "instrumented runtime not available")

let csharp_compiler = Actions.make
  ~name:"csharp-compiler"
  ~description:"Passes if the C# compiler is available"
  (Actions_helpers.pass_or_skip (travlangtest_config.csc<>"")
    "C# compiler available"
    "C# compiler not available")

let windows_unicode = Actions.make
  ~name:"windows-unicode"
  ~description:"Passes if Windows unicode support is available"
  (Actions_helpers.pass_or_skip (travlangtest_config.windows_unicode )
    "Windows Unicode support available"
    "Windows Unicode support not available")

let afl_instrument = Actions.make
  ~name:"afl-instrument"
  ~description:"Passes if AFL instrumentation is enabled"
  (Actions_helpers.pass_or_skip travlangtest_config.afl_instrument
    "AFL instrumentation enabled"
    "AFL instrumentation disabled")

let no_afl_instrument = Actions.make
  ~name:"no-afl-instrument"
  ~description:"Passes if AFL instrumentation is NOT enabled"
  (Actions_helpers.pass_or_skip (not travlangtest_config.afl_instrument)
    "AFL instrumentation disabled"
    "AFL instrumentation enabled")

let travlangdoc = travlang_tools.travlangdoc

let travlangdoc_output_file env prefix =
  let backend =
    Environments.safe_lookup travlang_variables.travlangdoc_backend env in
  let suffix = match backend with
    | "latex" -> ".tex"
    | "html" -> ".html"
    | "man" -> ".3o"
    | _ -> ".result" in
  prefix ^ suffix

let check_travlangdoc_output = make_check_tool_output
  "check-travlangdoc-output" travlangdoc

let travlangdoc_flags env =
  Environments.safe_lookup travlang_variables.travlangdoc_flags env

let compiled_doc_name input = input ^ ".odoc"

(* The compiler used for compiling both cmi file
   and plugins *)
let compiler_for_travlangdoc =
  let compiler = travlang_compilers.travlangc_byte in
  compile_modules compiler compiler#name
    compiler#output_variable

(* Within travlangdoc tests,
   modules="a.ml b.ml" is interpreted as a list of
   secondaries documentation modules that need to be
   compiled into cmi files and odoc file (serialized travlangdoc information)
   before the main documentation is generated *)
let compile_travlangdoc (basename,filetype as module_) log env =
  let expected_exit_status =
    travlang_tools.expected_exit_status env (travlangdoc :> travlang_tools.tool) in
  let what = Printf.sprintf "Compiling documentation for module %s" basename in
  Printf.fprintf log "%s\n%!" what;
  let filename =
    travlang_filetypes.make_filename (basename, filetype) in
  let (r,env) = compiler_for_travlangdoc [module_] log env in
  if not (Result.is_pass r) then (r,env) else
  let commandline =
    (* currently, we are ignoring the global travlangdoc_flags, since we
       don't have per-module flags *)
    [
    travlang_commands.travlangrun_travlangdoc;
    travlang_flags.stdlib;
    "-dump " ^ compiled_doc_name basename;
     filename;
  ] in
  let exit_status =
    Actions_helpers.run_cmd
      ~environment:(Environments.to_system_env env)
      ~stdin_variable: travlang_variables.compiler_stdin
      ~stdout_variable:travlangdoc#output_variable
      ~stderr_variable:travlangdoc#output_variable
      ~append:true
      log env commandline in
  if exit_status=expected_exit_status
  then (Result.pass, env)
  else begin
    let reason =
      (Actions_helpers.mkreason
        what (String.concat " " commandline) exit_status) in
    (Result.fail_with_reason reason, env)
  end

let rec travlangdoc_compile_all log env = function
  | [] -> (Result.pass, env)
  | a :: q ->
      let (r,env) = compile_travlangdoc a log env in
      if Result.is_pass r then
        travlangdoc_compile_all log env q
      else
        (r,env)

let setup_travlangdoc_build_env =
  Actions.make ~name:"setup_travlangdoc_build_env"
    ~description:"Setup travlangdoc build environment" @@ fun log env ->
  let (r,env) = setup_tool_build_env travlangdoc log env in
  if not (Result.is_pass r) then (r,env) else
  let source_directory = Actions_helpers.test_source_directory env in
  let root_file = Filename.chop_extension (Actions_helpers.testfile env) in
  let reference_prefix = Filename.make_path [source_directory; root_file] in
  let output = travlangdoc_output_file env root_file in
  let reference= reference_prefix ^ travlangdoc#reference_filename_suffix env in
  let backend = Environments.safe_lookup travlang_variables.travlangdoc_backend env in
  let env =
    Environments.apply_modifiers env  travlang_modifiers.(str @ unix)
    |> Environments.add Builtin_variables.reference reference
    |> Environments.add Builtin_variables.output output in
  let env =
    if backend = "man" then Environments.add_if_undefined
        Builtin_variables.skip_header_lines "1" env
    else env in
  Result.pass, env

let travlangdoc_plugin name = name ^ ".cmo"

let travlangdoc_backend_flag env =
  let backend = Environments.safe_lookup travlang_variables.travlangdoc_backend env in
  if backend = "" then "" else "-" ^ backend

let travlangdoc_o_flag env =
  let output =  Environments.safe_lookup Builtin_variables.output env in
  match Environments.safe_lookup travlang_variables.travlangdoc_backend env with
  | "html" | "manual" -> "index"
  | _ -> output

let run_travlangdoc =
  Actions.make ~name:"travlangdoc" ~description:"Run travlangdoc on the test file" @@
  fun log env ->
  (* modules corresponds to secondaries modules of which the
     documentation and cmi files need to be build before the main
     module documentation *)
  let modules =  List.map travlang_filetypes.filetype @@ modules env in
  (* plugins are used for custom documentation generators *)
  let plugins = List.map travlang_filetypes.filetype @@ plugins env in
  let (r,env) = compiler_for_travlangdoc plugins log env in
  if not (Result.is_pass r) then r, env else
  let (r,env) = travlangdoc_compile_all log env modules in
  if not (Result.is_pass r) then r, env else
  let input_file = Actions_helpers.testfile env in
  Printf.fprintf log "Generating documentation for %s\n%!" input_file;
  let load_all =
    List.map (fun name -> "-load " ^ compiled_doc_name (fst name))
    @@ (* sort module in alphabetical order *)
    List.sort Stdlib.compare modules in
  let with_plugins =
    List.map (fun name -> "-g " ^ travlangdoc_plugin (fst name)) plugins in
  let commandline =
  [
    travlang_commands.travlangrun_travlangdoc;
    travlangdoc_backend_flag env;
    travlang_flags.stdlib;
    travlangdoc_flags env]
  @ load_all @ with_plugins @
   [ input_file;
     "-o"; travlangdoc_o_flag env
   ] in
  let exit_status =
    Actions_helpers.run_cmd ~environment:(Environments.to_system_env env)
      ~stdin_variable: travlang_variables.compiler_stdin
      ~stdout_variable:travlangdoc#output_variable
      ~stderr_variable:travlangdoc#output_variable
      ~append:true
      log env commandline in
  if exit_status=0 then
    (Result.pass, env)
  else begin
    let reason = (Actions_helpers.mkreason
      "travlangdoc" (String.concat " " commandline) exit_status) in
    (Result.fail_with_reason reason, env)
  end

let _ =
  Environments.register_initializer Environments.Post
    "find_source_modules" find_source_modules;
  Environments.register_initializer Environments.Pre
    "config_variables" config_variables;
  List.iter register
  [
    setup_travlangc_byte_build_env;
    travlangc_byte;
    check_travlangc_byte_output;
    setup_travlangc_opt_build_env;
    travlangc_opt;
    check_travlangc_opt_output;
    setup_travlangopt_byte_build_env;
    travlangopt_byte;
    check_travlangopt_byte_output;
    setup_travlangopt_opt_build_env;
    travlangopt_opt;
    check_travlangopt_opt_output;
    run_expect;
    compare_bytecode_programs;
    compare_binary_files;
    setup_travlang_build_env;
    travlang;
    check_travlang_output;
    setup_travlangnat_build_env;
    travlangnat;
    check_travlangnat_output;
    flat_float_array;
    no_flat_float_array;
    flambda;
    no_flambda;
    shared_libraries;
    no_shared_libraries;
    native_compiler;
    native_dynlink;
    debugger;
    instrumented_runtime;
    csharp_compiler;
    windows_unicode;
    afl_instrument;
    no_afl_instrument;
    setup_travlangdoc_build_env;
    run_travlangdoc;
    check_travlangdoc_output;
    travlangdebug;
    travlangmklib;
    codegen;
    cc;
    travlangobjinfo
  ]
