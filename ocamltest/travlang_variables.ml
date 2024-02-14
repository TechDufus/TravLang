(**************************************************************************)
(*                                                                        *)
(*                                 travlang                                  *)
(*                                                                        *)
(*             Sebastien Hinderer, projet Gallium, INRIA Paris            *)
(*                                                                        *)
(*   Copyright 2016 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* Definition of variables used by built-in actions *)

(* The variables are listed in alphabetical order *)

(*
  The name of the identifier representing a variable and its string name
  should be similar. Is there a way to enforce this?
*)

open travlangtest_stdlib

open Variables (* Should not be necessary with a ppx *)

let all_modules = make ("all_modules",
  "All the modules to compile and link")

let arch = make ("arch",
  "Host architecture")

let binary_modules = make ("binary_modules",
  "Additional binary modules to link")

let bytecc_libs = make ("bytecc_libs",
  "Libraries to link with for bytecode")

let cpp = make ("cpp",
  "Command to use to invoke the C preprocessor")

let cppflags = make ("cppflags",
  "Flags passed to the C preprocessor")

let cc = make ("cc",
  "Command to use to invoke the C compiler")

let cflags = make ("cflags",
  "Flags passed to the C compiler")

let caml_ld_library_path_name = "CAML_LD_LIBRARY_PATH"

let export_caml_ld_library_path value =
  let current_value = Sys.safe_getenv caml_ld_library_path_name in
  let local_value =
    (String.concat Filename.path_sep (String.words value)) in
  let new_value =
    if local_value="" then current_value else
    if current_value="" then local_value else
    String.concat Filename.path_sep [local_value; current_value] in
  (caml_ld_library_path_name, new_value)

let caml_ld_library_path =
  make_with_exporter
    export_caml_ld_library_path
    ("ld_library_path",
      "List of paths to lookup for loading dynamic libraries")

let codegen_exit_status = make ("codegen_exit_status",
  "Expected exit status of codegen")

let compare_programs = make ("compare_programs",
  "Set to \"false\" to disable program comparison")

let compiler_directory_suffix = make ("compiler_directory_suffix",
  "Suffix to add to the directory where the test will be compiled")

let compiler_reference = make ("compiler_reference",
  "Reference file for compiler output for travlangc.byte and travlangopt.byte")

let compiler_reference2 = make ("compiler_reference2",
  "Reference file for compiler output for travlangc.opt and travlangopt.opt")

let compiler_reference_suffix = make ("compiler_reference_suffix",
  "Suffix to add to the file name containing the reference for compiler output")

let compiler_output = make ("compiler_output",
  "Where to log output of bytecode compilers")

let compiler_output2 = make ("compiler_output2",
  "Where to log output of native compilers")

let compiler_stdin = make ("compiler_stdin",
  "standard input of compilers")

let compile_only = make ("compile_only",
  "Compile only (do not link)")

let csc = make ("csc", "Path to the CSharp compiler")

let csc_flags = make ("csc_flags", "Flags for the CSharp compiler")

let directories = make ("directories",
  "Directories to include by all the compilers")

let flags = make ("flags",
  "Flags passed to all the compilers")

let last_flags = make ("last_flags",
  "Flags passed to all the compilers at the end of the commandline")

let libraries = make ("libraries",
  "Libraries the program should be linked with")

let mkdll = make ("mkdll",
  "Command to use to build a DLL")

let mkexe = make ("mkexe",
  "Command used to build an executable program DLL")

let module_ = make ("module",
  "Compile one module at once")

let modules = make ("modules",
  "Other modules of the test")

let nativecc_libs = make ("nativecc_libs",
  "Libraries to link with for native code")

let objext = make ("objext",
  "Extension of object files")

let libext = make ("libext",
  "Extension of library files")

let asmext = make ("asmext",
  "Extension of assembly files")

let travlangc_byte = make ("travlangc_byte",
  "Path of the travlangc.byte executable")

let travlangopt_byte = make ("travlangopt_byte",
  "Path of the travlangopt.byte executable")

let travlangrun = make ("travlangrun",
  "Path of the travlangrun executable")

let travlangc_flags = make ("travlangc_flags",
  "Flags passed to travlangc.byte and travlangc.opt")

let travlangc_default_flags = make ("travlangc_default_flags",
  "Flags passed by default to travlangc.byte and travlangc.opt")



let travlanglex_flags = make ("travlanglex_flags",
  "Flags passed to travlanglex")

let travlangopt_flags = make ("travlangopt_flags",
  "Flags passed to travlangopt.byte and travlangopt.opt")

let travlangopt_default_flags = make ("travlangopt_default_flags",
  "Flags passed by default to travlangopt.byte and travlangopt.opt")

let travlangyacc_flags = make ("travlangyacc_flags",
  "Flags passed to travlangyacc")

let travlang_exit_status = make ("travlang_exit_status",
  "Expected exit status of travlang")

let travlang_filetype_flag = make ("travlang_filetype_flag",
  "Filetype of the testfile (-impl, -intf, etc.)")

let travlangc_byte_exit_status = make ("travlangc_byte_exit_status",
  "Expected exit status of ocac.byte")

let travlangopt_byte_exit_status = make ("travlangopt_byte_exit_status",
  "Expected exit status of travlangopt.byte")

let travlangnat_exit_status = make ("travlangnat_exit_status",
  "Expected exit status of travlangnat")

let travlangc_opt_exit_status = make ("travlangc_opt_exit_status",
  "Expected exit status of ocac.opt")

let travlangopt_opt_exit_status = make ("travlangopt_opt_exit_status",
  "Expected exit status of travlangopt.opt")

let export_travlangrunparam value =
  ("travlangRUNPARAM", value)

let travlangrunparam =
  make_with_exporter
    export_travlangrunparam
    ("travlangrunparam",
      "Equivalent of travlangRUNPARAM")

let travlangsrcdir = make ("travlangsrcdir",
  "Where travlang sources are")

let travlangdebug_flags = make ("travlangdebug_flags",
  "Flags for travlangdebug")

let travlangdebug_script = make ("travlangdebug_script",
  "Where travlangdebug should read its commands")

let os_type = make ("os_type",
  "The OS we are running on")

let travlangdoc_flags = Variables.make ("travlangdoc_flags",
  "travlangdoc flags")

let travlangdoc_backend = Variables.make ("travlangdoc_backend",
  "travlangdoc backend (html, latex, man, ... )")

let travlangdoc_exit_status =
  Variables.make ( "travlangdoc_exit_status", "expected travlangdoc exit status")

let travlangdoc_output =
  Variables.make ( "travlangdoc_output", "Where to log travlangdoc output")

let travlangdoc_reference =
  Variables.make ( "travlangdoc_reference",
                   "Where to find expected travlangdoc output")

let travlang_script_as_argument =
  Variables.make ( "travlang_script_as_argument",
    "Whether the travlang script should be passed as argument or on stdin")

let plugins =
  Variables.make ( "plugins", "plugins for travlangdoc" )

let shared_library_cflags =
  Variables.make ("shared_library_cflags",
    "Flags used to compile C files for inclusion in shared libraries")

let sharedobjext =
  Variables.make ("sharedobjext",
    "Extension of shared object files")

let use_runtime =
  Variables.make ("use_runtime",
    "Whether the -use-runtime option should be used" )

let _ = List.iter register_variable
  [
    all_modules;
    arch;
    binary_modules;
    bytecc_libs;
    cpp;
    cppflags;
    cc;
    cflags;
    caml_ld_library_path;
    codegen_exit_status;
    compare_programs;
    compiler_directory_suffix;
    compiler_reference;
    compiler_reference2;
    compiler_reference_suffix;
    compiler_output;
    compiler_output2;
    compiler_stdin;
    compile_only;
    csc;
    csc_flags;
    directories;
    flags;
    last_flags;
    libraries;
    mkdll;
    module_;
    modules;
    nativecc_libs;
    objext;
    libext;
    asmext;
    travlangc_byte;
    travlangopt_byte;
    travlangrun;
    travlangc_flags;
    travlangc_default_flags;
    travlangopt_flags;
    travlangopt_default_flags;
    travlang_exit_status;
    travlang_filetype_flag;
    travlangc_byte_exit_status;
    travlangopt_byte_exit_status;
    travlangnat_exit_status;
    travlangc_opt_exit_status;
    travlangopt_opt_exit_status;
    travlangrunparam;
    travlanglex_flags;
    travlangyacc_flags;
    travlangdoc_flags;
    travlangdoc_backend;
    travlangdoc_output;
    travlangdoc_reference;
    travlangdoc_exit_status;
    travlangdebug_flags;
    travlangdebug_script;
    travlang_script_as_argument;
    os_type;
    plugins;
    shared_library_cflags;
    sharedobjext;
    use_runtime;
  ]
