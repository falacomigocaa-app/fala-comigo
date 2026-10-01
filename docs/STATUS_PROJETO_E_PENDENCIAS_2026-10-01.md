# Fala Comigo — situação da finalização

**Data do relatório:** 01/10/2026\
**Checkout:** `/home/ubuntu/fala-comigo`\
**Branch de trabalho:** `audit/creator-privacy-alignment`\
**PR de finalização:** [#87 — Finalize privacy, caregiver plans, and Flutter Web Pages route](https://github.com/falacomigocaa-app/fala-comigo/pull/87)\
**Escopo deste relatório:** estado técnico local e remoto observado; não representa aprovação de release nem publicação.

## Resumo executivo

A base local compila para Flutter Web e APK Android Debug. A análise estática e as suítes locais passaram, e foram corrigidos riscos importantes de perda de dados Hive, temporários de mídia e exclusão local. O site institucional já está publicado permanentemente no GitHub Pages.

**O projeto ainda não está pronto para distribuição pública nem para uso com dados reais.** A rota oficial `/fala-comigo/app/` ainda responde 404; a alteração que a prepara está na PR #87, que permanece em rascunho. Não houve merge nem deploy. A assinatura de produção não está configurada, a migração de boxes antigas foi intencionalmente desativada e ainda não há validação em dispositivos físicos.

## Validação técnica concluída

| Verificação | Resultado |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | passou |
| `flutter analyze --no-pub` | **No issues found** |
| `flutter test --no-pub` | **106 testes passaram** |
| `node --test tests/*.test.mjs` | **13 testes passaram** |
| `git diff --check` | passou após as atualizações documentais |
| `flutter build web --release --no-pub --base-href /fala-comigo/app/` | concluído; avisos de dependências no dry-run WebAssembly, sem falha no alvo JavaScript |
| `flutter build apk --debug --no-pub` | concluído; APK verificado com `apksigner`, assinatura v2 de debug |
| Preview combinado sandbox | HTTP 200 para site, `/app/` e `main.dart.js`; interface principal renderizada e console sem erros após o bootstrap |
| GitHub Pages oficial | homepage e política respondem 200; `/fala-comigo/app/` responde **404** |

### Artefatos locais verificados

- **APK Android Debug:** `/home/ubuntu/artifacts/Fala_Comigo_debug_2026-10-01.apk` — pacote `com.falacomigo.fala_comigo`, versão `1.0.0`, minSdk 24, targetSdk 36, assinatura v2 de debug. SHA-256: `6ba63c089db99b1d4237acc8052479df0074c61b33caf97d09c7aa17782c21a5`.
- **Pacote Flutter Web:** `/home/ubuntu/artifacts/Fala_Comigo_flutter_web_2026-10-01.zip` — build com base href `/fala-comigo/app/`, arquivo ZIP íntegro. SHA-256: `3d2bb13296c32a337eb1d3ddac78c20429c3f2d9634415be00c575ef6e22a7b3`.
- **Manual PDF:** `/home/ubuntu/artifacts/Manual_do_Usuario_Fala_Comigo_2026-10-01.pdf` — 6 páginas A4, gerado da versão 1.1 do Markdown. SHA-256: `1d6970b3c8f6445b875089cc94e2d2d9dbb0ea65e15a2b58567266361150e5b5`.

O preview combinado temporário desta sessão está em: <https://4176-ijwj8rsnu6oknbsn37ldj-36a4ebfd.us4.manus.computer/fala-comigo/>. Ele não é o domínio permanente do produto e não substitui a publicação no GitHub Pages.

## Correções técnicas locais nesta branch

- **Hive/dados locais:** removido o fallback de migração automática que poderia apagar ou substituir uma box legada após erro de chave/corrupção. A abertura atual falha fechada e, em plataformas nativas, preserva snapshot e tenta rollback antes de propagar erro. Há testes para box plaintext, chave divergente e abertura válida.
- **Mídia privada:** leitura de imagens em memória, sem cache temporário permanente descriptografado; arquivos materializados para leitura/compartilhamento têm liberação explícita, cleanup e limpeza de resíduos nativos. O Web continua sem suporte de mídia personalizada.
- **Apagar todos os dados:** inclui `parent_reminders`, invalida credenciais locais e tenta cancelar notificações; se o plugin falhar, a exclusão local continua e a interface informa que uma notificação genérica pode persistir.
- **Portal e site:** conteúdo público distingue prévia/demonstração de serviço real, controles fictícios estão desabilitados e a política de privacidade explicita limitações da Web.
- **Manual:** versão 1.1 alerta que a migração automática de boxes antigas está desativada e que esta build não deve substituir uma instalação com dados importantes.

Estas correções passaram pelos testes locais descritos acima. Isso **não** equivale a uma nova auditoria independente completa, a um scan MobSF atualizado ou a teste de penetração.

## Auditoria integral: cobertura parcial, não sign-off

Os seis relatórios especialistas concluídos em 29/09 cobrem app Flutter, projetos nativos, Flutter Web, site público, backend/portal e segurança. Os documentos originais foram preservados em [`docs/auditoria/2026-09-29/`](auditoria/2026-09-29/). O job especialista parou após 6/7 setores; o sétimo setor (**histórico desde o primeiro commit, documentação e CI**) foi coberto manualmente em 01/10 e está em [`docs/auditoria/2026-10-01/whole-repo-audit-07-history-docs-ci.md`](auditoria/2026-10-01/whole-repo-audit-07-history-docs-ci.md). Assim, os sete temas têm documentação, mas apenas os seis primeiros são pareceres de especialistas e não houve reauditoria independente de todas as correções recentes.

A revisão comparável das PRs cobriu **7 de 15 PRs** na rodada original; oito subrevisões não terminaram. Desde então existe também a PR #87, portanto o inventário remoto observado passou a **16 PRs abertas**. Os relatórios temáticos originais são uma fotografia anterior às correções locais deste branch; não se deve tratá-los como reauditoria pós-correção.

Achados que continuam relevantes como gates:

- não existe backend/autenticação/autorização server-side para portal ou sincronização; os painéis e registros compartilhados são protótipos locais/estáticos;
- findings anteriores do MobSF e controles de sessão/privacidade precisam de scan e validação atualizados antes de release;
- compatibilidade/migração de instalações legadas ainda não está implementada;
- testes de dispositivos, acessibilidade real e permissões Android ainda não foram executados.

## PRs e integração

A PR #87 está em **draft**. O workflow configura a futura rota `/fala-comigo/app/` e evita deploy em `pull_request`. A lista remota observada em 30/09 continha 16 PRs; vários itens tinham estado `DIRTY` ou `UNSTABLE`. Em especial, a stack de mudanças Web/portal não pode ser integrada em bloco: requer revisão das dependências e resolução de conflitos. Nenhuma PR foi mesclada nesta etapa.

No head `aced191`, os checks do GitHub passaram: Flutter quality e Pages build bem-sucedidos, deploy do Pages ignorado por ser `pull_request`, sem falhas. O commit documental desta rodada deve acionar novos checks; verificar novamente a ponta final.

Fotografia do `mergeStateStatus` do GitHub em 30/09 (estado de conflito/mergeabilidade, não aprovação funcional): **CLEAN** — #31, #32, #61, #65, #78 e #87 (a #87 em draft); **DIRTY** — #53, #60, #64, #68, #77, #79, #80, #81 e #83; **UNSTABLE** — #33. A #78 está empilhada sobre a #77 e não deve ser considerada isoladamente; estados e checks precisam ser consultados novamente após o push.

Os pareceres já concluídos registraram que os heads então examinados de #80 e #81 falhavam o build Web por `extensionHint` incompatível; a #81 também contém um portal sintético em memória sem autenticação, tenant ou RLS de produção. O head antigo de #83 tinha checks verdes, mas estava atrás da `main` e conflitava. A compilação local atual do branch de finalização passou; isso **não** atualiza nem valida os heads dessas PRs.

Os commits de segurança e site `e0a58e7` e `aced191` foram enviados à branch da PR #87 e os checks desse head passaram. Os relatórios e handoffs estão organizados em um commit documental separado nessa mesma branch; verificar a CI reacionada após sincronização. Manter a PR em draft até fechar os gates e revisar o payload público final.

## Bloqueios para release/publicação

1. **Migração Hive:** desativada para evitar perda de dados. Não atualizar por cima de instalação com dados importantes até existir migração testada, backup/restauração validado e plano de rollback.
2. **Assinatura Android:** `android/key.properties` e keystore de produção ausentes. O APK entregue é somente Debug; não foi gerado AAB assinado para loja.
3. **Flutter Web no Pages:** o site institucional continua no ar, mas a rota `/app/` ainda não foi implantada (responde 404). O deploy requer merge/CI e confirmação final do conteúdo que ficará público.
4. **Dados reais e segurança:** não usar esta build com dados reais de saúde/crianças; atualizar MobSF e completar revisão independente dos achados restantes.
5. **Portal/backend:** não anunciar como colaboração ou sincronização funcional; faltam Auth, isolamento por organização, autorização, transporte e RLS.
6. **Hardware:** testes físicos e validação humana permanecem para a etapa posterior definida pelo responsável.

## Próximos passos seguros

1. Confirmar que os commits temáticos e o commit documental estão visíveis na PR #87; verificar os checks do head mais recente.
2. Completar ou obter autorização para retomar as auditorias incompletas; rever individualmente conflitos/dependências das 16 PRs e integrar somente mudanças compatíveis e testadas.
3. Planejar migração/backup de boxes antigas e reexecutar scan de segurança.
4. Configurar keystore de produção fora do Git e gerar/testar AAB de release.
5. Antes do merge que ativa mudanças públicas e do deploy do Pages, obter confirmação sobre o payload exato (conteúdo do site, política e rota do app).
6. Só então iniciar a etapa de testes em aparelhos físicos, como solicitado pelo proprietário.
