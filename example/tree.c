#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "tree.h"

enum node_type { LEAF = 0, INTERNAL_NODE };

struct _tree {
    enum node_type type;
    union {
        /* type is LEAF */
        long val;
        /* type is INTERNAL_NODE */
        struct {
            char op;
            struct _tree* left;
            struct _tree* right;
        } node;
    } data;
};

typedef struct _tree* tree;



tree make_leaf(long v) {
    tree res = calloc(sizeof(struct _tree), 1);
    res->type = LEAF;
    res->data.val = v;
    return res;
}

tree make_node(tree l, char o, tree r) {
    tree res = calloc(sizeof(struct _tree), 1);
    res->type = INTERNAL_NODE;
    res->data.node.left = l;
    res->data.node.op = o;
    res->data.node.right = r;
    return res;
}



void dump_tree(tree v) {
    switch (v->type) {
        case LEAF:
            printf("VAL(%ld)", v->data.val);
            break;
        case INTERNAL_NODE:
            printf("NODE(");
            dump_tree(v->data.node.left);
            printf(", %c, ", v->data.node.op);
            dump_tree(v->data.node.right);
            printf(")");
            break;
        default:
            assert(0);
    }
}

void free_tree(tree v) {
    switch (v->type) {
        case INTERNAL_NODE:
            free_tree(v->data.node.left);
            free_tree(v->data.node.right);
        case LEAF:
            free(v);
            break;
        default:
            assert(0);
    }
}


bool is_zero(tree v) {
    return (v->type == LEAF) && (v->data.val == 0);
}
