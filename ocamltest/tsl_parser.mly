/**************************************************************************/
/*                                                                        */
/*                                 travlang                                  */
/*                                                                        */
/*             Sebastien Hinderer, projet Gallium, INRIA Paris            */
/*                                                                        */
/*   Copyright 2016 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

/* Parser for the Tests Specification Language */

%{

open Location
open Tsl_ast

let mkstring s = make_string ~loc:(symbol_rloc()) s

let mkidentifier id = make_identifier ~loc:(symbol_rloc()) id

let mkenvstmt envstmt =
  let located_env_statement =
    make_environment_statement ~loc:(symbol_rloc()) envstmt in
  Environment_statement located_env_statement

%}

%token <[`Above | `Below]> TSL_BEGIN_C_STYLE
%token TSL_END_C_STYLE
%token <[`Above | `Below]> TSL_BEGIN_travlang_STYLE
%token TSL_END_travlang_STYLE
%token COMMA LEFT_BRACE RIGHT_BRACE SEMI
%token <int> TEST_DEPTH
%token EQUAL PLUSEQUAL
/* %token COLON */
%token INCLUDE SET UNSET WITH
%token <string> IDENTIFIER
%token <string> STRING

%start tsl_block tsl_script
%type <Tsl_ast.tsl_block> tsl_block
%type <Tsl_ast.t> tsl_script

%%

node:
| statement_list tree_list { Ast ($1, $2) }

tree_list:
| { [] }
| tree tree_list { $1 :: $2 }

tree:
| LEFT_BRACE node RIGHT_BRACE { $2 }

statement_list:
| { [] }
| statement statement_list { $1 :: $2 }

statement:
| env_item SEMI { $1 }
| identifier with_environment_modifiers SEMI { Test (0, $1, $2) }

tsl_script:
| TSL_BEGIN_C_STYLE node TSL_END_C_STYLE { $2 }
| TSL_BEGIN_travlang_STYLE node TSL_END_travlang_STYLE { $2 }

tsl_block:
| TSL_BEGIN_C_STYLE tsl_items TSL_END_C_STYLE { $2 }
| TSL_BEGIN_travlang_STYLE tsl_items TSL_END_travlang_STYLE { $2 }

tsl_items:
| { [] }
| tsl_item tsl_items { $1 :: $2 }

tsl_item:
| test_item { $1 }
| env_item { $1 }

test_item:
  TEST_DEPTH identifier with_environment_modifiers { (Test ($1, $2, $3)) }

with_environment_modifiers:
| { [] }
| WITH identifier opt_environment_modifiers { $2::(List.rev $3) }

opt_environment_modifiers:
| { [] }
| opt_environment_modifiers COMMA identifier { $3::$1 }

env_item:
| identifier EQUAL string
    { mkenvstmt (Assignment (false, $1, $3)) }
| identifier PLUSEQUAL string
    { mkenvstmt (Append ($1, $3)) }
| SET identifier EQUAL string
    { mkenvstmt (Assignment (true, $2, $4)) }
| UNSET identifier
    { mkenvstmt (Unset $2) }

| INCLUDE identifier
  { mkenvstmt (Include $2) }

identifier: IDENTIFIER { mkidentifier $1 }

string: STRING { mkstring $1 }

%%
