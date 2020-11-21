%{

%}

COMENTARIO "//"..*
PONTOF [0-9]+.[0-9]*
VAR [a-zA-Z]+([0-9]*[a-zA-Z]*)*
SQRT "sqrt"
FLOAT "double"
TEXTO ["][^"]*["]

PRINT "show"
SCAN "read"

PRINTT "showS"
SCANS "readS"

WHILE "while"
IF "if"
ELSE "else"

INI "(>'.')><('.'<)"
FIM "<('.'<)(>'.')>"
%%


{COMENTARIO} {return COMENTARIO;}
{PRINT} {return PRINT;}
{PRINTT} {return PRINTT;}

{FLOAT} {return FLOAT;}

{SQRT} {return SQRT;}
{SCAN} {return SCAN;}
{SCANS} {return SCANS;}

{WHILE} {return WHILE;}
{IF} {return IF;}
{ELSE} {return ELSE;}

{INI} {return INI;}			
{FIM} {return FIM;}

{TEXTO} {
	strcpy (yylval.str,yytext);
	return TEXTO;
}

{PONTOF} {
	yylval.doub = atof(yytext);
	return PONTOF;
}

{VAR} {
	strcpy (yylval.str,yytext);
	return VAR;
}

[-+()=/*^{};]  {return *yytext;}			

">" {yylval.fn = 1; return CMP; }
"<" {yylval.fn = 2; return CMP; }
"<>" {yylval.fn = 3; return CMP; }
"==" {yylval.fn = 4; return CMP; }
">=" {yylval.fn = 5; return CMP; }
"<=" {yylval.fn = 6; return CMP; }

[\ \n\t]* {;}

. {;}

%%

int yywrap()
{
   return 1;
}
