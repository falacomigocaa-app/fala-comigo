# Auditoria das Pull Requests — 04/10/2026

**Repositório:** `falacomigocaa-app/fala-comigo`
**Linha de base:** `main` em `b08daa10d2314ea56fd079d07378fbcabe4e4335` (PR #90 integrada)
**Resultado desta etapa:** 6 PRs encerradas como redundantes/superadas; 9 PRs continuam abertas. Nenhuma PR de produto foi mesclada nesta auditoria; nenhuma branch foi apagada; nenhum deploy foi disparado por esta etapa.

## Escopo, método e limite

A lista foi atualizada diretamente no GitHub após sincronizar `origin/main`. Para cada PR foram verificados head, base, estado de mergeabilidade e checks disponíveis; as pontas foram comparadas com a `main`. Foram examinados os arquivos/hunks relevantes, a implementação atual da `main` e os logs dos jobs Flutter falhos de #33, #79, #80 e #81.

A tentativa de orquestração de uma equipe de 15 revisores não entregou avaliações por PR. Portanto, este documento é uma **triagem técnica manual baseada em evidências**, não uma revisão independente exaustiva linha a linha nem aprovação de release. As PRs abertas que continuarem em avaliação ainda precisam de revisão profunda e validação apropriada antes de integração.

Nenhum dado real de criança ou de saúde foi usado. A análise foi somente de código, documentação, metadados e logs de CI.

## PRs já resolvidas sem merge

| PR | Resultado | Evidência e motivo |
|---|---|---|
| [#31](https://github.com/falacomigocaa-app/fala-comigo/pull/31) | Encerrada como superada | A ponta `6582d91` já era ancestral de `main` (`ahead_by=0`). As alterações já estavam integradas por outra rota; não havia conteúdo a mesclar novamente. Branch preservada. |
| [#32](https://github.com/falacomigocaa-app/fala-comigo/pull/32) | Encerrada como superada | A ponta `9553e1d` já era ancestral de `main` (`ahead_by=0`). Branch preservada. |
| [#33](https://github.com/falacomigocaa-app/fala-comigo/pull/33) | Encerrada como superada | A ponta `9fc7b17` já era ancestral de `main` (`ahead_by=0`). O check histórico falhava na análise Dart, mas não se deve tentar mesclar um conteúdo já contido na `main`; a ponta atual da `main` é a referência. Branch preservada. |
| [#60](https://github.com/falacomigocaa-app/fala-comigo/pull/60) | Encerrada como superada | A `main` atual já tem tela de carregamento, falha de bootstrap e retry. O diff antigo mostrava exceção e stack trace completos ao usuário; não é apropriado reintegrar essa exposição. Branch preservada. |
| [#61](https://github.com/falacomigocaa-app/fala-comigo/pull/61) | Encerrada como baseline obsoleta | Gera somente APK debug da baseline PR29, estava 112 commits atrás, não tinha check automático de PR e usa `openSecureBoxWithMigration`, fora do gate fail-closed atual. Um futuro fluxo de APK deve construir a `main`/commit candidato atual e identificar o artefato por SHA. Branch preservada. |
| [#65](https://github.com/falacomigocaa-app/fala-comigo/pull/65) | Encerrada como superada | A `main` já executa `runApp` antes do bootstrap e mostra estados de loading/erro/retry. O diff antigo volta a usar `openSecureBoxWithMigration` e inclui gatilhos de CI para branches de recuperação que não representam o estado atual. Branch preservada. |

As closures foram feitas com comentário explicativo e sem merge, deploy ou exclusão das branches.

## PRs que continuam abertas

| PR | Estado atual e escopo | Finding/risco principal | Recomendação |
|---|---|---|---|
| [#53](https://github.com/falacomigocaa-app/fala-comigo/pull/53) | `DIRTY`; check `analyze-and-test` verde; documentação de execução manual e status do app/Web | A ficha de cenários F01–F17 é útil para a etapa futura de validação, mas os outros documentos são fotografias antigas e a PR conflita com a `main`. | Rebase seletivo; preservar a ficha de execução e atualizar links/status, sem declarar os testes físicos executados. |
| [#64](https://github.com/falacomigocaa-app/fala-comigo/pull/64) | `DIRTY`; check verde; governança/handoff | Sobrepõe `AGENTS.md` e os handoffs já atualizados por #88/#90; acrescenta regras Android/Web que merecem comparação, não merge integral cego. | Revisar e reaproveitar somente regras ainda ausentes; atualizar com a linha de base atual. |
| [#68](https://github.com/falacomigocaa-app/fala-comigo/pull/68) | `DIRTY`; check verde; manual mestre, escopo de portal e mudanças no site | O manual e a cronologia descrevem estado antigo. A mudança da homepage propõe publicar contatos diretos por e-mail/WhatsApp, dado que não deve ser tornado público sem confirmação explícita da pessoa responsável. | Não mesclar como está. Separar documentos úteis, atualizar o estado e pedir confirmação específica antes de qualquer contato pessoal no site. |
| [#77](https://github.com/falacomigocaa-app/fala-comigo/pull/77) | `DIRTY`; check verde; ADR de arquitetura independente do portal | É documental, mas formaliza uma decisão de arquitetura para um backend/portal ainda fora do produto operacional; está 8 commits atrás da `main`. | Rebase documental após confirmar que o escopo continua desejado; manter explícito que Auth, RLS e backend de produção ainda não existem. |
| [#78](https://github.com/falacomigocaa-app/fala-comigo/pull/78) | `CLEAN` contra a base `docs/record-option-a-public-url`; sem checks reportados | API PostgreSQL para dados sintéticos usa identidade/auth de desenvolvimento; não oferece autenticação nem isolamento prontos para produção. O portal real continua pendente. | Manter isolada como protótipo local/sintético; adicionar CI e testes negativos antes de qualquer integração; nunca usar dados reais nem publicar como serviço funcional. |
| [#79](https://github.com/falacomigocaa-app/fala-comigo/pull/79) | `DIRTY`; check Flutter falhou; branch empilhada | O CI falha no build Web porque `extensionHint` não existe na assinatura Web dessa ponta. Além disso, `materializeForReading(permanentPath)` cria um arquivo plaintext temporário, mas o retorno é descartado e não há liberação; o serviço exige liberação explícita. | **Bloqueada como está.** Rebase/split em branch limpa, remover a materialização não utilizada ou usar bytes em memória; se materializar, liberar em `finally`; testar ausência de temporário órfão e build Web. |
| [#80](https://github.com/falacomigocaa-app/fala-comigo/pull/80) | `DIRTY`; check Flutter falhou pelo mesmo erro Web de #79; empilhada sobre #79 | Altera o agendamento e o canal de notificação, incluindo alarmes exatos e intenção de tela cheia. Um novo ID de canal pode criar configurações novas e contornar preferências de importância escolhidas pelo usuário. | Não integrar em bloco. Separar a correção comum de #79; revisar UX de permissões/fallback e respeitar controles do Android. Exige teste real em aparelho quando os gates técnicos estiverem fechados. |
| [#81](https://github.com/falacomigocaa-app/fala-comigo/pull/81) | `DIRTY`; dois checks Flutter falharam pelo mesmo erro Web de #79; empilhada sobre #79/#80 | Acrescenta fluxo sintético de consentimento/grants, mas não constitui identidade, autorização server-side ou RLS de produção. | Manter sintética e isolada. Não usar dados reais nem tratar o fluxo como consentimento operacional; revisar autorização/negações e testes de integração antes de qualquer backend real. |
| [#83](https://github.com/falacomigocaa-app/fala-comigo/pull/83) | `DIRTY`; checks Flutter e validação estática do site verdes | Altera homepage/política/navegação pública e seu merge atualiza GitHub Pages. Testes estáticos/Chromium não substituem revisão legal, leitor de tela ou validação por pessoas usuárias. | Rebase e repetir checks; antes do merge que publicará conteúdo novo, obter autorização explícita e confirmar a redação/canal de contato. |

### Detalhe dos checks de #79–81

Nos três heads, o erro reportado é o parâmetro nomeado `extensionHint` ausente na implementação Web de `MediaStorageService.persistFile`. A `main` atual já possui esse parâmetro no stub Web, mas isso **não resolve automaticamente** os demais problemas nem valida as branches empilhadas. A correção precisa ser rebaseada e os checks executados novamente no head final.

## Dependências e ordem recomendada

1. **Documentos locais:** resolver #53 e comparar #64; não incorporar fotografias antigas como estado atual.
2. **Portal:** revisar #77 como decisão documental; só depois tratar #78 e #81, mantendo auth e dados sintéticos e sem anunciar backend de produção.
3. **App nativo:** extrair de #79 apenas mudanças pequenas e seguras, corrigir o ciclo de vida de arquivos temporários e validar Web/Flutter antes de considerar #80.
4. **Alarmes:** revisar permissões e preferências do canal antes de qualquer publicação; teste em dispositivo é gate posterior, não substituído por CI.
5. **Site:** #83 requer rebase, repetição de checks e autorização antes da mudança pública. #68 não deve republicar contatos diretos sem autorização específica.

## Próximo passo seguro

Preparar PRs pequenas a partir da `main` atual, em vez de mesclar branches empilhadas: primeiro documentação de execução manual; depois, se desejado, uma correção isolada de câmera/overflow sem plaintext temporário. Manter o portal e alarmes em espera até fechar suas decisões e gates. Em paralelo, preservar os blockers já registrados: finding CBC/MobSF, migração/backup Hive não implementados, signing/AAB de produção ausentes e validação física ainda não realizada.
