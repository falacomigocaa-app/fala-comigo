# Plano mestre executável — Opção A do Fala Comigo

**Data:** 25/09/2026  
**Decisão de produto vigente:** Opção A confirmada pelo proprietário.  
**Escopo deste plano:** consolidar auditorias de Git/continuidade, arquitetura, provedores, segurança/privacidade e migração/QA. É um plano de execução, não evidência de implementação. **Nenhum código de produção, conta, credencial, contratação, migração ou publicação é autorizado por este documento.**

## 1. Diagnóstico executivo

A decisão macro já está tomada: seguir a **Opção A**, sem voltar a pedir A/B/C. O site institucional público continua no GitHub Pages; o backend e o banco do futuro portal devem ser independentes do Manus e podem começar em camadas gratuitas, desde que o uso gratuito seja restrito a protótipos com dados sintéticos. A **`main` permanece protegida**: mudanças entram por branch e Pull Request revisável, sem trabalho direto nela.

A auditoria Git registrou, em seu snapshot inicial, `main` sincronizada com `origin/main` no commit `b43e18b` (PR #76 integrada). Isso é uma linha de base da auditoria, não uma afirmação de que o checkout compartilhado atual esteja limpo. Na verificação deste trabalho, o checkout estava na branch `docs/record-option-a-public-url`, ainda em `b43e18b`, com alterações pendentes em `CONTINUAR_AQUI_PRIMEIRO.md`, `PROMPT_RETORNO_NOVO_AGENTE.md` e `docs/CONTINUIDADE_ASSISTENTE_IA.md`, além dos relatórios de auditoria não rastreados. Esses diffs foram preservados e não são atribuídos a este plano: **revisá-los e identificar sua autoria antes de incluí-los em qualquer PR**.

O portal independente ainda não existe como implementação comprovada. Os contratos existentes são especificações; não comprovam API, autenticação, autorização multi-organização, RLS, recuperação de conta ou testes negativos em execução. A prévia web é sintética. O núcleo CAA deve continuar útil offline, sem depender de login, API, Internet ou plano.

A fronteira segura é: **Pages para presença institucional e encaminhamento; login e portal autenticado em origem independente; API como autoridade de autorização**. O GitHub Pages é hospedagem estática, sem backend nem autorização server-side, e a orientação oficial desaconselha usá-lo para envio de senhas ou como hospedagem gratuita primária de SaaS ([o que é GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages), [limites e uso](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits)). Portanto, nenhuma senha deve ser coletada no Pages.

O endereço Manus atualmente referido no site permanece **provisório até a migração independente estar implementada e validada**, conforme a instrução vigente desta consolidação. Isso não transforma Manus no destino arquitetural: não importar dados, não introduzir novas dependências ou funcionalidades, não chamar esse portal de solução independente e não mover a CTA para uma URL imaginária. A política da CTA na transição e o corte público devem ser tratados separadamente; após o corte validado, rollback não deve reencaminhar ao Manus.

**Recomendação central:** avançar agora com governança/documentação e especificação; desenvolver primeiro localmente e em CI, com fixtures sintéticas. Usar **PostgreSQL padrão** como modelo de persistência e uma API REST versionada como fronteira. Workers + Supabase Auth/Postgres é apenas uma **composição candidata para protótipo sintético**, não escolha de contratação. Não abrir contas, inserir credenciais ou ativar cobrança como parte deste plano.

## 2. Conflitos e resolução

| Conflito encontrado | Resolução consolidada | Consequência executável |
|---|---|---|
| Documentos ainda mandam escolher A/B/C, embora o proprietário tenha escolhido A. | A escolha macro está encerrada; vale a decisão mais recente do proprietário. | Substituir o gate A/B/C por gates independentes de arquitetura, provedor, credenciais, custos, privacidade e migração. Manter as opções antigas somente como histórico datado/superado. |
| “Interface no Pages” pode ser lido como formulário de senha/portal SaaS no Pages. | Interpretar a decisão de modo compatível com a natureza estática e a orientação publicada do Pages: institucional/entrada no Pages; login e portal em origem independente. | Registrar essa fronteira antes de coletar credenciais; não criar autenticação falsa em JavaScript público. Se o proprietário desejar outra interpretação, interromper antes de login e reavaliar segurança/política. |
| A PR #68 e a #64 estão desatualizadas; a #68 tem conflitos e URL Manus temporária. | Nenhuma delas é uma base segura para merge. A PR #68 está `DIRTY`, conflita com a `main` e propõe URL temporária; a #64 também está `DIRTY` e obsoleta. | Não mesclar #68 nem #64 como estão. Reaplicar apenas conteúdo ainda correto em branch nova da `main` vigente. Não confundir as antigas opções de layout parental (#31–#33) com a Opção A de infraestrutura. |
| CTA pública ainda aponta para Manus, enquanto a direção final é independência. Auditorias diferem entre removê-la já ou esperar o novo destino. | Regra vigente: o portal Manus permanece provisório até migração independente validada; Manus não é arquitetura-alvo. A transição da CTA é um item público separado, sem destino fictício. | Não anunciar migração antes dos critérios de aceite. Planejar a mudança da CTA em PR própria quando o destino independente estiver válido; decidir/documentar a apresentação pública durante o intervalo sem contrapor a instrução de caráter provisório. Nunca usar Manus como rollback depois do corte. |
| “Gratuito primeiro” parece suficiente para um portal com dados de famílias. | Grátis é somente protótipo/sandbox descartável com fixtures sintéticas; não é garantia de continuidade nem aprovação para dados reais. | Proibir dados reais, clínicos ou de crianças em planos gratuitos; exigir plano operacional e gates de privacidade, e-mail, backup/restauração e cobrança antes de qualquer piloto real. |
| As especificações são tratadas como se já houvesse produto conectado. | Contratos e protótipos não são implementação. Backend, autenticação remota, autorização, testes multi-tenant, recuperação e política para coleta remota permanecem pendentes. | Descrever como “não implementado” até evidência associada a commit, ambiente e testes. Não afirmar prontidão com base em documentação ou UI estática. |
| `PROJECT_HANDOFF.md` contém branch/commit antigos e chama o site publicado de não pronto. | Distinguir o site institucional já publicado do portal/backend ainda não migrado. Metadados de continuidade devem refletir observações atuais e sua data. | Atualizar handoff em PR documental, sem alterar o histórico técnico como se estados passados nunca tivessem existido. |

### Portais e PRs existentes

- A auditoria encontrou `site/index.html` apontando para `https://falacomigo-kyrh225w.manus.space/creator`. Esse destino é provisório e não prova migração.
- A PR #68 sugere outro endereço Manus temporário e tem conflitos com `CONTINUAR_AQUI_PRIMEIRO.md` e `PROJECT_HANDOFF.md`; não mesclar.
- A PR #64 é baseada em referência antiga; não mesclar cegamente.
- Estados `CLEAN` de PRs para branches de recuperação ou protótipo não significam integração na `main`.
- Não há evidência de conteúdo produtivo do Manus a importar. A migração começa vazia; qualquer importação exigiria solicitação, inventário, autorização e avaliação próprios.

## 3. Equipe mestra e responsabilidades

A equipe mestra coordena gates e revisão cruzada; não substitui o proprietário em escolhas de produto, risco, dados ou custos.

| Papel | Responsabilidades e entregáveis | Poder de bloqueio |
|---|---|---|
| **Proprietário do produto** | Confirmar fronteira Pages/portal, finalidade e escopo do MVP, responsáveis, orçamento/teto de gasto, região e autorização para contas, dados ou piloto. Aprovar qualquer custo, coleta real e corte público. | Decide produto, orçamento, contratação e dados reais. |
| **Coordenação mestra / responsável pela continuidade** | Manter plano único, sequência, riscos, donos, gates e critérios de pronto; conferir baseline e mudanças compartilhadas antes de PR; evitar contradições entre handoffs. | Pausa execução quando baseline/diff/autoria ou gate estão incertos. |
| **Responsável por Git, documentação e release** | Branches pequenas, PR, histórico verificável, `git diff --check`, links corretos, revisão de publicação Pages; jamais contornar proteção da `main`. | Bloqueia merge/deploy sem revisão ou evidência. |
| **Liderança de produto CAA, acessibilidade e experiência** | Garantir que app local-first e comunicação offline permaneçam independentes; revisar fluxos e linguagem, acessibilidade, usabilidade e avisos. | Bloqueia regressão que interrompa comunicação, acessibilidade ou autonomia. |
| **Arquitetura/backend e dados** | OpenAPI `/v1`, modelo de domínio, adaptadores de identidade/persistência, migrations PostgreSQL portáveis, desenho de autorização server-side e implantação separada. | Bloqueia cliente com autoridade indevida, dependência de API para CAA ou ausência de isolamento. |
| **Segurança, privacidade e proteção de dados** | Threat model, minimização/classificação, sessões, recuperação, MFA privilegiado, RLS/grants, logs mínimos, retenção/exclusão, incidentes e revisão de avisos/contratos antes da coleta. | Bloqueia credenciais/dados reais sem controles comprovados. |
| **Engenharia de QA/operação** | CI com banco descartável, testes allow/deny, acessibilidade, export/restore, alertas, runbooks, limites de consumo, rollback e evidências por commit. | Bloqueia promoção sem testes, restauração e operação praticáveis. |
| **Consultoria familiar/clínica/educacional, quando aplicável** | Revisar necessidade, linguagem, riscos de uso e salvaguardas de qualquer função conectada; não recebe acesso por patrocínio/benefício. | Recomenda pausa de piloto quando risco ao usuário não está mitigado. |

Decisões reversíveis de implementação podem ser feitas pela equipe dentro desta arquitetura. A equipe não pode assumir, em nome do proprietário, contratação/ativação de cobrança, domínio, coleta de dados pessoais reais, importação de dados, publicação ampla ou alteração material do produto.

## 4. Arquitetura inicial recomendada — sem contratar serviço

### Caminho incremental

Começar por **desenvolvimento local e CI efêmera**, não por criação de contas externas. Isso valida domínio, esquema e autorização sem comprometer o proprietário com um fornecedor. A abstração deve permitir escolher ou trocar provedor depois.

```text
Visitante ──> GitHub Pages (institucional, políticas e entrada pública)
                         └──> link para origem independente do portal, somente após validação

Portal independente ─┐
App Flutter (futuro) ─┴── HTTPS ──> API REST própria /v1 (autorização no servidor)
                                      ├── adaptador de identidade
                                      └── adaptador de persistência ──> PostgreSQL

Local/CI: API + Postgres descartável + fixtures sintéticas; sem serviços externos
```

### Limites e controles

1. **GitHub Pages:** conteúdo institucional estático, política, contato e link. Não coletar senha, armazenar sessão, colocar chave privilegiada ou implementar autorização no cliente.
2. **Portal/login:** origem separada do Pages para qualquer login e experiência autenticada. A URL de preview não é endereço público aprovado. Não habilitar cadastro aberto por conveniência.
3. **API própria `/v1`:** monólito modular inicialmente, contrato OpenAPI; única fronteira para o portal e futura sincronização explicitamente aprovada. Autorização, vínculo, consentimento, finalidade, escopo e revogação são validados no servidor em cada requisição.
4. **Persistência:** Postgres padrão, schema e migrations versionados. Recursos multi-organização carregam tenant/contexto; aplicar grants mínimos e RLS como defesa adicional, não como substituto da validação na API.
5. **Identidade:** interface/adaptador para um provedor gerenciado escolhido posteriormente. Testes locais podem simular identidades sintéticas, mas isso não é login de produção. Não construir autenticação artesanal no frontend.
6. **Dados MVP:** fixtures inteiramente sintéticas para console/organizações/licenças de demonstração. Sem crianças ou famílias reais, perfis comunicacionais, nomes, conteúdo CAA/frases, áudio, vídeo, fotos, diário, dados ABC/clínicos, sincronização ou pagamento.
7. **Armazenamento de arquivos:** nenhum no primeiro MVP. Se aprovado futuramente, bucket privado, autorização por operação, URLs curtas após validação, retenção/exclusão e restauração testadas.
8. **Segredos:** nunca em Git, `site/`, código Flutter, bundle web, issue, log ou screenshot. Chaves administrativas somente em secret manager e exclusivamente no backend.
9. **Princípio de produto:** app CAA, modo offline, acessibilidade, comunicação básica e dados locais não dependem de conta, conexão, assinatura ou backend. Falha remota nunca bloqueia a comunicação.

### Candidata técnica, não decisão comercial

Quando houver motivo para teste remoto sintético, a composição que melhor preserva o contrato existente é **API TypeScript/Hono em Cloudflare Workers + Supabase Auth/Postgres**, deixando lógica e contrato na API e Postgres atrás de adaptador. Alternativa é Supabase mais integrado, com simplicidade maior e acoplamento maior. **Não criar contas ou ativar billing por causa desta recomendação.** É válido começar e completar Gates 0–2 somente localmente.

Os relatórios consultados registram cotas que devem ser revalidadas na contratação: Workers Free tem teto diário e limite de CPU por invocação; Supabase Free pode pausar por inatividade, não inclui backup automático e o SMTP padrão é best-effort com limite de 2 mensagens/hora. Render Free/Postgres tem hibernação e expiração do banco, portanto não é opção de continuidade. Nenhuma dessas cotas é SLA ou permissão para dados reais.

## 5. Critérios para escolha de provedor

A equipe deve comparar fontes oficiais atualizadas no momento da decisão e preencher cada item. “Grátis” isoladamente não é critério de adequação.

1. **Adequação ao domínio:** Postgres relacional para organizações, memberships, consentimentos, grants e auditoria; quantificar retrabalho se escolher SQLite/D1 ou NoSQL.
2. **Portabilidade e custo de saída:** `pg_dump`/`pg_restore`, SQL padrão, exportação dos dados, migrations, limites de extensão, dependência de funções e plano separado de migração de identidade/sessões.
3. **Continuidade operacional:** políticas de pausa/hibernação/expiração, disponibilidade contratual, backups incluídos, retenção, RPO/RTO, teste de restauração e opções pagas reais. Não inferir backup a partir de export manual.
4. **Identidade e acesso:** MFA administrativo, sessões e revogação, recuperação, controles de abuso, OAuth/PKCE ou cookies seguros, capacidade de migrar usuários e canal de e-mail transacional confiável.
5. **Segurança:** isolamento por projeto/ambiente, logs e alertas sem payload, gestão de segredo, criptografia, grants/RLS, região, resposta a incidente e compromissos contratuais adequados ao uso futuro.
6. **Custo total previsível:** compute, banco, egress, e-mail, backup, domínio, ambientes extras, armazenamento, impostos/câmbio e operação. Definir responsável, teto e gatilhos de upgrade. Alertas de orçamento não necessariamente limitam cobrança.
7. **Falha segura e cotas:** comportamento quando cota acaba, provedor pausa ou e-mail falha; garantir que erro remoto não bloqueie CAA local nem cause perda silenciosa.
8. **Escala e operação da equipe:** maturidade, documentação, suporte, região disponível, observabilidade, complexidade de administração e esforço para manter migrations/restore.
9. **Privacidade e finalidade:** região não equivale automaticamente a conformidade. Confirmar papéis, contratos, retenção e tratamento antes de dados reais.
10. **Acesso e titularidade:** contas do provedor e domínios sob controle institucional definido pelo proprietário, MFA e pelo menos um plano de recuperação administrativa.

**Regra de seleção:** para sandbox, preferir menor custo de reversão e dados sintéticos; para piloto real, rejeitar qualquer opção sem continuidade, restauração ensaiada, identidade/e-mail confiáveis, controles de segurança e aprovação explícita do custo. Revalidar preços/cotas em fonte oficial imediatamente antes de provisionar. A comparação de setembro de 2026 é referência, não oferta vigente.

## 6. Sequência de programação em fases

Cada fase é feita em branch própria a partir da `main` vigente, com escopo pequeno, testes, diff revisado e PR. Nenhuma fase abaixo é autorização automática para a seguinte.

### Fase 0 — Baseline e governança (imediata, sem código de produto)

- Buscar estado atualizado e comparar `main`, branch, CI e PRs abertas; registrar commit e condição observados.
- Revisar os diffs compartilhados e localizar autoria antes de preservar, editar ou incluir alterações preexistentes.
- Consolidar decisão A, fronteira Pages/portal, proibição de coleta real e estado de migração Manus como provisório; documentar decisões pendentes sem apagar registros históricos.
- Não fazer merge de #68/#64 nem trabalhar na `main`.

**Aceite:** documentos sem gate A/B/C obsoleto; branch de trabalho baseada em `origin/main` atual; mudanças alheias conhecidas e separadas.

### Fase 1 — Primeiro PR documental

Criar PR exclusivamente de continuidade/ADR/checklist. Atualizar os documentos centrais listados no checklist da seção 8, datar a decisão, corrigir links e separar o status do site Pages do portal/backend ainda não implementados. **Não incluir código de produção, mudança da CTA ou credenciais.**

**Aceite:** conteúdo coeso, `git diff --check` limpo, histórico preservado, PR revisável, checks documentais apropriados e `main` inalterada.

### Fase 2 — Especificação e threat model executáveis

- Delimitar MVP sintético e inventário de dados permitido/proibido.
- Registrar ADR, diagrama de fronteiras e threat model; modelar identidade, organizações, vínculos, consentimento, grants e auditoria nos contratos existentes.
- Consolidar matriz de autorizações e erros anti-enumeração; especificar API `/v1`/OpenAPI, migrações SQL, retenção, exclusão e requisitos de sessão/recovery.

**Aceite:** revisão de arquitetura e segurança; nenhuma dependência/conta externa necessária; escopo e testes são verificáveis.

### Fase 3 — Fundação local e CI

- Implementar API modular/adaptadores e migrations Postgres em branch, usando ambiente local e banco efêmero em CI.
- Criar fixtures resetáveis sintéticas e execução de migrations do zero/evolução; adicionar lint, testes e scan de segredo conforme stack.
- Manter API e portal fora de Pages para componentes autenticados; não implementar pagamento, mídia nem sincronização.

**Aceite:** build e testes repetíveis; dados destruídos ao final de CI; sem segredos; app CAA não depende dos novos serviços.

### Fase 4 — Autorização e identidade em ambiente sintético

- Implementar identidade escolhida somente após seleção técnica e aprovação necessária; MFA privilegiado, sessão, logout/revogação, recuperação, rate limit e e-mail de teste.
- Autorizar cada operação no servidor considerando usuário/estado, organização, membership, vínculo, propósito, consentimento, escopo, prazo e recurso. Aplicar RLS e grants mínimos.
- Executar testes negativos no servidor e diretamente no banco, inclusive cross-tenant, consentimento, convite, revogação, exportação e idempotência.

**Aceite:** todas as negações críticas passam; identidade sintética não acessa outro tenant; não se coletam dados pessoais reais.

### Fase 5 — Staging sintético e operação

- Só com origem/ambiente autorizados, implantar com organizações e usuários fictícios; testar CORS/origins, cookies/CSRF se aplicável, erros, acessibilidade, mobile, limites e e-mail.
- Exportar e restaurar em banco vazio; validar contagens e integridade. Documentar RPO/RTO, alertas, incidentes, suporte, runbook e gatilhos financeiros.

**Aceite:** restore demonstrado, operação praticável e custos/limites compreendidos; não equivale à autorização de piloto real.

### Fase 6 — Gate de piloto real (se e somente se solicitado/aprovado)

Antes de qualquer dado pessoal: revisão jurídica/privacidade e LGPD, controlador/operadores, finalidade/base legal/melhor interesse, consentimentos, contratos, política e avisos atualizados, retenção/exclusão, suporte e resposta a incidentes. Exigir MFA, canal transacional, sessão revogável, backup/restore e plano pago ou outra continuidade aprovada. Definir população, campos estritos, responsáveis, acesso, prazo e consentimento explícitos.

**Aceite:** autorização do proprietário e gates técnicos/privacidade concluídos. Sem isso: manter staging sintético e dados reais desligados.

### Fase 7 — Migração validada e CTA pública

- Começar com ambiente novo e vazio; não importar Manus por padrão. Validar a origem independente HTTPS, login/logout, erros, testes negativos, isolamento, restore, operação e privacidade.
- Quando aprovado, preparar PR pública **separada e pequena** para trocar o CTA; publicar pelo workflow `site-pages.yml`; verificar a URL oficial `https://falacomigocaa-app.github.io/fala-comigo/`, HTML publicado e ausência de redirecionamento ao Manus.
- Planejar rollback para página de manutenção/indisponibilidade, nunca para dependência Manus após o corte.

**Aceite:** o destino funciona independente, sem login no Pages, meets os gates de segurança/operacional, CTA oficial verificada e PR publicada. O portal atual só deixa de ser provisório após esse aceite.

## 7. Matriz de riscos

| Risco | Prob. / impacto | Sinal ou condição | Mitigação e resposta | Gate |
|---|---|---|---|---|
| Senha enviada/coletada no GitHub Pages ou autenticação falsa no cliente | Média / **Crítico** | Formulário de login no site estático; chave/token no bundle | Login em origem independente; API server-side; nunca publicar segredo; interromper antes de aceitar credenciais | Fases 1, 4 e 7 |
| Acesso cruzado entre organizações ou uso indevido de consentimento | Média / **Crítico** | Teste negativo ausente/falha, IDOR/BOLA, revogação não efetiva | Deny-by-default, autorização atual na API, RLS/grants e testes de duas organizações por operação; qualquer sucesso indevido bloqueia promoção | Fases 2–5 |
| Dados reais inseridos em plano grátis/sandbox ou prévia | Média / **Crítico** | Nomes, e-mails familiares, perfis, mídia ou payload real em banco, logs ou screenshot | Fixtures sintéticas, reset, proibição explícita, inspeção de logs; suspender ambiente, preservar evidência mínima segura e executar resposta a incidente se ocorrer | Fases 0–6 |
| Pausa, limite, expiração, e-mail falho ou ausência de backup do free tier | Alta / **Alto** | Projeto pausado; quota excedida; recuperação não chega; não há restore | Free apenas sintético; testar export/restore; escolher tier/plano adequado e provedor de e-mail antes de dados reais | Fases 5–6 |
| CTA ou migração quebrada / URL fictícia | Média / **Alto** | 404, preview expirado, redirecionamento Manus depois do corte | Não publicar destino antes de gate; PR separada; smoke test pós-deploy; rollback para manutenção, nunca URL inventada | Fase 7 |
| Merge de PR obsoleta ou inclusão de diff alheio | Média / **Alto** | #68/#64 tratadas como base; mudanças compartilhadas sem autoria revisadas | Branch nova da `main` atual; inspecionar status/diffs; reaplicar seletivamente; revisão humana e CI | Fases 0–1 |
| Mudança do portal degradar CAA/offline | Baixa / **Crítico** | Falha remota bloqueia grade, fala ou modo offline | Separação de módulos; testes de instalação/offline e regressão; feature remota sem autoridade sobre núcleo | Fases 3–7 |
| Migração de banco/auth incompleta ou lock-in inesperado | Média / **Alto** | Dump não restaura identidade, roles, grants ou objetos; callback inválido | Postgres/migrations portáveis, adaptadores, plano separado de migração de identidade, ensaio em ambiente vazio e reconciliação de integridade | Fases 2, 5 e 7 |
| Coleta de dados de menores sem avisos/retensão/governança adequados | Média / **Crítico** | Política só local; papéis LGPD ou finalidade indefinidos | Não coletar; revisão jurídica/privacidade e contratos antes do piloto; minimização, consentimento, exclusão e melhor interesse definidos | Fase 6 |
| Cobrança inesperada ou exposição de conta/provedor | Média / **Alto** | Limites sem responsável, cartão ativado, billing excede expectativa | Nenhuma contratação automática; proprietário aprova teto, responsável, alertas e contingência antes de billing; lembrar que alerta não é limite | Fases 0, 5–6 |
| Recuperação/MFA/sessão administrativa insuficiente | Média / **Alto** | Conta compartilhada, e-mail de teste, sessão não revogável ou ausência de MFA | Identidades individuais, MFA para privilégio, recovery ensaiado, SMTP confiável e runbook de administrador | Fases 4–6 |

**Parada imediata:** qualquer vazamento de segredo/dado real, sucesso em teste que deveria negar, ausência de restore antes de piloto, acesso cross-tenant ou falha remota que bloqueie CAA interrompe o avanço até correção e repetição documentada do gate.

## 8. Checklist do primeiro PR

**Objetivo do primeiro PR:** conciliar documentação com a decisão confirmada e tornar a sequência executável. Deve ser pequeno, documental e derivado da `main` vigente. Este relatório não afirma que tal PR já foi criado.

### Preparação e proteção da `main`

- [ ] Confirmar o estado mais recente com `git fetch origin --prune`, `git status --short --branch`, `git rev-parse origin/main`, branches e PRs abertas.
- [ ] Registrar a revisão histórica da auditoria: `b43e18b` foi baseline daquele snapshot, mas confirmar se ainda é ponta de `origin/main`.
- [ ] Revisar diffs preexistentes em `CONTINUAR_AQUI_PRIMEIRO.md`, `PROMPT_RETORNO_NOVO_AGENTE.md` e `docs/CONTINUIDADE_ASSISTENTE_IA.md`, além dos relatórios já no workspace; preservar autoria e separar o que não pertence à PR.
- [ ] Criar branch de trabalho nova baseada na `origin/main` atual, sem commit direto, reset destrutivo, force-push ou merge de #68/#64.
- [ ] Manter a `main` protegida e não contornar regras de revisão/checks.

### Conteúdo documental

- [ ] Registrar explicitamente “Opção A escolhida”; retirar instruções vigentes de aguardar A/B/C, mantendo-as apenas como histórico superado datado.
- [ ] Atualizar `CONTINUAR_AQUI_PRIMEIRO.md` e `PROMPT_RETORNO_NOVO_AGENTE.md`: Pages institucional; portal/login separado; Opção A decidida; decisões restantes são gates separados.
- [ ] Atualizar `PROJECT_HANDOFF.md`: site institucional Pages publicado é distinto de backend/portal não implementado; corrigir metadados de branch/commit somente com estado verificado.
- [ ] Atualizar `README.md` e `docs/CONTINUIDADE_ASSISTENTE_IA.md` com links para a decisão e registrar a supersessão como entrada atual, sem reescrever fatos históricos.
- [ ] Referenciar este plano e os relatórios `01`–`05`; deixar claro que contratos são especificações e que nenhum backend independente está comprovado.
- [ ] Registrar o portal Manus como provisório até migração independente validada, sem afirmar que é solução-alvo, sem importar dados e sem inventar URL substituta.
- [ ] Registrar escopo sintético e gates de segurança/privacidade/backup/custo para qualquer piloto real.
- [ ] Distinguir “Opção A de infraestrutura” das opções antigas de layout parental.

### Revisão e merge

- [ ] Confirmar que a PR não inclui código de produção, mudança de CTA, credenciais, dados reais ou arquivos alheios sem revisão/autoria clara.
- [ ] Verificar referências e links, consistência entre os documentos e texto de histórico.
- [ ] Executar `git diff --check` e revisar todo o diff; rodar checks documentais aplicáveis.
- [ ] Descrever no corpo da PR baseline, arquivos, decisões alteradas, limites, validação executada e o que continua pendente.
- [ ] Aguardar checks e revisão; só integrar via fluxo protegido e registrar commit/resultado em continuidade.
- [ ] Não considerar o primeiro PR como implementação do portal, migração de Manus ou autorização para credenciais, contrato, cobrança, coleta real ou lançamento.

## 9. Decisões que ainda precisam do proprietário

A Opção A macro **não** está pendente. Ainda precisam ser definidos/aprovados, no momento adequado:

1. **Fronteira da interface:** confirmar operacionalmente que Pages é só institucional/entrada e que login/portal autenticado ficam em origem independente, conforme a orientação de segurança e política do Pages. É o gate anterior à coleta de credenciais.
2. **CTA enquanto provisório:** forma de apresentar publicamente o acesso atual até haver migração validada (mantê-lo claramente temporário ou ocultá-lo/desativá-lo em PR de conteúdo). Nenhuma dessas decisões autoriza rotular Manus como solução independente. Nenhuma URL fictícia.
3. **Escopo funcional do MVP sintético:** quais entidades administrativas/demonstrações ficam dentro e fora. Default recomendado: console e organizações/licenças fictícias; sem família/criança, clínica real, mídia ou sincronização.
4. **Provedor e região:** seleção após comparar documentação, região, custos e condições atuais. A candidatura Workers + Supabase Auth/Postgres é hipótese técnica; pode-se começar local sem escolher serviço.
5. **Titularidade e operação:** pessoas responsáveis pelas contas de infraestrutura, MFA, e-mail/remetente, recuperação, suporte, alertas, incidentes, domínio e acesso administrativo.
6. **Orçamento e gatilhos de upgrade:** aprovador, teto mensal, alertas e indicadores que obrigam upgrade/pausa; nenhuma ativação de billing sem aprovação.
7. **Continuidade:** RPO/RTO aceitáveis, retenção de backups, frequência de teste de restauração e procedimento de export/migração de dados e identidade.
8. **Dados e piloto real:** campos, finalidade, papéis de controlador/operador, base legal, melhor interesse, consentimentos, retenção/exclusão, participantes e autorização explícita. Até aprovação: zero dados reais.
9. **Autenticação/recuperação:** política de MFA para contas privilegiadas, canal de e-mail transacional e responsáveis pelo bootstrap/recuperação. Nenhuma senha deve ser registrada no repositório.
10. **Publicação e migração:** aprovação específica para a troca da CTA quando todos os critérios do Gate 7 forem comprovados. Importação de dados Manus, se algum dia solicitada, requer autorização separada e inventário próprio.

Não é necessário decidir agora a contratação ou comprometer-se com um provedor para avançar nas fases documental, de desenho e desenvolvimento local/CI. Se qualquer escolha passar a envolver custo, dados pessoais, exposição pública ampla ou migração irreversível, parar no gate correspondente e obter autorização explícita.

## 10. Referências internas

- [`01-git-continuity.md`](01-git-continuity.md) — linha de base, PRs e continuidade Git.
- [`02-architecture.md`](02-architecture.md) — arquitetura candidata e separação Pages/portal/API.
- [`03-providers.md`](03-providers.md) — comparação e limites de provedores (revalidar no momento da decisão).
- [`04-security.md`](04-security.md) — identidade, sessão, autorização, privacidade e riscos.
- [`05-migration-qa.md`](05-migration-qa.md) — sequência, critérios de aceite e transição.
- [`AGENTS.md`](../../AGENTS.md) — autonomia, prioridades e fluxo com `main` protegida.
- [`CONTINUAR_AQUI_PRIMEIRO.md`](../../CONTINUAR_AQUI_PRIMEIRO.md) — instruções de continuidade.
- [`PROJECT_HANDOFF.md`](../../PROJECT_HANDOFF.md) — transferência do projeto.
- Site oficial institucional: <https://falacomigocaa-app.github.io/fala-comigo/>.
