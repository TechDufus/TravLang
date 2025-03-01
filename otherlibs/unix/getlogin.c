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
#include <caml/alloc.h>
#include "caml/unixsupport.h"
#include <errno.h>

extern char * getlogin(void);

CAMLprim value caml_unix_getlogin(value unit)
{
  char * name;
  name = getlogin();
  if (name == NULL) caml_unix_error(ENOENT, "getlogin", Nothing);
  return caml_copy_string(name);
}
