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

/* The bytecode interpreter */

#ifndef CAML_INTERP_H
#define CAML_INTERP_H

#ifdef CAML_INTERNALS

#include "misc.h"
#include "mlvalues.h"

/* interpret a bytecode */
value caml_interprete (code_t prog, asize_t prog_size);

#endif /* CAML_INTERNALS */

#endif /* CAML_INTERP_H */
