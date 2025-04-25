%{
	#include<stdlib.h>
	#include<stdio.h>
	#include<string.h>
	#include "compiler.tab.h"
	int 	Lineno;
	int     wflag;
	void yyerror( char *);
%}
%option yylineno


digit	[0-9]
letter	[a-zA-Z]

%%	

"begindecl"						{yylval.name = strdup(yytext);return BEGINDECL;	}	
"enddecl"						{yylval.name = strdup(yytext);return ENDDECL;	}	
"integer"						{yylval.name = strdup(yytext);return INTEGER;	}		
{digit}+						{yylval.name = strdup(yytext); return NUMBER; 	}
"print"							{yylval.name = strdup(yytext);return PRINT; 	}
{letter}({letter}|{digit})*		{yylval.name = strdup(yytext);return VARIABLE; 	}
[-+*/=();,]				        {return *yytext;}	
"\\n"                     		{ ;	}
[ \t]							{ ;	}
.			       		  		{ ;	}		
%%


