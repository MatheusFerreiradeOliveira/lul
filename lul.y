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
		int type;
		char valor[50];
		struct variavel * prox;
	}VARIAVEL;
	
	//insere uma nova variável na lista de variáveis
	VARIAVEL * push(VARIAVEL*l,char n[], int type){
		VARIAVEL*new =(VARIAVEL*)malloc(sizeof(VARIAVEL));
		new->type = type;
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


	typedef struct ast { /*Estrutura de um nó*/
	int nodetype;
	struct ast *l; /*Esquerda*/
	struct ast *r; /*Direita*/
}Ast; 

typedef struct numval { /*Estrutura de um número*/
	int nodetype;
	double number;
}Numval;

typedef struct varval { /*Estrutura de um nome de variável, nesse exemplo uma variável é um número no vetor var[26]*/
	int nodetype;
	char var[50];
}Varval;

typedef struct texto { /*Estrutura de um texto*/
	int nodetype;
	char txt[50];
}TXT;	
	
typedef struct flow { /*Estrutura de um desvio (if/else/while)*/
	int nodetype;
	Ast *cond;		/*condição*/
	Ast *tl;		/*then, ou seja, verdade*/
	Ast *el;		/*else*/
}Flow;

typedef struct symasgn { /*Estrutura para um nó de atribuição. Para atrubior o valor de v em s*/
	int nodetype;
	char s[50];
	Ast *v;
}Symasgn;

%}

%union{
	int integer;
	float flo;
	char str[50];
}

%token <flo>PONTOF
%token <str>TEXTO
%token <str>VAR
%token SQRT
%token STRING
%token FLOAT
%token INT
%token BOOL
%token COMENTARIO
%token PRINT
%token SCAN
%token FIM
%token INI
%left '+' '-'
%left '*' '/'
%right '^'
%right NEG
%type <str> exp

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
			char aux[50];
			printf ("Digite um valor: ");
			scanf ("%s", &aux);
			VARIAVEL * runner = srch(listaVars, $3);
			if(runner == NULL) {
				printf("Variavel nao declarada: %s\n", $3);
			}
			else {
				strcpy(runner->valor,aux);
			}
		}

		|

		PRINT '(' exp ')' {
			printf ("%.2f \n",$3);
		}	

		| 		

		FLOAT VAR {
			VARIAVEL * runner = srch(listaVars,$2);
				if (runner == NULL){
					listaVars = push(listaVars,$2,1);
				}
				else				
					printf ("Redeclaracao de variavel: %s\n",$2);
		}

		|

		INT VAR {
			VARIAVEL * runner = srch(listaVars,$2);
				if (runner == NULL)
					listaVars = push(listaVars,$2,2);
				else				
					printf ("Redeclaracao de variavel: %s\n",$2);
		}

		|

		BOOL VAR {
			VARIAVEL * runner = srch(listaVars,$2);
				if (runner == NULL)
					listaVars = push(listaVars,$2,4);
				else				
					printf ("Redeclaracao de variavel: %s\n",$2);
		}

		|

		STRING VAR {
			VARIAVEL * runner = srch(listaVars,$2);
				if (runner == NULL)
					listaVars = push(listaVars,$2,3);
				else				
					printf ("Redeclaracao de variavel: %s\n",$2);
		}

		|

		VAR '=' exp {
			VARIAVEL * runner = srch(listaVars,$1);
			if (runner == NULL)
				printf ("Variavel nao declarada: %s\n",$1);
			else {
				//char converted[50];
				//sprintf(converted, "%.2f", $3);
				//runner -> valor = $3;
				strcpy(runner->valor, $3);
			}
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
		else{
			if(runner->type == 1)
				$$ = sqrt(atof(runner->valor));
			else if(runner->type == 2)
				$$ = sqrt(atoi(runner->valor));
			else
				printf("Essa variável não é numérica");
		}
	}
	|TEXTO {$$ = $1;}
	|PONTOF {$$ = atof($1);}
	|VAR {
		VARIAVEL * runner = srch (listaVars,$1);
			if (runner == NULL)
				printf ("Variavel nao declarada: %s\n",$1);
			else{
				if(runner->type == 1)
					$$ = atof(runner->valor);
				else if(runner->type == 2)
					$$ = atoi(runner->valor);
				else if(runner->type == 4)
					if(runner->valor == "true")
						$$ = 1;
					else
						$$ = 0;
				else
					$$ = runner->valor;
			}
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