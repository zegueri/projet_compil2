%{

#include <stdio.h>
#include <stdlib.h>

#include "tree.h"

void yyerror(tree*, const char*);
extern int yylex();

%}

%code requires {
    /* Ceci est nécessaire pour utiliser 'tree' (au lieu de 'struct _tree*')
     * dans %union et %parse-param.
     */
    #include "tree.h"
}

%union{
   long val;
   tree ast;
}

%token <val> NUM
%token PLUS MINUS TIMES DIV LPAREN RPAREN EOL OTHER

%type <ast> Expr

%left PLUS MINUS
%left TIMES DIV

%start S

%parse-param {tree* res}
%%

S:
    Expr EOL  { *res = $1;   return 0; }
  | error EOL { *res = NULL; return 0; }
  | EOL       { return 1; }
  ;

Expr:
    NUM                  { $$ = make_leaf($1); }
  | Expr PLUS Expr       { $$ = make_node($1, '+', $3); }
  | Expr MINUS Expr      { $$ = make_node($1, '-', $3); }
  | Expr TIMES Expr      { $$ = make_node($1, '*', $3); }
  | Expr DIV Expr        { if (is_zero($3)) {
                             /* La division par zéro est impossible, donc :
                              * 1. on affiche un message d'erreur avec notre fonction 'yyerror'.
                              * 2. on demande à bison de propager l'erreur via la macro 'YYERROR;'.
                              */
                             yyerror(NULL, "division by zero");
                             YYERROR;
                           }
                           $$ = make_node($1, '/', $3);
                         }
  | LPAREN Expr RPAREN   { $$ = $2; } 
  ;

%%

void yyerror(tree* res, const char *s) {
    (void)res;
    fprintf(stderr, "[parser]: %s\n", s);
}

