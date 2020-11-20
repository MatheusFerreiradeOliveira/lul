%{

%}

COMENTARIO "//"..*
PONTOF [0-9]+.[0-9]*
VAR [a-zA-Z]+([0-9]*[a-zA-Z]*)*
SQRT "sqrt"
INT "integer"
FLOAT "float"
STRING "st"


dasdasdas

TEXTO ["][^"]*["]
BOOL "bool"

PRINT "show"
SCAN "read"

PRINTT "showS"
SCANS "readS"

WHILE "while"
IF "if"
ELSE "else"

INI "(>'.')>"
FIM "<('.'<)"
%%

// Tipos
{FLOAT} {return FLOAT;}
{STRING} {return STRING;}
{BOOL} {return BOOL;}
{INT} {return INT;}

// funcoes
{COMENTARIO} {return COMENTARIO;}
{PRINT} {return PRINT;}
{PRINTT} {return PRINTT;}
{SQRT} {return SQRT;}
{SCAN} {return SCAN;}
{SCANS} {return SCANS;}

// lul
{INI} {return INI;}			
{FIM} {return FIM;}

{TEXTO} {
	yyval.str = yytext;
	return TEXTO;
}
{PONTOF} {
	yylval.flo = atof(yytext);
	return PONTOF;
	}

{VAR} {
	strcpy (yylval.str,yytext);
	return VAR;
	}

{PRINTT} {
	return
}

{WHILE} {return WHILE};
{IF} {return IF;}


IF "if"
ELSE "else"

[-+()=/*^] {return *yytext;}
	
[\ \n\t]*	{;}

. {;}

%%

int yywrap()
{
   return 1;
}
