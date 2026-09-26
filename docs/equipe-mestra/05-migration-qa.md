# Plano de migração e validação — Fala Comigo

**Data:** 25/09/2026  
**Papel:** Plano de migração e QA  
**Decisão considerada:** Opção A confirmada pelo proprietário — manter o site público no GitHub Pages, iniciar backend e banco independentes do Manus em camadas gratuitas quando possível e pagar somente quando a continuidade, o uso ou a segurança exigirem.  
**Escopo desta análise:** sequência de implementação, testes, migração gradual, aceite, rollback e critério para remover/substituir o link provisório do Manus.  
**Limite:** somente análise e documentação. Nenhum código de produção, configuração de provedor, conta, credencial, commit, publicação ou dado real foi criado ou alterado.

## Conclusão

A migração não deve ser tratada como uma troca direta de URL nem como importação do portal Manus. Neste checkout, os contratos e protótipos não provam que exista backend independente, autenticação, base remota ou autorização implantados. O site institucional estático está no Pages e `site/index.html` ainda contém o link “Espaço do Criador” para `https://falacomigo-kyrh225w.manus.space/creator`. Não foi identificada necessidade de migrar conteúdo de produção do Manus; portanto, o plano padrão é **não importar dados** e iniciar o novo ambiente vazio, com fixtures descartáveis inteiramente sintéticas.

O caminho seguro é: manter intacto o núcleo CAA local/offline; primeiro resolver a fronteira entre o site público e o portal autenticado; construir e testar a API e o banco em ambiente local/CI; fazer implantação não produtiva com identidades e organizações sintéticas; exercitar testes positivos, negativos, recuperação e rollback; e só depois promover, em etapas, as funções de baixo risco. A chamada pública só deve apontar para uma origem independente quando essa origem real estiver disponível, configurada e validada. Como o proprietário não quer o Criador vinculado ao Manus, a alternativa transitória é **remover/desativar a chamada ou substituí-la por aviso estático de “em migração” por uma PR de conteúdo** — não manter Manus como fallback e não apontar para um endereço inventado.

Há um bloqueio de arquitetura antes de construir login: a intenção “site/interface no GitHub Pages” precisa ser interpretada. O GitHub Pages é hospedagem estática e sua política diz que não se destina a hospedar gratuitamente um SaaS como propósito principal nem a transações sensíveis como envio de senhas/cartões [1]. A recomendação é delimitar “interface no Pages” como site institucional e ponto de entrada público; tela de login, sessão e portal autenticado ficam em outra origem independente. Não coletar credenciais no Pages até essa fronteira estar registrada.

## Estado observado e limites do que está provado

- A Opção A está escolhida; não se deve voltar a pedir a escolha A/B/C. A escolha exata dos provedores, região, origem do login, orçamento e plano de recuperação continua pendente.
- O endereço oficial do site é `https://falacomigocaa-app.github.io/fala-comigo/`. O workflow `.github/workflows/site-pages.yml` publica `site/` a partir de `main`; alterações públicas requerem branch/PR, checks, workflow e verificação do site publicado.
- O botão/link provisório para Manus foi localizado em `site/index.html` (rodapé). `site/rh/index.html` descreve um protótipo de dados sintéticos e avisa que backend e revisão de privacidade ainda são necessários; não é um console de produção.
- `CONTRATO_PORTAL_CONECTADO.md`, `CONTRATO_API_CONTINUIDADE_CUIDADO.md` e `CONTRATO_PORTAL_RH_AUTORIZACAO.md` são contratos/especificações, não evidência de endpoints, autorização, RLS ou testes de backend executados.
- O workflow Flutter existente cobre formatação, análise, testes e build Web. O workflow de Pages testa existência de arquivos e publica o conteúdo estático. Não foi encontrado nos arquivos inspecionados um workflow de backend, migration de banco, teste de isolamento multi-organização ou gate de deployment de API.
- A comparação já documentada recomenda, como candidata a **protótipo sintético**, API própria em Cloudflare Workers e Postgres/Auth gerenciados. Isso não é adoção aprovada nem decisão de contratação; revalidar provedores e termos antes de criar ambiente.
- O estado Git observado no início desta análise era branch `docs/record-option-a-public-url` com modificações pendentes em arquivos de continuidade e outros relatórios da equipe-mestra. Este relatório não alterou nem atribui essas mudanças; revisar o diff compartilhado antes de qualquer commit.

## Sequência recomendada e gates

### Gate 0 — Congelar o escopo e definir fronteiras

Antes de codificar autenticação, registrar num ADR e atualizar os documentos de continuidade para que não haja instrução antiga de “aguardar A/B/C”. Definir que o Pages é a presença institucional pública e que login/portal SaaS autenticado será hospedado em origem independente. Confirmar internamente o provedor candidato, a região e a separação de ambientes; não vincular cobrança, criar credenciais ou abrir cadastro externo nesta etapa.

Também fixar a linha de base do produto: funcionalidades CAA e uso offline não dependem de API, conta, pagamento ou estado do portal. O primeiro escopo conectado deve limitar-se a health/version, identidade administrativa controlada e entidades organizacionais/licenças de demonstração. Excluir dos ambientes gratuitos crianças reais, nomes, e-mails familiares, perfis de comunicação, cartões, frases, áudio, vídeo, registros ABC, prontuários e sincronização do app.

**Saída do gate:** ADR curto com fronteira Pages/portal, provedor apenas de protótipo, arquitetura de ambientes, classes de dados, responsáveis, URL provisória segura, decisões pendentes e condições explícitas para dados reais.

### Gate 1 — Preparar migração reversível e contratos executáveis

Construir numa branch revisável, começando por API REST versionada (`/v1`) e contrato OpenAPI. Isolar o domínio dos SDKs de identidade/banco por interfaces/adaptadores. Usar esquema Postgres portável, migrations SQL versionadas, constraints, `organization_id` em recursos organizacionais, dados de auditoria separados de conteúdo e fixtures resetáveis. Não embutir segredo privilegiado em `site/`, Flutter ou bundle JavaScript; não conceder autorização por esconder botão.

CI deve criar banco descartável, aplicar todas as migrations desde zero, aplicar evolução de uma versão anterior, executar testes e destruir os dados ao final. Incluir scan de segredo, build do portal/API e checagens de dependências. Cada run deve identificar commit/artefato; só migrar configuração por secret manager, sem copiar segredos entre ambiente local, staging e produção.

**Saída do gate:** API compila; contrato versionado; migrations repetíveis; fixtures sintéticas; ambiente local e CI reproduzíveis; sem chamada de produção ou importação do Manus.

### Gate 2 — Implementar autorização e identidade antes de fluxo público

Centralizar decisão de acesso no servidor. Em cada operação relevante, revalidar usuário/sessão, estado de conta, organização, membership, vínculo, consentimento, finalidade, escopo e prazo. Usar negação por padrão; aplicar grants mínimos e RLS no banco como defesa adicional, incluindo views/funções. Chaves administrativas permanecem no servidor. Definir sessão, logout e revogação, recuperação de conta, rate limit, confirmação de e-mail e MFA administrativo. Não confundir o PIN parental local com credencial de portal.

Executar a matriz de allow/deny no servidor e, quando Postgres for usado, diretamente contra o banco/RLS. Reutilizar e consolidar os testes já especificados nos contratos, sem aceitar que teste de UI substitua teste de autorização. Casos obrigatórios incluem organização A tentando ler B; convite pendente, expirado ou consumido; sessão inválida; vínculo ou consentimento vencido/revogado; escopo/finalidade incompatíveis; professor tentando conteúdo clínico; patrocinador tentando conteúdo ou uso individual; URL de arquivo indevida; repetição idempotente; conflito de versão; tentativa de enumeração; exportação não autorizada; revogação com próxima leitura negada.

**Saída do gate:** todos os testes de negação verdes em CI e revisados; erros externos não revelam existência de outra organização/sujeito; logs não têm senha, token, frase ou mídia; os fluxos de recuperação e revogação foram testados com contas sintéticas.

### Gate 3 — Testar o ciclo operacional em staging sintético

Implantar ambiente separado, sem dados reais e sem mistura com produção. Testar primeiro health/version e acesso administrativo; depois criar duas organizações de teste, usuários individuais de papéis distintos, convites, licenças e consentimentos fictícios. Validar caminhos de login/logout, expiração, revogação, concorrência, falha do provedor, limite de cota, indisponibilidade de e-mail, respostas 401/403/429 e recuperação após deploy. Confirmar CORS com origins exatos; se cookies forem usados, testar CSRF, `HttpOnly`, `Secure`, `SameSite` e proteção de cache. Testar teclado, leitor de tela, contraste e viewport móvel do portal separado.

Ensaiar exportação e restauração em banco vazio, conferir contagens e integridade, e documentar RPO/RTO desejados antes de qualquer uso com dados relevantes. Fazer carga coerente com a cota escolhida, monitorar latência, falhas, CPU, conexões, banco, egress e e-mails. Definir limite/alerta e responsável pela resposta; não considerar alerta de orçamento equivalente a teto de cobrança.

**Saída do gate:** teste de backup/restore concluído; alertas sem payload sensível; runbook de incidente, indisponibilidade, abuso e recuperação; custo máximo e gatilho de upgrade acordados. O piloto continua sintético.

### Gate 4 — Entrada gradual, com ativação explícita de cada função

Promover primeiro somente health/version e prévia autenticada com dados sintéticos. Em seguida, habilitar console do proprietário e gestão administrativa sintética. Depois validar organização, convite, consentimento e revogação com identidades de teste e duas organizações isoladas. Cada capacidade começa desligada por feature flag e só avança após gate próprio. Manter upload, mídia, frases, perfis de criança, prontuário, compartilhamento clínico, cobrança real e sincronização fora deste caminho.

Um piloto limitado com participantes reais é uma etapa posterior e separada: requer definição de controlador/operador, finalidade/base legal, melhor interesse, revisão jurídica/privacidade, consentimentos e contratos aplicáveis, retenção/exclusão, política e avisos atualizados, suporte, incidente, e-mail transacional confiável, MFA e sessão revogável, plano pago que assegure a continuidade necessária, backup/restore demonstrado, responsável pelo tratamento em cada organização e autorização explícita para os dados e o lançamento. Até esse gate, zero dados reais; não inferir conformidade LGPD a partir da arquitetura.

### Gate 5 — Troca pública da chamada do Criador

A troca para o novo destino **não** ocorre quando o backend “compila”, quando a tela existe em localhost, nem quando há uma URL de preview. O destino precisa existir na origem independente e estável, com TLS, callback/origin corretos e fluxo de ponta a ponta. Antes da PR que troca a CTA:

1. a nova origem está publicada, acessível sem Manus e com rota de entrada/caminho de erro claro;
2. a tela de login não está hospedada no Pages; nenhum segredo privilegiado está no cliente;
3. login, logout, expiração, recuperação, erro de rede e autorização de administrador passaram testes com contas sintéticas;
4. testes de negação, isolamento de duas organizações e RLS aplicável estão verdes;
5. privacidade e avisos refletem o tratamento real antes de qualquer coleta; registros e convites reais permanecem desligados enquanto faltarem gates legais/operacionais;
6. backup/restauração, alertas, limites de uso, contato de suporte e plano de rollback foram ensaiados;
7. navegação, acessibilidade, celular e retorno do link ao site foram verificados; a URL pública oficial foi testada após deploy.

Então abrir PR pequena apenas para a CTA/página pública, executar `site-pages.yml` e verificar o site efetivamente publicado em `https://falacomigocaa-app.github.io/fala-comigo/`. Confirmar que o link antigo não aparece mais no HTML publicado, que o link novo abre HTTPS e não redireciona a Manus, e que a página não promete funções ainda indisponíveis. Manter métricas de erro e disponibilidade sob observação após o corte. Se o portal oferecer apenas um subconjunto, comunicar que é acesso limitado e não habilitar signup ou coleta que ainda não foi aprovada.

Enquanto o Gate 5 não estiver satisfeito, o caminho público recomendado é uma alteração de conteúdo por PR que **retire ou desative a chamada Manus** e exiba aviso estático de migração/indisponibilidade temporária. Isso não equivale a migrar o portal e não deve encaminhar para uma tela falsa. Como o endereço antigo contradiz a decisão de independência, manter a chamada ativa é um risco de governança; a remoção transitória deve ser priorizada, mas não foi executada neste trabalho.

## Critérios de aceite objetivos

A migração só passa para o próximo gate quando houver evidência associada a um commit e ambiente identificados, e quando todos os itens aplicáveis abaixo forem aprovados:

- **Integridade do produto:** app CAA continua abrindo a grade em instalação limpa, funciona offline, fala/adiciona/limpa frases, preserva cartões e dados locais; falha remota não bloqueia comunicação básica. Executar testes existentes e testes do núcleo; manter a validação física Android separada do teste de backend. O APK Android e o portal não são evidência um do outro.
- **Build e banco:** lint/formatação/análise/testes, build Web/site/API, migrations desde vazio e upgrade de esquema passam; nenhum segredo ou dado real em Git, CI, screenshot ou log.
- **Autorização:** matriz positiva/negativa dos contratos executada do lado servidor; zero sucesso indevido em cross-tenant, consentimento, escopo, finalidade, validade, revogação e exportação. Repetição idempotente não duplica evento e conflito não sobrescreve silenciosamente.
- **Identidade e sessão:** usuário individual, recuperação e expiração testadas; logout e revogação impedem nova leitura; MFA privilegiada conforme a política; rate limit e respostas anti-enumeração verificados.
- **Privacidade:** nenhuma tela estática contém segredo; não há transmissão de conteúdo CAA ou mídia; os logs só contêm metadados mínimos; política/consentimento condizem com funcionalidades realmente ligadas.
- **Operação:** exportação, restore e integridade demonstrados em ambiente limpo; alertas e playbooks exercitados; ambiente sintético é separado; limites e custos estão explícitos; plano pago aprovado antes de dados reais quando a camada gratuita não oferece continuidade requerida.
- **Corte público:** PR e CI aprovados; workflow Pages concluído; URL oficial verificada; CTA aponta apenas à origem HTTPS independente funcional, sem Manus, falso login ou rota 404; rollback da CTA ensaiado.

Critério de parada: qualquer vazamento cross-tenant, sucesso em caso que devia negar, dado real inesperado, segredo exposto, ausência de restore, indisponibilidade de login/recovery, erro que bloqueie o núcleo local ou chamada pública quebrada impede promoção. Corrigir e repetir a evidência do gate afetado antes de prosseguir.

## Rollback e resposta a falhas

1. **Link ou frontend:** manter a CTA em PR separada do deploy do backend. Se o endereço novo falhar, retirar o link para uma página/aviso estático de indisponibilidade e reverter a alteração de conteúdo por nova PR/deploy Pages. **Não fazer rollback para o Manus**, pois essa dependência foi recusada pelo proprietário. Não transformar um endereço técnico de preview em destino público permanente.
2. **Portal/API:** manter build anterior implantável e configurações versionadas; feature flags permitem desligar login/convites/funções sem apagar dados. Se houver incidente de autorização, parar a função afetada e as gravações, revogar sessão/chave comprometida, preservar logs mínimos protegidos e investigar antes de reabrir.
3. **Esquema:** adotar migrações *expand/contract*: criar campos/tabelas compatíveis, implantar aplicação que aceite versões antiga e nova, verificar, e só depois remover/deprecar. Não executar migrations destrutivas no corte; rollback binário não restaura coluna/dados removidos. Quando `down` não for lossless, preferir correção futura (*forward fix*) testada.
4. **Dados:** como plano inicial não importa dados do Manus nem aceita conteúdo clínico, o rollback é simples: voltar aplicação para fora de serviço/leitura e manter banco sintético isolado. Se futura migração de dados vier a ser aprovada, exigir inventário, base legal/autorização, exporte com checksum, dry-run, freeze de escrita, reconciliação e restauração ensaiada. Depois de aceitar novas escritas, não restaurar cegamente snapshot antigo e perder operações; congelar, reconciliar ou reaplicar operações idempotentes.
5. **Provedor/cota/e-mail:** se uma cota ou serviço externo interromper o portal, comunicar indisponibilidade e manter app local funcionando; não degradar para permissões mais amplas, cache de conteúdo sensível, ou login fictício. Avaliar upgrade/migração em janela controlada, não diante do primeiro erro sem teste.
6. **Ensaio:** executar rollback em staging antes do corte: troca da CTA, reversão de frontend/API, desativação de feature flag, compatibilidade de esquema e restauração. Guardar resultado, commit, tempo medido e limitações no runbook; definir previamente RPO/RTO, responsáveis e limiar para interromper.

A estratégia de plano gratuito precisa ser interpretada como mecanismo de protótipo, não disponibilidade prometida. Na data da pesquisa, o Supabase Free lista 500 MB de banco, pode pausar projeto após uma semana de baixa atividade e não inclui backups automáticos; o SMTP padrão de Auth é limitado a duas mensagens por hora [2][3][4]. A documentação do Cloudflare informa limite Free de 100.000 requests/dia e 10 ms de CPU por invocação [5]. Portanto, planejar um gatilho de upgrade **antes** de aceitar dados reais, depender de recuperação por e-mail ou prometer operação contínua; confirmar preços, controles e cota novamente no momento de adoção. Nenhum valor citado congela preço ou autoriza despesa.

## Conflitos e decisões pendentes

1. **P0 — “Interface no Pages” versus login/SaaS.** Esclarecer o limite da Opção A. Recomendação: Pages para site público; origem independente para login e aplicação autenticada. Até isso estar resolvido, não coletar senha no Pages [1].
2. **P0 — CTA ainda aponta para Manus apesar da recusa do vínculo.** A página `site/index.html` mantém `/creator` em `manus.space`; os documentos declaram dependência provisória e migração não pronta. Resolver por página de aviso/remover CTA agora via PR e só colocar novo link após Gate 5.
3. **P0 — Contratos versus implementação.** Não confundir contrato de API, protótipo sintético ou build estático com serviço autenticado seguro. Há requisitos de backend, RLS, isolamento, auditoria e testes de negação ainda não comprovados.
4. **P0 — Ordem do piloto real e revisão legal.** `SEQUENCIA_FULL_STACK_ATE_PILOTO.md` coloca piloto controlado na sequência 11 e revisão jurídica/fiscal/suporte na 14, embora a descrição do piloto limite dados reais a aprovação documental e o checklist de lançamento exija controles previamente definidos. Realocar revisão jurídica/privacidade, e-mail, suporte, incidentes, retenção e backup para **antes** de qualquer piloto com dado pessoal; a etapa sintética pode ocorrer antes.
5. **P1 — “Gratuito primeiro” versus recuperação/continuidade.** Backup, SMTP, sessão, pausa e alertas variam por fornecedor/plano. Definir custo máximo/quem aprova e o gatilho de upgrade antes de abrir conta ou inserir dados relevantes; não esperar o limite estourar.
6. **P1 — Escolha de provedor e portabilidade.** O relatório de provedores considera Workers + Supabase como candidata sintética, mas isso ainda precisa decisão técnica. Definir também região, adapters, exportação de identidade, e-mail/callbacks e forma de migrar usuários; `pg_dump` não transfere automaticamente senha, sessões ou vínculos de IdP.
7. **P1 — Escopo de migração.** Não está provado que existam dados do Manus que devam ser migrados. Registrar “sem importação por padrão”; se houver pedido posterior, deve ser projeto aprovado separado, nunca scrape/importação incidental.
8. **P1 — Duplicidade de matrizes.** Os contratos API e RH repetem testes negativos com nomes distintos. Consolidar uma matriz canônica com endpoint/operação, ator, estado, resultado esperado, fixture, teste executado e evidência; os códigos de erro devem ser estáveis, sem revelar existência do recurso.
9. **Separação de gates Android e portal.** O problema de build/tela branca do app e validação física são gates móveis separados. Não podem servir como prova de migração web nem devem ser usados para atrasar a retirada de um link público que aponta para Manus; se futura sincronização for adicionada ao app, criar gate de integração próprio sem comprometer offline.

## Primeiras ações concretas

1. Registrar decisão de superfície: Pages = institucional; portal/login em origem independente. Se esta fronteira não refletir a intenção do proprietário, parar antes de coletar credenciais e retornar com a incompatibilidade.
2. Abrir uma PR exclusivamente de conteúdo para retirar/desativar o link `https://falacomigo-kyrh225w.manus.space/creator` e exibir aviso estático, sem criar URL substituta. Publicar pelo workflow atual e verificar a URL oficial. Esta é a recomendação de contenção; não foi feita nesta análise.
3. Criar ADR/issue para provedor candidato, ambiente local/CI/staging, região, origem autenticada, orçamento, owners, RPO/RTO e gatilho de plano pago; marcar credenciais, contratação e dados reais como gates separados.
4. Fixar escopo de MVP sintético e atualizar sequência de trabalho para pôr autenticação, testes de negação, backup/restore e operação antes de CTA com login e antes de qualquer piloto real.
5. Consolidar os 15 testes negativos de `CONTRATO_API_CONTINUIDADE_CUIDADO.md` e a matriz RH, adicionando caminho de teste executável por endpoint e por RLS. Exigir duas organizações sintéticas no CI.
6. Preparar migrations repetíveis e export/restore para Postgres vazio; testar desde zero e a partir da versão anterior antes de selecionar ou provisionar infraestrutura remota.
7. Depois que os gates de staging e operação passarem, implantar uma versão limitada sem dados clínicos, fazer canary com contas sintéticas e ensaiar rollback. Só então abrir a PR que troca a CTA do aviso para o destino independente.
8. Atualizar `CONTINUAR_AQUI_PRIMEIRO.md`, `docs/CONTINUIDADE_ASSISTENTE_IA.md`, handoffs aplicáveis e o ADR em cada etapa, com branch/commit, ambiente, comandos, evidência, resultado, limitações e próximo gate; não registrar segredos ou dados reais.

## Referências oficiais e documentos de base

Consulta a páginas oficiais de provedores em 25/09/2026. Revalidar limites e preço antes de adoção, porque podem mudar.

[1]: https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits "GitHub Pages — limites e limitações, incluindo uso de senha e SaaS"
[2]: https://supabase.com/pricing "Supabase — preços e cotas Free/Pro"
[3]: https://supabase.com/docs/guides/platform/free-project-pausing "Supabase — pausa de projeto Free e restauração"
[4]: https://supabase.com/docs/guides/auth/rate-limits "Supabase Auth — limite oficial de e-mails enviados"
[5]: https://developers.cloudflare.com/workers/platform/pricing/ "Cloudflare Workers — preços e limites do plano Free"
[6]: https://supabase.com/docs/guides/deployment/going-into-prod "Supabase — checklist oficial para produção"

Documentos internos consultados: `CONTINUAR_AQUI_PRIMEIRO.md`; `PROMPT_RETORNO_NOVO_AGENTE.md`; `AGENTS.md`; `PROJECT_HANDOFF.md`; `docs/CONTINUIDADE_ASSISTENTE_IA.md`; `docs/HANDOFF_TELA_BRANCA_APK.md`; `README.md`; `docs/SEQUENCIA_FULL_STACK_ATE_PILOTO.md`; `docs/PLANO_SEQUENCIAL_ATE_BUILD.md`; `docs/ROADMAP_FULL_CYCLE.md`; `docs/CHECKLIST_PRE_LANCAMENTO.md`; `docs/CONTRATO_PORTAL_CONECTADO.md`; `docs/CONTRATO_API_CONTINUIDADE_CUIDADO.md`; `docs/CONTRATO_PORTAL_RH_AUTORIZACAO.md`; `docs/MODELO_CUSTOS_E_PLANOS.md`; `docs/equipe-mestra/01-git-continuity.md`; `docs/equipe-mestra/02-architecture.md`; `docs/equipe-mestra/03-providers.md`; `docs/equipe-mestra/04-security.md`; `.github/workflows/flutter.yml`; `.github/workflows/site-pages.yml`; `site/index.html`; `site/rh/index.html`.
