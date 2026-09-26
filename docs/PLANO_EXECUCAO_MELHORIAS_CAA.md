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

#### Baseline já observado

O proprietário testou o APK em um **Realme C71 Android**. O app abriu sem tela branca ou travamentos, cartões e montagem de frases funcionaram, o uso sem Internet/modo avião funcionou e os textos não ficaram cortados no celular pequeno. O modo paisagem ficou menos confortável porque mostra poucas opções de cartões. TalkBack, tablet e iOS ainda não foram testados.

Foram observados dois problemas reais para priorização: falha ao salvar uma foto capturada pela câmera ao criar um cartão próprio (imagem da galeria funciona) e mensagem visual `right overflowed` na **tela parental**. Esses problemas devem ser corrigidos antes de ampliar o teste.

#### Implementação em andamento

Na branch `fix/parental-camera-and-overflow`, foi aplicada uma correção defensiva para persistência/verificação de fotos da câmera e uma reorganização responsiva do cabeçalho de localização e do seletor de orientação na tela parental. Ainda não é “passou”: o Flutter não está disponível localmente; a validação depende de CI, novo APK e repetição no Realme C71.

O diagnóstico temporário de 30 segundos foi removido do produto. O despertador deve ser validado somente pelo fluxo real de horário configurado, com entrada em tela cheia e reprodução da voz gravada ou TTS.

O lembrete recorrente do responsável foi incluído na mesma auditoria: a criação solicita permissões e usa `exactAllowWhileIdle`; ele permanece uma notificação normal do adulto, separada do modo despertador da criança. Validar no aparelho com um dia selecionado, múltiplos dias, exclusão e reinício.

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
