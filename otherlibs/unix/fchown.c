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

#include <caml/fail.h>
#include <caml/mlvalues.h>
#include <caml/signals.h>
#include "caml/unixsupport.h"

#ifdef HAS_FCHMOD

CAMLprim value caml_unix_fchown(value fd, value uid, value gid)
{
  int result;
  caml_enter_blocking_section();
  result = fchown(Int_val(fd), Int_val(uid), Int_val(gid));
  caml_leave_blocking_section();
  if (result == -1) caml_uerror("fchown", Nothing);
  return Val_unit;
}

#else

CAMLprim value caml_unix_fchown(value fd, value uid, value gid)
{ caml_invalid_argument("fchown not implemented"); }

#endif
