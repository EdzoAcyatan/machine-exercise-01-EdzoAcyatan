%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
typedef struct TreeNode TreeNode;                       /* Forward declaration of Tree Node */
int depth = 0;                                          /* Global variable for tracking depth */
void yyerror(const char *msg);
int yylex(void);
void indent(int);
/* Personal itoa function since itoa doesn't work with my compiler */
char* my_itoa(int num) {
    char *str = (char*)malloc(12); 
    sprintf(str, "%d", num);
    return str;
}

/* Parse tree node structure */
struct TreeNode {
    char *value;
    struct TreeNode *l;
    char tkn;
    struct TreeNode *r;
};

/* TreeNode Function declarations */
void printTree(TreeNode *node);
TreeNode* createNode(char *value, TreeNode *l, char tkn, TreeNode *r); 
TreeNode* createTerminalNode(char *value); 
%}


%union {
    int ival;
    double fval;
    struct TreeNode *node;                              /* Added node to the union for parse tree nodes */
}

%token <ival> NUM 
%token <fval> FNUM                                      /* added FNUM for floating-point numbers */
%token POW PLUS MINUS TIMES DIVIDE LPAREN RPAREN        /* added POW */

%left PLUS MINUS
%left TIMES DIVIDE
%right UMINUS POW                                       /* added POW */

%type <node> expr term factor program                   /* Nonterminals were made to be of type TreeNode* */

%%

/* Changed Grammar */
program:
    expr { printTree($1); }
    ;
    
expr:
    expr PLUS term { 
        $$ = createNode("expr", $1, '+', $3); 
    }
    | expr MINUS term { 
        $$ = createNode("expr", $1, '-', $3); 
    }
    | term { $$ = createNode("expr", $1, '\0', NULL); }
    ;
    
term:
    term TIMES factor { $$ = createNode("term", $1, '*', $3); }
    | term DIVIDE factor { $$ = createNode("term", $1, '/', $3); }
    | factor { $$ = createNode("term", $1, '\0', NULL); }
    ;
    
factor:
    NUM { $$ = createNode("factor", createNode(my_itoa($1), NULL, '\0', NULL), '\0', NULL); }
    | LPAREN expr RPAREN { $$ = createNode("factor", NULL, '(', $2); }
    | MINUS factor %prec UMINUS { $$ = createNode("-", $2, '\0', NULL); } /* Not sure if this is the proper behavior for a negative number */
    | factor POW factor { $$ = createNode("factor", $1, '^', $3); }
    ;
%%

TreeNode* createNode(char *value, TreeNode *l, char tkn, TreeNode *r) {
    TreeNode *node = (TreeNode*)malloc(sizeof(TreeNode));
    node->value = value;
    node->l = l;
    node->tkn = tkn;
    node->r = r;
    return node;
}

void printTree(TreeNode *node) {
    if (node == NULL) return;
    indent(depth);
    printf("%s\n", node->value);
    depth++;
    if (node->l != NULL) printTree(node->l);
    if (node->tkn != '\0') {
        indent(depth);
        printf("%c\n", node->tkn);
    }
    if (node->r != NULL) printTree(node->r);
    if (node->tkn == '(') {
        indent(depth);
        printf(")\n");
    }
    depth--;
}

void yyerror(const char *msg) {
    fprintf(stderr, "Parse error: %s\n", msg);
}

/* Function to print indentation based on depth */
void indent(int d) {                                           
    for (int i = 0; i < d; i++) {
        printf("  ");
    }
}

int main(void) {
    return yyparse();
}