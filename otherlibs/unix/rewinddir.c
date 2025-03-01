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
#include "caml/unixsupport.h"
#include <errno.h>
#include <sys/types.h>
#ifdef HAS_DIRENT
#include <dirent.h>
#else
#include <sys/dir.h>
#endif

#ifdef HAS_REWINDDIR

CAMLprim value caml_unix_rewinddir(value vd)
{
  DIR * d = DIR_Val(vd);
  if (d == (DIR *) NULL) caml_unix_error(EBADF, "rewinddir", Nothing);
  rewinddir(d);
  return Val_unit;
}

#else

CAMLprim value caml_unix_rewinddir(value d)
{ caml_invalid_argument("rewinddir not implemented"); }

#endif
