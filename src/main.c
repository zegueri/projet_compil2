#include "logic.h"
#include "parser.tab.h"
#include <stdio.h>

extern int yyparse(void);
extern FILE *yyin;
extern int yylineno;

int from_file = 0;

int main(int argc, char **argv)
{
    if (argc > 2) {
        fprintf(stderr, "usage: %s [file]\n", argv[0]);
        return 1;
    }
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
        if (!yyin) { perror(argv[1]); return 1; }
        from_file = 1;
    }

    logic_init();
    puts("Logic");
    puts("");
    if (yyparse() != 0 && from_file) {
        fprintf(stderr, "error near line %d\n", yylineno);
        return 1;
    }
    return 0;
}