%{
	#include <stdio.h>
	#include<stdlib.h>
	void yyerror(char *);
	int yylex(void);
	int sym[26];

%}

%token INTEGER VARIABLE
%left '+' '-'
%left '*' '/'
%left '('')'

%%

program :
	 program statement '\n'
	 |
	 ;
statement :
	   expr {printf("%d\n",$1);}
	   | VARIABLE '=' expr {sym[$1] = $3;}
	   ;
expr :
      INTEGER
      | VARIABLE {$$ = sym[$1];}
      | expr '+' expr {$$ = $1+$3;}
      | expr '-' expr {$$ = $1-$3;}
      | expr '*' expr {$$ = $1*$3;}
      | expr '/' expr {
      			if($3 != 0)
      			   { 
      			     $$ = $1/$3 ;
      			   } 
      		       else 
      		           { 
      		               printf("ERROR : Division By '0' is not possible");
      		           }
      		      }				
      | '('expr')' {$$ = $2;}
      ;

%%

void yyerror (char *s)
{
	fprintf(stderr , "%s\n",s);
	
}

int main(void)
{
	yyparse();
	return 0;
}

