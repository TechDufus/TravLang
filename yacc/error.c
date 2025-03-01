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

/* Based on public-domain code from Berkeley Yacc */

/* routines for printing error messages  */

#include "defs.h"

/* String displayed if we can't malloc a buffer for the UTF-8 conversion */
static char *unknown = "<unknown; out of memory>";

void fatal(char *msg)
{
    fprintf(stderr, "%s: f - %s\n", myname, msg);
    done(2);
}


void no_space(void)
{
    fprintf(stderr, "%s: f - out of space\n", myname);
    done(2);
}


void open_error(char_os *filename)
{
    char *u8 = caml_stat_strdup_of_os(filename);
    fprintf(stderr, "%s: f - cannot open \"%s\"\n", myname, (u8 ? u8 : unknown));
    done(2);
}


void unexpected_EOF(void)
{
    fprintf(stderr, "File \"%s\", line %d: unexpected end-of-file\n",
            virtual_input_file_name, lineno);
    done(1);
}


static void print_pos(char *st_line, char *st_cptr)
{
    char *s;

    if (st_line == 0) return;
    for (s = st_line; *s != '\n'; ++s)
    {
        if (isprint((unsigned char) *s) || *s == '\t')
            putc(*s, stderr);
        else
            putc('?', stderr);
    }
    putc('\n', stderr);
    for (s = st_line; s < st_cptr; ++s)
    {
        if (*s == '\t')
            putc('\t', stderr);
        else
            putc(' ', stderr);
    }
    putc('^', stderr);
    putc('\n', stderr);
}


static Noreturn void gen_error(int st_lineno, char *st_line, char *st_cptr, char *msg)
{
    fprintf(stderr, "File \"%s\", line %d: %s\n",
            virtual_input_file_name, st_lineno, msg);
    print_pos(st_line, st_cptr);
    done(1);
}


void syntax_error(int st_lineno, char *st_line, char *st_cptr)
{
    gen_error(st_lineno, st_line, st_cptr, "syntax error");
}


void unterminated_comment(int c_lineno, char *c_line, char *c_cptr,
                          char start_char)
{
    gen_error(c_lineno, c_line, c_cptr,
              start_char == '/' ? "unmatched /*" : "unmatched (*");
}


void invalid_literal(int s_lineno, char *s_line, char *s_cptr)
{
    gen_error(s_lineno, s_line, s_cptr, "cannot use literal as token name");
}


void unterminated_string(int s_lineno, char *s_line, char *s_cptr)
{
    gen_error(s_lineno, s_line, s_cptr, "unterminated string");
}


void unterminated_text(int t_lineno, char *t_line, char *t_cptr)
{
    gen_error(t_lineno, t_line, t_cptr, "unmatched %{");
}


void illegal_character(char *c_cptr)
{
    fprintf(stderr, "File \"%s\", line %d: illegal character\n",
            virtual_input_file_name, lineno);
    print_pos(line, c_cptr);
    done(1);
}


void used_reserved(char *s)
{
    fprintf(stderr, "File \"%s\", line %d: illegal use of reserved symbol \
`%s'\n", virtual_input_file_name, lineno, s);
    done(1);
}


void tokenized_start(char *s)
{
     fprintf(stderr, "File \"%s\", line %d: the start symbol `%s' cannot \
be declared to be a token\n", virtual_input_file_name, lineno, s);
     done(1);
}


void retyped_warning(char *s)
{
    fprintf(stderr, "File \"%s\", line %d: warning: the type of `%s' has been \
redeclared\n", virtual_input_file_name, lineno, s);
}


void reprec_warning(char *s)
{
    fprintf(stderr, "File \"%s\", line %d: warning: the precedence of `%s' has \
been redeclared\n", virtual_input_file_name, lineno, s);
}


void revalued_warning(char *s)
{
    fprintf(stderr, "File \"%s\", line %d: warning: the value of `%s' has been \
redeclared\n", virtual_input_file_name, lineno, s);
}


void terminal_start(char *s)
{
    fprintf(stderr, "File \"%s\", line %d: the entry point `%s' is a \
token\n", virtual_input_file_name, lineno, s);
    done(1);
}

void too_many_entries(void)
{
    fprintf(stderr, "File \"%s\", line %d: more than %u entry points\n",
            virtual_input_file_name, lineno, MAX_ENTRY_POINT);
    done(1);
}


void no_grammar(void)
{
    fprintf(stderr, "File \"%s\", line %d: no grammar has been specified\n",
            virtual_input_file_name, lineno);
    done(1);
}


void terminal_lhs(int s_lineno)
{
    fprintf(stderr, "File \"%s\", line %d: a token appears on the lhs \
of a production\n", virtual_input_file_name, s_lineno);
    done(1);
}


void prec_redeclared(void)
{
    fprintf(stderr, "File \"%s\", line %d: warning: conflicting %%prec \
specifiers\n", virtual_input_file_name, lineno);
}


void unterminated_action(int a_lineno, char *a_line, char *a_cptr)
{
    fprintf(stderr, "File \"%s\", line %d: unterminated action\n",
            virtual_input_file_name, a_lineno);
    print_pos(a_line, a_cptr);
    done(1);
}


void unknown_rhs(int i)
{
    fprintf(stderr, "File \"%s\", line %d: $%d is unbound\n",
            virtual_input_file_name, lineno, i);
    done(1);
}

void illegal_token_ref(int i, char *name)
{
    fprintf(stderr, "File \"%s\", line %d: $%d refers to terminal `%s', \
which has no argument\n",
            virtual_input_file_name, lineno, i, name);
    done(1);
}

void default_action_error(void)
{
    fprintf(stderr, "File \"%s\", line %d: no action specified for this \
production\n",
            virtual_input_file_name, lineno);
    done(1);
}


void undefined_goal(char *s)
{
    fprintf(stderr, "%s: e - the start symbol `%s' is undefined\n", myname, s);
    done(1);
}

void undefined_symbol(char *s)
{
    fprintf(stderr, "%s: e - the symbol `%s' is undefined\n", myname, s);
    done(1);
}


void entry_without_type(char *s)
{
    fprintf(stderr,
            "%s: e - no type has been declared for the start symbol `%s'\n",
            myname, s);
    done(1);
}

void polymorphic_entry_point(char *s)
{
    fprintf(stderr,
            "%s: e - the start symbol `%s' has a polymorphic type\n",
            myname, s);
    done(1);
}

void forbidden_conflicts(void)
{
    fprintf(stderr,
            "%s: the grammar has conflicts, but --strict was specified\n",
            myname);
    done(1);
}
