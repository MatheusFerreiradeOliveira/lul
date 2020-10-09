%{

%}

COMENTARIO "//"..*
PONTOF [0-9]+.[0-9]*
VAR [a-zA-Z]+([0-9]*[a-zA-Z]*)*
SQRT "sqrt"
INT "integer"
FLOAT "float"
STRING "st"
PRINT "show"
SCAN "read"
INI "(>'.')>"
FIM "<('.'<)"
%%

{FLOAT} {return FLOAT;}

{COMENTARIO} {return COMENTARIO;}

{STRING} {return STRING;}

{PRINT} {return PRINT;}

{SQRT} {return SQRT;}

{SCAN} {return SCAN;}

{INI} {return INI;}			
	
{FIM} {return FIM;}

{PONTOF} {
	yylval.flo = atof(yytext);
	return PONTOF;
	}

{VAR} {
	strcpy (yylval.str,yytext);
	return VAR;
	}
	
[-+()=/*^] {return *yytext;}
	
[\ \n\t]*	{;}

. {;}

%%

int yywrap()
{
   return 1;
}
