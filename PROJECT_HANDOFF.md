# Fala Comigo — Documento de transferência do projeto

## Como usar este arquivo

Este documento existe para permitir que outra pessoa, agente ou IA entenda o projeto sem depender do histórico desta conversa. Leia primeiro este arquivo, depois `AGENTS.md`, `README.md`, `docs/PLANO_SEQUENCIAL_ATE_BUILD.md` e `docs/CHECKLIST_PRE_LANCAMENTO.md`.

O código oficial está no GitHub:

- Repositório: https://github.com/falacomigocaa-app/fala-comigo
- Branch principal: `main`
- Estado atualizado em 04/10/2026: PRs #87–#90 integradas; `main` em `b08daa10d2314ea56fd079d07378fbcabe4e4335`. Após a auditoria inicial, seis PRs redundantes/superadas foram encerradas sem merge e permanecem nove abertas (#53, #64, #68, #77, #78, #79, #80, #81 e #83). Relatório: `docs/auditoria/2026-10-04/AUDITORIA_PR_ABERTAS.md`; confirme GitHub antes de agir.
- MobSF no APK de teste da main ([run 37142972414](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/37142972414)) reportou score 46/100, finding alto CBC/PKCS5/PKCS7 e finding alto `minSdk=24`. O relatório sanitizado está em `docs/auditoria/2026-10-03/MOBSF_MAIN_21A981F.md`. Há CBC em `flutter_secure_storage 9.2.4` no Android e em `HiveAesCipher` 2.2.3; a classe ofuscada do scan não foi mapeada exatamente. Nenhum dos dois caminhos está remediado.
- A PR documental #90 foi integrada em `b08daa1`; contém o relatório MobSF sanitizado e a correção do resumo do workflow MobSF. A migração Hive segue desativada.
- Situação e evidências pós-publicação: [`docs/STATUS_PROJETO_E_PENDENCIAS_2026-10-02.md`](docs/STATUS_PROJETO_E_PENDENCIAS_2026-10-02.md). O relatório de 01/10 e os handoffs datados de setembro são snapshots históricos.

Não existem segredos, tokens, senhas ou chaves privadas neste documento. Nunca coloque credenciais no Git.

## Identidade do produto

**Fala Comigo** é um aplicativo de Comunicação Aumentativa e Alternativa (CAA) para crianças e adolescentes autistas, suas famílias e redes de apoio. O produto deve apoiar comunicação, previsibilidade, autonomia e cuidado conectado sem transformar a criança em um conjunto de métricas.

A regra de produto mais importante é:

> A comunicação básica deve funcionar localmente, sem internet, sem conta e sem plano pago.

O aplicativo não diagnostica, não substitui terapia, não promete resultado clínico e não deve usar dados da criança para publicidade ou venda.

## Estado técnico conhecido

O projeto é Flutter multiplataforma, com diretórios para Android, iOS, Web, Windows, macOS e Linux. O núcleo atual está concentrado em `lib/`.

Já existem:

- grade de pictogramas e categorias;
- montagem de frases;
- síntese de voz;
- modos falar, adicionar e falar + adicionar;
- cartões padrão e cartões personalizados;
- área protegida do responsável;
- PIN parental com PBKDF2-HMAC-SHA256;
- sessão parental temporária;
- caixas Hive locais abertas com fail-closed/snapshot em plataformas nativas; a migração automática de dados antigos está desativada, e a criptografia/migração ainda não têm sign-off de release;
- armazenamento nativo de mídias com AES-GCM-256, sem que isso substitua a validação independente dos findings de segurança;
- exclusão local de dados, credenciais e chaves;
- registros ABC com exportação minimizada;
- diário de vídeo;
- alertas de transição com TTS ou áudio gravado;
- acessibilidade semântica para cartões e remoção de itens da frase;
- fallback para áudio ausente, corrompido ou incompatível;
- catálogo de planos e estados de licença;
- controle de recursos sem bloquear o modo offline;
- tela de status do plano na Área do Responsável;
- persistência local cifrada da licença;
- workflow do GitHub Actions com formatador, análise, testes, política de assinatura e build Web;
- política de privacidade e documentação de pré-lançamento.
- base local de continuidade do cuidado com perfil funcional, plano de comunicação e agenda;
- prévia web atualizada com os mesmos conceitos de perfil, plano, agenda, tarefas e aceite;
- estudo de preços e mapa de funcionalidades de SaaS clínico documentados separadamente.

A versão Web possui implementação condicional para mídia. O núcleo CAA pode ser compilado sem `dart:io`, mas mídia personalizada no navegador está deliberadamente limitada até existir armazenamento cifrado adequado para Web. Não remover essa proteção apenas para fazer uma demonstração compilar.

## Arquitetura relevante

A comunicação está em `lib/features/aac_grid/`. A Área do Responsável está em `lib/features/parental_area/`. Serviços transversais estão em `lib/core/services/`. O módulo de planos está em `lib/core/plans/`.

Arquivos importantes:

- `lib/main.dart`: inicialização do Hive, serviços e aplicação.
- `lib/features/aac_grid/presentation/screens/aac_grid_screen.dart`: tela principal da criança.
- `lib/features/aac_grid/data/providers/cards_provider.dart`: cartões, frase e comportamento de toque.
- `lib/features/aac_grid/presentation/widgets/grid_card.dart`: cartão acessível.
- `lib/features/aac_grid/presentation/widgets/sentence_bar_widget.dart`: barra de frase.
- `lib/features/parental_area/presentation/screens/settings_screen.dart`: painel parental.
- `lib/features/parental_area/presentation/screens/plan_status_screen.dart`: status e catálogo de planos.
- `lib/core/plans/plan_models.dart`: recursos, planos e licenças.
- `lib/core/plans/plan_catalog.dart`: catálogo inicial.
- `lib/core/plans/plan_access_controller.dart`: regras de acesso.
- `lib/core/plans/plan_access_provider.dart`: estado Riverpod.
- `lib/core/plans/plan_license_store.dart`: persistência cifrada da licença.
- `lib/core/services/data_wipe_service.dart`: exclusão completa local.
- `.github/workflows/flutter.yml`: validações automatizadas e build Web.

## Regras de planos

O catálogo atual contém:

- **Essencial:** gratuito, comunicação local e controles básicos.
- **Família:** recursos remotos opcionais; preço ainda não definido.
- **Cuidado Conectado:** vínculos autorizados com profissionais ou escolas; preço ainda não definido.
- **Patrocinado:** licença financiada por empresa ou instituição sem acesso ao conteúdo familiar; preço ainda não definido.
- **Organização:** plano administrativo não público para organizações.

Os estados de licença são `invited`, `active`, `grace`, `suspended`, `expired` e `revoked`. Os estados `active` e `grace` mantêm recursos remotos autorizados. Qualquer estado mantém a comunicação offline, acessibilidade, controle parental e dados locais.

Não existe cobrança real. Não conectar um provedor de pagamentos antes de comparar custos, taxas, portabilidade, cancelamento e impacto para famílias.

## Sequência de implementação

A sequência completa está em `docs/PLANO_SEQUENCIAL_ATE_BUILD.md`. A ordem resumida é:

```text
00 ambiente e linha de base
→ 01 navegação inicial
→ 02 grade CAA
→ 03 barra de frases
→ 04 cartões personalizados
→ 05 PIN e sessão
→ 06 Área do Responsável
→ 07 ABC e exportação
→ 08 mídia nativa
→ 09 alertas
→ 10 planos e licença
→ 11 build Web
→ 13 build Android de teste
→ 15 validação humana
→ 12 site institucional
→ 14 build Android de publicação
→ 16 portal conectado
→ 17 cobrança e domínio
```

O catálogo, a tela de planos e a persistência local já foram implementados. O ciclo atual iniciou a continuidade do cuidado local e especificou o contrato remoto; o próximo trabalho deve implementar a fundação server-side somente após escolher a infraestrutura, sem começar cobrança real prematuramente.

## Nova sequência full-stack até o piloto institucional

A condução full-cycle foi ampliada para incluir o site institucional, o console do proprietário, o portal multi-organização, autorizações, documentos, licenças, pagamentos em sandbox e o piloto controlado com uma clínica e um colégio. A sequência detalhada está em `docs/SEQUENCIA_FULL_STACK_ATE_PILOTO.md`.

A regra é separar aplicativo local, site público, portal conectado e console administrativo. Pagamento real, domínio, publicação ampla e sincronização de dados clínicos permanecem bloqueados até validação e confirmação explícita. O plano Essencial e a comunicação básica nunca dependem de assinatura.

## Próxima retomada recomendada

1. Confirmar a branch e o estado limpo do Git.
2. Ler `AGENTS.md` e este arquivo.
3. Instalar Flutter na versão usada pelo CI, atualmente `3.38.0`.
4. Executar `flutter pub get`.
5. Executar `dart format lib test`.
6. Executar `flutter analyze --no-fatal-infos --no-fatal-warnings`.
7. Executar `flutter test`.
8. Executar `flutter build web --release`.
9. Corrigir primeiro falhas do CI ou do núcleo CAA.
10. Trabalhar em branch própria, adicionar teste, revisar diff, comitar e enviar ao GitHub.
11. Tratar findings MobSF e desenhar migrações reversíveis para as duas camadas CBC, sem habilitar migração global nem usar dados reais.
12. Continuar a triagem seletiva das nove PRs abertas conforme `docs/auditoria/2026-10-04/AUDITORIA_PR_ABERTAS.md`; separar branches empilhadas e não mesclar #79–#81 em bloco.
13. Corrigir o ciclo de vida de mídia temporária antes de considerar a câmera; obter confirmação antes de mudanças de conteúdo público em #68/#83.
14. Preparar signing/AAB e coordenar teste físico somente após fechar gates técnicos, usando dados sintéticos.

Comandos básicos:

```bash
gh repo clone falacomigocaa-app/fala-comigo
cd fala-comigo
git checkout feat/affordable-plans-model
flutter pub get
dart format lib test
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build web --release
```

O ambiente usado para desenvolvimento pode não conter Flutter localmente. Nesse caso, usar o GitHub Actions como validação remota e declarar a limitação sem afirmar que os testes passaram localmente.

## Critérios do primeiro build funcional

O primeiro build está pronto para teste controlado quando:

- uma instalação limpa abre a grade CAA;
- cartões padrão funcionam sem internet;
- frases podem ser montadas, removidas e faladas;
- a Área do Responsável exige PIN;
- a sessão expira e bloqueia ao sair do segundo plano;
- cartões e configurações persistem;
- falhas de mídia não encerram o app;
- registros ABC e exportação respeitam minimização;
- alertas básicos funcionam sem conteúdo sensível nas notificações;
- plano Essencial aparece sem cobrança;
- exclusão completa remove dados locais, mídia, licença, credenciais e chaves;
- testes, análise e build Web passam no CI;
- Android é testado em celular e tablet antes de publicação.

## Limites do que ainda não está implementado

Ainda não estão prontos para produção:

- backend do portal conectado;
- contas e organizações remotas;
- autorização clínica no servidor;
- consentimento versionado remoto;
- auditoria de acesso remoto;
- sincronização clínica;
- cobrança real;
- painel corporativo em produção;
- site institucional público definitivo;
- domínio final;
- validação humana completa com famílias e profissionais;
- build Android de release validado em dispositivo real.

Não tratar documentação conceitual como implementação existente. O portal e o benefício corporativo exigem backend, isolamento e testes de negação antes de qualquer sincronização.

## Regras para a próxima IA

- Não pedir confirmação para decisões técnicas reversíveis.
- Priorizar falhas que interrompam a comunicação, depois segurança, acessibilidade, testes e produto.
- Não alterar a `main` diretamente quando uma branch de trabalho for suficiente.
- Não adicionar segredos ao repositório.
- Não usar dados reais de crianças em testes, logs, issues ou screenshots.
- Não bloquear comunicação, acessibilidade ou modo offline por plano.
- Não afirmar que um teste ou build passou sem evidência recente.
- Não comprar domínio, contratar serviço, ativar cobrança ou publicar amplamente sem confirmação explícita.
- Registrar decisões importantes em documentação versionada.

## Documentos de referência

- `AGENTS.md`: instruções persistentes de execução autônoma.
- `README.md`: setup e estrutura inicial.
- `docs/PLANO_SEQUENCIAL_ATE_BUILD.md`: sequência numerada até o build.
- `docs/ROADMAP_FULL_CYCLE.md`: roadmap de produto e engenharia.
- `docs/CHECKLIST_PRE_LANCAMENTO.md`: gates funcionais, acessibilidade, segurança e publicação.
- `docs/MODELO_AUTORIZACAO_CLINICAS_ESCOLAS.md`: modelo de autorização futura.
- `docs/MODELO_CUSTOS_E_PLANOS.md`: estratégia de baixo custo e planos.
- `docs/SEQUENCIA_FULL_STACK_ATE_PILOTO.md`: sequência de programação até o piloto com clínica e colégio.
- `docs/CONTRATO_PORTAL_CONECTADO.md`: entidades, estados, escopos e fila offline comuns ao app e web.
- `docs/CONTRATO_API_CONTINUIDADE_CUIDADO.md`: endpoints, payloads, consentimentos e testes de negação do portal.
- `docs/SUPABASE_STAGING_INICIANTE.md`: explicação simples do staging Supabase e dos próximos gates, sem expor segredos.
- `docs/HANDOFF_SUPABASE_STAGING.md`: identidade, estado verificado e limites do projeto Supabase de teste.
- `docs/PROPOSTA_CONSOLE_CRIADOR_PLANOS_LICENCAS.md`: proposta do painel de planos e licenças sem dados de clientes ou usuários.
- `docs/ESTUDO_PRECOS_PLANOS.md`: pesquisa de mercado e faixas de preço para validação.
- `docs/MAPA_FUNCIONALIDADES_SAAS_CLINICAS.md`: recursos de SaaS clínico priorizados para ajudar famílias.
- `privacy_policy.html`: política de privacidade alinhada ao armazenamento local.


## Atualização — 27/09/2026 — Supabase de staging

O responsável aprovou projeto novo Supabase na região de São Paulo depois de a conta exibir o valor estimado de **US$ 0/mês**. O projeto `Fala Comigo Staging` (`gojqeaontgshikdqlpfn`) está `ACTIVE_HEALTHY` na organização `falacomigocaa-app's Org`, região `sa-east-1`. O projeto existente em `us-east-1` não foi alterado. Após a criação, verificações somente de leitura confirmaram schema `public` vazio, sem migrations nem branches, e Security Advisor sem lints. Não foram consultados registros, criados usuários, configurado Auth, adicionadas tabelas/chaves ou enviados dados.

O Free está sendo usado para desenvolvimento com dados sintéticos. O preço e os limites podem mudar; o plano tem limites de uso e projetos inativos podem ser pausados. Não tratar como produção ou backup. Antes de mudança paga, de criar a conta do proprietário, alterar o banco ou usar dados reais, obter aprovação correspondente. Manter o CAA básico offline e sem login. A autenticação não concede por si só autorização clínica; revisar RLS, autorização server-side, consentimento, revogação, auditoria e testes negativos antes de qualquer piloto real. Ver `docs/SUPABASE_STAGING_INICIANTE.md` e `docs/HANDOFF_SUPABASE_STAGING.md`.


A documentação do staging foi enviada pela branch `docs/supabase-staging-created`, commit `0234cd90a7693c5c3c7c0a864e8119c5ab70058f`, na PR [#84](https://github.com/falacomigocaa-app/fala-comigo/pull/84). Ela não modifica o banco, o Auth ou o site público.


Atualização: a branch `docs/supabase-staging-created` avançou até `08e5b1fad32d823a1dd4f9a5e21d85fe6d96dfac`; a PR #84 permanece aberta e sem merge.


Estado Git: PR #84 foi integrada com CI verde por squash; `main` agora está em `49ee1a3`. Isso atualizou somente documentação do staging; não alterou o banco nem o site público.


## Atualização — prévia do Espaço do Criador

A proposta e protótipo estático para gestão de planos/licenças, sem exposição de dados clínicos, estão na PR #86. É prévia de dados fictícios: sem autenticação, Supabase, persistência, chamadas externas ou pagamentos. A PR permanece aberta e não deve ser mesclada/publicada sem revisão do responsável; o Pages publica apenas em push para `main`.


## Atualização — 28/09/2026 — validação local e estado de prontidão

O checkout atual de trabalho local está na branch `audit/creator-privacy-alignment`, HEAD `cc96eaf`, com alterações não commitadas. O site institucional tem endereço permanente no GitHub Pages; o workflow `site-pages.yml` publica apenas `site/`, não o Flutter Web. O app Web foi compilado como release e é servido apenas numa URL temporária do sandbox.

Após incluir `parent_reminders` no apagamento completo e adicionar uma regressão, `flutter test --no-pub` passou com **93 testes**, `node --test tests/creator-console.test.mjs` passou com **5 testes**, o formato dos dois arquivos Dart alterados está limpo, `flutter analyze --no-fatal-infos --no-fatal-warnings` retornou código 0 (37 diagnósticos não fatais), `flutter build web --release` passou e `flutter build apk --debug` passou. O APK debug foi verificado por `apksigner`; SHA-256 `e79271b5b6a8042d675be006c24e13b9b242e77c3e3b44ec35c1d81d00211f7f`. Nenhum teste em dispositivo foi feito.

As PRs #77–#81 e #83 permanecem fora do escopo de alterações remotas desta etapa; veja a fotografia e bloqueios no [resumo de status](docs/STATUS_PROJETO_E_PENDENCIAS_2026-09-28.md) e no relatório detalhado das PRs. O Supabase não foi acessado nem alterado. Não houve commit, push, merge nem publicação. A lista de pendências inclui corrigir `extensionHint` entre IO/Web, resolver conflitos/CI das PRs, decidir o destino permanente do Flutter Web, terminar backend/portal seguro e preparar o build de release antes dos testes reais planejados.

## Atualização — 29/09/2026 — validação, commits locais e rota Web

> **Snapshot histórico de 29/09:** os parágrafos desta seção descrevem o estado anterior à merge da PR #87 e ao deploy de 02/10. Para o estado atual, consulte [`docs/STATUS_PROJETO_E_PENDENCIAS_2026-10-02.md`](docs/STATUS_PROJETO_E_PENDENCIAS_2026-10-02.md).

Branch `audit/creator-privacy-alignment` enviada ao GitHub e PR [#87](https://github.com/falacomigocaa-app/fala-comigo/pull/87) aberta contra `main`. A PR contém correções de app/privacidade, testes, a rota Pages `/app/`, manual e handoffs. No último snapshot, os dois checks ainda estavam pendentes; não houve merge nem deploy.

Validação: formatação passou, `flutter analyze --no-pub` reportou **No issues found**, **98 testes Flutter** e **10 testes Node** passaram; build Web release, build APK debug e smoke visual da prévia `/fala-comigo/app/` passaram. A seleção local do cartão “Comer” adicionou o cartão à barra de frase na prévia. O APK tem assinatura de debug, SHA-256 `a94050ff151c65ecb21fb61982aafa8403bf45c81762121be48597f3c187dad7`; não foi instalado em telefone/tablet. O Web build alerta incompatibilidades apenas no dry-run Wasm; o alvo JavaScript release concluiu.

O workflow local prepara `site/` mais o Flutter Web em `/fala-comigo/app/`, e o site oferece uma entrada “Abrir prévia Web”. A prévia combinada temporária é `https://4176-ijwj8rsnu6oknbsn37ldj-36a4ebfd.us4.manus.computer/fala-comigo/`; o endereço oficial atual do GitHub Pages continua HTTP 200, mas a alteração da nova rota **não foi publicada** (a rota `/app/` ainda retorna 404). Houve push apenas da branch de trabalho e criação da PR #87; não houve merge nem acesso/alteração do Supabase. A publicação da rota pública exige revisão do payload final e confirmação explícita.

O manual de usuário foi criado em Markdown e PDF. A auditoria integral do repositório e a revisão atualizada das PRs devem ser consultadas antes de integrar. Permanecem pendentes AAB/release com chave de produção, revisão/decisão dos bloqueios de PR, backend seguro do portal e testes reais em aparelhos, conforme o plano do proprietário.
