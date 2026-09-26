# Auditoria Git e continuidade — Fala Comigo

**Data da auditoria:** 25/09/2026  
**Escopo:** estado real do Git, comparação da `main` com branches/PRs relevantes e contradições documentais relativas à decisão atual **Opção A**.  
**Decisão vigente informada pelo proprietário para esta tarefa:** manter o site/interface no GitHub Pages; iniciar backend e banco em camadas gratuitas, independentes do Manus; migrar para planos pagos apenas quando necessário.  
**Limite da execução:** auditoria somente. Nenhum código de produção, branch ou PR foi alterado; nenhum commit, publicação, credencial ou dado real foi criado/usado. Este relatório é o único arquivo novo desta tarefa.

**Nota sobre o workspace compartilhado:** o snapshot inicial desta auditoria estava em `main` limpa, conforme abaixo. Na verificação final, o workspace já aparecia em `docs/record-option-a-public-url`, com alterações em `CONTINUAR_AQUI_PRIMEIRO.md`, `PROMPT_RETORNO_NOVO_AGENTE.md` e `docs/CONTINUIDADE_ASSISTENTE_IA.md`, além deste diretório de relatório. Essas mudanças alheias ao arquivo deste relatório não foram feitas nem atribuídas por esta auditoria; revisar seu diff antes de preservar ou descartar.

## Conclusão executiva

O checkout estava sincronizado e limpo antes da criação deste relatório: branch local `main`, `HEAD` e `origin/main` no commit `b43e18b` (`Merge pull request #76 from falacomigocaa-app/docs/creator-no-manus`), sem commits locais à frente/atrás e sem alterações de trabalho. `git fetch origin --prune` atualizou as referências remotas. O merge da PR #76 já está na `main`; porém, seu conteúdo registra que a escolha A/B/C ainda está pendente. O estado do Git, portanto, está claro, mas a documentação de continuidade não foi atualizada para refletir a decisão de Opção A comunicada nesta tarefa.

Há conflitos de continuidade que bloqueiam uma retomada segura: vários documentos continuam mandando esperar uma escolha A/B/C; o site publicado ainda contém um link para o Criador no Manus Space; o handoff trata a página pública como não definitiva embora ela tenha sido publicada; e branches/PRs antigos preservam instruções e conteúdo superados. Em particular, a PR #68 está aberta, `DIRTY`, baseada numa `main` antiga e conflita textualmente com a `main` atual em dois documentos; sua versão do site também propõe outro endereço Manus temporário. **Não mesclar a PR #68 nem a PR #64 como estão.**

Além do conflito documental, há um ponto de arquitetura que requer reconciliação antes de implementar login: a documentação oficial do GitHub descreve Pages como hospedagem estática e diz que Pages não deve ser usado para transações sensíveis como envio de senhas, nem como hospedagem gratuita de site primariamente destinado a SaaS. Assim, a decisão “site/interface no Pages” não deve ser interpretada como hospedar nele uma tela que colete/envie a senha do Criador ou como tornar o portal SaaS uma aplicação Pages. A configuração mais segura a avaliar é manter a página pública institucional no Pages e servir o login/portal autenticado em origem independente, com backend e banco independentes, deixando no Pages apenas o link de encaminhamento. Isso precisa ser explicitamente alinhado à intenção do proprietário antes de implementar autenticação.

## 1. Estado real do Git

Auditoria executada no repositório `/home/ubuntu/fala-comigo`:

| Item | Estado observado |
|---|---|
| Branch local | `main` |
| `HEAD` | `b43e18bbdde178b97817faf03ec10abb65f16f12` (`b43e18b`) |
| `origin/main` | o mesmo commit `b43e18b` |
| Divergência local `main...origin/main` | `0 0` |
| Estado inicial do working tree | limpo: `## main...origin/main` |
| Remote | `origin` → `https://github.com/falacomigocaa-app/fala-comigo.git` |
| Branches locais | apenas `main` (`git branch -vv`) |
| Branches remotas | várias; incluem `integration/finalize-project`, `docs/ai-continuation-governance`, `fix/main-startup-and-android-build`, `recovery/pr29-with-current-web` e branches de funcionalidades/segurança |
| Tags | nenhuma listada |
| Ação de sincronização | `git fetch origin --prune`, sem alteração de conteúdo de trabalho |

A ponta atual de `main` incorpora PRs recentes sobre o site e a continuidade:

- #72: link estável do Criador;
- #73: correção do WhatsApp;
- #74: GitHub Pages definido como destino público oficial;
- #75: auditoria de ambiente público/portal;
- #76: decisão de retirar Manus do Criador e registrar um gate de migração.

A #76 foi mesclada em `b43e18b`; seu commit de conteúdo é `ee1f428`. A #66 (correção da inicialização Android) também aparece como já mesclada na história da `main`; isso não altera o achado de continuidade: os documentos de retomada do portal ainda estão no estado anterior à escolha Opção A.

## 2. Main comparada com branches e PRs relevantes

### PR #68 — `integration/finalize-project` → `main`

- **Estado GitHub consultado:** aberta, não draft, `DIRTY`; head `f21f0e5`; base reportada pela PR em `7aa12f5`, anterior aos commits mais recentes da `main`.
- **Divergência calculada localmente:** `git rev-list --left-right --count origin/main...origin/integration/finalize-project` retornou `17 11`: 17 commits exclusivos do lado `main` e 11 exclusivos da branch, em relação à base comum.
- **Simulação de merge:** `git merge-tree` encontrou alterações concorrentes em `CONTINUAR_AQUI_PRIMEIRO.md` e `PROJECT_HANDOFF.md`, com blocos incompatíveis. Não foi feito merge.
- **Conteúdo da branch:** além de adicionar `MANUAL_CONTINUIDADE_MESTRE.md` e `docs/ESCOPO_PORTAL_ORGANIZACOES_ASSINANTES.md`, altera `CONTINUAR_AQUI_PRIMEIRO.md`, `PROJECT_HANDOFF.md`, `README.md`, histórico de continuidade e `site/index.html`.
- **Risco decisivo:** a versão de `site/index.html` da branch propõe um destino de Criador em endereço temporário do Manus Computer, em conflito direto com a escolha atual de independência do Manus. O manual e a cronologia também congelam um estado anterior da `main` e do portal.
- **Recomendação:** não mesclar a PR #68 inteira nem usar seu site como fonte. Reutilizar apenas conteúdo documental que continue correto, após comparação pontual com a `main` atual e atualização explícita para a Opção A.

### PR #64 — `docs/ai-continuation-governance` → `main`

- **Estado GitHub consultado:** aberta, `DIRTY`; head `ecf924c`; base `0d0b685`.
- **Divergência observada:** a base comum é `0d0b685`; há 50 commits exclusivos da `main` atual e 1 exclusivo da branch.
- Trata-se de governança/handoff focada na antiga baseline Android. Não registra a escolha atual de hospedagem e está desatualizada frente à `main` e às decisões subsequentes.
- **Recomendação:** não mesclar cegamente. Se houver regra ainda útil, reaplicá-la em PR pequena baseada na `main` vigente.

### Outras PRs abertas observadas

Consulta de PRs abertas em 25/09/2026:

| PR | Branch fonte → destino | Estado de merge | Relevância para esta auditoria |
|---|---|---|---|
| #68 | `integration/finalize-project` → `main` | `DIRTY` | Alta: continuidade/handoff e alteração do link do Criador; não mesclar inteira |
| #64 | `docs/ai-continuation-governance` → `main` | `DIRTY` | Média: instruções antigas de retomada; não mesclar cegamente |
| #65 | `fix/bootstrap-after-runapp` → `recovery/pr29-with-current-web` | `CLEAN` | Não é PR contra `main`; não confundir como mudança integrada |
| #61 | `baseline/rebuild-pr29-debug-apk` → `main` | `CLEAN` | Android/CI, fora do escopo de hospedagem; aberta |
| #60 | `diagnostics/show-startup-failure` → `main` | `DIRTY`, draft | Android/diagnóstico; aberta, não mesclada |
| #53 | `qa/manual-flow-execution-sheet` → `main` | `DIRTY` | QA/documentação, sem relação direta com Opção A |
| #31–#33 | branches de UI parental encadeadas entre si | `CLEAN`/`UNSTABLE` | Não são a “Opção A” de infraestrutura; nomes referem-se a protótipo/layout parental |

A PR #66 não aparece aberta: está integrada na `main`. A PR #76 também está integrada, mas sua documentação ainda contém a escolha A/B/C como pendente. O estado `CLEAN` de PRs com destino `recovery/...` ou de branches de protótipo não significa que estejam integradas em `main`.

## 3. Conflitos e contradições documentais

| Fonte/trecho | Estado documentado | Estado/decisão atual | Risco e ação necessária |
|---|---|---|---|
| `CONTINUAR_AQUI_PRIMEIRO.md` §§ “Ponto de parada” e “Opções” (linhas 98–118) | Diz que o proprietário não quer Manus, mas manda aguardar A/B/C e confirmar provedor; mantém como provisório o link `manus.space/creator`. | O proprietário escolheu A: Pages para site/interface, backend e banco independentes, camadas gratuitas primeiro. | Instrução bloqueadora obsoleta: um novo agente pode reapresentar uma decisão já tomada ou parar sem motivo. Atualizar para “A escolhida”; deixar provedor exato, credenciais e eventual contratação como gates separados. Resolver a política transitória do link Manus. |
| `PROMPT_RETORNO_NOVO_AGENTE.md` §12 (linhas 305–315) | Manda apresentar A/B/C, aguardar escolha e não substituir o link Manus antes de haver migração funcional. | A escolha de arquitetura já foi feita, mas a migração não foi implementada/validada. | Marcar o gate de escolha como superado; preservar somente o gate de segurança de migração. Não permitir que o link existente seja entendido como autorização para continuar usando Manus. |
| `docs/CONTINUIDADE_ASSISTENTE_IA.md` §§ 40–41 (linhas 551–578) | Registra que o portal existente usa Manus OAuth/adminProcedure, recomenda Manus como backend/portal em trecho anterior e termina em “aguardar escolha A/B/C”. | Proprietário rejeita Manus no Criador e escolheu infraestrutura independente. | O histórico mistura uma recomendação anterior incompatível com a decisão atual e não declara formalmente que foi superada. Preservar como histórico datado, acrescentar um registro atual de supersessão e explicar que o portal Manus não é a implementação-alvo. |
| `site/index.html` (link do rodapé, linha 163) | “Espaço do Criador” aponta para `https://falacomigo-kyrh225w.manus.space/creator`. | Destino atual é incompatível com o requisito de não vincular o Criador ao Manus. | O site Pages está publicado com chamada de ação que encaminha ao serviço recusado pelo proprietário. Não redirecionar para uma tela inexistente; decidir se o link deve ficar temporariamente oculto/desativado ou ser mantido somente durante uma janela explícita de transição. Executar mudança pública apenas por PR e deploy Pages. |
| PR #68, arquivo `site/index.html` | Propõe outro endereço de Criador em Manus Computer, temporário, dentro de uma integração antiga. | Nenhum destino Manus é aceitável para a solução-alvo. | Não mesclar o arquivo. É risco de reintroduzir link expirável e dependência proibida. |
| `PROJECT_HANDOFF.md` linhas 11–12 | Aponta como branch de trabalho `feat/parental-area-professional-v2` e último commit `5464914`. | Estado atual confirmado é `main` em `b43e18b`; PRs recentes já integradas. | Metadados de retomada obsoletos podem levar o próximo agente a checkout de branch antiga. Atualizar branch/commit e distinguir estado de produto de último commit de código relevante. |
| `PROJECT_HANDOFF.md` linha 187 | Lista “site institucional público definitivo” como não pronto. | A continuidade registra site institucional publicado no Pages oficial, endereço `https://falacomigocaa-app.github.io/fala-comigo/`, e o workflow `.github/workflows/site-pages.yml` está versionado. | Contradição entre “site público” e “portal/Criador”. Revisar para dizer que o site institucional está publicado; login, console e portal independente ainda não foram migrados/validados. Não declarar a migração do Criador pronta por causa do Pages. |
| `PROJECT_HANDOFF.md` §§ 122–140 | Recomenda iniciar retomada por governança/site institucional; não diferencia o site já publicado do portal não migrado. | O site está publicado; o backend independente ainda é uma etapa futura. | Reordenar próximos passos para documentar a Opção A e especificar arquitetura/limites antes da implementação. |
| `AGENTS.md` §§ 24–28 e Opção A atual | Adia domínio/serviços pagos até o lançamento, mas permite fluxo autônomo para tarefas técnicas reversíveis. | A decisão permite começar com camadas gratuitas e pagar apenas se necessário. | Compatível se “gratuito” significar sem contratação paga; porém conta, credenciais, uso de dados, termos do provedor e migração para cobrança continuam ações de gate. Não criar conta/secreto ou ativar plano pago sem autorização apropriada. |
| PRs #31–#33 e documentação “Option A dashboard” | Usam “Option A” para uma opção de painel/layout parental. | “Opção A” nesta tarefa é arquitetura de hospedagem. | Ambiguidade de nomenclatura em busca/handoff. Escrever “Opção A — infraestrutura GitHub Pages + backend/banco independentes” e qualificar os branches antigos como “Opção A do layout parental”. |

### Diferença entre portal atual, contrato e implementação

Os contratos em `docs/CONTRATO_PORTAL_CONECTADO.md` e `docs/CONTRATO_API_CONTINUIDADE_CUIDADO.md` são especificações, não prova de backend independente executável. O `PROJECT_HANDOFF.md` e a continuidade antiga descrevem funções autenticadas como pertencentes a um projeto separado com Manus. Esse projeto não aparece como código versionado na `main` do repositório auditado e, por política atual, não é destino permitido para o Criador. Portanto:

- não afirmar que backend/banco independentes já existem;
- não tratar a versão Manus como migração concluída ou como arquitetura aceita;
- não importar nem reaproveitar segredos/dados dessa solução;
- manter o portal conectado bloqueado para dados reais até haver substituto independente, testes de isolamento/autorização e revisão de privacidade.

## 4. Bloqueio de compatibilidade: GitHub Pages e login/SaaS

A documentação oficial do GitHub é explícita em dois pontos importantes para interpretar a decisão:

1. [What is GitHub Pages?](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages) descreve Pages como hospedagem estática que publica HTML, CSS e JavaScript; Pages não fornece execução de backend contínuo, banco, sessão ou autorização server-side.
2. [GitHub Pages limits](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits) diz que Pages não se destina a site gratuito que seja primariamente um SaaS/negócio e que sites Pages não devem ser usados para transações sensíveis como envio de senhas ou dados de cartão. A mesma página menciona limites operacionais — site publicado até 1 GB, banda mensal “soft” de 100 GB e limite “soft” de dez builds/hora (com exceção para publicação por GitHub Actions no limite de builds) — que não são garantia de disponibilidade ou adequação para produto conectado.

**Implicação:** manter a brochura/site institucional estático no Pages é compatível com a finalidade documentada. Hospedar no Pages uma aplicação do Criador que recolha/envie credenciais, ou um portal que seja essencialmente SaaS, é uma incompatibilidade de política/uso a resolver. O navegador pode chamar APIs externas, mas isso não torna recomendável transferir a tela de senha/SaaS para Pages. Para não contradizer a escolha nem expor credenciais, a interpretação segura a submeter ao proprietário é: **site público institucional no Pages; portal/login conectado servido em origem independente; o Pages apenas encaminha para esse portal**. Se “interface no GitHub Pages” significar literalmente que o formulário de login e todo o SaaS serão servidos no Pages, é necessário alterar essa parte do desenho ou obter orientação oficial antes de implementar.

Há ainda uma nota de privacidade da mesma documentação de “What is GitHub Pages”: o GitHub informa que registra e armazena o endereço IP de visitantes para fins de segurança. Isso deve ser confrontado com a política de privacidade publicada, sem supor que o Pages seja uma hospedagem sem coleta técnica.

Este relatório não escolhe Render, Railway, Fly.io, Cloudflare, VPS ou outro provedor: nenhuma cotação, cota ou termos atuais desses serviços foi pesquisada, pois o escopo desta auditoria é continuidade Git e o proprietário não especificou a tecnologia. Antes de selecionar fornecedor, comparar as páginas oficiais vigentes de preço, limites gratuitos, dormência/cold start, backup/restauração, região, exportação/portabilidade, retenção, logs, termos e custos de saída.

## 5. Decisões/gates ainda necessários — não reabrir a escolha A/B/C

A escolha macro A está tomada. Não pedir novamente para escolher A/B/C. Permanecem decisões distintas:

1. **Interpretação da “interface no Pages”:** confirmar que o login/portal SaaS pode ser servido em origem independente e o Pages conter apenas o site e o link; isso é necessário para alinhar o desenho com os avisos oficiais do Pages.
2. **Destino de transição do link atual:** enquanto o portal independente não existir, decidir em PR pública se o CTA será ocultado/desativado, substituído por mensagem “em migração” ou deixado temporariamente apontando para Manus com aviso e prazo. A escolha atual de não usar Manus favorece desativar o link, mas não se deve fazer deploy/publicação ampla nesta auditoria.
3. **Fornecedor(es) e arquitetura concreta:** backend, banco, armazenamento de mídia (se houver), e-mail/recuperação de conta, domínios/origens, backup, monitoramento e autenticação. Verificar fontes oficiais quando forem selecionados.
4. **Escopo MVP:** apenas conta/console do proprietário ou portal multi-organização, convites e permissões? O plano “backend e banco” não implica que todos esses módulos possam entrar em produção agora.
5. **Dados e autorização:** manter somente dados sintéticos até definir finalidade, retenção, consentimento, isolamento por organização, auditoria e testes de negação. Não ligar sincronização clínica por assumir que a infraestrutura já existe.
6. **Gatilhos de migração a plano pago:** métricas/cotas que disparam upgrade, responsável pela aprovação de cobrança, contingência se serviço gratuito suspender, exportação e continuidade do acesso. A decisão “pagar quando necessário” não identifica esses limites.
7. **Credenciais e titularidade:** registrar qual usuário/organização controla as contas e como segredos serão provisionados no servidor; nenhum segredo deve entrar no Git ou no frontend. Esta auditoria não criou credenciais.

## 6. Recomendações

1. **Tomar este estado como baseline de continuidade:** `main` em `b43e18b`; checkout original limpo; PR #76 integrada. O registro do proprietário sobre Opção A passa a ser a decisão vigente, mas ainda precisa ser gravado nos documentos para não depender desta conversa.
2. **Não mesclar #68 ou #64.** A #68 conflita em texto com a main e tenta alterar o link Pages para um endereço Manus temporário; a #64 é uma proposta documental antiga baseada em `0d0b685`. Extrair somente trechos úteis em branch nova, após rebase conceitual sobre `origin/main`.
3. **Abrir uma PR pequena de continuidade/documentação contra a `main` atual**, atualizando ao menos `CONTINUAR_AQUI_PRIMEIRO.md`, `PROMPT_RETORNO_NOVO_AGENTE.md`, `PROJECT_HANDOFF.md`, `README.md` e acrescentando registro datado a `docs/CONTINUIDADE_ASSISTENTE_IA.md`. Marcar A/B/C como decisão superada; manter como pendentes apenas fornecedor, credenciais/cobrança, transição do CTA e detalhe de interface/login.
4. **Manter histórico antigo, mas explicitamente supersedido:** não apagar o relato de 25/09 nem reescrever decisões históricas; adicionar uma nota de vigência e referência à decisão atual.
5. **Separar claramente quatro ativos:** site institucional estático no Pages; interface de login/portal autenticado; API/backend; banco/armazenamento. Não afirmar que um contrato Markdown é serviço implementado.
6. **Não publicar login/credenciais no Pages.** Antes de implementar, reconciliar o requisito de “interface no Pages” com as limitações/políticas oficiais do Pages. Proposta mais segura: Pages para site institucional e entrada; portal/login e API na origem independente.
7. **Tratar o link Manus como dependência legada, não como destino aprovado.** A atualização do site deve ser isolada em PR e validada pelo workflow `.github/workflows/site-pages.yml`; não reintroduzir link efêmero da branch #68.
8. **Adiar escolha de fornecedor até comparação oficial**, mas preparar matriz com custo zero e gatilhos de upgrade. “Grátis” precisa incluir capacidade de backup/portabilidade e risco de suspensão/dormência, não apenas preço nominal.
9. **Restringir o primeiro piloto a dados sintéticos** e exigir testes de autenticação, autorização server-side, isolamento entre organizações, revogação e auditoria antes de qualquer dado real.
10. **Não misturar esta decisão com PRs de Android/UI.** PRs #60/#61/#65 e branches #31–#33 têm objetivos distintos e não devem ser usadas como base automática da migração de backend.

## 7. Primeiras ações concretas

1. Registrar no issue/brief da próxima PR: “Opção A escolhida pelo proprietário em 25/09/2026; não reapresentar A/B/C”. Anexar este relatório.
2. Criar branch documental nova **a partir do `origin/main` atual**; revisar `git status`, confirmar `b43e18b` como ponto de partida e não reusar como base `integration/finalize-project` nem `docs/ai-continuation-governance`.
3. Atualizar os documentos de primeira leitura para remover o gate “aguardar A/B/C” e adicionar a escolha A, deixando claro: Pages publicado ≠ portal migrado; Manus Space não é destino; provedor ainda não selecionado; backend independente não implementado.
4. Tratar a compatibilidade com GitHub Pages como gate pré-implementação: obter concordância de que o formulário/login e a interface SaaS ficarão em origem independente, ou rever a arquitetura antes de aceitar senhas no Pages.
5. Resolver explicitamente a chamada pública atual do Criador: abrir PR de conteúdo mínima para ocultar/suspender o link Manus até a nova origem estar funcional, **ou** documentar uma exceção temporária aprovada. Não trocar para URL inexistente e não usar URL temporária.
6. Só depois disso elaborar matriz oficial de provedores gratuitos e seus gatilhos de upgrade; solicitar aprovação antes de criar contas, emitir segredos, habilitar faturamento ou colocar qualquer portal acessível na internet.
7. Implementar a fundação em branch/PR separada, com dados sintéticos; criar CI/testes de autorização e backup/restore; comprovar origem de API, banco e comportamento de indisponibilidade antes de apontar o CTA Pages para ela.
8. Fazer merge e deploy apenas pelo fluxo de PR e após checks/revisão; conferir o site publicado e registrar commit, workflow e resultado no histórico de continuidade.

## 8. Evidência, limites e comandos reprodutíveis

Comandos de auditoria usados (somente leitura, salvo `git fetch` de referências):

```bash
git status --short --branch
git branch -vv
git remote -v
git log --oneline --decorate --graph --all -25
git fetch origin --prune
git rev-parse main origin/main
git rev-list --left-right --count main...origin/main
git branch -r -vv
gh pr list --repo falacomigocaa-app/fala-comigo --state open --limit 100
gh pr view 68 --repo falacomigocaa-app/fala-comigo
gh pr view 64 --repo falacomigocaa-app/fala-comigo
git merge-base origin/main origin/integration/finalize-project
git rev-list --left-right --count origin/main...origin/integration/finalize-project
git merge-tree <base-comum> origin/main origin/integration/finalize-project
git grep -n -i -E 'manus\\.space|Manus Space|aguardar.*escolha|Opção A' origin/main
```

O relatório registra fatos observados nas referências e PRs em 25/09/2026. O estado de deploy remoto do site não foi revalidado visualmente nesta auditoria; a existência do workflow Pages e o histórico publicado estão documentados no repositório. Não foi avaliada a configuração de contas/provedores, o portal em execução ou sua migração. A pesquisa externa restringiu-se a documentação oficial do GitHub Pages; preços e limites de provedores de backend/banco continuam pendentes de pesquisa na etapa de seleção.

### Referências oficiais

- GitHub Docs — [What is GitHub Pages?](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages)
- GitHub Docs — [GitHub Pages limits](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits)
- Repositório — [Pull request #68](https://github.com/falacomigocaa-app/fala-comigo/pull/68), [#64](https://github.com/falacomigocaa-app/fala-comigo/pull/64), [#76](https://github.com/falacomigocaa-app/fala-comigo/pull/76)
- Site público documentado — <https://falacomigocaa-app.github.io/fala-comigo/>
