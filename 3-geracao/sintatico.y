%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lexico.c"
#include "utils.c"
int contaVar = 0;
int rotulo = 0;
int ehRegistro = 0;
int tipo;
%}

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_LEIA
%token T_ESCREVA
%token T_ENQTO
%token T_FACA
%token T_FIMENQTO
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ATRIB
%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_V
%token T_F
%token T_NUMERO
%token T_NAO
%token T_ABRE
%token T_FECHA
%token T_LOGICO
%token T_INTEIRO
%token T_DEF 
%token T_FIMDEF
%token T_REGISTRO
%token T_IDPONTO

%start programa
/*VV precedência, o com maior precedência é T_VEZES e T_DIV*/
%left T_E T_OU
%left T_IGUAL 
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%

programa
    : cabecalho definicoes variaveis 
        { 
            mostraTabela();
            empilha (contaVar);
            if (contaVar)
                fprintf(yyout, "\tAMEM\t%d\n", contaVar);
        }    
     T_INICIO lista_comandos T_FIM
        { 
            int conta = desempilha();
            if(conta)
                fprintf(yyout, "\tDMEM\t%d\n", contaVar); 
        }
        { fprintf(yyout, "\tFIMP\n"); }
    ;

cabecalho 
    : T_PROGRAMA T_IDENTIF
        { fprintf(yyout, "\tINPP\n"); }     // escreve no arquivo após ler o cabecalho
    ;

tipo
    : T_LOGICO 
        { 
            tipo = LOG; 
            //TODO: #3 ALÉM DO TIPO, PRECISA GUARDAR O TAM(TAMANHO) DO TIPO E A POS(POSICAO) DO TIPO NA TAB. SIMBOLOS
        }
    | T_INTEIRO
        { 
            tipo = INT; 
            //TODO: IDEM    
        }
    | T_REGISTRO T_IDENTIF
        { 
            tipo = REG;
            //TODO: #4 AQUI TEM UMA CHAMADA DE buscaSimbolo PARA ENCONTRAR AS INFORMAÇÕES DE TAM E POS DO REGISTRO 
        }
    ;

definicoes
    : define definicoes 
    | /*vazio*/
    ;


define 
    : T_DEF {
            //TODO: #0 INICIAR A LISTA DE CAMPOS 
            

    }
    definicao_campos T_FIMDEF T_IDENTIF
    {
        //TODO: #2 INSERIR ESSE NOVO TIPO NA TABELA DE SIMBOLOS COM A LISTA QUE FOI MONSTADA.
    }
    ;

definicao_campos 
    : tipo lista_campos definicao_campos
    | tipo lista_campos 
    ;

lista_campos 
    : lista_campos T_IDENTIF
    {
        //TODO: #1 ACRESCENTAR ESSE CAMPO NA LISTA D ECAMPOS QUE ESTA SENDO CONSTRUIDA 
        //TODO: o deslocamento(endereço) do próximo campo será o deslocamento anteiror mais o tamanho desse campo
    }

    | T_IDENTIF
    {
        //todo: idem
    }
    ;


variaveis
    : /* vazio */
    | declaracao_variaveis
    ;

declaracao_variaveis
    : tipo lista_variaveis declaracao_variaveis
    | tipo lista_variaveis
    ;


lista_variaveis
    : lista_variaveis 
    T_IDENTIF 
    { 
        strcpy(elemTab.id, atomo);      // por id ser char?
        elemTab.end = contaVar;
        elemTab.tip = tipo;
        //TODO: #6 TEM OUTROS CAMPOS PARA ACRESCENTAR NA TAB.SIMBOLOS
        insereSimbolo (elemTab);
        contaVar++; 
        //TODO: #5 SE A VARIAVEL FOR RESGISTRO contaVar =  contaVar + TAM (TAMANHO DE REGISTRO)
    }
    | T_IDENTIF
        { 
            strcpy(elemTab.id, atomo);      // por id ser char?
            elemTab.end = contaVar;
            elemTab.tip = tipo;
            insereSimbolo (elemTab);
            contaVar++; 
        }
    ;

lista_comandos
    : /* vazio */
    | comando lista_comandos
    ;

comando 
    : entrada_saida
    | atribuicao
    | selecao
    | repeticao
    ;

entrada_saida   
    : entrada
    | saida
    ;

entrada
    : T_LEIA T_IDENTIF            //TODO: adiconar expressao de acesso
        { 
            int pos = buscaSimbolo (atomo);
            //TODO: #7 SE FOR REGISTRO, TEM QUE FAZER A repeticao DO TAM DO REGISTRO DE LEITURAS
            fprintf(yyout, "\tLEIA\n"); 
            fprintf(yyout, "\tARZG\t%d\n", tabSimb[pos].end); 
        }
    ;

saida 
    : T_ESCREVA expressao               //TODO: 
        { 
            desempilha(); 
            //TODO: #8 SE FOR REGISTRO, TEM QUE FAZER UMA repeticao DO TAM DO REGISTRO DE ESCRITAS
            fprintf(yyout, "\tESCR\n"); 
            
        }
    ;

atribuicao          
    : T_IDENTIF                 //TODO: lado esquerdo da expressão de acesso pode ser uma expressao de acesso
        {
            int pos = buscaSimbolo(atomo);
            empilha(pos);
            // TEM QUE GUARDAR O TAM E O POS SE FOR REGISTRO
        }
      T_ATRIB expressao
        {
            int tip = desempilha();
            int pos = desempilha();
            if (tabSimb[pos].tip != tip)
                yyerror("Incompatibilidade de tipo!"); 
            // TODO: #9 SE FOR REGISTRO TEM QUE FAZER UMA REPETIÇÃO DO TAM DO REGISTRO DO ARZG    
            fprintf(yyout, "\tARZG\t%d\n", tabSimb[pos].end); 
        }
    ;

selecao
    : T_SE expressao T_ENTAO 
        {   
            int t = desempilha();
            if (t != LOG)
                yyerror ("Incompatibilidade de tipo!");
            fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo); 
            empilha(rotulo);
        }
      lista_comandos T_SENAO 
        { 
            fprintf(yyout, "\tDSVS\tL%d\n", ++rotulo); 
            int rot = desempilha();
            fprintf(yyout, "L%d\tNADA\n", rot);
            empilha(rotulo); 
        }
      lista_comandos T_FIMSE
        { 
            int rot = desempilha();
            fprintf(yyout, "L%d\tNADA\n", rot); 
        }
    ;

repeticao
    : T_ENQTO 
        { 
            fprintf(yyout, "L%d\tNADA\n", ++rotulo); 
            empilha(rotulo);    
        }
      expressao T_FACA 
        { 
            int t = desempilha();
            if (t != LOG)
                yyerror ("Incompatibilidade de tipo!");
            fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo);
            empilha(rotulo); 
        }
      lista_comandos T_FIMENQTO
      {
            int rot1 = desempilha();
            int rot2 = desempilha();
            fprintf(yyout, "\tDSVS\tL%d\n", rot2);
            fprintf(yyout, "L%d\tNADA\n", rot1);
      }
    ;

expressao 
    : expressao T_VEZES expressao
        { testaTipo(INT, INT, INT); fprintf(yyout, "\tMULT\n"); }
    | expressao T_DIV expressao
        { testaTipo(INT, INT, INT); fprintf(yyout, "\tDIVI\n"); }
    | expressao T_MAIS expressao
        { testaTipo(INT, INT ,INT); fprintf(yyout, "\tSOMA\n"); }
    | expressao T_MENOS expressao
        { testaTipo(INT, INT ,INT); fprintf(yyout, "\tSUBT\n"); }
    | expressao T_MAIOR expressao
        { testaTipo(INT, INT, LOG); fprintf(yyout, "\tCMMA\n"); }
    | expressao T_MENOR expressao
        { testaTipo(INT, INT, LOG); fprintf(yyout, "\tCMME\n"); }
    | expressao T_IGUAL expressao
        { testaTipo(INT, INT, LOG); fprintf(yyout, "\tCMIG\n"); }
    | expressao T_E expressao
        { testaTipo(LOG, LOG, LOG); fprintf(yyout, "\tCONJ\n"); }
    | expressao T_OU expressao
        { testaTipo(LOG, LOG, LOG); fprintf(yyout, "\tDISJ\n"); }
    | termo
    ;


expressao_acesso
    : T_IDPONTO 
        { //---- PRIMEIRO NOME DO REGISTRO 
            if (!ehRegistro) {
                ehRegistro = 1;
                //TODO: #10 1. BUSCAR O SIMBOLOS  NA TABELA SIMBOLOS
                //TODO:     2. SE NAO FOR DO TIPO DE REGISTRO TEM ERRO 
                //TODO:     3. GUARDAR O TAM, POS E DES DESSE T_IDENTIF
            }else{
                //---- CAMPO QUE EH REGISTRO
                //---- 1. BUSCA ESSE CAMPO NA LISTA DE CAMPOS
                //---- 2. SE NAO ENCONTRAR, ERRO
                //---- 3. SE ENCONTRAR E NAO FOR REGISTRO, ERRO 
                //---- 4. GUARDAR O TAM, POS E DES DESSE CAMPO
            }     
        }
        expressao_acesso
    | T_IDENTIF
        {
            if (ehRegistro) {
                empilha(REG);
                //TODO: #11 1. BUSCAR ESSE CAMPO NA LISTA DE CAMPOS
                //TODO:     2. SE NAO ENCONTRAR, ERRO
                //TODO:     3. GUARDAR O TAM, DES E TIPO DESSE CAMPO    
            }   
            else {
                //TODO: #12 
                int pos = buscaSimbolo(atomo); 
                //TODO: GUARDAR TAM, DES TIP DESSA VARIAVEL
            }
            ehRegistro = 0;
        };
    


termo
    : expressao_acesso
    { 
        // TODO: #13 SE FOR REGISTRO TEM QUE FAZER UMA REPETIÇÃO DO TAM DO REGISTRO DO ARZG (EM ORDEM INVERSA)   
        printf(yyout, "\tCRVG\t%d\n", tabSimb[pos].end); 
        empilha(tipo);
    }
    | T_NUMERO
        { 
            fprintf(yyout, "\tCRCT\t%s\n", atomo); 
            empilha(INT);
        }
    | T_V
        { 
            fprintf(yyout, "\tCRCT\t1\n"); 
            empilha(LOG);
        }
    | T_F
        { 
            fprintf(yyout, "\tCRCT\t0\n"); 
            empilha(LOG);
        }
    | T_NAO termo
        {
            int t = desempilha();
            if (t != LOG)
                yyerror ("Incompatibilidade de tipo!"); 
            fprintf(yyout, "\tNEGA\n"); 
            empilha(LOG);
        }
    | T_ABRE expressao T_FECHA
    ;
%%

int main(int argc, char *argv[]) {
    char *p, nameIn[100], nameOut[100];
    argv++;          //pular para o próximo nome,    o primeiro nome é o nome do executável, por isso o salto
    if (argc < 2) {        //caso o único argumento seja o nome do executável então explicar como executar ele
        puts("\nCompilador da linguagem SIMPLES");
        puts("\n\tUSO: ./simples <NOME>[.simples]\n\n");
        exit(1);
    }
    p = strstr(argv[0], ".simples");        //caso haja a extensão .simples vamos apagar a extensão
    if (p) *p = 0;
    strcpy(nameIn, argv[0]);            //coloca a extensão, assim tratamos o caso quando não houve passagem da extensão
    strcat(nameIn, ".simples");         
    strcpy(nameOut, argv[0]);           // gera um novo arquivo com o mesmo nome mas com a extensão .mvs como arquivo de saída
    strcat(nameOut, ".mvs");
    yyin = fopen(nameIn, "rt");
    if (!yyin) {                                // caso o arquivo não abra
        puts ("Programa fonte não encontrado!");
        exit(2);
    }
    yyout = fopen(nameOut, "wt");
    yyparse();
    printf("programa ok!\n");
    return 0;
}