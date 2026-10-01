# Fala Comigo — progresso da auditoria e PRs

**Verificado em:** 29/09/2026, aproximadamente 04:20–04:28 (EDT)\
**Repositório:** [falacomigocaa-app/fala-comigo](https://github.com/falacomigocaa-app/fala-comigo) — público.\
**Limite:** leitura de GitHub e auditoria local; nenhum merge, push, publicação ou alteração de dados no Supabase foi feito nesta fotografia.

## Branches e PRs

A lista consultada pelo `gh pr list --state open` retornou **15 PRs abertas**. A mergeabilidade abaixo é somente a fotografia do GitHub naquele horário e pode mudar.

| PR | Título curto | Base | Estado observado | URL |
|---:|---|---|---|---|
| 31 | Protótipos da área parental | `feat/parental-dashboard-reliability` | MERGEABLE/CLEAN; stack | https://github.com/falacomigocaa-app/fala-comigo/pull/31 |
| 32 | Dashboard parental opção A | `feat/parental-dashboard-reliability` | MERGEABLE/CLEAN; stack | https://github.com/falacomigocaa-app/fala-comigo/pull/32 |
| 33 | Sistema visual profissional parental | `feat/parental-area-option-a` | MERGEABLE/UNSTABLE; stack | https://github.com/falacomigocaa-app/fala-comigo/pull/33 |
| 53 | Planilha de execução manual de fluxos | `main` | CONFLICTING/DIRTY | https://github.com/falacomigocaa-app/fala-comigo/pull/53 |
| 60 | Diagnóstico de falha de inicialização | `main` | CONFLICTING/DIRTY; draft | https://github.com/falacomigocaa-app/fala-comigo/pull/60 |
| 61 | Rebuild de APK debug da baseline | `main` | MERGEABLE/CLEAN | https://github.com/falacomigocaa-app/fala-comigo/pull/61 |
| 64 | Protocolo de continuidade para agentes | `main` | CONFLICTING/DIRTY | https://github.com/falacomigocaa-app/fala-comigo/pull/64 |
| 65 | Renderizar antes do bootstrap local | `recovery/pr29-with-current-web` | MERGEABLE/CLEAN; base não-main | https://github.com/falacomigocaa-app/fala-comigo/pull/65 |
| 68 | Organização de handoff/continuidade | `main` | CONFLICTING/DIRTY | https://github.com/falacomigocaa-app/fala-comigo/pull/68 |
| 77 | Arquitetura independente do portal | `main` | CONFLICTING/DIRTY | https://github.com/falacomigocaa-app/fala-comigo/pull/77 |
| 78 | API sintética do portal/PostgreSQL | `docs/record-option-a-public-url` | MERGEABLE/CLEAN; stack de #77 | https://github.com/falacomigocaa-app/fala-comigo/pull/78 |
| 79 | Câmera de cartões e overflow parental | `main` | CONFLICTING/DIRTY | https://github.com/falacomigocaa-app/fala-comigo/pull/79 |
| 80 | Alertas como despertador Android | `main` | CONFLICTING/DIRTY | https://github.com/falacomigocaa-app/fala-comigo/pull/80 |
| 81 | Consentimento e grants sintéticos | `main` | CONFLICTING/DIRTY | https://github.com/falacomigocaa-app/fala-comigo/pull/81 |
| 83 | Navegação acessível/responsiva do site | `main` | CONFLICTING/DIRTY | https://github.com/falacomigocaa-app/fala-comigo/pull/83 |

### Pareceres especialistas já concluídos

- **PR #83:** head `58b27e3` tem checks verdes antigos (27/09) e está baseado em main antigo; GitHub e `git merge-tree` indicaram conflitos em handoffs. O validador da PR não checa âncoras apenas com fragmento e não cobre `site/console-preview.html`. Não foi mesclada. Parecer completo: `/home/ubuntu/.manus-jobs/670963b09cbc_a0/output.txt`.
- **PR #80:** head `14f486b` está conflitando/atrás de main; seu último check falhou no build Web devido ao argumento `extensionHint` divergente. A stack mistura alertas, câmera, documentação e API sintética. O comportamento de alarmes/full-screen e permissões precisa de validação em aparelho real; há riscos de estado agendado inconsistente após falha e de API sem autenticação/tenant/RLS. Não foi mesclada. Parecer: `/home/ubuntu/.manus-jobs/670963b09cbc_a2/output.txt`.
- **PR #81:** head `f261607` está DIRTY e herda a stack #77–#80; o build Web reportado falhou. A API em memória permite caminho de escalada de papel `owner`, validação insuficiente de escopos/consentimentos e grants sem verificação completa de vínculo/tenant; não há autenticação, persistência/isolamento de produção, RLS ou CI abrangente. Não deve ser publicada nem integrada sem hardening e revisão. Parecer: `/home/ubuntu/.manus-jobs/670963b09cbc_a1/output.txt`.

O SHA `main` registrado pelos pareceres foi `cc96eaf4582d1f08b7cd32684b6f12b78dbb59b4`; confirmar novamente antes de rebase/push/merge. Sem branch protection/regras obrigatórias reportadas na consulta de #83; checks precisam ser revalidados no head atual.

## Supabase

A auditoria anterior consultou somente metadados/listas de projetos, tabelas e migrations por meio do conector. Nenhuma linha de usuário foi lida e **nenhum DDL/DML, migration ou alteração remota** foi executada. O resultado observado foi ausência de esquema operacional para o portal; confirmar novamente antes de projetar uma conexão.

## Trabalho local ainda não publicado

Checkout ativo: `/home/ubuntu/fala-comigo`, branch `audit/creator-privacy-alignment`. Há alterações locais não commitadas em Flutter, site, testes e documentação. Os testes e builds locais foram executados nesta sessão, mas esse checkout não foi enviado ao GitHub nesta fotografia. O GitHub Pages permanente existente é https://falacomigocaa-app.github.io/fala-comigo/; publicar qualquer atualização exige merge/push no repositório e verificação pós-deploy.

Os novos relatórios locais da auditoria integral ficam em `/home/ubuntu/reports/whole-repo-audit-*.md`; eles não substituem revisão de segurança externa nem teste em aparelho real.
