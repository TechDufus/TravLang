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

#define CAML_INTERNALS

#include <errno.h>
#include <math.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/signals.h>
#include <caml/io.h>
#include "caml/unixsupport.h"
#include "cst2constr.h"

#ifndef S_IFLNK
#define S_IFLNK 0
#endif
#ifndef S_IFIFO
#define S_IFIFO 0
#endif
#ifndef S_IFSOCK
#define S_IFSOCK 0
#endif
#ifndef S_IFBLK
#define S_IFBLK 0
#endif

#ifndef EOVERFLOW
#define EOVERFLOW ERANGE
#endif

static const int file_kind_table[] = {
  S_IFREG, S_IFDIR, S_IFCHR, S_IFBLK, S_IFLNK, S_IFIFO, S_IFSOCK
};

/* Transform a (seconds, nanoseconds) time stamp (in the style of
   struct timespec) to a number of seconds in floating-point.
   Make sure the integer part of the result is always equal to [seconds]
   (issue #9490). */

static double stat_timestamp(time_t sec, long nsec)
{
  /* The conversion of sec to FP is exact for the foreseeable future.
     (It starts rounding when sec > 2^53, i.e. in 285 million years.) */
  double s = (double) sec;
  /* The conversion of nsec to fraction of seconds can round.
     Still, we have 0 <= n < 1.0. */
  double n = (double) nsec / 1e9;
  /* The sum s + n can round up, hence s <= t + <= s + 1.0 */
  double t = s + n;
  /* Detect the "round up to s + 1" case and decrease t so that
     its integer part is s. */
  if (t == s + 1.0) t = nextafter(t, s);
  return t;
}

static value stat_aux(int use_64, struct stat *buf)
{
  CAMLparam0();
  CAMLlocal5(atime, mtime, ctime, offset, v);

  #include "nanosecond_stat.h"
  atime = caml_copy_double(stat_timestamp(buf->st_atime, NSEC(buf, a)));
  mtime = caml_copy_double(stat_timestamp(buf->st_mtime, NSEC(buf, m)));
  ctime = caml_copy_double(stat_timestamp(buf->st_ctime, NSEC(buf, c)));
  #undef NSEC
  offset = use_64 ? Val_file_offset(buf->st_size) : Val_int (buf->st_size);
  v = caml_alloc_small(12, 0);
  Field (v, 0) = Val_int (buf->st_dev);
  Field (v, 1) = Val_int (buf->st_ino);
  Field (v, 2) = caml_unix_cst_to_constr(buf->st_mode & S_IFMT, file_kind_table,
                                    sizeof(file_kind_table) / sizeof(int), 0);
  Field (v, 3) = Val_int (buf->st_mode & 07777);
  Field (v, 4) = Val_int (buf->st_nlink);
  Field (v, 5) = Val_int (buf->st_uid);
  Field (v, 6) = Val_int (buf->st_gid);
  Field (v, 7) = Val_int (buf->st_rdev);
  Field (v, 8) = offset;
  Field (v, 9) = atime;
  Field (v, 10) = mtime;
  Field (v, 11) = ctime;
  CAMLreturn(v);
}

CAMLprim value caml_unix_stat(value path)
{
  CAMLparam1(path);
  int ret;
  struct stat buf;
  char * p;
  caml_unix_check_path(path, "stat");
  p = caml_stat_strdup(String_val(path));
  caml_enter_blocking_section();
  ret = stat(p, &buf);
  caml_leave_blocking_section();
  caml_stat_free(p);
  if (ret == -1) caml_uerror("stat", path);
  if (buf.st_size > Max_long && (buf.st_mode & S_IFMT) == S_IFREG)
    caml_unix_error(EOVERFLOW, "stat", path);
  CAMLreturn(stat_aux(0, &buf));
}

CAMLprim value caml_unix_lstat(value path)
{
  CAMLparam1(path);
  int ret;
  struct stat buf;
  char * p;
  caml_unix_check_path(path, "lstat");
  p = caml_stat_strdup(String_val(path));
  caml_enter_blocking_section();
#ifdef HAS_SYMLINK
  ret = lstat(p, &buf);
#else
  ret = stat(p, &buf);
#endif
  caml_leave_blocking_section();
  caml_stat_free(p);
  if (ret == -1) caml_uerror("lstat", path);
  if (buf.st_size > Max_long && (buf.st_mode & S_IFMT) == S_IFREG)
    caml_unix_error(EOVERFLOW, "lstat", path);
  CAMLreturn(stat_aux(0, &buf));
}

CAMLprim value caml_unix_fstat(value fd)
{
  int ret;
  struct stat buf;
  caml_enter_blocking_section();
  ret = fstat(Int_val(fd), &buf);
  caml_leave_blocking_section();
  if (ret == -1) caml_uerror("fstat", Nothing);
  if (buf.st_size > Max_long && (buf.st_mode & S_IFMT) == S_IFREG)
    caml_unix_error(EOVERFLOW, "fstat", Nothing);
  return stat_aux(0, &buf);
}

CAMLprim value caml_unix_stat_64(value path)
{
  CAMLparam1(path);
  int ret;
  struct stat buf;
  char * p;
  caml_unix_check_path(path, "stat");
  p = caml_stat_strdup(String_val(path));
  caml_enter_blocking_section();
  ret = stat(p, &buf);
  caml_leave_blocking_section();
  caml_stat_free(p);
  if (ret == -1) caml_uerror("stat", path);
  CAMLreturn(stat_aux(1, &buf));
}

CAMLprim value caml_unix_lstat_64(value path)
{
  CAMLparam1(path);
  int ret;
  struct stat buf;
  char * p;
  caml_unix_check_path(path, "lstat");
  p = caml_stat_strdup(String_val(path));
  caml_enter_blocking_section();
#ifdef HAS_SYMLINK
  ret = lstat(p, &buf);
#else
  ret = stat(p, &buf);
#endif
  caml_leave_blocking_section();
  caml_stat_free(p);
  if (ret == -1) caml_uerror("lstat", path);
  CAMLreturn(stat_aux(1, &buf));
}

CAMLprim value caml_unix_fstat_64(value fd)
{
  int ret;
  struct stat buf;
  caml_enter_blocking_section();
  ret = fstat(Int_val(fd), &buf);
  caml_leave_blocking_section();
  if (ret == -1) caml_uerror("fstat", Nothing);
  return stat_aux(1, &buf);
}
