%{
	#include "y.tab.h"
	#include<stdio.h>
	#include <stdlib.h>
	void yyerror( char *);
%}

%%

[A-Z]      { 
		yylval = *yytext - 'A';
		 return VARIABLE; 
	   }

[0-9]+     { 
		yylval = atoi(yytext); 
		return INTEGER; 
	    }

[-+*/()=\n]  { 
		return *yytext; 
	      }

[ \t]         ; //to ignore white spaces

.            { 
		yyerror("INVALID INPUT"); 
	     }

%%

int yywrap(void) 
{ 
	return 1;
}

