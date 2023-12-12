    // Tabela de SImbolos
    #include <stdio.h>
    #include <stdlib.h>
    enum
    {
        INT, 
        LOG,
        REG
    };

    //TODO: criar lista de campos?

    //TODO: criar função para percorrer a lista de campos


    char nomeTipo[3][4] = {
        "INT", "LOG", "REG"
    };
    #define TAM_TAB 100

    typedef struct no * ptno;
    struct no {
        char nome[100];
        int tipo;
        int pos;
        int desl;
        int tam;
        ptno prox;
    };

    ptno insere (ptno L, char nome[100], int tipo, int pos, int desl, int tam){
        ptno p, novo;
        novo = (ptno)malloc(sizeof(struct no));
        strcpy(novo->nome, nome); // na hora de passar novo -> novo = nome deu erro de assigments
        novo -> tipo = tipo;
        novo -> pos = pos;
        novo -> desl = desl;
        novo -> tam = tam;
        novo -> prox = NULL;
        p = L;
        while (p && p-> prox)   
            p = p -> prox;
        if(p)
            p -> prox = novo;

        else
            L = novo;
        return L;
    }
    ptno busca (ptno L, char *nome){
        while (L && L -> nome != nome)
            L = L -> prox;
        return L;
        
    }

    void mostra (ptno L){
        while(L){
            if(L->prox){ 
                printf("(%s, %s, %d, %d, %d)=>",L-> nome, nomeTipo[L-> tipo], L -> pos, L-> desl, L->tam);
            } else {
                printf("(%s, %s, %d, %d, %d)",L-> nome, nomeTipo[L-> tipo], L -> pos, L-> desl, L->tam);
            }
            L = L -> prox;
        }
    }

    // criar uma estrutura e operações para manipular uma lista de campos

    #define TAM_TAB 100

    //acrescentar campos na tabela
    struct  elemTabSimbolos 
    {
        char id[100];   // nome do identificador   
        int end;        // endereco
        int tip;        // tipo
        int tam; 
        int pos;
        ptno campos;
    } tabSimb[TAM_TAB], elemTab;

    int posTab = 0;    // indica a próxima posição livre para inserção

    int buscaSimbolo (char *s) 
    {
        int i;
        for (i = posTab - 1; strcmp(tabSimb[i].id, s) && i >= 0; i--) 
                ;
        if (i == -1) 
        {
            char msg[200];
            sprintf(msg, "Identificador [%s] não ecnontrado!", s);
            yyerror(msg);
        }
        return i;
    }

    void insereSimbolo (struct elemTabSimbolos elem) 
    {
        int i;          
        if (posTab == TAM_TAB)
            yyerror("Tabela de Simbolos cheia!");                                                    //
        for (i = posTab - 1; strcmp(tabSimb[i].id, elem.id) && i >= 0; i--) 
                ;
        if (i != -1) 
        {    // caso encontre um nome igual ao que deseja inserir já existente na tabela
        char msg[200];    // se o valor for igual a -1 a tabela foi totalmente percorrida e não foram encontradas elementos duplicados
        sprintf(msg, "Identificador [%s] duplicado!", elem.id);
        yyerror(msg);
        }
        tabSimb[posTab++] = elem;         // insere o elemento na posição posTab++
    }

    void mostraTabela() 
    {
        puts("------------------------------------Tabela de Simbolos------------------------------------");
        printf("%30s | %3s | %s | %s | %s | %s \n", "ID", "END", "TIP", "TAM", "POS", "CAMPOS");
        for(int i = 0; i < 90; i++)
            printf("-");
        for(int i = 0; i < posTab; i++){
            printf("\n%30s | %3d | %s | %d | %d |" , 
                    tabSimb[i].id,
                    tabSimb[i].end,
                    nomeTipo[tabSimb[i].tip],
                    tabSimb[i].tam,
                    tabSimb[i].pos
                    );
            mostra(tabSimb[i].campos);
        }
        puts("");
    }

    // Pilha Semantica
    #define TAM_PIL 100
    int pilha[TAM_PIL];
    int topo = -1;      

    void empilha (int valor) 
    {
        if (topo == TAM_PIL)
            yyerror ("Pilha semantica cheia!");
        pilha[++topo] = valor;
    }

    int desempilha (void) 
    {
        if (topo == -1)
            yyerror ("Pilha semantica vazia!");
        return pilha[topo--];      // se a pilha não for vazia retorna a nova posição da pilha após desempilhar
    }

    // tipo1 e tipo2 são os tipos esperados na expressão
    // ret é o tipo que será empilhado com resultado da expressão
    void testaTipo (int tipo1, int tipo2, int ret) {
        int t2 = desempilha();
        int t1 = desempilha();
        if (t1 != tipo1 || t2 != tipo2) 
            yyerror("Incompatibilidade de tipo!");
        empilha(ret);
    }
