%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int yylex();
void yyerror (char *s){
	printf("%s\n", s);
}

	typedef struct variavel{
		char name[50];
		float valor;
		struct variavel * prox;
	}VARIAVEL;
	
	//insere uma nova variável na lista de variáveis
	VARIAVEL * push(VARIAVEL*l,char n[]){
		VARIAVEL*new =(VARIAVEL*)malloc(sizeof(VARIAVEL));
		strcpy(new->name,n);
		new->prox = l;
		return new;
	}
	
	//busca uma variável na lista de variáveis
	VARIAVEL *srch(VARIAVEL*l,char n[]){
		VARIAVEL*aux = l;
		while(aux != NULL){
			if(strcmp(n,aux->name)==0)
				return aux;
			aux = aux->prox;
		}
		return aux;
	}
	
	VARIAVEL *listaVars;
%}

%union{
	int integer;
	float flo;
	char str[50];
	}

%token <flo>PONTOF
%token <str>VAR
%token SQRT
%token STRING
%token FLOAT
%token COMENTARIO
%token PRINT
%token SCAN
%token FIM
%token INT
%token INI
%left '+' '-'
%left '*' '/'
%right '^'
%right NEG
%type <flo> exp

%%

prog: INI cod FIM
	;

cod: cod cmdos
	|
	;

cmdos: 	COMENTARIO {
			printf("Comentario\n");	
		}

		| 

		SCAN '(' VAR ')' {
			float aux;
			printf ("Digite um valor: ");
			scanf ("%f", &aux);
			VARIAVEL * runner = srch(listaVars, $3);
			if(runner == NULL) {
				printf("Variavel nao declarada: %s\n", $3);
			}
			else {
				runner -> valor = aux;
			}
		}

		|

		PRINT '(' exp ')' {
			printf ("%.2f \n",$3);
		}	

		| 		

		FLOAT VAR {
			VARIAVEL * runner = srch(listaVars,$2);
				if (runner == NULL)
					listaVars = push(listaVars,$2);
				else				
					printf ("Redeclaracao de variavel: %s\n",$2);
		}

		|

		VAR '=' exp {
			VARIAVEL * runner = srch(listaVars,$1);
			if (runner == NULL)
				printf ("Variavel nao declarada: %s\n",$1);
			else
				runner -> valor = $3;
		}

	;

exp: exp '+' exp {$$ = $1 + $3;}
	|exp '-' exp {$$ = $1 - $3;}
	|exp '*' exp {$$ = $1 * $3;}
	|exp '/' exp {$$ = $1 / $3;}
	|'(' exp ')' {$$ = $2;}
	|exp '^' exp {$$ = pow($1,$3);}
	|'-' exp %prec NEG {$$ = -$2;}
	|SQRT '(' VAR ')' {
		VARIAVEL* runner = srch(listaVars, $3);
		if(runner == NULL) 
			printf("Variavel naõ declarada: %s\n", $3);
		else
			$$ = sqrt(runner -> valor);
	}
	|PONTOF {$$ = $1;}
	|VAR {
		VARIAVEL * runner = srch (listaVars,$1);
			if (runner == NULL)
				printf ("Variavel nao declarada: %s\n",$1);
			else
				$$ = runner->valor;
			}
	;

%%

#include "lex.yy.c"

int main(){
	listaVars = NULL;
	yyin=fopen("entrada.lul","r");
	yyparse();
	yylex();
	fclose(yyin);
return 0;
}