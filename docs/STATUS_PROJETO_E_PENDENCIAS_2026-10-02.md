# Fala Comigo — estado após publicação da prévia Web

**Atualizado:** 04/10/2026
**Repositório:** `falacomigocaa-app/fala-comigo` (público)
**Base observada:** `main` no commit `21a981f` (PRs #87, #88 e #89 integradas); branch de documentação corrente `docs/record-hive-safety-merge`.
**Etapa Hive/segurança:** PR [#89](https://github.com/falacomigocaa-app/fala-comigo/pull/89) foi squash-merged em `21a981f`; CI confirmou 110 testes, análise e build Web. MobSF no run [37142972414](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/37142972414) concluiu com score 46/100, achados altos CBC/PKCS5/PKCS7 e `minSdk=24`; relatório sanitizado em [`docs/auditoria/2026-10-03/MOBSF_MAIN_21A981F.md`](auditoria/2026-10-03/MOBSF_MAIN_21A981F.md). Migração automática Hive e backup exportável continuam desativados/não implementados. O achado CBC permanece aberto.

## Resumo executivo

A PR [#87 — Finalize privacy, caregiver plans, and Flutter Web Pages route](https://github.com/falacomigocaa-app/fala-comigo/pull/87) foi marcada como pronta e squash-merged em `main` em 02/10/2026, no commit `43afb5c34b5c6ca7a2b05bb049dd8c1edb901b81`. A PR integrou 69 arquivos (+4.261/−1.099), incluindo mudanças de app, privacidade, site, testes e documentação.

O workflow do GitHub Pages executou para esse commit e os jobs `build` e `deploy` concluíram com sucesso. **O site institucional e a prévia Flutter Web estão publicados** nos endereços permanentes abaixo. Isso não equivale a lançamento comercial, prontidão clínica ou autorização para inserir dados reais.

## Evidências verificadas

- GitHub Pages — [workflow de build/deploy, run 37029707742](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/37029707742): conclusão `success`; jobs `build` e `deploy` bem-sucedidos.
- Flutter quality — [run 37029707714](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/37029707714): conclusão `success` no commit de merge.
- Respostas GET verificadas: homepage `/`, app `/app/`, política `/privacy.html` e `/app/main.dart.js` retornaram HTTP 200.
- HTML publicado: link “Abrir prévia Web” presente na homepage, base href `/fala-comigo/app/` no Flutter Web e aviso de uso de dados sintéticos na política.
- Smoke visual/interativo remoto: a interface Flutter carregou com categorias e cartões; o console do navegador não retornou mensagens; ao selecionar o cartão sintético “Comer”, ele apareceu na frase e o botão “Falar” foi habilitado. Isto é apenas um smoke test no navegador, não teste físico, de acessibilidade abrangente ou de todos os fluxos.

## Endereços oficiais

- Site institucional: <https://falacomigocaa-app.github.io/fala-comigo/>
- Prévia Flutter Web: <https://falacomigocaa-app.github.io/fala-comigo/app/>
- Política: <https://falacomigocaa-app.github.io/fala-comigo/privacy.html>

A rota `/app/` é acessível publicamente, sem login. O app Web trabalha com armazenamento local no navegador e não tem backend, autenticação ou sincronização conectada. **Usar somente dados sintéticos**; não inserir dados de crianças, saúde, diagnósticos, fotos, vídeos ou informações identificáveis.

## Situação técnica e limites

### Concluído nesta etapa

- PR #87 integrada; workflow de produção do Pages publicado com sucesso.
- Verificados os caminhos essenciais e a interação primária com um cartão padrão sintético.
- PR #89 integrada, com guarda para chave Hive ausente; migração continua deliberadamente desativada.
- Scan MobSF executado e triado; o resultado identificou achados altos e dívida criptográfica, não aprovação de release.
- O workflow MobSF está sendo corrigido na branch documental para resumir os campos aninhados e evitar publicar relatório JSON/PDF bruto nos próximos artifacts. A alteração aguarda nova CI.

### Ainda não é release completo

1. **Migração Hive legada:** a migração automática permanece desativada deliberadamente para evitar perda/corrupção. Snapshot/rollback do arquivo não é backup do usuário. Não instalar/atualizar sobre dispositivo com dados importantes sem plano de migração, backup/restauração e rollback testados.
2. **Android:** o artefato local conhecido é um APK Debug de 01/10, não AAB de distribuição. Keystore de produção e `android/key.properties` não estão configurados no repositório/ambiente; nunca adicionar esses segredos ao Git.
3. **Dispositivos físicos:** nenhum teste real foi realizado. O proprietário planejou essa etapa após a conclusão técnica.
4. **Segurança:** o scan MobSF atual de `21a981f` encontrou CBC/PKCS5/PKCS7 em classe Java ofuscada, `minSdk=24` e warnings de receiver, strings candidatas, arquivos temporários e armazenamento externo. `flutter_secure_storage 9.2.4` usa CBC por default no Android e `Hive 2.2.3` também implementa `HiveAesCipher` CBC; a classe exata do finding não foi mapeada. Nenhum dos dois caminhos está remediado. Não houve reauditoria independente integral.
5. **Portal/backend:** não há Auth, autorização server-side, isolamento por organização ou RLS de produção; demos estáticas/sintéticas não são um serviço conectado.
6. **Web:** mídia personalizada e capacidades nativas não são equivalentes às do Android; armazenamento do browser não deve ser tratado como cofre validado para dados sensíveis.
7. **Validação humana/acessibilidade:** o smoke de navegador não substitui validação com famílias/profissionais, TalkBack/VoiceOver, offline e permissões reais.

## Auditoria e PRs restantes

A revisão de PRs registrada anteriormente é parcial: o parecer comparável original cobriu 7 de 15 subrevisões. O inventário read-only de 04/10 confirmou 15 PRs de produto ainda abertas: **#83, #81, #80, #79, #78, #77, #68, #65, #64, #61, #60, #53, #33, #32 e #31**, além da PR documental #90 nesta branch. Uma tentativa anterior de auditoria em workflow não gerou pareceres por PR; não tratar esse ciclo como auditoria concluída. Atualizar heads, bases, checks e mergeabilidade antes de qualquer decisão.

## Próximos passos recomendados

1. Atualizar refs e inventário das PRs abertas; revisar cada diff, head/base, checks, conflitos e dependências, sem integrar stacks em bloco.
2. Priorizar riscos que possam interromper a comunicação CAA ou afetar privacidade/dados locais; corrigir em branch com testes.
3. Fechar a auditoria individual das PRs restantes e selecionar mudanças seguras para revisão/merge item a item, sem agrupar stacks.
4. Desenhar e testar migração em etapas do armazenamento seguro e das boxes Hive para remover CBC sem perder a chave ou dados; preservar backup/rollback e usar somente fixtures sintéticas.
5. Remediar/triagem os achados MobSF, revisar os warnings e reexecutar scan no candidato corrigido; avaliar `minSdk` como escolha de suporte, não elevar para 29 automaticamente.
6. Depois de fechar os gates técnicos, preparar signing seguro fora do Git e AAB; então coordenar os testes em aparelhos reais conforme o plano do proprietário.
7. Manter a prévia Web sinalizada como pré-lançamento e limitada a dados sintéticos; não anunciar backend/portal como funcional.

## Instruções de continuidade

Use [`PROMPT_RETORNO_NOVO_AGENTE.md`](../PROMPT_RETORNO_NOVO_AGENTE.md) como prompt copiável e [`CONTINUAR_AQUI_PRIMEIRO.md`](../CONTINUAR_AQUI_PRIMEIRO.md) como leitura inicial. Este relatório foi atualizado em 04/10/2026; revalide branch, PRs, checks e URLs no GitHub antes de nova ação.
