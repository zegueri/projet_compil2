%option noyywrap
%{
#include "logic.h"         
#include "parser.tab.h"    
#include <string.h>
#include <ctype.h>
%}

%%
[ \t]+                    /* skip whitespace */
"\n"                       return NEWLINE;
"("                        return LPAREN;
")"                        return RPAREN;
"{"                        return LBRACE;
"}"                        return RBRACE;
","                        return COMMA;
";"                        return SEMICOLON;
"="                        return EQUAL;
"!"                        return NOT;
"||"|"|"                return OR;
"&&"|"&"                return AND;
"^"                         return XOR;
"=>"                        return IMPL;

[01]                      { yylval.num = yytext[0]-'0'; return BOOL; }

(?i:and)                  return KW_AND;
(?i:or)                   return KW_OR;
(?i:xor)                  return KW_XOR;
(?i:not)                  return KW_NOT;
(?i:define)               return KW_DEFINE;
(?i:eval)                 return KW_EVAL;
(?i:table)                return KW_TABLE;
(?i:list)                 return KW_LIST;
(?i:varlist)              return KW_VARLIST;
(?i:formula)              return KW_FORMULA;
(?i:at)                   return KW_AT;

[A-Za-z][A-Za-z0-9_]*     {
    yylval.str = strdup(yytext);
    return IDENT;
}

.                          { fprintf(stderr, "Unknown char: %s\n", yytext); }
%%