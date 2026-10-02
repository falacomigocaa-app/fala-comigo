# Relatórios de auditoria — fotografia de 29/09/2026

Os relatórios desta pasta são as saídas especialistas preservadas do checkout local auditado em 29/09/2026. Eles analisam seis áreas: app Flutter, código nativo, Flutter Web, site público, backend/portal e segurança.

**Cobertura incompleta:** o job amplo encerrou após 6 de 7 setores; o setor pendente era **histórico desde o primeiro commit, documentação e CI**. A revisão das PRs foi registrada como 7 de 15 itens concluídos; os demais pareceres não foram produzidos. O snapshot de PRs é antigo: havia 15 PRs na rodada; a PR #87 foi aberta posteriormente e não fazia parte daquela revisão.

> Complementação posterior: o setor pendente foi coberto manualmente em 01/10/2026. Ver [o relatório de Git, documentação e CI](../2026-10-01/whole-repo-audit-07-history-docs-ci.md); os pareceres independentes das PRs permanecem parciais.

Os achados sobre migração Hive e temporários de mídia são históricos em relação às correções locais descritas em `../../STATUS_PROJETO_E_PENDENCIAS_2026-10-01.md`. As correções passaram por regressões locais, mas os pareceres **não foram reexecutados** e não constituem aprovação independente pós-correção. Em particular, não substituem uma nova análise MobSF, testes em aparelho ou a conclusão da revisão item a item das PRs.

Arquivos:

- `whole-repo-audit-01-app.md`
- `whole-repo-audit-02-native.md`
- `whole-repo-audit-03-flutter-web.md`
- `whole-repo-audit-04-public-site.md`
- `whole-repo-audit-05-latest-backend.md`
- `whole-repo-audit-06-security.md`
- `fala-comigo-audit-progress-2026-09-29.md`
- `fala-comigo-open-pr-review-2026-09-28.md`
