# LEIA PRIMEIRO — Continuidade obrigatória do Fala Comigo

O prompt completo para iniciar outro agente está em [`PROMPT_RETORNO_NOVO_AGENTE.md`](PROMPT_RETORNO_NOVO_AGENTE.md). Ele pode ser copiado integralmente para uma nova conversa.

> **Não alterar a `main` diretamente.** Antes de executar qualquer correção, leia este arquivo, `AGENTS.md`, `PROJECT_HANDOFF.md` e `docs/HANDOFF_TELA_BRANCA_APK.md`.

## Estado atual verificado — 29/09/2026

- Checkout local em `/home/ubuntu/fala-comigo`, branch `audit/creator-privacy-alignment`, HEAD local `fa3dc9c`; há dois commits locais organizados (`9224c4c` para app/privacidade/testes e `fa3dc9c` para site/rota Web). Ainda não foram enviados ao GitHub.
- Validação local final: `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze --no-pub` (**sem problemas**), `flutter test --no-pub` (**98/98**) e `node --test tests/*.test.mjs` (**10/10**) passaram; builds Flutter Web release e Android debug concluíram.
- APK debug: `build/app/outputs/flutter-apk/app-debug.apk`, pacote `com.falacomigo.fala_comigo`, versão `1.0.0+1`, minSdk 24/targetSdk 36, assinatura de debug verificada; SHA-256 `a94050ff151c65ecb21fb61982aafa8403bf45c81762121be48597f3c187dad7`. Não instalaram em aparelho.
- A rota planejada do app é `/fala-comigo/app/`. O workflow local combina `site/` e o build Flutter com base-href `/fala-comigo/app/`. A prévia combinada temporária é `https://4176-ijwj8rsnu6oknbsn37ldj-36a4ebfd.us4.manus.computer/fala-comigo/`; app em `/app/`. O GitHub Pages oficial continua ativo, mas ainda não recebeu esta mudança.
- Nenhum push, merge ou deploy foi feito. Antes de tornar pública a nova rota, mostrar a URL/payload final e obter confirmação explícita; revisar primeiro o relatório atualizado das PRs e da auditoria integral.
- AAB/release assinado com chave de produção e testes em dispositivos físicos continuam pendentes.

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

Aguardar o proprietário escolher A, B ou C. Se escolher A ou C, confirmar também onde o backend será hospedado e como o banco será provido. Não construir uma falsa autenticação no JavaScript do site. Não apagar o portal atual antes de existir migração funcional e validação.

O link público atual ainda aponta para `https://falacomigo-kyrh225w.manus.space/creator` e isso é conhecido como estado provisório. Só trocar o link depois que o novo destino real estiver funcionando e publicado no GitHub Pages.


## Atualização — 27/09/2026 — compatibilidade Web da correção de câmera

- Repositório conferido em `/home/ubuntu/fala-comigo`; `origin/main` está em `b43e18b` e estava limpa antes da alteração.
- PRs abertas verificadas: #79 (câmera/overflow), #80 (despertador) e #81 (permissões sintéticas). Seus checks mais recentes falharam na compilação Web com `No named parameter with the name 'extensionHint'` em `add_card_screen.dart`.
- Alteração isolada em `fix/web-media-api-parity`: a assinatura do stub `media_storage_service_web.dart` passou a aceitar o mesmo parâmetro nomeado opcional da implementação nativa. O stub continua lançando `UnsupportedError`; armazenamento de mídia na Web não foi habilitado.
- **Estado:** pendente de CI; Flutter e adb não estão instalados nesta sessão. Nenhuma validação em aparelho foi feita. Nenhuma alteração na `main`.
- **Commit/PR:** commit `0aae627` publicado; PR [#82](https://github.com/falacomigocaa-app/fala-comigo/pull/82) aberta contra `main`.
- **Validação local:** revisão do diff e `git diff --check` passaram. Flutter/adb ausentes, portanto testes Flutter, build APK e aparelho não executados.
- **Próximo gate:** verificar CI da PR #82; se os checks passarem, gerar APK de teste e solicitar validação no Realme C71. Não classificar como validado-em-aparelho sem evidência do proprietário.


## Atualização — 27/09/2026 — staging Supabase de São Paulo criado

- O proprietário escolheu criar um projeto novo em São Paulo e confirmou custo antes da criação. O `get_cost` retornou US$ 0/mês na organização disponível; o projeto foi criado após confirmação explícita e está `ACTIVE_HEALTHY`.
- Projeto `Fala Comigo Staging`; ref `gojqeaontgshikdqlpfn`; organização `falacomigocaa-app's Org`; região `sa-east-1` (São Paulo). O projeto antigo `Fala comigo CAA` (`nwtrszfhtrtucdoifukg`, `us-east-1`) ficou intocado.
- Verificações somente de leitura após criação: schema `public` sem tabelas; migrations e branches vazias; Security Advisor sem lints reportados. Nenhuma linha de dado foi consultada; nenhuma conta de Auth, login, tabela, chave ou segredo foi criado/configurado.
- Repositório: branch `docs/supabase-staging-created`, baseada na `main` `1281c39`, para registrar esta etapa. Novo guia simples em `docs/SUPABASE_STAGING_INICIANTE.md` e handoff técnico em `docs/HANDOFF_SUPABASE_STAGING.md`.
- Limites oficiais Free consultados: até 2 projetos ativos, 500 MB DB por projeto, 50.000 MAU, 1 GB storage, 5 GB egress; cota pode depender de agregação. Projetos com baixa atividade por 7 dias podem pausar. Free não deve ser tratado como produção, backup nem disponibilidade garantida; rever limites oficiais antes de crescer.
- **Produto:** app CAA básico permanece offline/local e sem conta; login inicial pretendido é apenas do proprietário no Espaço do Criador. Auth não é autorização clínica; backend real requer RLS e testes de negação. Nunca expor `service_role` ou senha no app/site/Git/chat.
- **Próximo gate:** definir em linguagem simples as funções mínimas do Espaço do Criador; mostrar desenho e regras de segurança antes de criar conta, tabelas ou migrations. Usar somente dados sintéticos. Qualquer plano/add-on com custo, conta de proprietário, publicação ou uso real exige gate próprio.
- PR #83 está com ambos os checks verdes, mas segue aberta e não publicada; merge do site requer autorização explícita porque altera o GitHub Pages público.


### Registro de entrega documental — PR #84

A documentação do staging foi commitada como `0234cd90a7693c5c3c7c0a864e8119c5ab70058f` na branch `docs/supabase-staging-created`; PR [#84](https://github.com/falacomigocaa-app/fala-comigo/pull/84) aberta contra `main`, ainda sem merge. O diff da documentação passou `git diff --check` antes do commit. O banco permanece vazio e não conectado ao código.


### Cabeça atual da PR #84

O commit final da branch de documentação é `08e5b1fad32d823a1dd4f9a5e21d85fe6d96dfac` (inclui ajuste da redação de backups do Free); PR [#84](https://github.com/falacomigocaa-app/fala-comigo/pull/84) continua aberta e sem merge. Worktree local deve permanecer limpa após este registro.


### Atualização — PR #84 mesclada

A PR documental #84 foi squash-merged com CI verde; `origin/main` está em `49ee1a3` (`docs(supabase): document free São Paulo staging (#84)`). Isso integrou somente os handoffs; não executou migrations, não configurou Auth e não publicou o site. Staging segue vazio. A PR pública #83 permanece aberta e não publicada, pendente de autorização do responsável para o merge.


## Atualização — Espaço do Criador: gestão de planos/licenças, sem dados de usuários

Em 27/09/2026, o responsável definiu que ao entrar no Espaço do Criador deseja gerir valores dos planos e gerar licenças para modalidades particular, clínicas/escolas e vendas corporativas/patrocínio. Explicitou que **não quer saber nem ver dados sensíveis, dados de clientes ou mesmo dados/contas de usuários**. Tratar isso como limite do produto, não apenas como preferência visual: sem CRM, diretório de contas, busca individual, perfis, histórico individual de resgate ou métricas individualizadas no console. Sem pagamentos no MVP.

Parecer independente de produto, privacidade e UX recomendou catálogo com versões, licenças opacas em lote, validade/revogação de lote e contagens agregadas. Há uma escolha ainda pendente: aceitar que o servidor guarde hash/estado técnico por código (sem identidade) para impedir uso repetido, enquanto o console vê somente agregados, ou proibir até esse estado individual e aceitar menos funcionalidades. A proposta completa está em `docs/PROPOSTA_CONSOLE_CRIADOR_PLANOS_LICENCAS.md`.

**Nenhuma tabela, migration, Auth, chave ou integração foi criada para esse painel.** Próximo passo: confirmar as decisões comerciais e esse limite técnico; então fazer um protótipo estático com dados inventados e mostrar prévia temporária antes de qualquer persistência. Não publicar automaticamente.


### Clarificação posterior do limite de dados — 27/09/2026

O responsável esclareceu que o que não quer ver são **dados clínicos e informações sensíveis desse tipo**. Corrigir a interpretação anterior: isso não significa automaticamente que nomes comerciais de clínicas/empresas ou metadados de licença estejam proibidos. Esses itens continuam a ser decisões de produto; não inventar cadastro/diretório de usuários. O princípio absoluto é não expor conteúdo clínico, diagnósticos, prontuários, comunicação, imagens/documentos ou indicadores clínicos. A proposta foi corrigida para refletir essa distinção. Existe agora uma prévia estática do console em `site/console-preview.html`; contém apenas dados fictícios, não chama serviços externos e não tem login ou persistência. Verifique-a na URL temporária compartilhada na conversa; não é publicação oficial.


### Entrega da prévia — PR #86

A proposta e o arquivo estático `site/console-preview.html` foram enviados na PR [#86](https://github.com/falacomigocaa-app/fala-comigo/pull/86), branch `docs/creator-console-license-scope`, commit inicial `06f77db87473426b12a06f2a1651ce663caf5db9`. Estado no momento do registro: PR aberta, check Flutter pendente. Não mesclar nem publicar no Pages sem aprovação do responsável. A prévia temporária é `https://4174-iqpj1o8qmwmk8nx17twm5-3af4165c.us1.manus.computer/console-preview.html`.


## Atualização — 28/09/2026 — prontidão local, APK e pendências

- Estado local: sandbox `/home/ubuntu/fala-comigo`, branch `audit/creator-privacy-alignment`, HEAD `cc96eaf`; há mudanças locais ainda não commitadas. Nesta etapa não houve commit, push, PR, merge, publicação ou acesso ao Supabase.
- O site institucional permanente continua no GitHub Pages: `https://falacomigocaa-app.github.io/fala-comigo/`. Ajustes locais em `site/` ainda não foram publicados.
- Flutter Web release e Android debug foram compilados localmente. O APK debug tem SHA-256 `e79271b5b6a8042d675be006c24e13b9b242e77c3e3b44ec35c1d81d00211f7f` e assinatura v2 verificada; não foi instalado em aparelho.
- Flutter: 93 testes passaram; análise não fatal retornou código 0 com 37 diagnósticos (34 info, 3 warnings). Node: 5/5 testes passaram. Build Web e build APK debug passaram.
- `DataWipeService` foi corrigido localmente para também excluir `parent_reminders`; a regressão correspondente passou.
- Prévias temporárias agora respondem HTTP 200: site/console na porta 4174 e Flutter Web release na 4175. Elas não são publicação permanente e dependem do sandbox.
- Próximos gates: resolver `extensionHint`/CI das PRs #79–#81, atualizar e revisar conflitos das PRs #77–#83, decidir se o Flutter Web terá rota pública permanente, implementar backend conectado seguro, preparar build release e deixar os testes reais em dispositivos para a etapa posterior definida pelo proprietário.
- Resumo completo: [`docs/STATUS_PROJETO_E_PENDENCIAS_2026-09-28.md`](docs/STATUS_PROJETO_E_PENDENCIAS_2026-09-28.md).
