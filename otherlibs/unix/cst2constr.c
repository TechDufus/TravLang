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
#include <caml/fail.h>
#include "cst2constr.h"

value caml_unix_cst_to_constr(int n, const int *tbl, int size, int deflt)
{
  int i;
  for (i = 0; i < size; i++)
    if (n == tbl[i]) return Val_int(i);
  return Val_int(deflt);
}
