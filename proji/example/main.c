#include <stdio.h>
#include <stdlib.h>

#include "parser.tab.h"
#include "tree.h"

int main(int argc, char* argv[]) {
    if (argc != 1) {
        fprintf(stderr, "usage: %s\n", argv[0]);
        exit(1);
    }

    yydebug = 0; /* put 1 to make bison verbose */
    
    tree res;
    while (yyparse(&res) == 0) {
        if (res != NULL) {
            printf("--> ");
            dump_tree(res);
            free_tree(res);
            printf("\n");
        }
    }

    return 0;
} 
