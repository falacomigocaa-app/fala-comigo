# Prompt mestre para retomar o Fala Comigo com qualquer agente de IA

Copie e cole o texto abaixo na primeira mensagem de uma nova IA que for continuar este projeto.

---

## PROMPT PARA O NOVO AGENTE

Você está assumindo a continuidade do projeto **Fala Comigo**, um aplicativo Flutter de Comunicação Aumentativa e Alternativa (CAA) para pessoas autistas e suas famílias.

Sua tarefa é continuar o trabalho com o mesmo cuidado técnico, sem perder mudanças anteriores, sem sobrescrever a `main` de forma destrutiva e sem inventar validações.

### 1. Leia obrigatoriamente antes de fazer qualquer alteração

No repositório `/home/ubuntu/fala-comigo`, leia nesta ordem:

```text
CONTINUAR_AQUI_PRIMEIRO.md
AGENTS.md
PROJECT_HANDOFF.md
docs/HANDOFF_TELA_BRANCA_APK.md
docs/CONTINUIDADE_ASSISTENTE_IA.md
docs/CHECKLIST_PRE_LANCAMENTO.md
docs/MATRIZ_FLUXOS_CRITICOS.md
```

Depois execute:

```bash
cd /home/ubuntu/fala-comigo
git fetch origin --prune
git status --short --branch
git log --all --oneline --decorate -25
gh pr list --repo falacomigocaa-app/fala-comigo --state open --limit 30
```

Você deve apresentar primeiro um resumo com:

- branch atual;
- commit atual da `origin/main`;
- PRs abertas relacionadas ao Android, tela branca e APK;
- arquivos modificados localmente;
- jobs do GitHub Actions em execução;
- o que já foi comprovado;
- o que ainda não foi comprovado;
- próximo passo de menor risco.

Não comece editando arquivos antes desse diagnóstico.

### 2. Contexto técnico obrigatório

A `main` não deve ser alterada diretamente durante a investigação.

A correção em andamento está na branch:

```text
fix/main-startup-and-android-build
```

A PR principal dessa correção é:

```text
PR #66 — Fix: prevent Android startup white screen
```

A `main` estava no commit `0d0b685` quando a correção foi criada.

O problema observado foi:

```text
O APK instala e abre, mas a tela fica totalmente branca.
```

A causa provável já identificada é:

```text
HiveError: The box "pictogram_cards" is already open and of type Box<dynamic>
```

A `main` abria `pictogram_cards` sem tipo explícito, enquanto o provider da grade exige `Box<PictogramCard>`.

A correção seletiva da PR 66 faz o seguinte:

1. tipa `SecureBoxService.openSecureBox<T>`;
2. tipa `SecureBoxService.openSecureBoxWithMigration<T>`;
3. usa `Hive.openBox<T>` na abertura e migração;
4. abre `pictogram_cards` como `Box<PictogramCard>` no `lib/main.dart`;
5. aplica `org.jetbrains.kotlin.android` no Gradle Android;
6. mantém a keystore obrigatória para builds release;
7. não remove funcionalidades do CAA, offline, parental, RH, privacidade ou segurança;
8. adiciona documentação de continuidade para próximos agentes.

### 3. PRs que não devem ser mescladas cegamente

A PR 29 está aberta, mas está `DIRTY` porque foi criada contra uma versão antiga da `main`.

```text
PR #29 — Fix Android debug build and add test guide
```

Ela contém parte da correção, mas não deve ser mesclada inteira. Compare sempre os arquivos atuais e reaplique apenas alterações comprovadas.

A PR 60 está aberta como draft e contém uma tela diagnóstica para mostrar a exceção de inicialização:

```text
PR #60 — Diagnostics: mostrar erro de inicialização no APK
```

Não fechar, apagar ou mesclar a PR 60 sem avaliar se o APK corrigido ainda apresenta a tela branca. Ela pode ser necessária para obter o erro real no aparelho.

### 4. Regras de segurança do trabalho

Nunca faça:

- `git reset --hard` sem preservar o estado atual;
- `git push --force`;
- exclusão de branches, PRs ou commits;
- alteração direta na `main` durante diagnóstico;
- commit de APK, AAB, keystore, token, senha ou segredo;
- uso de dados reais de crianças;
- remoção do modo offline;
- bloqueio da comunicação básica por plano pago;
- liberação de dados clínicos, frases, fotos, vídeos ou métricas individuais para RH;
- declaração de “build aprovado” apenas porque o APK foi compilado.

O aplicativo deve continuar funcionando sem internet, sem conta e sem pagamento para a comunicação básica.

### 5. Ordem exata da próxima execução

Primeiro verifique a PR 66:

```bash
gh pr view 66 --repo falacomigocaa-app/fala-comigo --json number,title,state,isDraft,mergeStateStatus,statusCheckRollup,commits,files,url
gh pr checks 66 --repo falacomigocaa-app/fala-comigo
```

Depois confira o workflow do APK:

```bash
gh run list --repo falacomigocaa-app/fala-comigo --workflow android-test-apk.yml --branch fix/main-startup-and-android-build --limit 10
```

Se ainda não houver execução do commit correto, rode:

```bash
gh workflow run android-test-apk.yml \
  --repo falacomigocaa-app/fala-comigo \
  --ref fix/main-startup-and-android-build
```

Acompanhe a execução até terminar. Não declare resultado antes de consultar o status final.

Quando o workflow terminar, baixe o artefato:

```bash
mkdir -p /tmp/fala-comigo-apk-corrigido
gh run download RUN_ID \
  --repo falacomigocaa-app/fala-comigo \
  --dir /tmp/fala-comigo-apk-corrigido
find /tmp/fala-comigo-apk-corrigido -type f -maxdepth 4 -print
sha256sum /tmp/fala-comigo-apk-corrigido/**/*.apk
```

Substitua `RUN_ID` pelo número real da execução. Registre o SHA-256 no handoff, mas não envie o APK para o Git.

### 6. Se Flutter estiver disponível localmente

Execute na branch da PR 66:

```bash
flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build web --release
flutter build apk --debug
```

Se Flutter ou Android SDK não estiverem disponíveis, registre a limitação e use o GitHub Actions. Nunca diga que passou localmente sem executar.

### 7. Validação no aparelho Android

Depois de obter o APK:

1. fazer instalação limpa;
2. abrir com internet desligada;
3. verificar se a grade CAA aparece;
4. testar falar, adicionar e falar + adicionar;
5. montar e limpar frases;
6. testar cartões padrão;
7. testar área parental e PIN com dados sintéticos;
8. testar retorno do segundo plano;
9. testar acessibilidade e TalkBack;
10. registrar modelo, Android, versão do APK e resultado.

Classifique cada etapa apenas como:

```text
PASSOU
FALHOU
NÃO EXECUTADO
```

Se a tela continuar branca, não tente adivinhar. Use a PR 60 ou uma nova branch diagnóstica para mostrar a exceção de inicialização. Cole no relatório somente o tipo e a mensagem do erro, removendo dados sensíveis.

### 8. Critério para integrar na main

Só propor merge da PR 66 depois de:

- checks do GitHub Actions verdes;
- `git diff --check` aprovado;
- análise e testes concluídos;
- APK debug gerado e verificado;
- SHA-256 registrado;
- revisão do diff confirmando que nenhuma funcionalidade existente foi removida;
- documentação atualizada;
- ausência de segredos e dados reais.

A validação física em aparelho deve continuar claramente separada da validação de build.

### 9. Atualização obrigatória após cada etapa

Ao terminar qualquer etapa, atualize todos estes arquivos:

```text
CONTINUAR_AQUI_PRIMEIRO.md
docs/HANDOFF_TELA_BRANCA_APK.md
docs/CONTINUIDADE_ASSISTENTE_IA.md
```

No registro, inclua sempre:

- data;
- objetivo;
- branch;
- commit;
- PR ou run relacionado;
- comandos executados;
- resultado real;
- limitações;
- riscos;
- próximo passo;
- se a `main` foi ou não alterada.

Também atualize o corpo da PR correspondente com o resultado. Não deixe o próximo agente depender apenas do histórico da conversa.

### 10. Formato obrigatório do relatório de retorno

Ao finalizar uma etapa, responda usando este formato:

```text
ETAPA FINALIZADA: [nome da etapa]

BRANCH:
COMMIT:
PR:
MAIN ALTERADA: sim/não

O QUE FOI FEITO:
- ...

VALIDAÇÕES EXECUTADAS:
- comando — resultado

ARTEFATOS:
- APK/AAB/URL/SHA-256, se houver

O QUE AINDA NÃO FOI VALIDADO:
- ...

RISCOS OU LIMITAÇÕES:
- ...

PRÓXIMO PASSO SEGURO:
- ...

ARQUIVOS DE CONTINUIDADE ATUALIZADOS:
- ...
```

Não use “finalizado” se ainda houver um job, teste ou validação importante em andamento. Nesse caso, informe claramente que a etapa está aguardando resultado.

### 11. Objetivo final desta retomada

O objetivo imediato não é lançar o aplicativo, ativar cobrança, conectar o portal RH ou sincronizar dados clínicos.

O objetivo imediato é:

1. corrigir a tela branca causada pela abertura Hive sem tipagem;
2. gerar um APK de teste a partir da correção baseada na `main` atual;
3. comprovar que o APK instala e abre a grade CAA;
4. documentar o resultado para que outro agente continue sem perder o fio;
5. somente depois avaliar o merge na `main`.

Comece agora lendo os arquivos obrigatórios e fazendo o diagnóstico do estado atual. Não altere arquivos antes de apresentar o resumo inicial.

---

## FIM DO PROMPT


---

## 12. Gate atual — Criador sem Manus Space

O proprietário não quer vínculo com Manus ou Manus Space no Espaço do Criador. O e-mail planejado para o futuro login próprio é `falacomigocaa@gmail.com`. A tentativa parcial de implementação foi revertida e não existe login próprio pronto.

Antes de programar, apresente estas opções e aguarde escolha:

- **A (recomendada):** GitHub Pages para site/interface + backend e banco em provedor independente do Manus, com login próprio por e-mail e senha.
- **B:** somente GitHub Pages, aceitando que haverá apenas interface estática sem autenticação, banco, convites ou permissões reais.
- **C:** avaliar outro provedor independente escolhido pelo proprietário.

Nunca criar uma falsa autenticação no JavaScript público. GitHub Pages não executa backend contínuo. Não remover o portal atual nem substituir o link `https://falacomigo-kyrh225w.manus.space/creator` até existir uma migração funcional, validada e publicada.

### 13. Decisão já tomada — Opção A e URL oficial

O proprietário já escolheu a **Opção A**: manter o site e a interface pública no GitHub Pages, iniciar backend e banco independentes em camadas gratuitas quando possível e migrar para planos pagos somente quando necessário. Não pedir novamente essa escolha; a próxima decisão técnica é comparar e definir a infraestrutura, sem contratar ou ativar cobrança sem autorização.

A única URL pública oficial do projeto é `https://falacomigocaa-app.github.io/fala-comigo/`. Toda alteração pública deve ser feita em `site/`, revisada em PR, publicada pelo `site-pages.yml` e conferida nessa URL. Atualize sempre os arquivos de continuidade ao finalizar cada etapa.
