#ifndef LOGIC_H
#define LOGIC_H

#define MAX_FUNCS 128
#define MAX_VARS 8
#define MAX_NAME 32

typedef struct {
    char name[MAX_NAME];
    int arity;                     /* number of variables */
    char vars[MAX_VARS][MAX_NAME]; /* variable names */
    int num_entries;               /* size of table = 1<<arity */
    unsigned char table[1<<MAX_VARS];
    char *formula;                 /* textual formula, NULL if none */
} Function;

void logic_init(void);
const Function *get_function(const char *name);
int eval_function_direct(const Function *f, const int *values);

int add_function_table(const char *name, int arity, const char vars[][MAX_NAME],
                       const unsigned char *table, int num_entries,
                       const char *formula);
void list_functions(void);

void print_varlist(const char *name);

void print_table(const char *name);

void print_formula(const char *name);

void eval_and_print(const char *name, const int *values, int value_count);

#endif
