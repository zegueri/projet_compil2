#include "logic.h"        
#include "parser.tab.h"   
#include <stdio.h>

extern int yyparse(void);

int main(void)
{
    logic_init();
    puts("Logic");
    puts("");
    yyparse();
    return 0;
}