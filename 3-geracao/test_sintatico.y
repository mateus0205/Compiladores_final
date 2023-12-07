// Teste para verificar se o tamanho do tipo é calculado corretamente
int tamanhoEsperado = 4; // Tamanho esperado para o tipo "int"
int tamanhoCalculado = calculaTamanhoTipo("int");
assert(tamanhoCalculado == tamanhoEsperado);

// Teste para verificar se a posição do tipo é encontrada corretamente
int posicaoEsperada = 2; // Posição esperada para o tipo "int"
int posicaoEncontrada = buscaPosicaoTipo("int");

//bison -d nome_do_arquivo.y
