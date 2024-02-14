(* TEST
 readonly_files = "test_functor.ml test_loc_modtype_type_eq.ml \
   test_loc_modtype_type_subst.ml test_loc_type_eq.ml test_loc_type_subst.ml \
   mpr7852.mli";
 setup-travlangc.byte-build-env;
 {
   module = "test_functor.ml";
   travlangc.byte;
 }{
   module = "test_loc_type_eq.ml";
   travlangc_byte_exit_status = "2";
   travlangc.byte;
 }{
   module = "test_loc_modtype_type_eq.ml";
   travlangc_byte_exit_status = "2";
   travlangc.byte;
 }{
   module = "test_loc_type_subst.ml";
   travlangc_byte_exit_status = "2";
   travlangc.byte;
 }{
   module = "test_loc_modtype_type_subst.ml";
   travlangc_byte_exit_status = "2";
   travlangc.byte;
 }{
   check-travlangc.byte-output;
 }{
   flags = "-w +32";
   module = "mpr7852.mli";
   travlangc_byte_exit_status = "0";
   travlangc.byte;
 }{
   check-travlangc.byte-output;
 }
*)
