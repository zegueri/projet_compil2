#include "logic.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>

static Function funcs[MAX_FUNCS];
static int func_count = 0;
static const char *default_names[MAX_VARS] = {"x","y","z","s","t","u","v","w"};

void logic_init(void) { func_count = 0; }

static Function *lookup(const char *name)
{
    for (int i = 0; i < func_count; ++i)
        if (!strcmp(funcs[i].name, name))
            return &funcs[i];
    return NULL;
}

static int compute_arity(int num_entries)
{
    int a = 0;
    while ((1 << a) < num_entries && a <= MAX_VARS) a++;
    if ((1 << a) != num_entries || a > MAX_VARS) return -1;
    return a;
}

int add_function_table(const char *name, int arity, const char vars[][MAX_NAME],
                       const unsigned char *table, int num_entries)
{
    if (num_entries > (1 << MAX_VARS)) {
        fprintf(stderr, "Table too large (max %d)\n", 1 << MAX_VARS);
        return -1;
    }
    if (func_count >= MAX_FUNCS) { fprintf(stderr, "Function limit reached\n"); return -1; }

    if (arity < 0) {
        arity = compute_arity(num_entries);
        if (arity < 0) {
            fprintf(stderr, "Invalid table size %d (must be power of two ≤ 256)\n", num_entries);
            return -1;
        }
    }

    /* overwrite if already exists */
    Function *existing = lookup(name);
    if (existing) { *existing = funcs[func_count - 1]; func_count--; }

    Function *f = &funcs[func_count++];
    strncpy(f->name, name, MAX_NAME - 1);
    f->name[MAX_NAME - 1] = '\0';
    f->arity = arity;
    f->num_entries = num_entries;

    for (int i = 0; i < arity; ++i) {
        if (vars) strncpy(f->vars[i], vars[i], MAX_NAME - 1);
        else      strncpy(f->vars[i], default_names[i], MAX_NAME - 1);
        f->vars[i][MAX_NAME - 1] = '\0';
    }

    memcpy(f->table, table, num_entries);
    printf("→ define %s (%d vars) ok\n", name, arity);
    return 0;
}

void list_functions(void)
{
    printf("→ list; ");
    for (int i = 0; i < func_count; ++i) printf("%s ", funcs[i].name);
    printf("\n");
}

void print_varlist(const char *name)
{
    Function *f = lookup(name);
    if (!f) { fprintf(stderr, "Unknown function %s\n", name); return; }
    printf("→ varlist %s; ", name);
    for (int i = 0; i < f->arity; ++i) printf("%s ", f->vars[i]);
    printf("\n");
}

void print_table(const char *name)
{
    Function *f = lookup(name);
    if (!f) { fprintf(stderr, "Unknown function %s\n", name); return; }
    printf("→ table %s; { ", name);
    for (int i = 0; i < f->num_entries; ++i) printf("%d ", f->table[i]);
    printf("}\n");
}

static int eval_function(const Function *f, const int *values)
{
    int idx = 0;
    for (int i = 0; i < f->arity; ++i) idx = (idx << 1) | (values[i] & 1);
    return f->table[idx];
}

void eval_and_print(const char *name, const int *values, int value_count)
{
    Function *f = lookup(name);
    if (!f) { fprintf(stderr, "Unknown function %s\n", name); return; }
    if (value_count != f->arity) {
        fprintf(stderr, "eval %s: expected %d values, got %d\n", name, f->arity, value_count);
        return;
    }
    int res = eval_function(f, values);
    printf("→ eval %s; %d\n", name, res);
}
