/**************************************************************************/
/*                                                                        */
/*                                 travlang                                  */
/*                                                                        */
/*          Xavier Leroy and Damien Doligez, INRIA Rocquencourt           */
/*                                                                        */
/*   Copyright 1996 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

/* Operations on mutexes from the travlang stdlib */

#ifndef CAML_SYNC_H
#define CAML_SYNC_H

#ifdef CAML_INTERNALS

#include "mlvalues.h"
#include "platform.h"

typedef pthread_mutex_t * sync_mutex;

#define Mutex_val(v) (* ((sync_mutex *) Data_custom_val(v)))

CAMLextern int caml_mutex_lock(sync_mutex mut);
CAMLextern int caml_mutex_unlock(sync_mutex mut);

value caml_ml_mutex_lock(value wrapper);
value caml_ml_mutex_unlock(value wrapper);
value caml_ml_condition_broadcast(value wrapper);

#endif /* CAML_INTERNALS */

#endif /* CAML_SYNC_H */
