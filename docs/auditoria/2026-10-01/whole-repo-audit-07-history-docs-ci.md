# Auditoria 07 — histórico Git, documentação e CI/CD

**Data da revisão:** 01/10/2026\
**Modo:** leitura somente; sem alteração de branches remotas, regras do repositório, dados Supabase ou deploy.\
**Base consultada:** `origin/main` em `cc96eaf`, branch `audit/creator-privacy-alignment` em `84b976c` antes dos novos commits locais.\
**Escopo:** história alcançável em todas as refs, relação da branch de finalização com `main`, `AGENTS.md`, handoffs e workflows `.github/workflows/`.

## História e relação entre branches

A consulta encontrou **349 commits alcançáveis por todas as refs**; a história de `origin/main` contém 282 commits. O primeiro commit observado é `10d6f48` (30/08/2026), “Primeira versao do app Fala Comigo”; `origin/main` estava em `cc96eaf` (27/09/2026), “feat: preview Espaço do Criador (#86)”. Há múltiplas branches de trabalho e PRs antigas; os nomes de branch nos documentos históricos não descrevem necessariamente o checkout atual.

No snapshot revisado, `audit/creator-privacy-alignment` estava **5 commits à frente e 0 atrás** de `origin/main`, com base comum `cc96eaf`. O delta já commitado dessa PR abrangia 45 arquivos e era relativamente amplo para uma única PR (app, site, documentação, workflows/artefatos gerados e testes). A árvore de trabalho continha alterações adicionais ainda não incluídas nesse delta. A PR #87 estava em draft. Recomendação: manter a `main` intacta, revisar o delta tematicamente e nunca fazer force-push/rebase destrutivo; conferir a base novamente antes de atualizar ou integrar.

O inventário de `docs/` tinha 33 arquivos na raiz, além de históricos e handoffs com datas diferentes. Foram encontradas instruções antigas de branches/commits e descrições antigas da migração Hive. O início de `CONTINUAR_AQUI_PRIMEIRO.md`, `PROJECT_HANDOFF.md` e `docs/CONTINUIDADE_ASSISTENTE_IA.md` foi atualizado para apontar ao relatório vigente; seções datadas anteriores continuam como histórico, não como instrução operacional.

## Workflows observados

### Flutter quality checks (`flutter.yml`)

Executa em `push` para `main` e `feat/**` e em `pull_request` contra `main`. Instala Flutter 3.38.0, verifica `dart format`, roda `flutter analyze --no-fatal-infos --no-fatal-warnings`, aplica uma verificação textual para impedir fallback ao keystore debug, roda `flutter test` e compila Flutter Web. Não compila AAB nem APK Android em cada PR; também não roda a suíte Node do site.

### GitHub Pages (`site-pages.yml`)

Em `push` para `main` nos caminhos de site/app e em `pull_request` com caminhos semelhantes, executa `node --test`, compila Flutter Web com base `/fala-comigo/app/` e monta o artefato combinado site + `public/app/`. O job `deploy` é explicitamente ignorado em `pull_request`; publica em eventos diferentes de PR, com o fluxo efetivo esperado após push para `main` ou execução manual. Essa separação é apropriada para impedir publicação por uma PR não mesclada. Na consulta oficial de 01/10, homepage e política retornavam HTTP 200, enquanto a rota `/fala-comigo/app/` retornava 404, coerente com a PR ainda não mesclada.

### APK Android de teste (`android-test-apk.yml`)

É acionado por `workflow_dispatch`, cria uma keystore efêmera de teste, assina um **APK de teste**, verifica a assinatura e publica artefato por 14 dias. Não é assinatura de produção, nem caminho de AAB para loja. Os valores de assinatura são efêmeros do workflow e não devem ser reutilizados.

### MobSF (`mobsf-security-scan.yml`)

Também é acionado somente por `workflow_dispatch`. Cria APK de release **não produtivo** com keystore efêmera, sobe MobSF em Docker e publica relatórios como artefatos. Não é gate automático de PR. A imagem usa a tag móvel `latest`, o que reduz reprodutibilidade; a alteração para digest/tag fixa e a exigência de execução de scan antes do release devem ser avaliadas. Os achados do relatório MobSF existente precisam ser reexecutados sobre o estado atual.

## Achados operacionais e recomendações

1. **Merge protegido por evidências:** uma PR `CLEAN` não implica revisão funcional nem checks atuais. Várias PRs são stacked; respeitar dependências e conflitos, principalmente #77–#81. Os checks verdes da #83 pertenciam a um head antigo. Verificar novamente CI e base em cada PR.
2. **Cobertura CI incompleta:** Flutter PR CI aceita infos e warnings e não executa Node; o workflow Pages executa Node e build Web apenas quando os caminhos dele são afetados. A existência de workflows manuais de APK/MobSF não substitui um gate automatizado e reproduzível para release.
3. **Segurança fora do gate contínuo:** MobSF é manual e usa `latest`; não há evidência de scan pós-correção obrigatório. Reexecutar, revisar os findings e fixar versão/digest antes de classificar o aplicativo como pronto para release.
4. **Release Android:** não há keystore de produção no checkout (`android/key.properties` está ausente e segredos não devem ser adicionados ao Git). O workflow do APK de teste não resolve a assinatura de distribuição. AAB assinado permanece bloqueado por credencial segura e fluxo de release.
5. **Documentos versionados:** manter um resumo atual datado; não sobrescrever históricos de setembro. Vincular handoffs ao relatório vigente e rotular snapshots antigos para evitar execução de instruções obsoletas.
6. **Publicação Web:** a rota gerada é tecnicamente compilável e o job de deploy está separado dos PRs; ainda falta merge autorizado, CI no head final e validação pós-publicação do domínio permanente.

## Conclusão

Este setor foi coberto manualmente após o job especialista correspondente não concluir. O relatório completa a leitura documental/histórica local, mas não transforma a revisão das PRs em completa: a auditoria independente de PR registrou **7 de 15** pareceres concluídos na rodada inicial, e agora há 16 PRs abertas incluindo a #87. Use este documento junto aos seis relatórios temáticos em `docs/auditoria/2026-09-29/` e ao estado vigente em `docs/STATUS_PROJETO_E_PENDENCIAS_2026-10-01.md`.
