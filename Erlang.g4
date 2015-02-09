grammar Erlang;

root: form*;

form : attribute '.'
     | function '.'
     ;

attribute : '-' ATOM attr_val
	  | '-' ATOM typed_attr_val
          | '-' ATOM '(' typed_attr_val ')'
          | '-' 'spec' type_spec
          | '-' 'callback' type_spec
	  ;

type_spec : spec_fun type_sigs
          | '(' spec_fun type_sigs ')'
	  ;

spec_fun : ATOM
         | ATOM ':' ATOM
	 | ATOM '/' INTEGER '::'
	 | ATOM ':' ATOM '/' INTEGER '::'
	 ;

typed_attr_val : expr ',' typed_record_fields
               | expr '::' top_type
	       ;

typed_record_fields : '{' typed_exprs '}' ;

typed_exprs : typed_expr
            | typed_expr ',' typed_exprs
	    | expr ',' typed_exprs
	    | typed_expr ',' exprs
	    ;

typed_expr : expr '::' top_type ;

type_sigs : type_sig
          | type_sig ';' type_sigs
	  ;

type_sig : fun_type
         | fun_type 'when' type_guards
	 ;

type_guards : type_guard
            | type_guard ',' type_guards
	    ;

type_guard : ATOM '(' top_types ')'
           | VAR '::' top_type
	   ;

top_types : top_type
          | top_type ',' top_types
	  ;

top_type : VAR '::' top_type_100
         | top_type_100
	 ;

top_type_100 : type_200
             | type_200 '|' top_type_100
	     ;

type_200 : type_300 '..' type_300
         | type_300
	 ;

type_300 : type_300 add_op type_400
         | type_400
         ;

type_400 : type_400 mult_op type_500
         | type_500
         ;

type_500 : prefix_op type
         | type
	 ;

type : '(' top_type ')'
     | VAR
     | ATOM
     | ATOM '(' ')'
     | ATOM '(' top_types ')'
     | ATOM ':' ATOM '(' ')'
     | ATOM ':' ATOM '(' top_types ')'
     | '[' ']'
     | '[' top_type ']'
     | '[' top_type ',' '...' ']'
     | '#' '{' '}'
     | '#' '{' map_pair_types '}'
     | '{' '}'
     | '{' top_types '}'
     | '#' ATOM '{' '}'
     | '#' ATOM '{' field_types '}'
     | binary_type
     | INTEGER
     | 'fun' '(' ')'
     | 'fun' '(' fun_type_100 ')'
     ;

fun_type_100 : '(' '...' ')' '->' top_type
             | fun_type
	     ;

fun_type : '(' ')' '->' top_type
         | '(' top_types ')' '->' top_type
	 ;

map_pair_types : map_pair_type
               | map_pair_type ',' map_pair_types
	       ;

map_pair_type  : top_type '=>' top_type ;

field_types : field_type
            | field_type ',' field_types
	    ;

field_type : ATOM '::' top_type ;

binary_type : '<<' '>>'
            | '<<' bin_base_type '>>'
	    | '<<' bin_unit_type '>>'
	    | '<<' bin_base_type ',' bin_unit_type '>>'
	    ;

bin_base_type : VAR ':' type ;

bin_unit_type : VAR ':' VAR '*' type ;

attr_val : expr
         | expr ',' exprs
	 | '(' expr ',' exprs ')'
	 ;

function : function_clauses ;

function_clauses : function_clause
                 | function_clause ';' function_clauses
		 ;

function_clause : ATOM clause_args clause_guard clause_body ;

clause_args : argument_list ;

clause_guard : 'when' guard
             | 
	     ;

clause_body : '->' exprs ;

expr : 'catch' expr
     | expr_100
     ;

expr_100 : expr_150 '=' expr_100
         | expr_150 '!' expr_100
	 | expr_150
	 ;

expr_150 : expr_160 'orelse' expr_150
         | expr_160
	 ;

expr_160 : expr_200 'andalso' expr_160
         | expr_200
	 ;

expr_200 : expr_300 comp_op expr_300
         | expr_300
	 ;

expr_300 : expr_400 list_op expr_300
         | expr_400
	 ;

expr_400 : expr_400 add_op expr_500
         | expr_500
	 ;

expr_500 : expr_500 mult_op expr_600
         | expr_600
	 ;

expr_600 : prefix_op expr_700
         | map_expr
	 | expr_700
	 ;

expr_700 : function_call
         | record_expr
	 | expr_800
	 ;

expr_800 : expr_max ':' expr_max
         | expr_max
	 ;

expr_max : VAR
         | atomic
	 | list
	 | binary
	 | list_comprehension
	 | binary_comprehension
	 | tuple
//       | struct
         | '(' expr ')'
	 | 'begin' exprs 'end'
	 | if_expr
	 | case_expr
	 | receive_expr
	 | fun_expr
	 | try_expr
	 ;

list : '[' ']'
     | '[' expr tail
     ;

tail : ']'
     | '|' expr ']'
     | ',' expr tail
     ;

binary : '<<' '>>'
       | '<<' bin_elements '>>'
       ;

bin_elements : bin_element
             | bin_element ',' bin_elements
	     ;

bin_element : bit_expr opt_bit_size_expr opt_bit_type_list ;

bit_expr : prefix_op expr_max
         | expr_max
	 ;

opt_bit_size_expr : ':' bit_size_expr
                  | 
		  ;

opt_bit_type_list : '/' bit_type_list
                  | 
		  ;

bit_type_list : bit_type '-' bit_type_list
              | bit_type
	      ;

bit_type : ATOM
         | ATOM ':' INTEGER
	 ;

bit_size_expr : expr_max;

list_comprehension : '[' expr '||' lc_exprs ']' ;
binary_comprehension : '<<' binary '||' lc_exprs '>>' ;
lc_exprs : lc_expr
         | lc_expr ',' lc_exprs
	 ;

lc_expr : expr
        | expr '<-' expr
        | binary '<=' expr
	;

tuple : '{' '}'
      | '{' exprs '}'
      ;

//struct : ATOM tuple ;

map_expr : '#' map_tuple
         | expr_max '#' map_tuple
	 | map_expr '#' map_tuple
	 ;

map_tuple : '{' '}'
          | '{' map_fields '}'
	  ;

map_fields : map_field
           | map_field ',' map_fields
	   ;

map_field : map_field_assoc
          | map_field_exact
	  ;

map_field_assoc : map_key '=>' expr ;

map_field_exact : map_key ':=' expr ;

map_key : expr ;

// N.B. This is called from expr_700.
// N.B. Field names are returned as the complete object, even if they are
// always ATOMs for the moment, this might change in the future.

record_expr : '#' ATOM '.' ATOM
            | '#' ATOM record_tuple
	    | expr_max '#' ATOM '.' ATOM
	    | expr_max '#' ATOM record_tuple
	    | record_expr '#' ATOM '.' ATOM
	    | record_expr '#' ATOM record_tuple
	    ;

record_tuple : '{' '}'
             | '{' record_fields '}'
	     ;

record_fields : record_field
              | record_field ',' record_fields
	      ;

record_field : VAR '=' expr
             | ATOM '=' expr
	     ;

// N.B. This is called from expr_700.

function_call : expr_800 argument_list ;

if_expr : 'if' if_clauses 'end' ;

if_clauses : if_clause
           | if_clause ';' if_clauses
	   ;

if_clause : guard clause_body ;

case_expr : 'case' expr 'of' cr_clauses 'end' ;

cr_clauses : cr_clause
           | cr_clause ';' cr_clauses
	   ;

cr_clause : expr clause_guard clause_body ;

receive_expr : 'receive' cr_clauses 'end'
             | 'receive' 'after' expr clause_body 'end'
	     | 'receive' cr_clauses 'after' expr clause_body 'end'
	     ;

fun_expr : 'fun' ATOM '/' INTEGER
         | 'fun' atom_or_var ':' atom_or_var '/' integer_or_var
	 | 'fun' fun_clauses 'end'
	 ;

atom_or_var : ATOM
            | VAR
	    ;

integer_or_var : INTEGER
               | VAR
	       ;

fun_clauses : fun_clause
            | fun_clause ';' fun_clauses
	    ;

fun_clause : argument_list clause_guard clause_body
           | VAR argument_list clause_guard clause_body
	   ;

try_expr : 'try' exprs 'of' cr_clauses try_catch
         | 'try' exprs try_catch
	 ;

try_catch : 'catch' try_clauses 'end'
          | 'catch' try_clauses 'after' exprs 'end'
	  | 'after' exprs 'end'
	  ;

try_clauses : try_clause
            | try_clause ';' try_clauses
	    ;

try_clause : expr clause_guard clause_body
           | ATOM ':' expr clause_guard clause_body
           | VAR ':' expr clause_guard clause_body
	   ;
	   
argument_list : '(' ')'
              | '(' exprs ')'
	      ;

exprs : expr
      | expr ',' exprs
      ;

guard : exprs
      | exprs ';' guard
      ;

atomic : CHAR
       | INTEGER
       | FLOAT
       | ATOM
       | strings
       ;

strings : STRING* ;

prefix_op : '+'
          | '-'
	  | 'bnot'
	  | 'not'
	  ;

mult_op : '/'
        | '*'
	| 'div'
	| 'rem'
	| 'band'
	| 'and'
	;

add_op : '+'
       | '-'
       | 'bor'
       | 'bxor'
       | 'bsl'
       | 'bsr'
       | 'or'
       | 'xor'
       ;

list_op : '++'
        | '--'
	;

comp_op : '=='
        | '/='
	| '=<'
	| '<'
	| '>='
	| '>'
	| '=:='
	| '=/='
	;

VAR : [A-Z|_][A-Z|a-z|0-9|_]* ;
ATOM : [a-z][A-Z|a-z|0-9|_]* ;
INTEGER : [0-9]+ ;
FLOAT : [0-9]+'.'[0-9]+ ;
CHAR : '$'[A-Z|a-z] ;
STRING : '"' (~('"') | '\\' ('"' | '\\') | '~')* '"' ;

WS : ('\n' | '\r' | '\t' | ' ' ) { skip(); } ;
