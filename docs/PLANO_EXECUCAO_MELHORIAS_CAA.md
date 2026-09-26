# Plano incremental de melhorias do Fala Comigo

**Status:** planejamento aprovado; nenhuma funcionalidade deste documento foi implementada automaticamente.

## Objetivo

Evoluir o aplicativo em pequenas etapas, começando pelas melhorias básicas que reduzem risco e aumentam a qualidade de uso, sem quebrar o núcleo atual nem perder as melhorias de médio e longo prazo.

A regra permanente é:

> O controle de usuários administra recursos e pessoas autorizadas, mas nunca bloqueia a comunicação básica da criança ou do adolescente.

## Ordem segura de execução

### Etapa 0 — comprovar o que já existe

Antes de alterar código:

- instalar em um celular Android e um tablet Android reais;
- verificar abertura e ausência de tela branca;
- testar cartões, frases e fala;
- testar modo avião, reinício e retorno do segundo plano;
- testar TalkBack, foco, contraste e tamanho dos alvos;
- registrar cada fluxo como **Passou**, **Falhou** ou **Não executado**.

**Critério:** não alterar recursos que ainda não foram observados em um aparelho real sem antes registrar o comportamento atual.

### Etapa 1 — melhorias básicas de baixo risco

Implementar em PRs pequenas e independentes:

1. mensagens claras quando a voz não estiver disponível;
2. mostrar a frase montada na tela mesmo quando o áudio falhar;
3. botão de limpar/desfazer sem apagar dados indevidamente;
4. feedback visual previsível ao selecionar um cartão;
5. tamanhos de alvo e texto configuráveis sem mudar o modelo de dados;
6. contraste e modo visual de baixa estimulação;
7. tela informativa simples sobre dados locais e recursos conectados;
8. validação de campos e mensagens de erro compreensíveis.

**Critério:** cada PR deve preservar os cartões existentes, funcionar offline e conter teste automatizado ou roteiro manual reproduzível.

### Etapa 2 — conteúdo brasileiro e contingência

Depois das melhorias básicas:

- criar uma versão identificada do vocabulário brasileiro;
- não sobrescrever silenciosamente cartões existentes;
- permitir restauração do conteúdo anterior;
- revisar palavras e frases com usuários de CAA, famílias e profissionais;
- criar prancha imprimível de emergência;
- permitir exportação manual iniciada pelo responsável.

**Critério:** atualização de conteúdo não pode apagar dados locais nem exigir login ou Internet.

### Etapa 3 — recuperação, acessibilidade e segurança

- corrigir e testar migração do armazenamento;
- revisar o achado CBC/Hive e a estratégia criptográfica;
- testar interrupção, recuperação e rollback;
- validar TalkBack, foco, contraste, fonte e orientação;
- avaliar switch e varredura somente se entrarem no escopo;
- repetir análise de segurança no artefato correto.

**Critério:** nenhuma migração pode apagar a versão anterior antes de confirmar a nova gravação.

### Etapa 4 — release e suporte

- resolver o identificador Android;
- criar build/release reproduzível e assinado;
- confirmar instalação limpa e atualização;
- alinhar política, ficha de loja e comportamento real;
- preparar teste interno do Google Play;
- manter canal para registrar falhas e feedback.

### Etapa 5 — recursos conectados opcionais

Somente depois das etapas anteriores:

- vinculação opcional do responsável;
- controle de usuários e dispositivos;
- backup escolhido pelo responsável;
- sincronização opcional;
- portal institucional;
- autenticação Google ou link mágico;
- colaboração autorizada.

Esses recursos devem ficar isolados do núcleo infantil e não podem interromper o uso local.

## Melhorias mantidas na fila futura

A pesquisa comparativa continua válida e não foi descartada. Permanecem na fila:

- vocabulário brasileiro mais amplo e revisado;
- acesso por switch e varredura;
- suporte profissional e colaboração;
- interoperabilidade e exportação;
- portal conectado;
- sincronização seletiva;
- métricas administrativas não clínicas, somente se justificadas e autorizadas;
- auditoria independente de segurança e usabilidade;
- sustentabilidade de manutenção e distribuição.

## Regra de trabalho

Cada melhoria deve:

1. ter uma branch própria;
2. alterar uma área pequena;
3. incluir teste ou evidência manual;
4. preservar o funcionamento offline;
5. não exigir login da criança;
6. não usar dados clínicos reais;
7. permitir reversão antes de avançar para a próxima etapa.
