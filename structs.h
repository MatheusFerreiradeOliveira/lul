#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

//int - 0
//núm - 1
//string - 2

typedef struct vars
{ //estrutura de uma variável
    int nodetype;
    char name[50];
    double valor;
    char valors[1000];
    double *vet;
    struct vars *prox;
} VARI;

//nova variável FLOAT
VARI *ins_f(VARI *l, char n[])
{
    VARI *neww = (VARI *)malloc(sizeof(VARI));
    strcpy(neww->name, n);
    neww->prox = l;
    neww->nodetype = 1;
    return neww;
}

//nova variável INT
VARI *ins_i(VARI *l, char n[])
{
    VARI *new = (VARI *)malloc(sizeof(VARI));
    strcpy(new->name, n);
    new->prox = l;
    new->nodetype = 0;
    return new;
}

//nova variável STRING
VARI *ins_s(VARI *l, char n[])
{
    VARI *new = (VARI *)malloc(sizeof(VARI));
    strcpy(new->name, n);
    new->prox = l;
    new->nodetype = 2;
    return new;
}

//busca uma variável na lista de variáveis
VARI *srch(VARI *l, char n[])
{
    VARI *aux = l;
    while (aux != NULL)
    {
        if (strcmp(n, aux->name) == 0)
            return aux;
        aux = aux->prox;
    }
    return aux;
}

typedef struct ast
{
    int nodetype;
    struct ast *l;
    struct ast *r;
} Ast;

typedef struct numval
{ /*Estrutura de um número*/
    int nodetype;
    double valor;
} Numval;

typedef struct varval
{ /*Estrutura de um nome de variável, nesse exemplo uma variável é um número no vetor var[26]*/
    int nodetype;
    char var[50];
    int size;
    Ast *length;
} Varval;

typedef struct texto
{ /*Estrutura de um texto*/
    int nodetype;
    char txt[50];
} TXT;

typedef struct flow
{ /*Estrutura de um desvio (if/else/while)*/
    int nodetype;
    Ast *cond; /*condição*/
    Ast *tl;   /*then, ou seja, verdade*/
    Ast *el;   /*else*/
} Flow;

typedef struct symasgn
{ /*Estrutura para um nó de atribuição. Para atrubior o valor de v em s*/
    int nodetype;
    char s[50];
    Ast *v;
    int pos;
    Ast *indice;
} Symasgn;

VARI *l1; /*Variáveis*/
VARI *aux;

Ast *newast(int nodetype, Ast *l, Ast *r)
{ /*Função para criar um nó*/

    Ast *a = (Ast *)malloc(sizeof(Ast));
    if (!a)
    {
        printf("out of space");
        exit(0);
    }
    a->nodetype = nodetype;
    a->l = l;
    a->r = r;
    return a;
}

Ast *newvari(int nodetype, char nome[50])
{ /*Função de que cria uma nova variável*/
    Varval *a = (Varval *)malloc(sizeof(Varval));
    if (!a)
    {
        printf("out of space");
        exit(0);
    }
    a->nodetype = nodetype;
    strcpy(a->var, nome);
    return (Ast *)a;
}

Ast *newnum(double d)
{ /*Função de que cria um novo número*/
    Numval *a = (Numval *)malloc(sizeof(Numval));
    if (!a)
    {
        printf("out of space");
        exit(0);
    }
    a->nodetype = 'K';
    a->valor = d;
    return (Ast *)a;
}

Ast *newflow(int nodetype, Ast *cond, Ast *tl, Ast *el)
{ /*Função que cria um nó de if/else/while*/
    Flow *a = (Flow *)malloc(sizeof(Flow));
    if (!a)
    {
        printf("out of space");
        exit(0);
    }
    a->nodetype = nodetype;
    a->cond = cond;
    a->tl = tl;
    a->el = el;
    return (Ast *)a;
}

Ast *newcmp(int cmptype, Ast *l, Ast *r)
{ /*Função que cria um nó para testes*/
    Ast *a = (Ast *)malloc(sizeof(Ast));
    if (!a)
    {
        printf("out of space");
        exit(0);
    }
    a->nodetype = '0' + cmptype; /*Para pegar o tipe de teste, definido no arquivo.l e utilizar na função eval()*/
    a->l = l;
    a->r = r;
    return a;
}

Ast *newasgn(char s[50], Ast *v)
{ /*Função para um nó de atribuição*/
    Symasgn *a = (Symasgn *)malloc(sizeof(Symasgn));
    if (!a)
    {
        printf("out of space");
        exit(0);
    }
    a->nodetype = '=';
    strcpy(a->s, s);
    a->v = v; /*Valor*/
    // printf("passou %s", a->s);
    //printf ("aqui:%lf\n",((VARI*)a->v)->valor);
    return (Ast *)a;
}

Ast *newasgnS(char s[50], Ast *v)
{ /*Função para um nó de atribuição*/
    Symasgn *a = (Symasgn *)malloc(sizeof(Symasgn));
    if (!a)
    {
        printf("out of space");
        exit(0);
    }
    a->nodetype = 'a';
    strcpy(a->s, s);
    a->v = v; /*Valor*/
    // printf("passou %s", a->s);
    //printf ("aqui:%lf\n",((VARI*)a->v)->valor);
    return (Ast *)a;
}


Ast *newValorVal(char s[])
{ /*Função que recupera o nome/referência de uma variável, neste caso o número*/

    Varval *a = (Varval *)malloc(sizeof(Varval));
    if (!a)
    {
        printf("out of space");
        exit(0);
    }
    a->nodetype = 'N';
    strcpy(a->var, s);
    return (Ast *)a;
}

Ast *newValorValS(char s[50])
{ /*Função que recupera o nome/referência de uma variável, neste caso o número*/
    Varval *a = (Varval *)malloc(sizeof(Varval));
    if (!a)
    {
        printf("out of space");
        exit(0);
    }
    a->nodetype = 'Q';
    // printf("%s", s);
    strcpy(a->var, s);
    // printf("CRIOU %s\n", s);
    return (Ast *)a;
}

Ast *searchVar(int nodetype, char s[50])
{
    Symasgn *a = (Symasgn *)malloc(sizeof(Symasgn));
    if (!a)
    {
        printf("out of space");
        exit(0);
    }
    a->nodetype = nodetype;
    // printf("%s", s);
    strcpy(a->s, s);
    // printf("CRIOU %s\n", s);
    return (Ast *)a;
}

char *eval2(Ast *a)
{ /*Função que executa operações a partir de um nó*/
    VARI *aux1;
    char *v2;

    switch (a->nodetype)
    {
    case 'Q':
        aux1 = srch(l1, ((Varval *)a)->var);
        return aux1->valors;
        break;

    default:
        printf("EVAL2: internal error: bad node %c\n", a->nodetype);
        break;
    }

    return v2;
}

double evalAux(Ast *a)
{
    double v;
    double value;
    char v1[50];
    char *v2;
    VARI *aux1;
    if (!a)
    {
        printf("internal error, null eval");
        return 0.0;
    }
    switch (a->nodetype)
    {
    case 'K':
        v = ((Numval *)a)->valor;
        break; /*Recupera um número*/
    case 'N':
        aux1 = srch(l1, ((Varval *)a)->var);
        if (aux1->nodetype == 1 || aux1->nodetype == 0)
            v = aux1->valor;
        else
            printf("Variável não é do tipo Numérico\n");
        break;

    case 'n':
        aux1 = srch(l1, ((Varval *)a)->var);
        v = aux1->vet[((Varval *)a)->size];
        break;

    case '+':
        v = evalAux(a->l) + evalAux(a->r);
        break; 
    case '-':
        v = evalAux(a->l) - evalAux(a->r);
        break; 
    case '*':
        v = evalAux(a->l) * evalAux(a->r);
        break; 
    case '/':
        v = evalAux(a->l) / evalAux(a->r);
        break;
    case '%':
        v = (int) evalAux(a->l) % (int) evalAux(a->r);
        break;
    case '^':
        v = pow(evalAux(a->l), evalAux(a->r));
        break;
    case '~':
        v = pow(evalAux(a->l), (1 / evalAux(a->r)));
        break;
    case 'M':
        v = -evalAux(a->l);
        break;

    case '1':
        v = (evalAux(a->l) > evalAux(a->r)) ? 1 : 0;
        break; /*Operações lógicas. "árv esq   >   árv dir"  Se verdade 1, falso 0*/
    case '2':
        v = (evalAux(a->l) < evalAux(a->r)) ? 1 : 0;
        break;
    case '3':
        v = (evalAux(a->l) != evalAux(a->r)) ? 1 : 0;
        break;
    case '4':
        v = (evalAux(a->l) == evalAux(a->r)) ? 1 : 0;
        break;
    case '5':
        v = (evalAux(a->l) >= evalAux(a->r)) ? 1 : 0;
        break;
    case '6':
        v = (evalAux(a->l) <= evalAux(a->r)) ? 1 : 0;
        break;
    default:
        printf("EVAL1: internal error: bad node %c\n", a->nodetype);
        break;
    }
    return v;
}

char *parseSTR(Ast *a)
{
    // printf("PASSOU AQUI %c\n", a->nodetype);
    char *v = (char *)malloc(1000 * sizeof(char));
    double value;
    VARI *aux1;
    if (!a)
    {
        printf("internal error, null eval");
        return NULL;
    }
    switch (a->nodetype)
    {
    case '$':
        return ((TXT *)a->l)->txt;
        break;
    case '7':
        value = evalAux(a->l);
        sprintf(v, "%.2lf", value);
        break;
    case '8':
        value = evalAux(a->l);
        sprintf(v, "%.0lf", value);
        break;
    case '9':
        // printf("aqui=> %s\n", ((Symasgn *)(a->l))->s);
        aux1 = srch(l1, ((Symasgn *)(a->l))->s);
        // printf("nodetype: %d\n", aux1->nodetype);
        if (aux1->nodetype == 2)
            return aux1->valors;
        else
            printf("Variável não é do tipo String %c\n", a->nodetype);
        break;
    default:
        printf("STRING: internal error: bad node %c\n", a->nodetype);
        break;
    }
    return v;
}

double eval(Ast *a)
{ /*Função que executa operações a partir de um nó*/
    double v;
    double value;
    char v1[50];
    char *v2;
    VARI *aux1;
    if (!a)
    {
        printf("internal error, null eval");
        return 0.0;
    }
    switch (a->nodetype)
    {
    case 'K':
        v = ((Numval *)a)->valor;
        break; /*Recupera um número*/
    case 'N':
        aux1 = srch(l1, ((Varval *)a)->var);
        // printf("entrou aqui %d<-\n", aux1->nodetype);
        // value = (int)aux1->nodetype;
        // printf("Passo: %lf", aux1->valor);
        v = aux1->valor;
        break;

    case 'n':
        aux1 = srch(l1, ((Varval *)a)->var);
        // printf("==> %s", ((Varval *)a)->var);
        // value = eval(((Varval *)a)->length);
        value = eval(((Varval *)a)->length);
        // printf(">>> %.1lf\n", value);
        // printf("var: %s, id: %.0lf\n", ((Varval *)a)->var, value);
        v = aux1->vet[(int)value];
        break;

    case '+':
        v = eval(a->l) + eval(a->r);
        break;
    case '-':
        v = eval(a->l) - eval(a->r);
        break;
    case '*':
        v = eval(a->l) * eval(a->r);
        break;
    case '/':
        v = eval(a->l) / eval(a->r);
        break;
    case '%':
        v = (int)eval(a->l) % (int)eval(a->r);
        break;
    case '^':
        v = pow(eval(a->l), eval(a->r));
        break;
    case '~':
        v = pow(eval(a->l), (1 / eval(a->r)));
        break;
    case 'M':
        v = -eval(a->l);
        break;

    case '1':
        v = (eval(a->l) > eval(a->r)) ? 1 : 0;
        break;
    case '2':
        v = (eval(a->l) < eval(a->r)) ? 1 : 0;
        break;
    case '3':
        v = (eval(a->l) != eval(a->r)) ? 1 : 0;
        break;
    case '4':
        v = (eval(a->l) == eval(a->r)) ? 1 : 0;
        break;
    case '5':
        v = (eval(a->l) >= eval(a->r)) ? 1 : 0;
        break;
    case '6':
        v = (eval(a->l) <= eval(a->r)) ? 1 : 0;
        break;

    case '=':
        v = eval(((Symasgn *)a)->v); /*Recupera o valor*/
        aux = srch(l1, ((Symasgn *)a)->s);
        if (aux->nodetype == 1)
        { //lembrar de verificar os demais tipos
            aux->valor = v;
        }
        else
        {
            // ((Varval *)a)->length
            // printf("=> %lf, %lf <== \n", ((Varval *)a)->length, ((Symasgn *)a)->indice);
            value = eval(((Symasgn *)a)->indice);
            // printf(">>> %.1lf\n", value);
            //printf("vetor: %d", ((Symasgn *)a)->pos);
            aux->vet[(int)value] = v;
            // printf("==%lf\n", aux->vet[(int)value]);
        }
        break;

    case 'a':
        //v = eval(((Symasgn *)a)->v); /*Recupera o valor*/
        strcpy(v1,  parseSTR(((Symasgn *)a)->v));
        aux = srch(l1, ((Symasgn *)a)->s);
        strcpy(aux->valors, v1);
        break;
        
    case 'I': /*CASO IF*/
        if (eval(((Flow *)a)->cond) != 0)
        {                                  /*executa a condição / teste*/
            if (((Flow *)a)->tl)           /*Se existir árvore*/
                v = eval(((Flow *)a)->tl); /*Verdade*/
            else
                v = 0.0;
        }
        else
        {
            if (((Flow *)a)->el)
            {
                v = eval(((Flow *)a)->el); /*Falso*/
            }
            else
                v = 0.0;
        }
        break;

    case 'W':
        //printf ("WHILE\n");
        v = 0.0;
        if (((Flow *)a)->tl)
        {
            while (eval(((Flow *)a)->cond) != 0)
            {
                v = eval(((Flow *)a)->tl);
            }
        }
        break;

    case 'L':
        eval(a->l);
        v = eval(a->r);
        break; /*Lista de operções em um bloco IF/ELSE/WHILE. Assim o analisador não se perde entre os blocos*/

    case 'P':
        v = eval(a->l); /*Imprime um FLOAT*/
        printf("%.2f\n", v);
        break;

    case 'S':
        fflush(stdin);
        scanf("%lf", &v);
        fflush(stdin);
        aux1 = srch(l1, ((Varval *)a)->var);
        aux1->valor = v;
        break;

    case 'T':
        fflush(stdin);
        scanf("%[^\n]s", v1);
        fflush(stdin);
        aux1 = srch(l1, ((Varval *)a)->var);
        strcpy(aux1->valors, v1);
        break;

    case 'Y':
        v2 = eval2(a->l); /*Recupera um valor STR*/
        printf("%s\n", v2);
        break; /*Função que imprime um valor (string)*/

    /** =========  Função que imprime um valor (string) ============ */
    // subdivisao do float
    case 'q':
        eval(a->r);
        eval(a->l);
        /*Recupera um valor STR*/
        // printf("->%.2lf", v1);
        // strcat($1, $2);
        break; /*Função que imprime um valor (string)*/
    case 'p':
        value = eval(a->l); /*Recupera um valor STR*/
        printf("%.2lf\n", value);
        break;

    // subdivisao do int
    case 'v':
        eval(a->r);
        eval(a->l);
        /*Recupera um valor STR*/
        // printf("->%.2lf", v1);
        // strcat($1, $2);
        break; /*Função que imprime um valor (string)*/
    case 'u':
        value = eval(a->l);
        printf("%d\n", (int)value);
        break;

    //Modelo antigo
    /*case 's':
        printf("%s", ((Varval *)a->l)->var);
        break; */

    case 'z':
        aux1 = srch(l1, ((Varval *)a)->var);
        if (aux1->nodetype == 2)
            printf("%s\n", aux1->valors);
        else
            printf("Variável não é do tipo String %c\n", a->nodetype);
        break;

    case 'Z':
        printf("%s\n", ((TXT*)a->l)->txt);
        break;

    case 'V': //armazena um float
        l1 = ins_f(l1, ((Varval *)a)->var);
        break;
    case 'U': //armazena um int
        l1 = ins_i(l1, ((Varval *)a)->var);
        break;
    case 'X': //armazena um string
        l1 = ins_s(l1, ((Varval *)a)->var);
        break;

    case 'D': //declarar e inserir float
        v = eval(a->r);
        l1 = ins_f(l1, ((Symasgn *)(a->l))->s);
        l1->valor = v;
        break;
    case 'd': //declarar varios float
        l1 = ins_f(l1, ((Symasgn *)(a->l))->s);
        eval(a->r);
        break;

    case 'G': //declarar e inserir int
        v = eval(a->r);
        l1 = ins_i(l1, ((Symasgn *)(a->l))->s);
        l1->valor = v;
        break;
    case 'g': //declarar varios int
        l1 = ins_i(l1, ((Symasgn *)(a->l))->s);
        eval(a->r);
        break;

    case 'H': //declarar e inserir string
        // printf("AQUI OOOHHH: %s, %s\n", ((Symasgn *)(a->l))->s, ((Varval *)a->r)->var);
        l1 = ins_s(l1, (((Symasgn *)(a->l))->s));
        strcpy(l1->valors, ((Varval *)a->r)->var);
        break;
    case 'h': //declarar varios string
        l1 = ins_s(l1, ((Symasgn *)(a->l))->s);
        eval(a->r);
        break;
    case '@':
        v2 = parseSTR(((Symasgn *)a)->v);
        // printf("=====> %s <======\n", v2);
        aux1 = srch(l1, ((Symasgn *)a)->s);
        // printf("@ copy:%s <- %s\n", ((Symasgn *)a)->s, v2);
        if (aux1->nodetype == 2)
            strcpy(aux1->valors, v2);
        else
            printf("Variável %s não é do tipo String \n", ((Symasgn *)a)->s);
        // v = eval(((Symasgn *)a)->v); /*Recupera o valor*/
        // concatenar
        break;
    case '#':
        // printf("# rotas\n");
        v2 = parseSTR(((Symasgn *)a)->v);
        // printf("=====> %s <======\n", v2);
        aux1 = srch(l1, ((Symasgn *)a)->s);
        if (aux1->nodetype == 2)
            strcat(aux1->valors, v2);
        else
            printf("Variável %s não é do tipo String \n", ((Symasgn *)a)->s);
        // v = eval(((Symasgn *)a)->v); /*Recupera o valor*/
        // concatenar
        break;
    default:
        printf("EVAL1: internal error: bad node %c\n", a->nodetype);
        break;
    }
    return v;
}
