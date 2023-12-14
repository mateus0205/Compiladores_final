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
int tam; // tamanho da estrutura qdo percorre expressão de acesso
int des; // deslocamento para chegar no campo
int pos; // posicao do tipo na tabela de simbolos
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
            if (conta)
               fprintf(yyout, "\tDMEM\t%d\n", conta); 
        }
        { fprintf(yyout, "\tFIMP\n"); }
   ;

cabecalho
   : T_PROGRAMA T_IDENTIF
       {
          strcpy(elemTab.id, "inteiro");
          elemTab.end = -1;
          elemTab.tip = INT;
          elemTab.tam = 1;
          elemTab.pos = pos++;
          insereSimbolo(elemTab);

          strcpy(elemTab.id, "logico");
          elemTab.end = -1;
          elemTab.tip = LOG;
          elemTab.tam = 1;
          elemTab.pos = pos++;
          insereSimbolo(elemTab);

         fprintf(yyout, "\tINPP\n");
       }
   ;

tipo
   : T_LOGICO
         { 
            tipo = LOG; 
            // TODO #1
            // Além do tipo, precisa guardar o TAM (tamanho) do tipo e a POS (posição) do tipo na tab. símbolos
            tam = tabSimb[pos].tam; 
            pos = tabSimb[pos].pos; 

         }
   | T_INTEIRO
         { 
            tipo = INT;
            // idem 
           tam = tabSimb[pos].tam; 
            pos = tabSimb[pos].pos; 
        }
   | T_REGISTRO T_IDENTIF
         { 
            tipo = REG; 
            // TODO #2
            // Aqui tem uma chamada de buscaSimbolo para encontrar as informações de TAM e POS do registro
            int posRegistro = buscaSimbolo(atomo);
            elemTab.tam = tabSimb[posRegistro].tam;
            elemTab.pos = tabSimb[posRegistro].pos;
            elemTab.listaCampos = tabSimb[pos].listaCampos;
         }
   ;

definicoes
   : define definicoes
   | /* vazio */
   ;

define 
      : T_DEF
         {
            // TODO #3
            // Iniciar a lista de campos
            struct listaCampos lista_campos;
            elemTab.listaCampos = NULL;
         } 
   definicao_campos T_FIMDEF T_IDENTIF
       {
            // TODO #4
            // Inserir esse novo tipo na tabela de símbolos com a lista que foi montada
            strcpy(elemTab.id, atomo); //guarda o identificador encontrado na tabela
            elemTab.end = -1;
            elemTab.tip = REG;
            insereSimbolo(elemTab);
       }
   ;

definicao_campos
   : tipo lista_campos definicao_campos
   | tipo lista_campos
   ;

lista_campos
   : lista_campos T_IDENTIF
      {
         // Acrescentar esse campo na lista de campos que está sendo construída
         elemTab.listaCampos = insere(elemTab.listaCampos, atomo, tipo, pos, elemTab.tam, tam);
         des += elemTab.tam;
         elemTab.tam += tam;
      }
   | T_IDENTIF
      {
         // Idem
         elemTab.listaCampos = insere(elemTab.listaCampos, atomo, tipo, pos, elemTab.tam, tam);
         des += elemTab.tam;
         elemTab.tam += tam;
      }


variaveis
   : /* vazio */
   | declaracao_variaveis
   ;

declaracao_variaveis
   : tipo lista_variaveis declaracao_variaveis
   | tipo lista_variaveis
   ;


lista_variaveis
   : lista_variaveis T_IDENTIF
        { 
            strcpy(elemTab.id, atomo);
            elemTab.end = contaVar;
            elemTab.tip = tipo;
            // TODO #6
            // Tem outros campos para acrescentar na tab. símbolos
            elemTab.tam = tam;
            elemTab.pos = pos;
            insereSimbolo (elemTab);

            // Incrementa o contador pelo tamanho do registro, não pelo tamanho da variável individual
            if (elemTab.tip == REG) {
               contaVar += elemTab.tam;
            } else {
               contaVar++;
            }
        }
   | T_IDENTIF
        { 
            strcpy(elemTab.id, atomo);
            elemTab.end = contaVar;
            elemTab.tip = tipo;
            // idem
            elemTab.tam = tam;
            elemTab.pos = pos;
            insereSimbolo (elemTab);

            // idem 
            if (elemTab.tip == REG) {
               contaVar += elemTab.tam;
            } else {
               contaVar++;
            }
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
   : T_LEIA expressao_acesso
       { 
          int pos = buscaSimbolo (atomo);
          // TODO #8
          // Se for registro, tem que fazer uma repetição do TAM do registro de leituras
          for (int i = 0; i < tam; i++){
            fprintf(yyout, "\tLEIA\n"); 
            fprintf(yyout, "\tARZG\t%d\n", tabSimb[pos].end);
          }
       }
   ;

saida
   : T_ESCREVA expressao
       {  
          desempilha(); 
          // TODO #9
          // Se for registro, tem que fazer uma repetição do TAM do registro de escritas
          for (int i = 0; i < tam; i++){
            fprintf(yyout, "\tESCR\n"); 
          }
      }
   ;

atribuicao
   : expressao_acesso
       { 
         // TODO #10 - FEITO
         // Tem que guardar o TAM, DES e o TIPO (POS do tipo, se for registro)
          empilha(tam);
          empilha(des);
          empilha(tipo);
       }
     T_ATRIB expressao
       { 
          int tipexp = desempilha();
          int tipvar = desempilha();
          int des = desempilha();
          int tam = desempilha();
          if (tipexp != tipvar)
             yyerror("Incompatibilidade de tipo!");
          // TODO #11 - FEITO
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de ARZG
          for (int i = 0; i < tam; i++)
             fprintf(yyout, "\tARZG\t%d\n", des + i); 
       }
   ;

selecao
   : T_SE expressao T_ENTAO 
       {  
          int t = desempilha();
          if (t != LOG)
            yyerror("Incompatibilidade de tipo!");
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
            yyerror("Incompatibilidade de tipo!");
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
       {  testaTipo(INT,INT,INT); fprintf(yyout, "\tMULT\n");  }
   | expressao T_DIV expressao
       {  testaTipo(INT,INT,INT); fprintf(yyout, "\tDIVI\n");  }
   | expressao T_MAIS expressao
      {  testaTipo(INT,INT,INT); fprintf(yyout, "\tSOMA\n");  }
   | expressao T_MENOS expressao
      {  testaTipo(INT,INT,INT); fprintf(yyout, "\tSUBT\n");  }
   | expressao T_MAIOR expressao
      {  testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMMA\n");  }
   | expressao T_MENOR expressao
      {  testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMME\n");  }
   | expressao T_IGUAL expressao
      {  testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMIG\n");  }
   | expressao T_E expressao
      {  testaTipo(LOG,LOG,LOG); fprintf(yyout, "\tCONJ\n");  }
   | expressao T_OU expressao
      {  testaTipo(LOG,LOG,LOG); fprintf(yyout, "\tDISJ\n");  }
   | termo
   ;

expressao_acesso
   : T_IDPONTO
       {   //--- Primeiro nome do registro
           if (!ehRegistro) {
              ehRegistro = 1;
              // TODO #12
              // 1. busca o simbolo na tabela de símbolos
              // 2. se não for do tipo registo tem erro
              // 3. guardar o TAM, POS e DES desse t_IDENTIF
              ptregistro campo = busca(elemTab.listaCampos, atomo);
              if (!campo) {
                 yyerror("Erro: Campo não encontrado no registro.");
              }
              if (campo->tipo != REG) {
                 yyerror("Erro: O campo não é do tipo registro.");
              }
              tam = campo->tam;
              des = campo->desl;
              tipo = campo->tipo;
           } else {
              //--- Campo que eh registro
              // 1. busca esse campo na lista de campos
              // 2. se não encontrar, erro
              // 3. se encontrar e não for registro, erro
              // 4. guardar o TAM, POS e DES desse CAMPO
              ptregistro campo = busca(elemTab.listaCampos, atomo);
              if (!campo) {
                 yyerror("Erro: Campo não encontrado no registro.");
              } else if (campo->tipo != REG) {
                 yyerror("Erro: O campo não é do tipo registro.");
              } else {
                 tam = campo->tam;
                 pos = campo->pos;
                 des = campo->desl;
              }
           }
       }
     expressao_acesso
   | T_IDENTIF
       {   
           if (ehRegistro) {
               // TODO #13
               // 1. buscar esse campo na lista de campos
               // 2. Se não encontrar, erro
               // 3. guardar o TAM, DES e TIPO desse campo.
               //    o tipo (TIP) nesse caso é a posição do tipo
               //    na tabela de simbolos
               ptregistro campo = busca(elemTab.listaCampos, atomo);
               if (!campo) {
                  yyerror("Erro: Campo não encontrado no registro.");
               }
               tam = campo->tam;
               des = campo->desl;
               tipo = campo->tipo;
           }
           else {
              // TODO #14
              int pos = buscaSimbolo (atomo);
              // guardar TAM, DES e TIPO dessa variável
              tam = tabSimb[pos].tam;
              des = tabSimb[pos].end;
              tipo = tabSimb[pos].tip;
           }
           ehRegistro = 0;
       };

termo
   : expressao_acesso
       {
          // TODO #15
          // Se for registro, tem que fazer uma repetição do TAM do registro de CRVG (em ondem inversa)
          if (ehRegistro) {
             for (int i = tam - 1; i >= 0; i--) {
                fprintf(yyout, "\tCRVG\t%d\n", des + i);
             }
          } else {
             fprintf(yyout, "\tCRVG\t%d\n", des);
          }
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
    argv++;
    if (argc < 2) {
        puts("\nCompilador da linguagem SIMPLES");
        puts("\n\tUSO: ./simples <NOME>[.simples]\n\n");
        exit(1);
    }
    p = strstr(argv[0], ".simples");
    if (p) *p = 0;
    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");
    yyin = fopen(nameIn, "rt");
    if (!yyin) {
        puts ("Programa fonte não encontrado!");
        exit(2);
    }
    yyout = fopen(nameOut, "wt");
    yyparse();
    printf("programa ok!\n\n");
    return 0;
}
