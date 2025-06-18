#ifndef __TREE_H__
#define __TREE_H__

#include <stdbool.h>

typedef struct _tree* tree;


tree make_leaf(long);
tree make_node(tree, char, tree);

void dump_tree(tree);
void free_tree(tree);

bool is_zero(tree);


#endif // __TREE_H__
