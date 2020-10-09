%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int yylex();
void yyerror (char *s){
	printf("%s\n", s);
}

	typedef struct vars{
		char name[50];
		float valor;
		struct vars * prox;
	}VARS;
	
	//insere uma nova variável na lista de variáveis
	VARS * push(VARS*l,char n[]){
		VARS*new =(VARS*)malloc(sizeof(VARS));
		strcpy(new->name,n);
		new->prox = l;
		return new;
	}
	
	//busca uma variável na lista de variáveis
	VARS *srch(VARS*l,char n[]){
		VARS*aux = l;
		while(aux != NULL){
			if(strcmp(n,aux->name)==0)
				return aux;
			aux = aux->prox;
		}
		return aux;
	}
	
	VARS *l1;
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

cmdos: 	SCAN '(' VAR ')' {
			float aux;
			printf ("Digite um valor: ");
			scanf ("%f", &aux);
			VARS * runner = srch(l1, $3);
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
			VARS * runner = srch(l1,$2);
				if (runner == NULL)
					l1 = push(l1,$2);
				else				
					printf ("Redeclaracao de variavel: %s\n",$2);
		}

		|

		VAR '=' exp {
			VARS * runner = srch(l1,$1);
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
		VARS* runner = srch(l1, $3);
		if(runner == NULL) 
			printf("Variavel naõ declarada: %s\n", $3);
		else
			$$ = sqrt(runner -> valor);
	}
	|PONTOF {$$ = $1;}
	|VAR {
		VARS * runner = srch (l1,$1);
			if (runner == NULL)
				printf ("Variavel nao declarada: %s\n",$1);
			else
				$$ = runner->valor;
			}
	;

%%

#include "lex.yy.c"

int main(){
	l1 = NULL;
	yyin=fopen("entrada.lul","r");
	yyparse();
	yylex();
	fclose(yyin);
return 0;
}