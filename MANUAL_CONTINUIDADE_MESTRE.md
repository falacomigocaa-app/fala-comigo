# Fala Comigo — Manual mestre de continuidade para agentes de IA

**Versão:** 1.0
**Atualizado em:** 25 de setembro de 2026
**Repositório:** `falacomigocaa-app/fala-comigo`
**Responsável:** proprietário do projeto Fala Comigo

## 1. Finalidade

Este manual permite que outro agente de IA continue o projeto sem depender do histórico da conversa, sem repetir trabalho e sem bagunçar a `main`.

O agente deve atuar como uma **equipe técnica coordenada**, reunindo análise de programação, Flutter, Android, Web, layout, acessibilidade, privacidade, testes e produto. Ele deve apresentar soluções executáveis, não apenas listar problemas.

> **Regra central:** entender primeiro, propor a menor solução segura, validar com evidência e só então alterar ou publicar.

## 2. Ordem obrigatória de leitura

Antes de executar qualquer alteração, ler nesta ordem:

1. `CONTINUAR_AQUI_PRIMEIRO.md`
2. `AGENTS.md`
3. `PROJECT_HANDOFF.md`
4. este arquivo: `MANUAL_CONTINUIDADE_MESTRE.md`
5. `docs/CONTINUIDADE_ASSISTENTE_IA.md`
6. `docs/HANDOFF_TELA_BRANCA_APK.md`, quando o assunto envolver Android, APK ou tela branca
7. `docs/CHECKLIST_PRE_LANCAMENTO.md`
8. `docs/PLANO_SEQUENCIAL_ATE_BUILD.md`

Depois disso, confirmar o estado real do GitHub e do ambiente. Nunca confiar apenas em uma descrição antiga de branch ou commit.

## 3. Estado confirmado da integração

A integração final foi concluída.

| Item | Estado |
|---|---|
| Branch principal | `main` |
| PR de integração | [PR 67](https://github.com/falacomigocaa-app/fala-comigo/pull/67) |
| Commit final na `main` | `7aa12f5` — `Merge integration: Android startup fix and parental area` |
| Branch de integração | `integration/finalize-project`, preservada para auditoria |
| CI pós-merge | aprovado |
| Deploy GitHub Pages | aprovado |
| Testes Flutter locais | 92 aprovados |
| Build Web release local | aprovado |
| APK debug local | aprovado, aproximadamente 153 MB |
| Build Android release | ainda depende de keystore de produção e validação em dispositivo real |

Site publicado: <https://falacomigocaa-app.github.io/fala-comigo/>

APK debug local, quando disponível neste ambiente: `build/app/outputs/flutter-apk/app-debug.apk`.

## 4. O que foi integrado

- Correção do bootstrap Android e da abertura tipada do Hive para evitar a tela branca.
- Plugin Kotlin Android e configuração Gradle compatível.
- Inicialização resiliente com carregamento, erro sanitizado e retry.
- Inicialização de TTS e notificações depois do primeiro frame.
- Melhorias da Área Parental das PRs 30, 32 e 33.
- Correções e proteção Android associadas à PR 66.
- Inventário de exclusão local, incluindo dados, mídia, credenciais e chaves.
- Melhorias de acessibilidade e layout em telas parentais.
- Site institucional e publicação GitHub Pages.
- Testes, formatação, análise estática e workflows de CI.

## 5. Regras de atuação do agente

### 5.1 Antes de agir

O agente deve:

1. explicar em poucas linhas o que entendeu;
2. verificar branch, commit, status e remotes;
3. localizar os arquivos envolvidos;
4. distinguir fato comprovado, hipótese e pendência;
5. propor uma solução de baixo risco;
6. informar quais comandos e validações pretende executar.

### 5.2 O que pode fazer sem pedir confirmação novamente

Pode executar autonomamente ações locais, reversíveis e de baixo risco:

- ler arquivos e logs;
- instalar ferramentas no sandbox;
- criar worktree temporário;
- rodar formatador, análise, testes e builds;
- corrigir erro de compilação ou teste dentro do escopo já autorizado;
- criar documentação de continuidade;
- revisar diff;
- preparar branch de trabalho;
- criar commit e abrir/atualizar PR, se isso estiver dentro da demanda aprovada.

### 5.3 Quando deve parar e pedir confirmação

Deve parar antes de:

- fazer merge na `main`;
- publicar uma versão ampla ou release de produção;
- gerar/enviar AAB de produção;
- alterar cobrança, domínio, conta, permissões, segurança ou acesso;
- contratar serviço ou usar credencial nova;
- excluir dados, branches ou histórico;
- ativar backend clínico, sincronização ou portal conectado;
- fazer qualquer ação externa irreversível.

A pergunta deve ser curta e objetiva, contendo o payload exato. Exemplo:

> **Validação concluída.** CI, testes e build passaram. Posso mesclar a PR 68 na `main` usando o commit `abc1234`, preservando a branch de integração?

O usuário pode responder simplesmente: **“Sim, pode prosseguir.”** Só depois dessa confirmação o agente executa a ação de alto impacto.

### 5.4 Regra de ouro sobre problemas

Não responder apenas “há um problema”. Sempre apresentar:

1. causa provável;
2. evidência;
3. solução recomendada;
4. risco da solução;
5. validação necessária;
6. próximo passo.

## 6. Fluxo técnico padrão

```text
entender demanda
→ ler handoff
→ verificar estado real
→ criar branch/worktree
→ reproduzir problema
→ implementar menor correção
→ adicionar/ajustar teste
→ formatar
→ analisar
→ testar
→ gerar build
→ revisar diff
→ registrar evidências
→ abrir/atualizar PR
→ pedir confirmação para merge/publicação
→ executar ação confirmada
→ verificar resultado
→ atualizar handoff
```

Comandos iniciais:

```bash
git fetch origin --prune
git status --short --branch
git log --oneline --decorate -12
git rev-parse origin/main
gh pr list --repo falacomigocaa-app/fala-comigo --state open
```

Validação Flutter preferencial:

```bash
export PATH=/tmp/flutter/bin:$PATH
flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build web --release
```

Validação Android, quando o SDK estiver disponível:

```bash
export ANDROID_SDK_ROOT=/home/ubuntu/android-sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
flutter build apk --debug
```

## 7. Organização da “equipe mestre”

O agente principal deve pensar como especialistas, mas não criar alterações conflitantes em paralelo sem necessidade.

| Especialista | Pergunta que deve responder |
|---|---|
| Flutter/Dart | Compila? Há erro de estado, ciclo de vida ou tipagem? |
| Android/Gradle | APK abre? SDK, JDK, assinatura e manifest estão corretos? |
| Web | O build e a página publicada carregam sem quebrar o modo local? |
| UI/layout | Há overflow, duplicação, tela branca ou hierarquia confusa? |
| Acessibilidade | Semântica, foco, contraste e alvos são adequados? |
| Segurança/privacidade | Dados, PIN, mídia, wipe e exportação continuam protegidos? |
| QA/testes | Existe teste reproduzível e evidência recente? |
| Produto | A mudança preserva comunicação local-first e não inventa função clínica? |

A síntese deve terminar com: **decisão recomendada, arquivos envolvidos, comandos de validação e confirmação necessária**.

## 8. Regras permanentes do produto

- A comunicação básica funciona sem internet, conta ou plano pago.
- Não bloquear comunicação, acessibilidade ou modo offline por licença.
- Não coletar, vender ou usar dados de crianças para publicidade.
- O app não diagnostica nem substitui terapia.
- Não tratar documentação conceitual como backend implementado.
- Portal conectado exige autorização no servidor, consentimento, isolamento por organização, auditoria e testes negativos.
- Cobrança real, domínio definitivo e publicação ampla exigem confirmação explícita.
- Nunca colocar senha, token, PIN, chave privada ou dado real de criança no Git.

## 9. Como o proprietário deve enviar uma nova demanda

O proprietário pode enviar mensagens simples. O agente deve transformar a mensagem em plano técnico e não perder o contexto.

### Exemplo A — correção de erro

Mensagem do proprietário:

> “A tela de cartões está dando overflow no celular. Analise e resolva sem quebrar o layout parental.”

Resposta operacional esperada:

> “Entendi: vou reproduzir o overflow, localizar a causa, aplicar uma correção responsiva pequena, atualizar o teste visual/estrutural, rodar análise e testes e deixar a PR pronta. Só pedirei confirmação antes de merge ou publicação.”

### Exemplo B — análise sem alteração

Mensagem:

> “Analise por que o APK e a Web estão diferentes, mas não altere nada ainda.”

Conduta:

- ler código e workflows;
- comparar commits e artefatos;
- executar diagnósticos seguros;
- entregar causa, evidência e plano;
- não fazer commit, push ou merge.

### Exemplo C — execução autorizada

Mensagem:

> “Pode aplicar a solução recomendada, testar e preparar a PR. Não faça merge ainda.”

Conduta:

- criar branch;
- implementar;
- testar;
- fazer commit/push;
- abrir ou atualizar PR;
- apresentar resultado;
- esperar confirmação apenas para merge/publicação.

### Exemplo D — confirmação de alto impacto

Agente:

> “A PR 68 está verde: CI aprovado, 92 testes, Web release e APK debug aprovados. O merge fará a `main` avançar para `abc1234`. A branch será preservada. Posso mesclar?”

Proprietário:

> “Sim, pode mesclar.”

Ação posterior:

- executar merge;
- verificar commit da `main`;
- verificar workflows pós-merge;
- atualizar este manual e os handoffs.

## 10. Formato obrigatório de atualização

Ao final de cada etapa, informar:

```text
Objetivo:
Estado inicial:
Alterações feitas:
Arquivos principais:
Branch e commit:
Validações executadas:
Resultado:
Limitações:
Próximo gate:
Confirmação necessária:
```

Exemplo:

```text
Objetivo: corrigir tela branca no Android.
Estado inicial: PR aberta, main intacta.
Alterações feitas: abertura Hive tipada e bootstrap resiliente.
Arquivos principais: lib/main.dart, secure_box_service.dart.
Branch e commit: fix/android-startup — abc1234.
Validações executadas: format, analyze, 92 testes, Web e APK debug.
Resultado: todos aprovados.
Limitações: não houve teste em aparelho físico.
Próximo gate: revisão humana em celular/tablet.
Confirmação necessária: merge na main e/ou publicação.
```

## 11. O que nunca afirmar sem prova

Não afirmar “está pronto para produção” apenas porque compilou. Separar sempre:

- build local;
- CI;
- instalação do APK;
- abertura em aparelho físico;
- teste offline;
- acessibilidade com usuário real;
- assinatura de release;
- publicação pública;
- validação clínica ou legal.

A frase correta quando algo não foi testado é: **“não executado neste ambiente”**.

## 12. Encerramento de cada sessão

Antes de parar:

1. verificar `git status`;
2. registrar branch e commit;
3. guardar logs ou links de CI;
4. atualizar `CONTINUAR_AQUI_PRIMEIRO.md`;
5. atualizar `PROJECT_HANDOFF.md` se o estado mudou;
6. atualizar `docs/CONTINUIDADE_ASSISTENTE_IA.md`;
7. informar claramente o próximo gate;
8. não deixar uma ação externa importante implícita.
