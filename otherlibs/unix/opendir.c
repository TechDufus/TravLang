/**************************************************************************/
/*                                                                        */
/*                                 travlang                                  */
/*                                                                        */
/*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           */
/*                                                                        */
/*   Copyright 1996 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/signals.h>
#include "caml/unixsupport.h"
#include <sys/types.h>
#ifdef HAS_DIRENT
#include <dirent.h>
#else
#include <sys/dir.h>
#endif

CAMLprim value caml_unix_opendir(value path)
{
  CAMLparam1(path);
  DIR * d;
  value res;
  char * p;

  caml_unix_check_path(path, "opendir");
  p = caml_stat_strdup(String_val(path));
  caml_enter_blocking_section();
  d = opendir(p);
  caml_leave_blocking_section();
  caml_stat_free(p);
  if (d == (DIR *) NULL) caml_uerror("opendir", path);
  res = caml_alloc_small(1, Abstract_tag);
  DIR_Val(res) = d;
  CAMLreturn(res);
}
