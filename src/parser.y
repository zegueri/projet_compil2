%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "logic.h"

int yyerror(const char *s);
extern int yylex(void);
extern int from_file;
extern int yylineno;


/* ---------- structures et helpers ---------- */
enum NType { N_CONST, N_VAR, N_NOT,
               N_AND, N_OR, N_XOR, N_IMPL };

struct Node {
    enum NType type;
    int   val;        /* pour N_CONST */
    int   vidx;       /* pour N_VAR   */
    struct Node *l,*r;
};

/* fabrique de nœuds */
struct Node *mk_const(int v){ struct Node*n=calloc(1,sizeof(*n)); n->type=N_CONST; n->val=v; return n; }
struct Node *mk_var(int id){ struct Node*n=calloc(1,sizeof(*n)); n->type=N_VAR;   n->vidx=id; return n; }
struct Node *mk_un (enum NType t,struct Node*a){ struct Node*n=calloc(1,sizeof(*n)); n->type=t; n->l=a;        return n; }
struct Node *mk_bin(enum NType t, struct Node*a,struct Node*b){ struct Node*n=calloc(1,sizeof(*n)); n->type=t; n->l=a; n->r=b; return n; }

static int eval_node(const struct Node*n,const int*vals){
    switch(n->type){
        case N_CONST: return n->val;
        case N_VAR:   return vals[n->vidx];
        case N_NOT:   return !eval_node(n->l,vals);
        case N_AND:   return eval_node(n->l,vals)&eval_node(n->r,vals);
        case N_OR:    return eval_node(n->l,vals)|eval_node(n->r,vals);
        case N_XOR:   return eval_node(n->l,vals)^eval_node(n->r,vals);
        case N_IMPL:  return (!eval_node(n->l,vals))|eval_node(n->r,vals);
    }
    return 0;
}
void free_node(struct Node*n){ if(!n)return; free_node(n->l); free_node(n->r); free(n); }


/* ---------- buffers ---------- */
static unsigned char boolbuf[256];   /* tables brutes */
static int  bool_count = 0;

static char varnames[MAX_VARS][MAX_NAME];
static int  varcnt = 0;
static int  have_varlist = 0;
static const char *def_names[MAX_VARS] = {"x","y","z","s","t","u","v","w"};

static int  vals[8];  /* pour eval */
static int  valcnt2 = 0;

static int get_var_index(const char*name){
    if(!have_varlist){
        for(int i=0;i<MAX_VARS;i++){
            if(strcmp(name,def_names[i])==0){
                if(varcnt<i+1) varcnt = i+1;
                return i;
            }
        }
        fprintf(stderr,"Unknown variable %s\n",name);
        return 0;
    } else {
        for(int i=0;i<varcnt;++i)
            if(!strcmp(name,varnames[i])) return i;
        if(varcnt>=MAX_VARS){
            fprintf(stderr,"Trop de variables (max %d)\n",MAX_VARS);
            return 0;
        }
        strncpy(varnames[varcnt],name,MAX_NAME-1);
        varnames[varcnt][MAX_NAME-1]='\0';
        return varcnt++;
    }
}

static char* node_to_string(const struct Node*n){
    char *res=NULL,*a,*b;
    switch(n->type){
        case N_CONST:
            asprintf(&res,"%d",n->val);
            break;
        case N_VAR:
            asprintf(&res,"%s", have_varlist ? varnames[n->vidx] : def_names[n->vidx]);
            break;
        case N_NOT:
            a=node_to_string(n->l);
            asprintf(&res,"!%s",a); free(a);
            break;
        case N_AND:
            a=node_to_string(n->l); b=node_to_string(n->r);
            asprintf(&res,"(%s & %s)",a,b); free(a); free(b);
            break;
        case N_OR:
            a=node_to_string(n->l); b=node_to_string(n->r);
            asprintf(&res,"(%s | %s)",a,b); free(a); free(b);
            break;
        case N_XOR:
            a=node_to_string(n->l); b=node_to_string(n->r);
            asprintf(&res,"(%s ^ %s)",a,b); free(a); free(b);
            break;
        case N_IMPL:
            a=node_to_string(n->l); b=node_to_string(n->r);
            asprintf(&res,"(%s => %s)",a,b); free(a); free(b);
            break;
    }
    return res;
}
%}

%union {
    int   num;
    char *str;
    struct Node *node;
}

%token <num> BOOL
%token <str> IDENT
%token NEWLINE LPAREN RPAREN LBRACE RBRACE COMMA SEMICOLON
%token KW_DEFINE KW_EVAL KW_TABLE KW_LIST KW_VARLIST KW_FORMULA KW_AT
%token KW_AND KW_OR KW_XOR KW_NOT
%token AND OR XOR NOT EQUAL IMPL

%type <node> expr

%right IMPL
%left  OR KW_OR
%left  XOR KW_XOR
%left  AND KW_AND
%right NOT KW_NOT '!'

%%  /* ---------- grammaire ---------- */

input:                /* vide */ | input line ;

line:  command NEWLINE
     | NEWLINE
     ;

command:
      KW_LIST                                { list_functions(); }
    | define_cmd
    | KW_TABLE   IDENT                       { print_table($2);     free($2); }
    | KW_VARLIST IDENT                       { print_varlist($2);   free($2); }
    | KW_FORMULA IDENT                       { print_formula($2);   free($2); }
    | KW_EVAL    IDENT KW_AT value_seq       { eval_and_print($2,vals,valcnt2); free($2); }
    ;

/* ----- define ----- */
define_cmd:
      KW_DEFINE IDENT opt_varlist EQUAL table_def
        {
          int arity = have_varlist ? varcnt : -1;
          const char (*names)[MAX_NAME] = have_varlist ? varnames : NULL;
          add_function_table($2,arity,names,boolbuf,bool_count,NULL);
          free($2);
        }
    | KW_DEFINE IDENT opt_varlist EQUAL expr
        {
          int arity = varcnt;
          int size  = 1 << arity;
          unsigned char tbl[1<<MAX_VARS];
          for(int idx=0; idx<size; ++idx){
              int v[MAX_VARS];
              for(int i=0;i<arity;++i)
                  v[i] = (idx >> (arity-1-i)) & 1;
              tbl[idx] = eval_node($5,v);
          }
          const char (*names)[MAX_NAME] = have_varlist ? varnames : NULL;
          char *form = node_to_string($5);
          add_function_table($2,arity,names,tbl,size,form);
          free(form);
          free_node($5); free($2);
        }
    ;

/* ----- liste optionnelle de variables ----- */
opt_varlist:
      /* vide */                                { varcnt = 0; have_varlist = 0; }
    | LPAREN { have_varlist = 1; varcnt = 0; } id_list RPAREN
    ;

id_list:
      IDENT                    { get_var_index($1); free($1); }
    | id_list COMMA IDENT      { get_var_index($3); free($3); }
    ;

/* ----- table brute ----- */
table_def: LBRACE table_values RBRACE ;

table_values:
      BOOL               { bool_count=0; boolbuf[bool_count++]=(unsigned char)$1; }
    | table_values BOOL  { boolbuf[bool_count++]=(unsigned char)$2; }
    ;

/* ----- valeurs pour eval ----- */
value_seq:
      BOOL            { valcnt2=0; vals[valcnt2++]=$1; }
    | value_seq BOOL  {           vals[valcnt2++]=$2; }
    ;

/* ----- expressions booléennes ----- */
expr:
      expr IMPL expr            { $$ = mk_bin(N_IMPL,$1,$3); }
    | expr OR expr              { $$ = mk_bin(N_OR,$1,$3); }
    | expr KW_OR expr           { $$ = mk_bin(N_OR,$1,$3); }
    | expr XOR expr             { $$ = mk_bin(N_XOR,$1,$3); }
    | expr KW_XOR expr          { $$ = mk_bin(N_XOR,$1,$3); }
    | expr AND expr             { $$ = mk_bin(N_AND,$1,$3); }
    | expr KW_AND expr          { $$ = mk_bin(N_AND,$1,$3); }
    | NOT expr                  { $$ = mk_un (N_NOT,$2);    }
    | KW_NOT expr               { $$ = mk_un (N_NOT,$2);    }
    | LPAREN expr RPAREN        { $$ = $2; }
    | IDENT                     { $$ = mk_var(get_var_index($1)); free($1); }
    | BOOL                      { $$ = mk_const($1); }
    ;
%%

int yyerror(const char *s){
    if(from_file)
        fprintf(stderr,"Parse error line %d: %s\n", yylineno, s);
    else
        fprintf(stderr,"Parse error: %s\n", s);
    return 0;
}
