(* TEST
 modules = "nocrypto.mli fortuna.ml rng.ml";
 {
   setup-travlangc.byte-build-env;
   {
     module = "nocrypto.mli";
     travlangc.byte;
   }{
     flags = "-for-pack Nocrypto";
     module = "fortuna.ml";
     travlangc.byte;
   }{
     flags = "-for-pack Nocrypto";
     module = "rng.ml";
     travlangc.byte;
   }{
     program = "nocrypto.cmo";
     flags = "-pack";
     all_modules = "fortuna.cmo rng.cmo";
     travlangc.byte;
   }
 }{
   setup-travlangopt.byte-build-env;
   {
     module = "nocrypto.mli";
     travlangopt.byte;
   }{
     flags = "-for-pack Nocrypto";
     module = "fortuna.ml";
     travlangopt.byte;
   }{
     flags = "-for-pack Nocrypto";
     module = "rng.ml";
     travlangopt.byte;
   }{
     program = "nocrypto.cmx";
     flags = "-pack";
     all_modules = "fortuna.cmx rng.cmx";
     travlangopt.byte;
   }
 }
*)
