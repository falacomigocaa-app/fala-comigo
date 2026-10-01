# Revisão somente-leitura das PRs abertas do Fala Comigo

**Data da fotografia:** 2026-09-28\
**Repositório:** [falacomigocaa-app/fala-comigo](https://github.com/falacomigocaa-app/fala-comigo)\
**Escopo:** PRs abertas **#79, #80, #81, #78 e #77**, nesta ordem de análise. A revisão consultou metadados, base/head, arquivos e commits, checks do GitHub, logs dos checks e a genealogia local das branches. Nenhum merge, push, comentário ou alteração no repositório foi feito.

> **Fora deste conjunto:** a PR **#83 foi inspecionada separadamente pelo agente principal** e não faz parte deste relatório.

## 1. Regra de leitura: aberta não significa publicada

As cinco PRs continuam `open` e não são rascunhos. Isso **não** significa que seus conteúdos já estejam em `main`.

Na fotografia consultada, `origin/main` está em `cc96eaf` (`feat: preview Espaço do Criador (#86)`), enquanto os commits próprios abaixo não são ancestrais de `main`:

- **#77:** `dcbdced` — formalização da arquitetura de portal independente;
- **#78:** `1463c05`, `3db64b7` — API sintética e validação PostgreSQL;
- **#79:** `7e522f0` — correção de câmera e layouts estreitos;
- **#80:** `159ca6e`, `f2f2632`, `14f486b` — alarme Android, lembretes e documentação de autorização;
- **#81:** `f261607` — consentimento e grants de sujeito sintético.

Há um encadeamento importante: **#78 usa a branch de #77 como base; #79 carrega #78; #80 carrega #79; #81 carrega #80**. Por isso, o diff de algumas PRs contra `main` repete documentação, API e código de PRs anteriores. As tabelas abaixo distinguem o **delta próprio** da PR do conteúdo herdado, para não contar o mesmo trabalho cinco vezes.

## 2. Resumo por impacto

| Área | Impacto real no conjunto aberto | O que ainda não aconteceu em `main` |
|---|---|---|
| **Site permanente** | #77 registra a decisão de que GitHub Pages fica como site institucional/encaminhamento e que portal, API, banco e login têm origem independente. #78 declara que não altera URL/CTA. #79–#81 não trazem mudança de `site/` nem publicação de portal. | Nenhuma dessas PRs publica portal, troca o CTA/link do Criador ou altera o site permanente. A decisão documental da #77 não é, por si só, rollout em produção. |
| **App Android/Web** | #79 corrige persistência da foto da câmera e overflow da área parental. #80 transforma alertas agendados em alarme Android de tela cheia. #81 não acrescenta funcionalidade de app; carrega o código anterior por ancestralidade. | Não há APK novo validado nem evidência de que essas mudanças estejam em `main`. O Web está bloqueado no check atual pela assinatura `extensionHint` introduzida pela #79. |
| **Portal conectado** | #77 formaliza a Opção A. #78 implementa/valida a base sintética do Gate 2B, com API local, fixtures, auditoria, idempotência e migration PostgreSQL. #80 acrescenta documentação de autorização/compartilhamento. #81 implementa o Gate 3A sintético de sujeito, consentimento, convite, relação, grant, leitura mínima e revogação. | Não existe, nestas PRs, login real, OAuth/OIDC, e-mail/link mágico, sessão de produção, banco remoto persistente, portal Web adulto conectado ou dados reais. A API diz expressamente que não deve ser publicada. |

## 3. Estado transversal dos checks e reviews

- **Review humana:** `review_decision` está nulo em todas; não há reviewers solicitados nem aprovação registrada.
- **#77:** `analyze-and-test` concluído com **sucesso** ([run 36180186432](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36180186432)). Mesmo assim, a PR está `mergeable=false`, `mergeable_state=dirty` contra o `main` atual.
- **#78:** nenhum check-run/status atual foi reportado pela API para o head consultado. Isso não invalida os testes descritos na PR; significa apenas que não há check atual do GitHub para usar como gate.
- **#79:** `analyze-and-test` **falhou** ([run 36225053690](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36225053690)). O build Web falha em `add_card_screen.dart` porque `MediaStorageService.persistFile` recebe `extensionHint`, mas a implementação Web não aceita esse parâmetro (`media_storage_service_web.dart` mantém a assinatura de um argumento).
- **#80:** `analyze-and-test` **falhou** ([run 36229526435](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36229526435)) pela mesma falha Web herdada da #79; a API mostra `mergeable_state=unknown`, portanto o cálculo de merge precisa ser atualizado depois de sincronizar a branch.
- **#81:** há dois `analyze-and-test` concluídos com **falha** ([run 36258028740](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36258028740) e [run 36258026477](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36258026477)); ambos registram a mesma falha Web de `extensionHint` herdada da #79. Os 18 testes locais e a migration PostgreSQL declarados na descrição da #81 são evidência do autor, não um check GitHub verde no head atual.

## 4. Tabela por PR

### PR #77 — arquitetura de portal independente

[Ver PR #77](https://github.com/falacomigocaa-app/fala-comigo/pull/77)

| Dimensão | Resultado da revisão |
|---|---|
| **Estado/base/head** | Aberta, não-draft; base `main`; head `docs/record-option-a-public-url` em `dcbdced`. `mergeable=false`, `dirty`. 11 arquivos, essencialmente documentação (`+1379/-4`). |
| **Delta próprio** | Formaliza a **Opção A**: GitHub Pages somente institucional/encaminhamento; login, portal, API e banco fora do site; PostgreSQL e API REST como base de especificação; protótipo inicial com fixtures sintéticas. Adiciona ADR e relatórios da equipe-mestra sobre arquitetura, continuidade, provedores, segurança, migração e QA. |
| **Site permanente** | **Impacto documental, não de runtime.** Registra o limite site/portal e mantém o link/CTA do Criador sem troca nesta etapa. Não altera arquivos do site nem publica nada. |
| **App Android/Web** | Nenhuma mudança de código do app. |
| **Portal conectado** | Define a direção arquitetural, mas não cria backend publicado, login, banco remoto ou portal Web. |
| **Checks atuais** | `analyze-and-test` verde; `git diff --check` e verificação documental foram declarados verdes na descrição. Não há aprovação humana registrada. |
| **Dependências e merge** | A base é `main`, mas a branch ficou atrás do `main` atual. A simulação de merge encontrou conflitos de conteúdo em `CONTINUAR_AQUI_PRIMEIRO.md`, `PROJECT_HANDOFF.md` e `docs/CONTINUIDADE_ASSISTENTE_IA.md`. Resolver esses conflitos e decidir quais atualizações de continuidade permanecem é trabalho humano antes do merge. |
| **Decisão humana** | Aprovar ou não a Opção A como decisão vigente; preservar o limite “site institucional versus portal independente”; escolher se os relatórios extensos entram como documentação canônica ou devem ser enxugados. |

### PR #78 — API sintética e validação PostgreSQL (Gate 2B)

[Ver PR #78](https://github.com/falacomigocaa-app/fala-comigo/pull/78)

| Dimensão | Resultado da revisão |
|---|---|
| **Estado/base/head** | Aberta, não-draft; base **é a branch da #77** (`docs/record-option-a-public-url`), head `spec/mvp-portal-sintetico` em `f0880ee`. `mergeable=true`, `clean` em relação à sua base, não em relação ao `main` atual. 21 arquivos no diff contra a base (`+1446/-6`). |
| **Delta próprio** | Mantém `portal-api/` local com header `x-synthetic-user-id`, autorização server-side, escopos, auditoria, idempotência e rotas `/v1`; adiciona `pg`, lockfile e teste de integração que aplica `001_initial.sql` e verifica as sete tabelas, constraints e isolamento entre organizações. |
| **Site permanente** | Nenhum impacto de runtime. A própria descrição exclui mudança de URL/CTA e publicação do portal. |
| **App Android/Web** | Nenhuma mudança de código do app. |
| **Portal conectado** | É a primeira base executável do portal, porém **sintética e local**: armazenamento em memória, fixtures determinísticas, sem contas externas, sem autenticação real, sem banco remoto e sem portal Web publicado. As rotas cobrem identidade sintética, organizações/memberships, convites, benefícios e auditoria. |
| **Checks atuais** | Nenhum check/status atual foi reportado para o head pela API. A descrição informa: migration aplicada em PostgreSQL 16.15 descartável; 13 testes com `PGTEST_URL`; 12 testes sem a variável e uma integração ignorada; `npm audit --audit-level=high` sem vulnerabilidades; `git diff --check` verde. |
| **Dependências e merge** | Depende explicitamente da #77, pois usa o ADR/handoff da Opção A. A estratégia segura é resolver/mergir #77, atualizar a branch da #78 para o `main` resultante e repetir os testes. Não se deve interpretar `clean` como “pronta para merge em `main`”. |
| **Decisão humana** | Aceitar ou não a API sintética como Gate 2B; confirmar que fixtures e header nunca sejam publicados; decidir o gate de segurança/operação anterior a qualquer identidade real. |

### PR #79 — câmera dos cartões e overflow parental

[Ver PR #79](https://github.com/falacomigocaa-app/fala-comigo/pull/79)

| Dimensão | Resultado da revisão |
|---|---|
| **Estado/base/head** | Aberta, não-draft; base `main`; head `fix/parental-camera-and-overflow` em `7e522f0`. `mergeable=false`, `dirty`. Contra `main`, aparecem 30 arquivos (`+2879/-37`) porque a branch carrega #77/#78; o delta funcional próprio está concentrado em 3 arquivos de app e o commit `7e522f0`. |
| **Delta próprio** | `persistFile` IO aceita `extensionHint`; a tela de adicionar cartão passa `.jpg` quando a origem é câmera e materializa/verifica a mídia cifrada antes de exibi-la como pronta. A tela de configurações envolve o seletor de orientação em rolagem horizontal e separa o selo `OFFLINE` do cabeçalho de localização para telas estreitas. |
| **Site permanente** | Nenhuma alteração em `site/`, URL, CTA ou publicação de portal. A documentação/API herdada não transforma o site em portal conectado. |
| **App Android/Web** | Impacto direto no app: correção do fluxo de foto capturada pela câmera, persistência privada/cifrada e layout parental em retrato/paisagem. O Android é o cenário do defeito observado (Realme C71), mas a chamada compartilhada também entra no build Web. |
| **Checks atuais** | `analyze-and-test` falhou. Erro-raiz no build Web: `No named parameter with the name 'extensionHint'` em `add_card_screen.dart:116`; a implementação Web (`media_storage_service_web.dart`) não tem assinatura compatível. A descrição registra somente `git diff --check` verde, Flutter indisponível no sandbox e pendências de CI, novo APK e repetição no Realme C71. |
| **Dependências e merge** | A branch é descendente da #78, embora tenha base declarada `main`; também conflita com o `main` atual em documentação de continuidade. Antes do merge: corrigir a paridade IO/Web (ou tornar a chamada condicional por plataforma), atualizar/rebasear contra `main`, regenerar CI e repetir os fluxos de câmera e layout. |
| **Decisão humana** | Definir o contrato multiplataforma de `MediaStorageService`: o Web aceitará `extensionHint`, ignorará a dica ou bloqueará mídia privada de forma explícita? Aprovar a correção do comportamento de câmera somente após teste físico e confirmar que a solução não expõe mídia cifrada. |

### PR #80 — alertas como despertador real no Android

[Ver PR #80](https://github.com/falacomigocaa-app/fala-comigo/pull/80)

| Dimensão | Resultado da revisão |
|---|---|
| **Estado/base/head** | Aberta, não-draft; base `main`; head `fix/transition-alert-alarm-mode` em `14f486b`. `mergeable_state=unknown` (o GitHub ainda não calculou); 39 arquivos no diff contra `main` (`+3149/-84`) por carregar a cadeia anterior. Delta funcional próprio: commits `159ca6e` e `f2f2632`; `14f486b` é documentação de autorização/compartilhamento do portal. |
| **Delta próprio** | Inicializa o serviço de notificações cedo e de forma idempotente; usa canal Android novo de alta prioridade; pede permissões ao salvar alerta; configura `showWhenLocked`/`turnScreenOn`; usa `alarmClock`; remove o diagnóstico temporário de 30 segundos; mantém áudio gravado e faz fallback TTS para o título; ajusta os lembretes parentais para o horário exato/configuração automática. |
| **Site permanente** | Nenhuma mudança de site ou publicação. A documentação de autorização é apenas especificação. |
| **App Android/Web** | Impacto principal no **Android**: alerta agendado deve abrir a experiência de tela cheia como despertador, inclusive sobre tela bloqueada. Não há uma funcionalidade Web intencional nessa PR, mas o head continua sem build Web por carregar a incompatibilidade `extensionHint` da #79. |
| **Portal conectado** | Apenas documentação adicional de fluxos de autorização e compartilhamento; não conecta o app a portal, login ou banco. |
| **Checks atuais** | `analyze-and-test` falhou no Web pela mesma assinatura incompatível da #79. A descrição informa `git diff --check` verde, Flutter indisponível e pendências de CI, APK e teste em aparelho com horário próximo, tela bloqueada, voz gravada e TTS. |
| **Dependências e merge** | O head descende da #79 e da base sintética #78; portanto, o merge cumulativo fica bloqueado pelos conflitos/erro Web anteriores. É preferível corrigir #79 primeiro e então atualizar a branch, ou extrair/cherry-pickar os commits de alarme sobre um `main` saneado. |
| **Decisão humana** | Validar UX e política Android para tela bloqueada, permissões, canal novo, TTS e comportamento com o app encerrado; decidir se as mudanças de alarme e a documentação de portal devem continuar na mesma PR. |

### PR #81 — consentimento e grants de sujeito sintético (Gate 3A)

[Ver PR #81](https://github.com/falacomigocaa-app/fala-comigo/pull/81)

| Dimensão | Resultado da revisão |
|---|---|
| **Estado/base/head** | Aberta, não-draft; base `main`; head `feat/gate-3a-synthetic-permissions` em `f261607`. `mergeable=false`, `dirty`; 39 arquivos contra `main` (`+3434/-84`) por carregar #77–#80. Delta funcional próprio: commit `f261607`. |
| **Delta próprio** | Acrescenta `child_subjects`, `consents` e `care_relationships`; liga convite a consentimento; cria relação/grant após aceite; aplica escopos, finalidade, versão do aviso e validade; permite leitura mínima do sujeito com grant vigente; revoga server-side grant, consentimento e relação. A migration e os testes PostgreSQL acompanham a API. Rotas sintéticas descritas: criação de consentimento, convite ligado à criança, aceite, leitura mínima e revogação. |
| **Site permanente** | Nenhuma mudança em site, URL, CTA ou publicação. |
| **App Android/Web** | Nenhum delta funcional próprio no app; os arquivos Android/Dart listados no diff contra `main` são herança da cadeia. |
| **Portal conectado** | Impacto conceitual e de backend no portal, mas ainda **não conectado**: usa `x-synthetic-user-id`, fixtures/memória e schema descartável. A própria PR exclui e-mail, sessão, OAuth, portal Web adulto conectado e dados reais; Gate 3B (autenticação real, banco persistente e portal mínimo) fica para depois. |
| **Checks atuais** | Dois `analyze-and-test` falharam no build Web por `extensionHint` herdado. A descrição relata 18/18 testes locais com PostgreSQL descartável, `npm audit` sem vulnerabilidades e `git diff --check` verde; isso não substitui um check atual verde no head. |
| **Dependências e merge** | A branch descende da #80, que descende de #79/#78/#77, e está `dirty` contra o `main` atual. Para evitar trazer app e docs cumulativos, atualizar a base da API após #78 e reaplicar apenas `f261607` (ou outra unidade revisada). Não aplicar a migration Gate 3A isoladamente sem o schema/código Gate 2B que ela altera. |
| **Decisão humana** | Aprovar a semântica de consentimento, escopos, finalidade, validade, revogação em cascata e minimização; exigir revisão de segurança/privacidade antes de qualquer identidade real; decidir o contrato de transição para Gate 3B e a futura UI do portal. |

## 5. Dependências de merge: leitura operacional

### Grafo de branches observado

```text
main (atual, posterior às branches)
  └─ #77  dcbdced  (base main; docs/ADR da Opção A)
       └─ #78  f0880ee  (base = head de #77; API Gate 2B + PostgreSQL)
            └─ #79  7e522f0  (base declarada main; head carrega #77/#78 + app)
                 └─ #80  14f486b  (carrega #79 + alarme Android + docs)
                      └─ #81  f261607  (carrega #80 + Gate 3A sintético)
```

Esse grafo explica por que uma leitura ingênua do diff da #81 parece incluir câmera, alarmes, ADR e toda a API: são mudanças ancestrais da branch, não quatro novas implementações repetidas na #81.

### Bloqueadores concretos

1. **Defasagem e conflitos:** #77, #79 e #81 estão `dirty`; a simulação identifica pelo menos conflitos de conteúdo nos arquivos de continuidade para #77 e nos descendentes. #80 está com mergeabilidade `unknown` e precisa de novo cálculo.
2. **Build Web quebrado:** o contrato `persistFile` foi ampliado no IO pela #79, mas não no Web. Enquanto isso não for resolvido, #79, #80 e #81 não têm check de CI verde.
3. **Checks incompletos:** #78 não tem check atual reportado, apesar dos testes locais descritos. É necessário reexecutar CI após atualizar a branch.
4. **Validação de dispositivo ausente:** #79 e #80 ainda precisam de APK novo e teste manual; o autor declara Flutter indisponível no ambiente local.
5. **Aprovação humana ausente:** nenhuma PR tem decisão de review registrada. Mesmo #77, que tem check verde, não deve ser tratada como aprovada automaticamente.

## 6. Decisões humanas que não devem ser escondidas pelo status técnico

- **Arquitetura e produto:** confirmar que o site permanente continua institucional e que o portal independente não será publicado por acidente ao integrar docs/API.
- **Estratégia de integração:** escolher entre merge sequencial após atualizar cada branch ou separar os deltas próprios por cherry-pick/rebase. Não fazer merge cego dos heads cumulativos em `main`.
- **Contrato Web de mídia:** decidir e implementar a semântica de `extensionHint` no Web; depois exigir build Web verde.
- **Android:** aceitar a experiência sobre tela bloqueada, permissões e canal de alta prioridade; validar aparelho bloqueado, app morto, voz gravada, fallback TTS e horário próximo.
- **Privacidade/autorização:** revisar se a finalidade, escopos, validade, convite, relação e revogação do Gate 3A atendem ao produto e às obrigações de privacidade antes de substituir a identidade sintética.
- **Produção:** decidir explicitamente quando haverá autenticação real, banco persistente, portal Web e dados reais. Nenhum desses itens é entregue pelas PRs abertas analisadas.

## 7. Sequência recomendada de próximos passos

1. **Preservar a fotografia e o escopo.** Manter #83 fora deste lote, como revisão separada do agente principal. Não inferir publicação a partir de `open`; registrar que #77–#81 ainda não estão em `main`.
2. **Resolver a fundação documental (#77).** Atualizar a branch contra o `main` atual, resolver conflitos de continuidade, revisar ADR/Opção A e obter aprovação humana. Só então considerar merge.
3. **Atualizar e validar a base do portal (#78).** Reapontar/rebasear #78 sobre o `main` pós-#77; rerodar `npm test` com e sem `PGTEST_URL`, aplicar a migration em PostgreSQL descartável, executar `npm audit` e obter check GitHub atual. Manter a API explicitamente local/sintética.
4. **Sanear o contrato de mídia antes do app (#79).** Implementar a mesma assinatura no Web ou fazer a chamada ser corretamente específica por plataforma; rodar análise, testes e build Web. Depois gerar APK e repetir câmera/salvamento no Realme C71 e layout parental em retrato/paisagem.
5. **Integrar o alarme Android (#80).** Rebasear ou reaplicar apenas os commits próprios sobre a base corrigida; rodar CI e teste em dispositivo bloqueado/ desbloqueado, app encerrado, voz gravada, fallback TTS, permissão e horário próximo. Atualizar o cálculo `mergeable`.
6. **Integrar o Gate 3A (#81).** Reaplicar o delta `f261607` sobre a API Gate 2B atualizada, evitando carregar app/docs cumulativos; rodar os 18 testes, migration PostgreSQL, testes de isolamento/revogação e revisão de segurança/privacidade. Não publicar a API sintética.
7. **Fazer smoke test pós-merge por superfície.** Confirmar que URL/CTA e site permanente permanecem inalterados; validar build Web; validar APK/Android; validar apenas o backend sintético local. Qualquer portal Web conectado, login real ou banco persistente deve ser uma decisão e entrega posterior, não uma suposição desta série.
8. **Planejar o Gate 3B separadamente.** Só depois da decisão humana sobre identidade real, sessão, persistência, portal adulto, consentimento operacional e governança de dados.

## Conclusão

O conjunto aberto representa uma sequência de decisões e incrementos ainda não integrados: **#77 decide a arquitetura**, **#78 prova a base sintética do portal**, **#79 corrige dois problemas reais do app**, **#80 amplia alertas para alarme Android** e **#81 estende autorização sintética para consentimento/grants**. O único check verde é o da #77; #79–#81 estão bloqueadas pelo mesmo erro de compilação Web herdado, e #78 precisa de check atual. O próximo passo seguro é integrar por deltas, respeitando a cadeia, corrigindo o contrato Web e obtendo decisões humanas explícitas — sem tratar nenhuma dessas PRs abertas como conteúdo já publicado em `main`.
