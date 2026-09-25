# LEIA PRIMEIRO — Continuidade obrigatória do Fala Comigo

O prompt completo para iniciar outro agente está em [`PROMPT_RETORNO_NOVO_AGENTE.md`](PROMPT_RETORNO_NOVO_AGENTE.md). Ele pode ser copiado integralmente para uma nova conversa.

> **Não alterar a `main` diretamente.** Antes de executar qualquer correção, leia este arquivo, `AGENTS.md`, `PROJECT_HANDOFF.md` e `docs/HANDOFF_TELA_BRANCA_APK.md`.

## Estado imediato em 25/09/2026

O projeto está em uma branch de correção chamada `fix/main-startup-and-android-build`, baseada na `origin/main` no commit `0d0b685`. A `main` remota não foi alterada nesta retomada.

O problema relatado é: **o APK instala e abre, mas mostra uma tela totalmente branca**. A causa mais provável foi localizada e não é uma mudança de produto: `pictogram_cards` era aberta no bootstrap como `Box<dynamic>`, enquanto a grade exige `Box<PictogramCard>`. O erro Android já observado foi:

```text
HiveError: The box "pictogram_cards" is already open and of type Box<dynamic>
```

A PR 29 contém a correção, mas está `OPEN` e `DIRTY` porque foi criada sobre uma `main` antiga. **Não mesclar a PR 29 inteira.** A correção foi reaplicada seletivamente na branch atual.

A PR 60 adiciona uma tela que mostra a exceção de inicialização em vez de deixar branco, mas está `OPEN` e `DRAFT`. Não foi mesclada. A tentativa de merge foi recusada pelo GitHub por ela ser draft. **Não apagar nem fechar a PR 60 antes de obter o erro real, se a correção Hive não resolver.**

## Correções já preparadas nesta branch

- `lib/main.dart`: `pictogram_cards` abre como `Box<PictogramCard>`.
- `lib/core/services/secure_box_service.dart`: as funções de abertura e migração são genéricas e usam `Hive.openBox<T>`.
- `android/app/build.gradle.kts`: plugin `org.jetbrains.kotlin.android` aplicado.
- Build release continua exigindo `android/key.properties`; não adicionar keystore ou segredo ao Git.
- `docs/HANDOFF_TELA_BRANCA_APK.md`: explicação completa, comandos, evidências e limites.
- `docs/CONTINUIDADE_ASSISTENTE_IA.md`: registro histórico atualizado.

## Próxima ordem obrigatória

1. Não fazer reset, rebase destrutivo, force-push ou exclusão de branch.
2. Executar `git diff --check` e revisar o diff.
3. Confirmar que a branch contém somente a correção seletiva e a documentação.
4. Fazer commit e push da branch.
5. Abrir ou atualizar uma PR contra `main`.
6. Aguardar e revisar CI: formatação, análise, testes e build Web.
7. Executar o workflow `Android test APK artifact` no commit da branch/PR.
8. Baixar o APK, registrar SHA-256 e instalar em aparelho Android real.
9. Classificar o resultado como `abriu`, `falhou com erro visível` ou `não executado`.
10. Só depois decidir se a correção deve entrar na `main`.

Se o ambiente não tiver Flutter/Android SDK, não declarar build local aprovado. Usar CI e informar a limitação. O Codemagic ainda não foi executado nesta retomada; um APK do GitHub Actions não prova que o Codemagic ou a `main` via Codemagic passaram.

## Regra de atualização obrigatória

Ao concluir **cada etapa**, o agente deve atualizar:

1. este arquivo, na seção “Histórico curto”;
2. `docs/HANDOFF_TELA_BRANCA_APK.md`, quando a etapa tratar de APK, Android ou tela branca;
3. `docs/CONTINUIDADE_ASSISTENTE_IA.md`, para manter a sequência histórica;
4. o corpo da PR com comandos, resultados, commit, branch e próximo gate.

### Destino oficial das atualizações Web

O endereço público oficial do projeto é:

`https://falacomigocaa-app.github.io/fala-comigo/`

Toda alteração de conteúdo, layout, contato, navegação ou função pública que possa rodar no site estático deve ser feita no diretório `site/`, enviada para uma PR contra `main` e publicada pelo workflow `site-pages.yml`. Não considerar uma mudança concluída enquanto ela não estiver na `main` e confirmada no endereço oficial.

O Manus Space não substitui o GitHub Pages. Ele pode ser usado somente como ambiente técnico separado para backend autenticado, banco, testes ou preview do portal. Nunca apresentar o Manus Space como a página pública oficial nem deixar uma atualização pública somente nele.

Limite técnico obrigatório: autenticação, banco, permissões server-side e assinaturas reais não podem ser protegidos apenas no GitHub Pages. Nesses casos, a interface pública continua no GitHub Pages e deve encaminhar para o backend/portal seguro, com essa separação documentada.

Não registrar neste repositório credenciais, tokens, chaves privadas, PINs, fotos, vídeos, nomes completos ou dados clínicos reais.

## Histórico curto

- **25/09/2026:** `origin/main` confirmado em `0d0b685`; PR 29 continua aberta e `DIRTY`; PR 60 continua draft e verde; nenhuma alteração foi perdida.
- **25/09/2026:** causa provável da tela branca identificada na tipagem da caixa Hive; correção seletiva preparada em `fix/main-startup-and-android-build`.
- **25/09/2026:** APK diagnóstico anterior preservado fora do Git; ele foi gerado pelo GitHub Actions na branch de diagnóstico, não pelo Codemagic e não pela `main` atual.
- **25/09/2026:** prompt mestre criado em `PROMPT_RETORNO_NOVO_AGENTE.md`, com leitura obrigatória, regras de preservação, comandos de diagnóstico, validação do APK e formato de atualização passo a passo.
- **25/09/2026:** regra oficial reforçada: atualizações públicas devem terminar no GitHub Pages oficial; Manus Space não pode ser tratado como substituto do site público. Backend seguro permanece separado quando tecnicamente necessário.

## Comandos de retomada

```bash
git fetch origin --prune
git status --short --branch
git log origin/main -12 --oneline --decorate
git diff --check
gh pr list --repo falacomigocaa-app/fala-comigo --state open
```

## Resultado que ainda não pode ser afirmado

Ainda não se pode afirmar que o APK corrigido abre em aparelho real, que o Codemagic passou, que a `main` foi corrigida ou que o aplicativo está pronto para publicação. Essas afirmações exigem evidência posterior e devem ser registradas neste arquivo.


## Evidência mais recente do build

O workflow `Android test APK artifact` da PR 66 terminou com sucesso no run [36109508895](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36109508895), usando o commit `abe8633` da branch de correção. O APK foi gerado, verificado pelo `apksigner` e publicado como artefato de teste. SHA-256: `63f3d897f07995baff7262b4f43d691733f0e7c80e25f97988a9bc818b373646`.

Esse resultado confirma somente o build e a integridade estrutural do APK. Ainda falta instalar e abrir o aplicativo em aparelho Android real para confirmar que a grade CAA não permanece branca.


## Ponto de parada — Espaço do Criador sem Manus Space — 25/09/2026

O proprietário decidiu que não quer vincular o Espaço do Criador ao Manus nem usar o Manus Space. O e-mail desejado para o acesso próprio é `falacomigocaa@gmail.com`. Nenhuma senha deve ser registrada neste repositório ou enviada em texto no chat.

A implementação de login próprio foi apenas iniciada durante a análise e foi totalmente desfeita antes de qualquer commit/checkpoint, para não deixar o portal inconsistente. Não afirmar que o login próprio já existe.

### Limitação técnica que o próximo agente deve explicar

GitHub Pages hospeda somente arquivos estáticos. Ele não executa backend contínuo, banco de dados, sessões seguras, convites, permissões server-side ou assinaturas reais. Portanto, não é tecnicamente possível manter um portal real inteiro somente no GitHub Pages.

### Opções apresentadas ao proprietário

1. **Opção A — recomendada:** site público e interface do Criador no GitHub Pages, com backend e banco em infraestrutura independente do Manus (por exemplo Render, Railway, Fly.io, Cloudflare Workers/D1 ou VPS). O login será próprio com `falacomigocaa@gmail.com` + senha. Nenhum link ou dependência do Manus Space.
2. **Opção B:** somente GitHub Pages, com uma tela estática. Não haverá autenticação ou banco reais; não serve para administrar organizações, planos e convites.
3. **Opção C:** avaliar outra infraestrutura independente escolhida pelo proprietário antes de implementar.

### Gate obrigatório antes de programar

A escolha macro A/B/C foi concluída: o proprietário escolheu a **Opção A**. Permanecem como gates separados a especificação, a escolha do provedor, a criação de contas, as credenciais, os custos, a privacidade, a validação e a migração. Não construir uma falsa autenticação no JavaScript do site. Não apagar o portal atual antes de existir migração funcional e validação.

O link público atual ainda aponta para `https://falacomigo-kyrh225w.manus.space/creator` e isso é conhecido como estado provisório. Só trocar o link depois que o novo destino real estiver funcionando e publicado no GitHub Pages.

## Decisão confirmada — Opção A e endereço oficial — 25/09/2026

O proprietário confirmou a **Opção A**: manter o site e a interface pública no GitHub Pages, iniciar o backend e o banco em infraestrutura independente com camadas gratuitas quando possível e evoluir para planos pagos somente quando o crescimento justificar. A arquitetura deve permitir migração e expansão sem dependência obrigatória de um único provedor.

O endereço público oficial confirmado é exatamente:

`https://falacomigocaa-app.github.io/fala-comigo/`

Toda alteração pública deve continuar sendo feita em `site/`, passar por branch e Pull Request contra `main`, ser publicada pelo workflow `site-pages.yml` e ser conferida nesse endereço. A lista de continuidade deve ser atualizada ao final de cada etapa para os próximos agentes de IA. O link do Manus Space permanece provisório até a nova solução estar funcional, validada e publicada.

### Etapa 1 e 2 concluídas — handoff e ADR

Em 25/09/2026, o `PROJECT_HANDOFF.md` foi atualizado para refletir o estado atual da `main`, a Opção A e a separação entre site institucional e portal autenticado. Foi criado o ADR [`docs/ADR-001-opcao-a-portal-independente.md`](docs/ADR-001-opcao-a-portal-independente.md), que formaliza a arquitetura, os limites do GitHub Pages, o MVP sintético e os gates antes de login, provedor, cobrança ou dados reais.

Esta etapa foi somente documental. Não houve implementação de backend, criação de conta externa, contratação, cobrança, coleta de dados, troca do link do Criador ou alteração da `main`.

### Gate 1A concluído — especificação do MVP sintético

Foi criada a especificação [`docs/ESPECIFICACAO_MVP_PORTAL_SINTETICO.md`](docs/ESPECIFICACAO_MVP_PORTAL_SINTETICO.md). Ela delimita o MVP sem dados reais, define fixtures determinísticas, entidades mínimas, papéis, escopos, endpoints, auditoria, matriz de autorização e testes de negação.

O Gate 1A não implementa login, API, banco remoto, provedor, cobrança ou interface autenticada. O próximo passo é o **Gate 2 — implementação local**, em branch separada, com PostgreSQL descartável, migrations, fixtures e testes automatizados. Não iniciar o Gate 2 antes de revisar esta especificação e manter a `main` protegida.

### Gate 2A em andamento — API local sintética

Foi criada a pasta `portal-api/` com uma API Node.js local, identidade sintética, fixtures determinísticas, autorização server-side, rotas `/v1`, idempotência, auditoria e 12 testes automatizados. Também foi criada a migration SQL PostgreSQL `portal-api/migrations/001_initial.sql`.

Os testes locais passaram, mas PostgreSQL e Docker não estão disponíveis neste ambiente; portanto, a migration ainda não foi executada contra um banco real. O próximo passo é o **Gate 2B — validar migrations e testes contra PostgreSQL descartável**, sem provedor externo. O servidor sintético não pode ser publicado nem executado com `NODE_ENV=production`.
