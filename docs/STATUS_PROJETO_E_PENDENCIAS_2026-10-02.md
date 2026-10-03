# Fala Comigo — estado após publicação da prévia Web

**Atualizado:** 03/10/2026
**Repositório:** `falacomigocaa-app/fala-comigo` (público)
**Base observada:** `main` no commit `174ba5d` (PR #87 e PR documental #88 integradas)
**Trabalho em andamento:** branch `fix/refuse-missing-hive-key`, baseada em `174ba5d`; guarda fail-closed, testes sintéticos incluindo limpeza dos snapshots no wipe explícito e plano Hive. Ainda não está na `main`; migração automática continua desativada.

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
- Handoffs e prompt mestre precisam ser sincronizados com a publicação (esta atualização documental).

### Ainda não é release completo

1. **Migração Hive legada:** a migração automática permanece desativada deliberadamente para evitar perda/corrupção. Snapshot/rollback do arquivo não é backup do usuário. Não instalar/atualizar sobre dispositivo com dados importantes sem plano de migração, backup/restauração e rollback testados.
2. **Android:** o artefato local conhecido é um APK Debug de 01/10, não AAB de distribuição. Keystore de produção e `android/key.properties` não estão configurados no repositório/ambiente; nunca adicionar esses segredos ao Git.
3. **Dispositivos físicos:** nenhum teste real foi realizado. O proprietário planejou essa etapa após a conclusão técnica.
4. **Segurança:** não há scan MobSF atualizado após as mudanças mais recentes nem reauditoria independente integral pós-correções.
5. **Portal/backend:** não há Auth, autorização server-side, isolamento por organização ou RLS de produção; demos estáticas/sintéticas não são um serviço conectado.
6. **Web:** mídia personalizada e capacidades nativas não são equivalentes às do Android; armazenamento do browser não deve ser tratado como cofre validado para dados sensíveis.
7. **Validação humana/acessibilidade:** o smoke de navegador não substitui validação com famílias/profissionais, TalkBack/VoiceOver, offline e permissões reais.

## Auditoria e PRs restantes

A revisão de PRs registrada anteriormente é parcial: o parecer comparável original cobriu 7 de 15 subrevisões. O inventário read-only de 03/10, depois da merge da #88, confirmou 15 PRs abertas: **#83, #81, #80, #79, #78, #77, #68, #65, #64, #61, #60, #53, #33, #32 e #31**. Uma tentativa de auditoria em workflow não gerou pareceres por PR; não tratar este ciclo como auditoria concluída. Atualizar heads, bases, checks e mergeabilidade antes de qualquer decisão.

## Próximos passos recomendados

1. Atualizar refs e inventário das PRs abertas; revisar cada diff, head/base, checks, conflitos e dependências, sem integrar stacks em bloco.
2. Priorizar riscos que possam interromper a comunicação CAA ou afetar privacidade/dados locais; corrigir em branch com testes.
3. Definir desenho e testes de migração/restauração Hive antes de reativar migração automática.
4. Reexecutar MobSF e revisar findings com base no código atual.
5. Depois da conclusão técnica, preparar signing seguro fora do Git e AAB; então coordenar os testes em aparelhos reais conforme o plano do proprietário.
6. Manter a prévia Web sinalizada como pré-lançamento e limitada a dados sintéticos; não anunciar backend/portal como funcional.

## Instruções de continuidade

Use [`PROMPT_RETORNO_NOVO_AGENTE.md`](../PROMPT_RETORNO_NOVO_AGENTE.md) como prompt copiável e [`CONTINUAR_AQUI_PRIMEIRO.md`](../CONTINUAR_AQUI_PRIMEIRO.md) como leitura inicial. O estado precisa ser revalidado no GitHub antes de nova ação: este relatório é um snapshot de 02/10/2026, não uma garantia de que branches, PRs ou URLs permanecerão inalterados.
