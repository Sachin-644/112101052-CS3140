%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <ctype.h>

    int yylex();
    int yywrap();
    void yyerror(char*);

    int count = 0;
    int siz = 100;

    struct node {
        struct node *left;
        struct node *right;
        char *treenodename;
    };

    void init_sym_table();
    int search(char *);
    void insert_entry(char *, char *);
    struct node* create_node(struct node*, struct node*, char*);
    void inorder(struct node*, int);
    void printfn(char*);
    void print_sym_table();
    void print_abs_tree(struct node*);

    struct sym_tab_entry {
        char *id_name;
        char *type;
    };

    struct sym_tab_entry sym_tab[100];
    struct node *head;
%}

%union {
    char* name;
    struct node* treenode;
}

%token <name> BEGINDECL ENDDECL INTEGER PRINT VARIABLE
%token <name> NUMBER IF ELSE

%type <treenode> Prog Gdecl_sec Gdecl_list Gdecl Glist Gid MainBlock stmt_list statement assign_stmt print_stmt var_list 
%type <treenode> expr var_expr

%left '+' '-'
%left '*' '/'
%left '%'

%%

Prog        : Gdecl_sec MainBlock                      { $$ = create_node($1, $2, "PROGRAM"); head = $$; }
            ;

Gdecl_sec   : BEGINDECL Gdecl_list ENDDECL             { $$ = $2; }
            ;

Gdecl_list  : Gdecl                                    { $$ = $1; }
            | Gdecl Gdecl_list                         { $$ = create_node($1, $2, "DECLARATIONS"); }
            ;

Gdecl       : INTEGER Glist ';'                        { $$ = $2; }
            ;

Glist       : Gid                                      { $$ = $1; }
            | Gid ',' Glist                            { $$ = create_node($1, $3, "VAR_LIST"); }
            ;

Gid         : VARIABLE                                 { $$ = create_node(NULL, NULL, $1); insert_entry($1, "int"); }
            | VARIABLE '[' NUMBER ']'                  {
                                                        char arr_type[50]; 
                                                        sprintf(arr_type, "int[%s]", $3); 
                                                        $$ = create_node(NULL, NULL, $1); 
                                                        insert_entry($1, strdup(arr_type));
                                                      }
            ;

MainBlock   : stmt_list                                { $$ = $1; }
            ;

stmt_list   : statement                                { $$ = $1; }
            | statement stmt_list                      { $$ = create_node($1, $2, "STATEMENTS"); }
            ;

statement   : assign_stmt ';'                          { $$ = $1; }
            | print_stmt ';'                           { $$ = $1; }
            | IF '(' expr ')' statement                { $$ = create_node($3, $5, "IF"); }
            | IF '(' expr ')' statement ELSE statement { 
                                                        struct node* ifnode = create_node($3, $5, "IF");
                                                        $$ = create_node(ifnode, $7, "IF_ELSE");
                                                      }
            ;

assign_stmt : var_expr '=' expr                        { $$ = create_node($1, $3, "ASSIGN"); }
            ;

print_stmt  : PRINT '(' var_list ')'                   { $$ = create_node($3, NULL, "PRINT"); }
            ;

var_list    : var_expr                                 { $$ = $1; printfn($1->treenodename); }
            | var_expr ',' var_list                    { $$ = create_node($1, $3, "PRINT_LIST"); }
            ;

expr        : NUMBER                                   { $$ = create_node(NULL, NULL, $1); }
            | var_expr                                 { $$ = $1; }
            | '(' expr ')'                             { $$ = $2; }
            | expr '+' expr                            { $$ = create_node($1, $3, "ADD"); }
            | expr '-' expr                            { $$ = create_node($1, $3, "SUB"); }
            | expr '*' expr                            { $$ = create_node($1, $3, "MUL"); }
            | expr '/' expr                            { $$ = create_node($1, $3, "DIV"); }
            | expr '%' expr                            { $$ = create_node($1, $3, "MOD"); }
            ;

var_expr    : VARIABLE                                 { $$ = create_node(NULL, NULL, $1); }
            | VARIABLE '[' expr ']'                    { $$ = create_node($3, NULL, $1); }  // a[expr]
            ;

%%

void yyerror(char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    init_sym_table(); 
    printf("Parsing the input...\n");
    yyparse();
    printf("\nSymbol Table:\n");
    print_sym_table();
    printf("\nAbstract Syntax Tree:\n");
    print_abs_tree(head);
    return 0;
}

void init_sym_table() {
    for (int i = 0; i < 100; i++) {
        sym_tab[i].id_name = "\0";
        sym_tab[i].type = "\0";
    }
}

int search(char* id) {
    for (int i = 0; i < 100; i++) {
        if (strcmp(sym_tab[i].id_name, id) == 0) {
            return i;
        }
    }
    return -1;
}

void insert_entry(char* name, char* type) {
    char* varname = strdup(name);
    char* vartype = strdup(type);
    if (search(name) == -1) {
        sym_tab[count].id_name = varname;
        sym_tab[count].type = vartype;
        count++;
    }
}

struct node* create_node(struct node *left, struct node *right, char *token) {
    struct node* newnode = (struct node*)malloc(sizeof(struct node));
    char *newstr = (char *)malloc(strlen(token) + 1);
    strcpy(newstr, token);
    newnode->left = left;
    newnode->right = right;
    newnode->treenodename = newstr;
    return newnode;
}

void inorder(struct node *root, int depth) {
    if (root == NULL) return;
    printf("%*s%s\n", depth * 4, "", root->treenodename);
    if (root->left) inorder(root->left, depth + 1);
    if (root->right) inorder(root->right, depth + 1);
}

void print_sym_table() {
    printf("id_name\ttype\n");
    for (int i = 0; i < count; i++) {
        printf("%s\t%s\n", sym_tab[i].id_name, sym_tab[i].type);
    }
}

void printfn(char* name) {
    int index = search(name);
    if (index != -1) {
        printf("%s\t%s\n", sym_tab[index].id_name, sym_tab[index].type);
    } else {
        printf("%s\t<not declared>\n", name);
    }
}

void print_abs_tree(struct node* head) {
    inorder(head, 0);
}
