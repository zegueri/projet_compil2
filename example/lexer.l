%{
  #include <stdlib.h>
  #include "parser.tab.h"
%}

digit     [0-9]
integer   {digit}+

%option noinput
%option nounput
%option noyywrap
%%

{integer} {
      yylval.val = strtol(yytext, NULL, 10);
      return NUM;
    }

"+"   { return PLUS;   }
"-"   { return MINUS;  }
"*"   { return TIMES;  }
"/"   { return DIV;    }
"("   { return LPAREN; }
")"   { return RPAREN; }
"\n"  { return EOL;    }

[ \r\t] { /* les espaces sont ignorés */ }
.       { return OTHER;            }
<<EOF>> { return EOL;              }

%%
