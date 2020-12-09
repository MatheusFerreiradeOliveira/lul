%{
#include <string.h>
#include <stdio.h>

%}

NUM [0-9]+\.?[0-9]*
TEXTO ["][^"]*["]
VARS [a-zA-Z_]+[a-zA-z0-9_]*
INI "(>'.')>"
FIM "<('.'<)"
	
STRING "string"
INT "int"
FLOAT "float"

SQRT "sqrt"
IF "IF"
ELSE "ELSE"
WHILE "WHILE"

SHOWS "shows"
SHOWF "showf"
SHOWI "showi"

READS "reads"
READF "readf"
READI "readi"

COMENTARIO "//"
IGNORE [\s\t\n" "]

%%
{INI} { return INI; }
{FIM} { return FIM; }

{IF} { return IF; }
{ELSE} { return ELSE; }
{WHILE} { return WHILE; }

{SHOWS} { return SHOWS; }
{SHOWF} { return SHOWF; }
{SHOWI} { return SHOWI; }

{READF} { return READF; }
{READS} { return READS; }
{READI} { return READI; }

{STRING} { return STRING; }
{INT} { return INT; }
{FLOAT} { return FLOAT; }

{SQRT} { return SQRT; }

{VARS} {
	strcpy(yylval.str,yytext);
	return VARS;
}

{TEXTO} {
    char aux[50];
    strncpy ( aux, &yytext[1], strlen(yytext)-2);
    aux[strlen(yytext)-2]='\0';
    strcpy (yylval.str, aux);
	return TEXTO;  
}

{NUM} {
	yylval.flo = atof(yytext);
	return NUM;
	}

[-+()=%/*^,{}:\[\]] {return *yytext;}

{COMENTARIO}..*|"/**"(..*|{IGNORE})*"*/" {;}

">" {yylval.fn = 1; return CMP; }
"<" {yylval.fn = 2; return CMP; }
"!=" {yylval.fn = 3; return CMP; }
"==" {yylval.fn = 4; return CMP; }
">=" {yylval.fn = 5; return CMP; }
"<=" {yylval.fn = 6; return CMP; }

{IGNORE} {;}
. {;}

%%

int yywrap() {
   return 1;
}