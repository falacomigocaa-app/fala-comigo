# Fala Comigo — estado após publicação da prévia Web

**Atualizado:** 04/10/2026 — triagem inicial das PRs
**Repositório:** `falacomigocaa-app/fala-comigo` (público)
**Base observada:** `main` no commit `b08daa10d2314ea56fd079d07378fbcabe4e4335` (PRs #87–#90 integradas).
**Etapa Hive/segurança:** PR #89 foi squash-merged em `21a981f`; CI confirmou 110 testes, análise e build Web. PR #90 integrou o relatório sanitizado e a correção do resumo MobSF em `b08daa1`. MobSF no run [37142972414](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/37142972414) concluiu com score 46/100, achados altos CBC/PKCS5/PKCS7 e `minSdk=24`; relatório em [`docs/auditoria/2026-10-03/MOBSF_MAIN_21A981F.md`](auditoria/2026-10-03/MOBSF_MAIN_21A981F.md). Migração Hive e backup exportável continuam desativados/não implementados; o achado CBC permanece aberto.

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
- O workflow MobSF foi ajustado pela PR #90 integrada: o resumo usa os campos aninhados e o artifact evita publicar o relatório JSON/PDF bruto. A futura execução do scan ainda deve ser inspecionada; a correção não significa que os findings foram resolvidos.

### Ainda não é release completo

1. **Migração Hive legada:** a migração automática permanece desativada deliberadamente para evitar perda/corrupção. Snapshot/rollback do arquivo não é backup do usuário. Não instalar/atualizar sobre dispositivo com dados importantes sem plano de migração, backup/restauração e rollback testados.
2. **Android:** o artefato local conhecido é um APK Debug de 01/10, não AAB de distribuição. Keystore de produção e `android/key.properties` não estão configurados no repositório/ambiente; nunca adicionar esses segredos ao Git.
3. **Dispositivos físicos:** nenhum teste real foi realizado. O proprietário planejou essa etapa após a conclusão técnica.
4. **Segurança:** o scan MobSF atual de `21a981f` encontrou CBC/PKCS5/PKCS7 em classe Java ofuscada, `minSdk=24` e warnings de receiver, strings candidatas, arquivos temporários e armazenamento externo. `flutter_secure_storage 9.2.4` usa CBC por default no Android e `Hive 2.2.3` também implementa `HiveAesCipher` CBC; a classe exata do finding não foi mapeada. Nenhum dos dois caminhos está remediado. Não houve reauditoria independente integral.
5. **Portal/backend:** não há Auth, autorização server-side, isolamento por organização ou RLS de produção; demos estáticas/sintéticas não são um serviço conectado.
6. **Web:** mídia personalizada e capacidades nativas não são equivalentes às do Android; armazenamento do browser não deve ser tratado como cofre validado para dados sensíveis.
7. **Validação humana/acessibilidade:** o smoke de navegador não substitui validação com famílias/profissionais, TalkBack/VoiceOver, offline e permissões reais.

## Auditoria e PRs restantes

Em 04/10, seis PRs antigas foram encerradas sem merge: #31–33 porque suas pontas já eram ancestrais da `main`; #60 e #65 porque o bootstrap atual as substitui; #61 porque era uma baseline PR29 obsoleta. As branches foram preservadas. Permanecem abertas **nove PRs: #53, #64, #68, #77, #78, #79, #80, #81 e #83**. O relatório de diffs, checks, conflitos, dependências e recomendações está em [`docs/auditoria/2026-10-04/AUDITORIA_PR_ABERTAS.md`](auditoria/2026-10-04/AUDITORIA_PR_ABERTAS.md). O workflow de análise paralela não entregou pareceres por PR; esta etapa é uma triagem manual, não revisão exaustiva ou aprovação de release.

## Próximos passos recomendados

1. Continuar a revisão profunda das nove PRs abertas conforme o relatório; revalidar cada head/base/check e não integrar stacks em bloco.
2. Priorizar riscos que possam interromper a comunicação CAA ou afetar privacidade/dados locais; corrigir em branch com testes.
3. Rebasear seletivamente a ficha manual #53; avaliar #64/#68/#77 como documentação. Não publicar o contato proposto em #68 sem confirmação explícita.
4. Desenhar e testar migração em etapas do armazenamento seguro e das boxes Hive para remover CBC sem perder a chave ou dados; preservar backup/rollback e usar somente fixtures sintéticas.
5. Remediar/triagem os achados MobSF, revisar os warnings e reexecutar scan no candidato corrigido; avaliar `minSdk` como escolha de suporte, não elevar para 29 automaticamente.
6. Depois de fechar os gates técnicos, preparar signing seguro fora do Git e AAB; então coordenar os testes em aparelhos reais conforme o plano do proprietário.
7. Corrigir separadamente #79 antes de considerar #80/#81: o CI aponta incompatibilidade `extensionHint` no Web, e a chamada `materializeForReading` descartada cria arquivo plaintext temporário sem liberação.
8. Manter a prévia Web sinalizada como pré-lançamento e limitada a dados sintéticos; #83 altera conteúdo público e precisa de autorização antes do merge/deploy; não anunciar backend/portal como funcional.

## Instruções de continuidade

Use [`PROMPT_RETORNO_NOVO_AGENTE.md`](../PROMPT_RETORNO_NOVO_AGENTE.md) como prompt copiável e [`CONTINUAR_AQUI_PRIMEIRO.md`](../CONTINUAR_AQUI_PRIMEIRO.md) como leitura inicial. Este relatório foi atualizado em 04/10/2026; revalide branch, PRs, checks e URLs no GitHub antes de nova ação.
