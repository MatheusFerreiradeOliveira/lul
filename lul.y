%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>	
#include "structs.h"

int yylex();
void yyerror (char *s){
	printf("%s\n", s);
}

%}

%union{
	float flo;
	int fn;
	char str[50];
	Ast *a;
	}

%token <flo>NUM
%token <str>VARS
%token <str>TEXTO
%token INI FIM IF ELSE WHILE STRING INT FLOAT SHOWF SHOWS SHOWI READI READF READS
%token <fn> CMP

%right '='
%left '+' '-'
%left '*' '/' '%'
%right '^' SQRT
%left CMP

%type <a> exp list stmt prog aString

%nonassoc IFX VARPREC VARPREC2 DECLPREC NEG VET PRECFLOAT PRINT MULTIPRINT decint decfloat decstring

%%

val: INI prog FIM
	;

prog: stmt 		{eval($1);}
	| prog stmt {eval($2);}
	;
	
	
stmt: IF '(' exp ')' '{' list '}' %prec IFX {$$ = newflow('I', $3, $6, NULL);}
	| IF '(' exp ')' '{' list '}' ELSE '{' list '}' {$$ = newflow('I', $3, $6, $10);}
	| WHILE '(' exp ')' '{' list '}' {$$ = newflow('W', $3, $6, NULL);}

	| VARS '=' exp %prec VARPREC { $$ = newasgn($1,$3);}
	| VARS '=' TEXTO %prec VARPREC2 { $$ = newasgnS($1, newast('$', newValorValS($3), NULL));}

	| INT VARS %prec decint { $$ = newvari('U',$2);}
    | FLOAT VARS %prec decfloat { $$ = newvari('V',$2);}
    | STRING VARS %prec decstring { $$ = newvari('X',$2);}

    | INT VARS '=' exp{ $$ = newast('G', newvari('U',$2) , $4);}
    | FLOAT VARS '=' exp{ $$ = newast('D', newvari('V',$2) , $4);}
    | STRING VARS '=' TEXTO { $$ = newast('H', newvari('X',$2) , newValorValS($4));}


	| READF '(' VARS ')' {  $$ = newvari('S', $3);}
	| READS '(' VARS ')' {  $$ = newvari('T', $3);}
	| READI '(' VARS ')' {  $$ = newvari('S', $3);}

	| SHOWF '(' exp')' { $$ = newast('p', $3, NULL);}
	| SHOWS '(' aString ')' { $$ = $3; }
	| SHOWI '(' exp')' { $$ = newast('u', $3, NULL);}
	;

aString: VARS { $$ = searchVar('z', $1);}
		| TEXTO {$$ = newast('Z', newValorValS($1), NULL)}
		;

list: stmt {$$ = $1;}
		| list stmt { $$ = newast('L', $1, $2);	}
		;
	
exp: 
	 exp '+' exp {$$ = newast('+',$1,$3);}		/*Expressões matemáticas*/
	|exp '-' exp {$$ = newast('-',$1,$3);}
	|exp '*' exp {$$ = newast('*',$1,$3);}
	|exp '/' exp {$$ = newast('/',$1,$3);}
    |exp '%' exp {$$ = newast('%',$1,$3);}
	|'(' exp ')' {$$ = $2;}
    |exp '^' exp { $$ = newast('^', $1, $3);  }
    |SQRT '(' exp ',' exp ')' { $$ = newast('~', $3, $5); }
	|exp CMP exp {$$ = newcmp($2,$1,$3);}		/*Testes condicionais*/
	|'-' exp %prec NEG {$$ = newast('M',$2,NULL);}
	|NUM 	{$$ = newnum($1);}						/*token de um número*/
	|VARS 	%prec VET {$$ = newValorVal($1);}		/*token de uma variável*/

	;

;

%%

#include "lex.yy.c"

int main(){
	yyin=fopen("entrada.lul","r");
	yyparse();
	yylex();
	fclose(yyin);
return 0;
}

