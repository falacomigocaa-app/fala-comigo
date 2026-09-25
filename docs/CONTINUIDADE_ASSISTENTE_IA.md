# Fala Comigo — Continuidade para assistência por IA

**Última atualização:** 24 de setembro de 2026
**Estado:** `main` integrada e limpa; linha de base MobSF registrada; próxima continuidade deve monitorar segurança sem limitar as funções do produto.

## 1. Objetivo deste documento

Este arquivo permite que outra pessoa ou assistência por IA retome o projeto rapidamente, entendendo o que foi analisado, quais decisões foram tomadas, quais comandos foram executados, o que já está pronto e o que ainda falta realizar.

Cada etapa relevante deve registrar:

- data e objetivo;
- comando executado;
- resultado resumido;
- arquivos ou branches afetados;
- riscos ou conflitos encontrados;
- próximo passo recomendado.

Nenhuma credencial, token, senha, chave privada ou dado real de criança deve ser registrado neste documento.

## 2. Identificação do projeto

- **Produto:** Fala Comigo — Comunicação Aumentativa e Alternativa (CAA/PECS).
- **Repositório:** `falacomigocaa-app/fala-comigo`.
- **Branch principal:** `main`.
- **Branch de trabalho avaliada:** `feat/affordable-plans-model`.
- **Conta GitHub conectada:** `falacomigocaa-app`.
- **Permissões confirmadas:** leitura, push, maintain e admin.
- **Regra central do produto:** a comunicação básica deve funcionar localmente, sem internet, sem conta e sem plano pago.

## 3. Documentos lidos

Foram lidos ou avaliados os documentos centrais e de continuidade da branch de trabalho:

- `README.md`;
- `PROJECT_HANDOFF.md`;
- `docs/PLANO_SEQUENCIAL_ATE_BUILD.md`;
- `docs/CHECKLIST_PRE_LANCAMENTO.md`;
- `docs/ROADMAP_FULL_CYCLE.md`;
- `docs/SEQUENCIA_FULL_STACK_ATE_PILOTO.md`;
- `docs/MODELO_CUSTOS_E_PLANOS.md`;
- `docs/MODELO_AUTORIZACAO_CLINICAS_ESCOLAS.md`;
- `docs/MODELO_BENEFICIO_CORPORATIVO_PCD.md`;
- `docs/RELATORIO_FUNCOES_INSTITUCIONAIS.md`;
- `privacy_policy.html`;
- `store_listing.md`.

## 4. Estado atual conhecido

### Já implementado ou documentado

- grade de pictogramas e categorias;
- montagem e reprodução de frases;
- modos de toque falar, adicionar e falar + adicionar;
- cartões padrão e personalizados;
- área protegida do responsável;
- PIN parental com PBKDF2-HMAC-SHA256;
- sessão parental temporária;
- caixas Hive protegidas;
- mídia nativa cifrada;
- exclusão local de dados, credenciais e chaves;
- registros ABC e exportação minimizada;
- diário de vídeo;
- alertas de transição;
- acessibilidade semântica;
- tratamento de mídia ausente ou corrompida;
- catálogo de planos e estados de licença;
- controle local de recursos sem bloquear o modo offline;
- tela de status de planos;
- rotinas, lembretes, relatórios e tendências na branch affordable;
- site institucional em desenvolvimento;
- workflows de CI e validações de qualidade;
- documentação de pré-lançamento e privacidade.

### Ainda não pronto para produção

- Flutter/Dart instalado neste ambiente local;
- validação local completa com `flutter analyze` e `flutter test`;
- build Web local validado;
- build Android validado em celular e tablet reais;
- validação humana com famílias e profissionais;
- backend do portal conectado;
- contas e organizações remotas;
- autorização clínica no servidor;
- consentimento versionado remoto;
- auditoria de acesso remoto;
- sincronização clínica;
- cobrança real;
- painel corporativo em produção;
- domínio final;
- publicação ampla.

## 5. Situação das branches

### `main`

- Branch principal atual.
- Commit observado: `299cb9e` — `Add corporate PCD benefit model`.
- Working tree local da `main` está limpa após o clone.

### `feat/affordable-plans-model`

- Commit observado: `d0af6e2` — `feat: add local parent routine reminders`.
- Está significativamente à frente da `main`.
- Possui aproximadamente 78 arquivos alterados em relação à `main`, com cerca de 7.533 adições e 851 remoções.
- Workflows recentes do GitHub Actions foram concluídos com sucesso.
- O trabalho inclui planos locais, área parental, rotinas, relatórios, tendências, site institucional, testes e documentação.

### Observação sobre a documentação

`PROJECT_HANDOFF.md` registra um commit mais antigo (`8b0d7d7`) como último commit do handoff. Esse registro precisa ser atualizado quando a branch e o estado do projeto forem consolidados.

## 6. Validações já realizadas

- GitHub conectado e autenticado.
- Repositório localizado e clonado.
- Permissão de `push` confirmada pela API do GitHub.
- Branches e histórico recente avaliados.
- CI da `feat/affordable-plans-model` consultado: resultados recentes com sucesso.
- Tentativa de testes locais registrada: não executada porque `flutter` não está instalado nesta sessão.
- Nenhuma alteração, commit, push ou merge foi feito no GitHub durante a avaliação.

## 7. Ordem planejada para a integração com `main`

A integração deve ser feita sem alterar a `main` remota inicialmente:

1. confirmar estado limpo e referências atualizadas;
2. registrar o ponto de partida;
3. comparar `main` e `feat/affordable-plans-model`;
4. simular o merge em worktree ou branch temporária;
5. listar conflitos automáticos;
6. classificar conflitos de código, documentação, produto e cronograma;
7. revisar alterações sensíveis de CAA, privacidade, planos e acessibilidade;
8. instalar ou disponibilizar Flutter para validação local, se possível;
9. executar formatação, análise, testes e build Web;
10. revisar o diff final;
11. somente após decisão explícita, criar commit, push ou Pull Request.

## 8. Regras de segurança da integração

- Não fazer merge direto na `main` sem revisar o diff.
- Não fazer push ou publicar alterações sem registrar o resultado nesta documentação.
- Não apagar branches ou commits.
- Não registrar segredos no Git.
- Não usar dados reais de crianças em testes, logs, issues ou screenshots.
- Não bloquear comunicação, acessibilidade ou modo offline por plano.
- Não afirmar que um teste passou sem evidência recente.
- Não ativar cobrança real, domínio, portal clínico ou sincronização sem as validações e confirmações previstas.
- Documentação conceitual não deve ser tratada como implementação pronta.

## 9. Checklist rápido de retomada

- [x] GitHub conectado.
- [x] Repositório identificado.
- [x] Permissões de escrita confirmadas.
- [x] `main` identificada.
- [x] `feat/affordable-plans-model` identificada.
- [x] Documentos centrais lidos.
- [x] CI remoto consultado.
- [ ] Flutter instalado localmente.
- [ ] Testes locais executados.
- [ ] Build Web local executado.
- [ ] Simulação de integração realizada.
- [ ] Conflitos classificados.
- [ ] Diff de integração revisado.
- [ ] Decisão sobre merge tomada.
- [ ] Commit de integração criado.
- [ ] Push ou Pull Request realizado.

## 10. Registro de comandos e etapas

### 23/09/2026 — Avaliação inicial

**Objetivo:** confirmar conexão, localizar o repositório e entender o estado do projeto.

**Ações realizadas:**

- verificação da conexão GitHub;
- verificação da autenticação da conta `falacomigocaa-app`;
- listagem de repositórios acessíveis;
- clone local do repositório;
- inspeção de branches, histórico e documentação;
- consulta das permissões do repositório;
- consulta dos resultados recentes do GitHub Actions;
- criação de worktree isolado da `feat/affordable-plans-model`.

**Resultado:** acesso confirmado; nenhum commit, push ou merge realizado.

**Limitação:** Flutter não está instalado no ambiente local.

## 11. Próximo passo

Aguardar os comandos ou a autorização operacional para iniciar a simulação de transferência da `feat/affordable-plans-model` para a `main`. A primeira ação deve ser somente de comparação/simulação, sem alteração na `main` remota.

## 13. Primeira etapa de integração — linha de base e simulação

**Data:** 23 de setembro de 2026.

Foi feita uma atualização das referências remotas com `git fetch origin --prune`, sem alteração no GitHub. A linha de base registrada foi:

| Referência | Commit | Situação |
| --- | --- | --- |
| `origin/main` | `299cb9e` | branch principal |
| `origin/feat/affordable-plans-model` | `d0af6e2` | branch de trabalho |
| ancestral comum | `299cb9e` | a affordable parte exatamente da main |

Foi executada uma simulação de merge usando `git merge-tree`. O resultado não apresentou conflitos textuais, marcadores de conflito, arquivos deletados ou necessidade de resolução manual. Como a ancestral comum é exatamente o commit atual da `main`, a integração é tecnicamente um avanço linear/fast-forward, desde que a decisão de publicação seja tomada depois da revisão.

A diferença contém 78 arquivos: 42 de aplicação em `lib/`, 8 de documentação, 18 testes, 2 arquivos de CI, 3 itens de site/assets e 5 arquivos de outras categorias. A checagem de diff não apresentou erro estrutural, mas apontou espaços à direita em três linhas de documentação de `RELATORIO_FUNCOES_INSTITUCIONAIS.md` e `SEQUENCIA_FULL_STACK_ATE_PILOTO.md`. Isso é uma pendência de qualidade documental, não um conflito de merge.

Não foram encontrados marcadores de conflito ou nomes de arquivos que indiquem segredos evidentes. Essa verificação não substitui a análise completa de conteúdo sensível.

**Conclusão da etapa:** não há conflito técnico de Git entre a `main` atual e a `feat/affordable-plans-model`. Ainda não foi feito merge, commit, push ou alteração na `main` remota. O próximo gate é a revisão multidisciplinar do diff e a validação disponível antes de qualquer fast-forward.

## 14. Revisão multidisciplinar inicial do diff

O módulo de planos preserva explicitamente o núcleo offline: `PlanAccessController` libera comunicação, controles parentais, acessibilidade e armazenamento local independentemente de licença; recursos remotos dependem de licença e estado compatíveis. Os testes adicionados cobrem plano Essencial, licença ativa, período de transição, suspensão, expiração, revogação, status desconhecido e ausência de dados clínicos na serialização.

O CI da branch adiciona build Web e um workflow de GitHub Pages para o diretório `site/`. O workflow está tecnicamente separado e exige arquivos mínimos, mas um avanço da branch para `main` poderá disparar publicação pública do site se o GitHub Pages estiver configurado para essa fonte. Essa publicação será tratada como gate separado e não será acionada automaticamente durante a simulação.

A branch adiciona 18 arquivos de teste, 42 arquivos de aplicação, documentação e site. Não foram encontrados marcadores de conflito, arquivos deletados ou segredos evidentes na inspeção inicial. A análise local de Flutter continua bloqueada porque a toolchain não está instalada.

**Pendências de validação:** revisar visualmente os fluxos; corrigir os três espaços à direita documentados; revisar o workflow de Pages antes de qualquer publicação; e revisar o diff final em relação ao cronograma.

## 15. Validação local da affordable

**Data:** 23 de setembro de 2026.

Foi instalada a versão Flutter `3.38.0`, com Dart `3.10.0`, correspondente à versão declarada no CI. Na cópia isolada da branch foram executados `flutter pub get`, verificação de formatação, `flutter analyze --no-fatal-infos --no-fatal-warnings`, `flutter test` e `flutter build web --release`.

O resultado foi:

| Verificação | Resultado |
| --- | --- |
| Dependências | concluído; 84 pacotes possuem versões mais novas incompatíveis com as restrições atuais, sem falha de instalação |
| Formatação | a verificação retornou status 1 porque 12 arquivos foram formatados pelo comando; a branch precisa registrar essa normalização ou aceitar o comportamento atual do CI |
| Análise estática | concluída sem falha bloqueadora; foram reportados 33 issues informativos/avisos, incluindo um import não utilizado em `weekly_trends_screen.dart` e APIs depreciadas |
| Testes Flutter | **46 testes passaram** |
| Build Web release | concluído com sucesso; `build/web` foi gerado |

O build Web também apresentou avisos de compatibilidade com o dry-run WebAssembly em dependências (`flutter_secure_storage_web`, `package:js` e `flutter_tts`). Isso não impediu o build JavaScript atual, mas deve ser registrado como limitação técnica da compatibilidade futura com Wasm.

O comando de dependências regenerou arquivos de plugin em Linux, macOS e Windows apenas na cópia local. Essas alterações geradas não representam alteração da branch remota e devem ser descartadas ou tratadas separadamente antes de qualquer diff de integração.

**Conclusão da etapa:** a affordable compila para Web e passa os 46 testes locais, mas não está totalmente limpa do ponto de vista de qualidade: a formatação ainda altera 12 arquivos e existem 33 avisos informativos/diagnósticos. Não há bloqueio de compilação ou teste neste ambiente.

## 16. Segunda validação após ajustes mecânicos

Foi criada a branch local `integration/affordable-to-main-preview`, baseada em `d0af6e2`, para preparar a integração sem tocar na branch remota. Nessa branch foram aplicadas somente alterações mecânicas: formatação dos 12 arquivos apontados e remoção do import Hive não utilizado em `weekly_trends_screen.dart`.

Após os ajustes, foram executados novamente `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze --no-fatal-infos --no-fatal-warnings`, `flutter test` e `flutter build web --release`.

| Verificação | Resultado final |
| --- | --- |
| Formatação | passou; 74 arquivos verificados, 0 alterados |
| Análise estática | passou no modo não fatal; 32 issues informativos/deprecados permanecem, sem falha bloqueadora |
| Testes Flutter | **46 testes passaram** |
| Build Web release | concluído com sucesso |

Os arquivos gerados automaticamente pelos comandos de dependência foram restaurados e não fazem parte das alterações intencionais. A branch local contém apenas as normalizações de código, a remoção do import não utilizado e este documento de continuidade. Ainda não existe commit ou push dessas correções.

**Conclusão da etapa:** a cópia de integração está formatada, analisada, testada e compilada para Web. O próximo passo técnico é revisar o diff dessas correções e decidir como incorporá-las ao fluxo da branch affordable antes do fast-forward da `main`.

## 17. Pré-integração publicada para revisão

Foi criada a branch local `integration/affordable-to-main-preview` e registrado o commit `22628ad` (`chore: prepare affordable branch for main integration`). O commit contém as normalizações de formatação, a remoção do import não utilizado e este documento de continuidade.

A branch foi enviada ao GitHub sem alterar a `main`. Foi aberto o Pull Request [#27](https://github.com/falacomigocaa-app/fala-comigo/pull/27), com destino `main`, para manter a integração revisável e rastreável. O PR registra os resultados de formatação, análise, 46 testes e build Web.

**Estado:** aguardando a revisão final do diff e dos checks do PR. O merge não foi executado. A publicação do site via GitHub Pages continua sendo um efeito separado a revisar antes de qualquer merge na `main`.

Na consulta seguinte, o PR estava `OPEN`, com `mergeStateStatus: CLEAN`, sem conflitos e sem checks remotos listados ainda. A branch local está limpa e o commit local coincide com `origin/integration/affordable-to-main-preview` em `a500f38`.

## 18. Integração concluída na `main`

Em 23 de setembro de 2026, o Pull Request #27 foi mesclado com sucesso na `main`. O merge gerou o commit `5a0d12517557c218b98074347ee578ed1a710a95`. A branch `main` local foi atualizada para esse commit e está limpa, alinhada com `origin/main`.

Após o merge, foram disparados dois workflows no GitHub Actions para o novo commit: `Flutter quality checks` e `Publicar site institucional`. No momento deste registro, ambos estavam `in_progress`; os resultados finais ainda precisam ser verificados quando concluírem.

O endpoint de GitHub Pages retornou `404 Not Found` antes do merge, indicando que Pages ainda não estava configurado no repositório. Portanto, o workflow do site foi disparado, mas a publicação pública definitiva depende da configuração do Pages e de sua conclusão com sucesso.

**Estado da integração:** código da affordable incorporado à `main`; merge concluído; nenhum dado clínico, cobrança ou portal conectado foi ativado. Pendência imediata: confirmar os resultados dos workflows pós-merge e, se necessário, corrigir somente problemas de CI ou de configuração do site.

## 19. Pós-merge — falha de configuração do GitHub Pages

O workflow `Publicar site institucional` do commit `5a0d125` foi executado e falhou na etapa `actions/configure-pages@v5`. O log informa `Get Pages site failed` e confirma que o repositório ainda não tem GitHub Pages habilitado para publicação por GitHub Actions. A API de Pages também retornou `404 Not Found`.

Isso não representa falha do aplicativo Flutter nem do código integrado. O workflow está preparado para publicar o diretório `site/`, mas a ativação do Pages é uma mudança de publicação externa e deve ser feita separadamente, com confirmação explícita antes de tornar o site público. Não foi ativado automaticamente.

O workflow `Flutter quality checks` do commit `41956c3` estava em andamento no momento deste registro. O resultado deve ser verificado antes de declarar a validação pós-merge completamente encerrada.

## 20. GitHub Pages habilitado

O proprietário confirmou manualmente a configuração correta em **Settings → Pages**. A fonte está definida como `GitHub Actions`, com branch `main` e caminho `/`. A API passou a confirmar a configuração e forneceu a URL pública:

<https://falacomigocaa-app.github.io/fala-comigo/>

O workflow `Publicar site institucional` foi solicitado novamente após a ativação do Pages e concluiu com sucesso. A URL pública respondeu HTTP 200 e exibiu o título `Fala Comigo — Comunicação que respeita o seu tempo`:

<https://falacomigocaa-app.github.io/fala-comigo/>

**Conclusão:** o GitHub Pages está habilitado e o site institucional está publicado com sucesso. A publicação não ativa cobrança, portal clínico ou sincronização de dados; ela publica somente os arquivos estáticos versionados em `site/`.

## 21. Próxima fase — matriz de fluxos críticos

Foi criada a matriz executável `docs/MATRIZ_FLUXOS_CRITICOS.md` na branch `qa/critical-flow-matrix`. Ela organiza 24 fluxos, relaciona cada um aos testes automatizados existentes e separa as validações que ainda exigem celular, tablet, iOS, leitor de tela ou observação humana.

A matriz registra a evidência atual de 46 testes Flutter e build Web aprovado. Os fluxos mais importantes ainda classificados como parciais ou pendentes manuais incluem primeira execução, grade CAA, modos de toque, frases, PIN, sessão parental, mídia, alertas, exclusão, acessibilidade e testes em Android real.

O próximo ciclo deve começar por um celular Android e um tablet Android, usando dados sintéticos e sem internet, antes de qualquer nova construção de portal, sincronização clínica ou cobrança.

## 12. Atuação multidisciplinar da assistência

Para a continuação deste projeto, a assistência atuará de forma integrada nas seguintes responsabilidades:

| Área | Responsabilidades aplicadas |
| --- | --- |
| Arquitetura e backend | Solutions Architect, Software Architect, Principal Backend Engineer e Staff API Specialist: arquitetura, contratos, segurança, autorização, persistência, integração futura e limites do backend. |
| Web e mobile | Senior Web Engineer, Staff Mobile Engineer — iOS e Staff Mobile Engineer — Android: Flutter, Web, Android, iOS, builds, compatibilidade, permissões, armazenamento e uso offline. |
| Design | Head of Design, Product Design Lead, Design System Architect e Senior UX/UI Designer: acessibilidade, hierarquia visual, consistência, design system, fluxos e experiência da criança e do responsável. |
| Produto | Technical Product Manager e Product Owner: escopo, prioridades, cronograma, critérios de aceite, decisões de produto e preservação da sequência planejada. |
| Qualidade | QA Automation Engineer: estratégia de testes, testes de regressão, testes de negação, CI, revisão de risco e critérios de pronto. |

Essa atuação significa que cada alteração será analisada por mais de uma perspectiva antes de ser considerada pronta. A documentação, o diff, os testes, a acessibilidade, a privacidade e o impacto no cronograma serão avaliados conjuntamente.

As validações que não podem ser inventadas ou substituídas por análise de código continuarão explícitas: teste em celular e tablet reais, observação com famílias e profissionais, revisão jurídica ou regulatória, confirmação de decisões comerciais e aprovação para publicação ou cobrança.

## 22. Validação técnica pós-merge da `main`

Após a integração da matriz, a `main` foi validada novamente com Flutter `3.38.0`. A formatação verificou 74 arquivos sem alterações, a análise estática terminou sem falha bloqueadora com 32 issues informativos/deprecados, **46 testes passaram** e `flutter build web --release` concluiu com sucesso.

Os arquivos gerados automaticamente durante `flutter pub get` foram restaurados, deixando a cópia local da `main` limpa. A sessão possui somente um dispositivo Linux desktop; não há celular ou tablet Android conectado, `adb devices` não encontrou dispositivos e não existem ferramentas iOS disponíveis. Portanto, F21, F22 e F23 da matriz continuam pendentes de execução física.

**Próximo gate:** executar F01–F17 em um celular Android e um tablet Android, começando offline e usando dados sintéticos. O resultado deve ser registrado na `MATRIZ_FLUXOS_CRITICOS.md` antes de iniciar portal conectado, sincronização clínica ou cobrança.


## 17. Retomada: separação entre portal RH e benefício familiar

**Data:** 23 de setembro de 2026.
**Branch:** `feat/rh-portal-entitlement-boundary`.
**Base:** `origin/main` no início desta retomada.

Foi definida uma separação explícita entre dois produtos que uma empresa pode contratar de forma independente:

- portal RH/benefícios, para administração de programa, convites, validade, contrato e métricas agregadas;
- benefício patrocinado à família, para conceder recursos sem expor conteúdo familiar ou clínico.

Uma empresa pode contratar somente o portal RH sem receber qualquer licença familiar ou acesso a dados de crianças. O benefício patrocinado não concede acesso ao painel administrativo da empresa. O núcleo CAA offline permanece gratuito e independente dessas ofertas.

A implementação inicial adiciona os entitlements `benefitAdministration` e `aggregateReporting` ao plano administrativo `organization`. Foram incluídos testes de negação para confirmar que:

- o plano administrativo não libera `sponsoredLicense` nem `careNetwork`;
- o plano patrocinado não libera `organizationPortal`, `benefitAdministration` nem `aggregateReporting`;
- ambos preservam a comunicação básica offline.

A arquitetura e os critérios de proteção de dados estão em `docs/MODELO_PORTAL_RH_E_BENEFICIO.md`. O documento reforça minimização, finalidade, segregação de organizações, auditoria, convites individuais, métricas agregadas com limiar mínimo, ausência de conteúdo clínico em logs e revisão jurídica/LGPD antes de produção.

Ainda não foi feito merge, push ou alteração na `main`. A próxima etapa é executar formatação, análise, testes e build Web disponíveis; depois revisar o diff e abrir uma PR somente se a validação estiver adequada. Pagamento, reembolso, integração automática com RH, sincronização clínica e dados reais continuam bloqueados.


## 18. Etapa automática: contrato técnico do backend RH

**Data:** 23 de setembro de 2026.
**Branch:** `feat/rh-backend-authorization-contract`.

Após a publicação do console RH sintético, foi iniciado o contrato técnico do backend. O documento `docs/CONTRATO_PORTAL_RH_AUTORIZACAO.md` separa identidade, organização, membership, programa, licença, convite, autorização de cuidado e auditoria.

O contrato reforça que `benefitAdministration` não implica `sponsoredLicense`, que uma licença patrocinada não implica `organizationPortal` e que a comunicação offline continua fora do ciclo comercial. Também define dados mínimos, operações permitidas, negações obrigatórias, estados de licença, transições e requisitos de logs sem conteúdo clínico.

O próximo gate é validar as negações no servidor com duas organizações isoladas antes de qualquer endpoint real, integração de RH, cobrança, sincronização ou dado de produção.


## 19. Fechamento do ciclo RH: autorização, licença, auditoria e suporte

**Data:** 23 de setembro de 2026.
**Commits integrados:** `930a006` (contrato de autorização), `2262f92` (política de autorização e 56 testes), `7924721` (isolamento organizacional), `95c0f35` (máquina de estados de licença), `6f35b55` (auditoria e retenção) e `91fb516` (acesso elevado).

O ciclo de protótipo RH foi concluído na `main`. Foram adicionados contratos e políticas locais para: separação de entitlements; negação por sessão, conta, organização, papel, finalidade, escopo, prazo e limiar; estados `invited`, `active`, `grace`, `suspended`, `expired` e `revoked`; eventos administrativos mínimos; retenção por finalidade; e suporte temporário limitado a metadados administrativos.

O console RH publicado continua sintético e sem backend real. Não existe acesso a diagnóstico, conteúdo, mídia, registro clínico, frequência individual ou exportação familiar. A comunicação básica offline permanece independente. O acesso elevado exige aprovação, motivo, mesma organização, escopo permitido, validade máxima de duas horas e revogação.

**Validação final:** análise estática concluída com exit code 0, suíte completa com 56 testes, build Web release concluído e auditoria estrutural `FINAL RH FLOW AUDIT: PASS`. Os avisos restantes são dependências/depreciações e incompatibilidades de WASM já conhecidas, sem falha do build Web convencional.

**Próximo limite:** não iniciar endpoints de produção, integração com sistemas de RH, cobrança ou sincronização clínica sem revisão de privacidade/LGPD, definição de controlador/operador, contratos, retenção final, testes de segurança e ambiente separado com dados sintéticos.


## 20. Linha de base de segurança e continuidade para novos agentes

**Data:** 24 de setembro de 2026.
**Estado Git:** PRs #45, #46, #47, #48, #49, #50 e #51 integradas; `main` local sincronizada com `origin/main` no commit `c8b9528` (`Merge: atualizar continuidade de segurança`).

### Decisão de produto

A segurança deve melhorar **sem limitar o aplicativo**. Não remover comunicação alternativa, área parental, mídia, notificações, relatórios, funcionamento offline ou portal RH apenas para aumentar a nota do scanner. A estratégia é segurança por implementação, migração compatível e revisão contínua.

Por enquanto, não alterar o algoritmo de armazenamento nem elevar o `minSdk` automaticamente. Os achados conhecidos são dívida técnica monitorada. Qualquer correção futura deve preservar os dados existentes, testar migração/recuperação e medir impacto de compatibilidade antes de ser integrada.

### Linha de base MobSF

Foi executado o workflow manual `MobSF mobile security scan` com sucesso:

- **Run:** [35950414857](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/35950414857)
- **MobSF:** v4.5.4
- **Artefato:** APK release de teste, assinado por chave efêmera do runner; não é build de produção.
- **SHA-256:** `b262679c154266f4bfb3573b13ced36c3f2b206e4d7dee77135816c01cfd1a2d`
- **Score MobSF:** 46
- **Resumo:** 2 achados altos, 5 warnings, 1 hotspot de permissões, 1 informação e nenhum tracker detectado estaticamente.

Achados prioritários:

1. CBC com PKCS5/PKCS7 em código obfuscado associado à criptografia usada pelo `HiveAesCipher` (`MSTG-CRYPTO-3`). Revisar dependência/formato e planejar migração autenticada sem quebrar dados.
2. `minSdk=24` classificado como Android 7.0 vulnerável/desatualizado. Decisão de compatibilidade pendente; não elevar automaticamente.
3. `ProfileInstallReceiver` com `android.permission.DUMP` exportado.
4. Warnings de hardcoded em plugin de notificações, arquivos temporários, armazenamento externo e possíveis strings sensíveis; revisar falsos positivos e origem.
5. Hotspot de permissões: câmera, imagens, áudio e notificações. Manter apenas as necessárias, solicitadas em contexto e explicadas ao responsável.

O relatório sanitizado está em `security/reports/MOBSF_2026-09-24.md`. O plano operacional está em `docs/PLANO_SEGURANCA_OWASP_MASVS_MOBSF.md`. Não registrar no GitHub o APK, o PDF completo, tokens, chaves ou dados reais; os artefatos completos ficam somente na execução controlada do Actions.

### Protocolo obrigatório para qualquer nova função

Antes de integrar uma nova função, o agente deve:

1. ler este documento, `PROJECT_HANDOFF.md`, o roadmap aplicável e o plano MASVS/MobSF;
2. identificar se a função adiciona permissões, dependências, armazenamento, mídia, logs, intents, links, exportação ou dados do portal RH;
3. preservar o modo offline, a comunicação básica e os limites entre dados familiares/clínicos e dados administrativos RH;
4. executar testes, análise, `git diff --check` e validações específicas da função;
5. comparar o impacto contra a linha de base MobSF, sem suprimir achados para melhorar artificialmente a pontuação;
6. registrar no handoff o que mudou, o resultado dos testes, riscos, branch/PR e próximo passo;
7. repetir o MobSF em marcos relevantes, principalmente antes de piloto ou quando houver mudança de criptografia, permissões, armazenamento ou dependências Android.

Se o novo agente encontrar um conflito entre aumentar a pontuação e preservar uma função importante, deve manter a função e propor uma solução de implementação segura, documentando a decisão para revisão humana.


## 23. Retomada segura — auditoria e correções críticas

**Data:** 24 de setembro de 2026.
**Branch:** `fix/critical-regressions-and-ci`.
**Base:** `main` no commit `ee07118`.

Foi realizada uma auditoria independente em quatro frentes: núcleo Flutter/CAA, site publicado, segurança OWASP/MobSF e QA/CI. A `main` estava limpa e alinhada com `origin/main`; a auditoria não alterou a `main`.

Foram encontrados e corrigidos nesta branch os seguintes problemas de alto impacto:

- o apagamento local agora inclui a caixa `visual_routine` e repopula os cartões padrão imediatamente, evitando uma grade vazia após o wipe sem reiniciar o processo;
- a edição de cartão persiste explicitamente `isCustomImage` e aguarda a gravação, evitando que uma foto privada seja renderizada como asset público;
- TTS e notificações foram retirados do caminho crítico do bootstrap, para que falha de plugin opcional não impeça a abertura da grade CAA;
- o CI passou a verificar formatação com `dart format --output=none --set-exit-if-changed lib test`;
- o smoke check do GitHub Pages passou a validar também o protótipo RH;
- o site alinhou o status MobSF para “varredura concluída; achados em revisão”, melhorou contraste e navegação estreita, marcou o convite RH como indisponível no protótipo e incluiu favicon;
- foi adicionado teste de regressão para edição de imagem personalizada.

**Limitação atual:** Flutter, Dart e `adb` não estão instalados nesta sessão. Portanto, a validação local de análise, testes, build e dispositivos ainda não foi executada. A branch precisa passar pelo GitHub Actions antes de qualquer merge. A auditoria também confirmou que validação em celular/tablet, acessibilidade com tecnologia assistiva, revisão dinâmica MASVS/MobSF, decisão sobre `minSdk`, revisão do CBC/Hive e backend RH continuam fora do que pode ser declarado pronto.

**Próximo gate:** revisar o diff, fazer commit e abrir uma PR; aguardar CI verde e revisar a saída antes de integrar. Não iniciar cobrança, backend RH real, sincronização clínica, domínio ou publicação ampla.


## 24. Fechamento da correção crítica

**Data:** 24 de setembro de 2026.

A PR #54 (`Fix: preservar comunicação em recuperação local e fortalecer CI`) foi integrada na `main` com o commit `df32256`. A `main` local foi sincronizada com `origin/main` e permaneceu limpa.

Os workflows pós-merge concluíram com sucesso para esse commit:

- Flutter quality checks — run [36089138936](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36089138936): formatação estrita, análise estática, política de assinatura, testes e build Web release;
- Publicar site institucional — run [36089138902](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36089138902): publicação do diretório `site/` no GitHub Pages.

A correção está integrada e validada pelo CI remoto. Os avisos do runner sobre Node.js 20 e futura migração do `ubuntu-latest` são avisos de infraestrutura do GitHub Actions, não falhas do projeto.

Isso não altera os gates ainda pendentes: testes em celular/tablet reais, acessibilidade com tecnologia assistiva, revisão dinâmica MASVS/MobSF, decisão sobre CBC/Hive e `minSdk`, backend RH real, cobrança e validação humana. O projeto está em estado tecnicamente consistente para a próxima etapa de validação manual, não em lançamento amplo.


## 25. Retomada da tela branca e reaplicação segura da correção Android

**Data:** 25 de setembro de 2026.
**Branch de correção:** `fix/main-startup-and-android-build`.
**Base:** `origin/main` no commit `0d0b685`.

A PR #29 (`fix/android-kotlin-plugin`) continua aberta e aparece como `DIRTY` porque foi criada sobre uma versão anterior da `main`. Ela contém duas correções importantes, mas não deve ser mesclada inteira sem revisão: aplicação explícita do plugin Kotlin no Gradle Android e tipagem de `pictogram_cards` como `Box<PictogramCard>`.

A `main` atual ainda tinha `SecureBoxService.openSecureBoxWithMigration(cardsBoxName)` sem tipo explícito, enquanto `cardsBoxProvider` exige `Hive.box<PictogramCard>(cardsBoxName)`. Esse desacordo é compatível com o erro observado anteriormente no Android:

`HiveError: The box "pictogram_cards" is already open and of type Box<dynamic>`

Esse erro ocorre antes de `runApp` e pode aparecer ao usuário como uma tela branca. A PR #60 (`diagnostics/show-startup-failure`) adiciona uma tela de erro visível para diagnóstico, mas é draft e não foi integrada. A tentativa de merge foi recusada pelo GitHub exatamente porque a PR está marcada como draft. Nenhuma alteração foi perdida na `main`.

Na branch de correção foram reaplicadas somente as mudanças necessárias:

- `SecureBoxService` agora usa `openSecureBox<T>` e `openSecureBoxWithMigration<T>`;
- todas as chamadas internas de abertura/migração preservam `Hive.openBox<T>`;
- `lib/main.dart` abre `pictogram_cards` com `<PictogramCard>`;
- `android/app/build.gradle.kts` aplica `org.jetbrains.kotlin.android`;
- a keystore continua obrigatória para release e não é adicionada ao Git.

O APK obtido na branch diagnóstica `diagnostics/show-startup-failure` não foi gerado pelo Codemagic nem pela `main`; foi gerado pelo GitHub Actions no run [36096527894](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36096527894), com SHA-256 `86ba70c8868d4919fe7b00ccf262a25b774ad06b6a698b4e21ce6db77df0da06`. Ele é um artefato de diagnóstico, não uma prova de abertura correta da `main`.

O handoff operacional detalhado está em `docs/HANDOFF_TELA_BRANCA_APK.md`. O próximo gate é abrir uma PR baseada na `main` atual com a correção seletiva, aguardar análise/testes/build Android debug verdes e instalar o APK em aparelho real. A validação deve separar instalação, abertura da grade, navegação e execução offline. Nenhum resultado de aparelho deve ser inventado.

**Regra para o próximo agente:** não mesclar a PR #29 diretamente; não apagar a PR #60; não reverter a linha de segurança/RH; comparar a `main` atual e reaplicar apenas correções comprovadas. Se a tela continuar branca após a correção Hive, usar a tela diagnóstica da PR #60 ou logs do aparelho para obter a exceção específica.

## 26. Prompt mestre para novas retomadas

**Data:** 25 de setembro de 2026.

Foi criado o arquivo `PROMPT_RETORNO_NOVO_AGENTE.md` na raiz do repositório. Ele contém uma instrução completa, pronta para copiar e colar em outra assistência por IA. O prompt obriga a leitura dos handoffs, preserva a `main`, identifica a PR #66, diferencia validação de CI de validação em aparelho, orienta a geração do APK e define o formato de atualização após cada etapa.

O arquivo `CONTINUAR_AQUI_PRIMEIRO.md` aponta diretamente para esse prompt, e `README.md` também indica o aviso como primeira leitura. Qualquer agente futuro deve atualizar esses arquivos e `docs/HANDOFF_TELA_BRANCA_APK.md` ao concluir uma etapa.


## 27. APK corrigido da PR 66 gerado com sucesso

**Data:** 25 de setembro de 2026.
**Branch:** `fix/main-startup-and-android-build`.
**Commit do build:** `abe8633`.

O workflow `Android test APK artifact` concluiu com sucesso no run [36109508895](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36109508895). O Flutter foi configurado, as dependências foram instaladas, o APK foi construído, verificado com `apksigner` e publicado como artefato.

O APK de teste `fala-comigo-test.apk` possui SHA-256 `63f3d897f07995baff7262b4f43d691733f0e7c80e25f97988a9bc818b373646`. Ele foi assinado com chave efêmera do GitHub Actions e não é um APK de produção nem uma execução do Codemagic.

A evidência confirma o build e a integridade estrutural do APK. Ainda falta a validação física em celular ou tablet Android para confirmar a abertura da grade CAA, o funcionamento offline e a ausência da tela branca. Nenhuma alteração foi feita na `main`.


## 18. Integração candidata — 25/09/2026

Foi criada a branch local `integration/finalize-project` a partir de `origin/main` no commit `0d0b685`. A PR 66 foi integrada como base técnica, preservando a abertura tipada de `Box<PictogramCard>`, o plugin Kotlin Android e a guarda de assinatura de release. Em seguida, foi integrada a cabeça da PR 33, que já contém a ancestralidade das PRs 30 e 32, sem reaplicar essas PRs separadamente.

Os conflitos foram resolvidos manualmente. A resolução preserva a correção Android e o bootstrap resiliente, inclui as caixas parentais no inventário de exclusão, preserva `visual_routine`, apaga a chave nativa de mídia durante o wipe, corrige o import da tela de continuidade parental e torna `hintText` compatível na decoração dos campos parentais. O bootstrap agora renderiza a árvore Flutter imediatamente, mostra carregamento e erro sanitizado com retry, e inicializa TTS/notificações somente após o primeiro frame.

Ainda não foi criado commit ou push desta branch. Flutter, Dart e adb não estão disponíveis nesta sessão; portanto, format, análise, testes, build Web, APK e teste em aparelho continuam gates obrigatórios no CI e na validação humana. A `main` remota não foi alterada.

Próximo passo: revisar o diff completo, executar `git diff --check`, registrar o commit da integração e enviar uma PR de integração para que o CI valide a combinação antes de qualquer decisão sobre a `main`.


## 28. Manual mestre e estado final da integração — 25/09/2026

Foi criado o manual operacional [`MANUAL_CONTINUIDADE_MESTRE.md`](../MANUAL_CONTINUIDADE_MESTRE.md). Ele define a ordem de leitura, o contexto do projeto, o estado real da `main`, a atuação como equipe técnica, exemplos de comandos do proprietário, formato de atualização e os momentos em que o agente deve pedir confirmação.

A integração da PR 67 foi concluída na `main` com o commit `7aa12f5` (`Merge integration: Android startup fix and parental area`). A branch `integration/finalize-project` foi preservada para auditoria.

Evidências finais registradas na sessão:

- CI da PR e CI pós-merge: sucesso;
- deploy do site institucional no GitHub Pages: sucesso;
- 92 testes Flutter locais: aprovados;
- análise estática sem erros fatais;
- formatter Flutter 3.38.0: aprovado;
- build Web release local: aprovado;
- APK debug local: aprovado, aproximadamente 153 MB.

O APK debug não é uma release de produção. A publicação Android de produção continua dependente de keystore de release, validação em aparelho real e demais gates do checklist. O backend conectado, sincronização clínica, cobrança real e domínio definitivo continuam fora do escopo implementado.

A partir desta data, qualquer agente deve tratar a descrição histórica anterior deste documento como histórico, consultar a `main` real e seguir o manual mestre antes de agir. Para ações externas de alto impacto, o agente deve apresentar o payload e aguardar confirmação explícita do proprietário.


## 29. Regra reforçada de continuidade entre agentes — 25/09/2026

O proprietário confirmou que a continuidade deve ser atualizada em toda demanda para que outros agentes entendam imediatamente o que já foi feito. O manual mestre agora exige comparação com o trabalho anterior, classificação do estado como resolvido, parcial, pendente, falha conhecida ou novo trabalho, registro das evidências e indicação explícita do próximo gate.

Nenhuma alteração de código foi feita nesta etapa; somente a documentação de continuidade foi reforçada. A regra passa a valer para todas as retomadas futuras.

## 30. Verificação dos layouts parentais na main — 25/09/2026

Foi analisado o contexto `CONTEXTO_RECUPERACAO_LAYOUTS_AGENTE(1).txt` enviado pelo proprietário. A comparação confirmou que as PRs 30, 32, 33 e 66 são ancestrais da `origin/main` no commit `7aa12f5`; não devem ser mescladas novamente.

A `main` atual contém os arquivos do dashboard e os módulos parentais de rotina, diário, alertas, tendências, relatórios, perfil, privacidade, acesso familiar, tarefas compartilhadas e continuidade do cuidado. A leitura de `settings_screen.dart` confirmou que esses módulos possuem rotas acessíveis pelo dashboard atual.

Nenhuma alteração de código foi feita nesta etapa; somente análise e geração de artefato. Foi gerado um APK diretamente da `origin/main` em `7aa12f5`, com sucesso. SHA-256: `e5f626b361c16add29a8bf5993df57acbc141b9ef079b4313bb079cdf32b964c`. O artefato foi salvo fora do repositório em `/home/ubuntu/fala-comigo-main-7aa12f5-layout-check.apk`.

Conclusão: a hipótese mais forte é que o APK anteriormente testado (`abe8633`) era anterior à integração visual completa. O próximo passo é instalar o APK da main atual em aparelho/emulador e comparar visualmente. Só recuperar código antigo se uma tela realmente estiver ausente nessa versão.

## 31. Correção do erro app_settings — 25/09/2026

Ao testar o APK gerado da `main` atual, foi reproduzido o erro `HiveError: The box "app_settings" is already open and of type Box<PictogramCard>`. A causa foi localizada em `lib/main.dart`: o bootstrap abria `app_settings` com o tipo de `pictogram_cards`, embora a caixa de configurações armazene valores heterogêneos.

Foi criada a branch `fix/app-settings-box-type` com o commit `078ebcd`. A correção troca somente a abertura de `app_settings` para `Box<dynamic>` e preserva `pictogram_cards` como `Box<PictogramCard>`. A PR 69 foi aberta para `main`.

Validações locais da branch: formatter aprovado, análise sem erros fatais, suíte de testes aprovada e APK debug aprovado. SHA-256 do APK corrigido: `8217746f4846dd447406733c246e412ae81394ff6c7ca6ee1aa2da085fc4d168`.

O APK corrigido ainda precisa ser instalado e testado no aparelho. O merge da PR 69 depende dos checks remotos e de confirmação do proprietário.

## 32. Confirmação do APK corrigido — 25/09/2026

O proprietário confirmou que o APK da branch `fix/app-settings-box-type` funcionou após a correção da tipagem Hive de `app_settings`. A PR 69 está aberta contra `main`, com `analyze-and-test` aprovado, estado `MERGEABLE` e sem conflito.

A correção está pronta para merge técnico, mas o merge permanece pendente de confirmação explícita do proprietário conforme o manual de continuidade.

## 33. PR 69 mesclada na main — 25/09/2026

Após confirmação explícita do proprietário, a PR 69 foi mesclada na `main`. O commit resultante é `9e97da0` (`Fix app_settings Hive box type`). A correção testada no APK agora está oficial na linha principal.

O workflow pós-merge `Flutter quality checks` foi disparado para o commit `9e97da0` e estava `in_progress` no momento deste registro. O resultado final deve ser verificado antes de declarar a etapa totalmente encerrada.

## 34. Escopo profissional de organizações, convites e assinantes — 25/09/2026

A auditoria confirmou que o app atual possui `AccessGrant` e permissões locais, mas não envia convite remoto nem cria autorização server-side. O `site/portal.html` é uma prévia estática com dados sintéticos; seus botões não autenticam, não persistem dados e não processam assinaturas.

Foi criado `docs/ESCOPO_PORTAL_ORGANIZACOES_ASSINANTES.md`, com o fluxo de convite individual e expirável, consentimento separado de benefício, matriz de papéis e escopos, arquitetura Web full-stack, planos de assinantes, fases, testes de negação e decisões necessárias. Não foi ativada cobrança, backend real ou compartilhamento de dados.

## 35. Portal real e contatos públicos — 25/09/2026

O proprietário confirmou que não deseja somente protótipo e já possui escola e clínica ABA para teste controlado. Foi inicializado o projeto Web full-stack real `/home/ubuntu/fala-comigo-portal`, com autenticação Manus, banco MySQL/TiDB, API tRPC e armazenamento preparado.

Primeiro corte implementado: organizações, membros, convites individuais com token hash, expiração, aceite autenticado, auditoria mínima e limite server-side. A regra inicial de piloto foi aplicada: organização começa com `seatLimit = 1`; ao atingir o limite, adicionar pessoa exige ativação do plano Organização. Benefício patrocinado e permissão de dados continuam separados.

O portal tem dashboard autenticado, criação de organização, preparação de convite, cópia/compartilhamento do link, página `/invite/:token` e aceite com visualização de finalidade, escopos e prazo. O fluxo real ainda está em validação automatizada antes do checkpoint/publicação.

O site institucional foi atualizado para contato por `falacomigocaa@gmail.com` e WhatsApp `+55 67 99163-32279`. O portal está separado do site público; `site/portal.html` continua identificado como prévia estática até o portal real ser publicado.
