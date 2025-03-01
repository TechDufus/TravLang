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
#include <caml/fail.h>
#include "caml/unixsupport.h"

#ifdef HAS_SOCKETS

#include "caml/socketaddr.h"

CAMLprim value caml_unix_string_of_inet_addr(value a)
{
  char * res;
#ifdef HAS_IPV6
#ifdef _WIN32
  char buffer[64];
  union sock_addr_union sa;
  int len;
  int retcode;
  if (caml_string_length(a) == 16) {
    memset(&sa.s_inet6, 0, sizeof(struct sockaddr_in6));
    sa.s_inet6.sin6_family = AF_INET6;
    sa.s_inet6.sin6_addr = GET_INET6_ADDR(a);
    len = sizeof(struct sockaddr_in6);
  } else {
    memset(&sa.s_inet, 0, sizeof(struct sockaddr_in));
    sa.s_inet.sin_family = AF_INET;
    sa.s_inet.sin_addr = GET_INET_ADDR(a);
    len = sizeof(struct sockaddr_in);
  }
  retcode = getnameinfo
    (&sa.s_gen, len, buffer, sizeof(buffer), NULL, 0, NI_NUMERICHOST);
  if (retcode != 0)
    res = NULL;
  else
    res = buffer;
#else
  char buffer[64];
  if (caml_string_length(a) == 16)
    res = (char *)
      inet_ntop(AF_INET6, (const void *) &GET_INET6_ADDR(a),
                buffer, sizeof(buffer));
  else
    res = (char *)
      inet_ntop(AF_INET, (const void *) &GET_INET_ADDR(a),
                buffer, sizeof(buffer));
#endif
#else
  res = inet_ntoa(GET_INET_ADDR(a));
#endif
  if (res == NULL) caml_uerror("string_of_inet_addr", Nothing);
  return caml_copy_string(res);
}

#else

CAMLprim value caml_unix_string_of_inet_addr(value a)
{ caml_invalid_argument("string_of_inet_addr not implemented"); }

#endif
