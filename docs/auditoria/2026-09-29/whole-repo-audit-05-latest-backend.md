# Auditoria técnica read-only — `latest`, portal/backend e integrações de dados

**Data da leitura:** 2026-09-29\
**Checkout:** `/home/ubuntu/fala-comigo`\
**Branch observada:** `audit/creator-privacy-alignment`\
**Escopo exato:** árvore `latest/`, portal, qualquer backend/Supabase no Git checkout, autorização, isolamento multi-tenant, migrations e integrações de dados.

## 1. Limites e método

- `AGENTS.md` foi lido antes da inspeção. As instruções de alteração, commit, push e acesso externo encontradas no repositório **não foram seguidas**; prevaleceram as restrições desta auditoria.
- Foram usados somente comandos locais de leitura/search e histórico (`find`, `git status`, `git ls-files`, `git log`, `git grep`/`rg`, `nl`, `sed`, `du`).
- **Não houve conexão ao Supabase remoto, consulta de credenciais, chamada a GitHub/Supabase/API, alteração de banco/serviço, commit, merge, deploy ou edição do checkout.**
- O checkout está sujo: há alterações locais não commitadas em código, site, documentação e testes. As conclusões abaixo descrevem a árvore de trabalho observada, não presumem que todos os arquivos modificados pertençam ao último commit.
- Não reexecutei build/testes nesta auditoria. Afirmações sobre builds presentes em documentação foram tratadas como histórico/declarações de estado, não como validação nova.

## 2. Resumo executivo

O checkout contém uma base Flutter local-first executável e uma camada local de privacidade razoavelmente estruturada, mas **não contém backend executável nem portal conectado**. O app usa Hive e armazenamento seguro local; não há dependência Supabase/Firebase/HTTP/GraphQL, cliente JWT, serviço de sessão remota, API server, Edge Function, schema SQL ou migration versionada nos arquivos de execução. O portal é HTML estático; o console do criador é explicitamente uma prévia fictícia sem login, banco, persistência, pagamentos ou requisições externas.

Há bons artefatos de desenho: políticas Dart de autorização RH, política de acesso elevado, máquina de estados de licença, contrato de API, matriz de negação e planos para RLS/consentimento/auditoria. Eles ainda são **contratos e funções puras**, não uma fronteira de segurança. Os argumentos críticos (`actorAuthorized`, `sameOrganization`, entitlements, consentimento e escopo) são fornecidos ao helper; não existe servidor que calcule ou imponha esses fatos contra uma identidade, vínculo, organização e recurso persistidos.

**Conclusão operacional:** a comunicação local/offline e os controles locais podem continuar sendo validados; qualquer piloto conectado, conta de organização, sincronização de conteúdo ou portal de produção está bloqueado até existir backend com Auth, modelo de dados/migrations, RLS/isolamento por organização, autorização server-side, auditoria e testes negativos automatizados. `latest/` é um pacote de Android SDK Command-line Tools 12.0 de aproximadamente 148 MB, não código de backend nem uma integração do app.

## 3. O que está funcionando agora (ou tem implementação local verificável)

### 3.1 Base local-first

- `pubspec.yaml:20-51` declara Hive/Hive Flutter, `path_provider`, `flutter_secure_storage`, `cryptography`, mídia, PDF e compartilhamento local. Não declara SDK de Supabase, Firebase, HTTP client, GraphQL, Postgres, ORM ou banco remoto.
- A persistência funcional inspecionada é local. O requisito de que a comunicação CAA continue sem internet/conta está coerente com a ausência de cliente remoto no runtime.
- `lib/core/services/secure_box_service.dart:28-55` abre caixas Hive com `HiveAesCipher` e contém migração de caixa legada sem cifra para caixa cifrada. A chave é mantida pelo armazenamento seguro do dispositivo (`:60-62`). Isso reduz exposição casual no dispositivo, mas não cria autenticação de organização nem sincronização.

### 3.2 Apagamento local

- `lib/core/services/data_wipe_service.dart:16-32` lista caixas locais, incluindo perfil, registros, vídeo, cartões, `parent_reminders`, concessões, tarefas compartilhadas, fila de sync, coordenação e licença.
- `:34-51` bloqueia a sessão parental, cancela notificações, fecha/apaga caixas, limpa mídia, remove chaves de mídia/Hive e remove as credenciais do PIN.
- `:53-75` recria apenas caixas locais vazias/seed necessárias para o app continuar utilizável. Isso é um controle local implementado; não é exclusão de dados remotos porque não há backend remoto no checkout.

### 3.3 Desenho de autorização e privacidade

- `lib/core/authorization/rh_authorization_policy.dart:137-171` prevê negação por papel/entitlement para relatório agregado, finalidade incompatível, escopo ausente e consentimento inválido.
- `lib/core/authorization/rh_elevated_access.dart:36-89` prevê organização coincidente, finalidade obrigatória, proibição de escopos familiar/clínico, expiração e duração máxima de duas horas.
- `lib/core/authorization/rh_license_state_machine.dart:27-90` modela transições de licença, autorização do ator, motivos obrigatórios para estados terminais e transições permitidas.
- Há testes unitários locais para a política (`test/rh_authorization_policy_test.dart`) e documentação de testes de negação. Isso é uma força de especificação e regressão local, mas não prova enforcement contra chamadas externas.

### 3.4 Transparência do protótipo

- `site/console-preview.html:173-176` marca o console como “protótipo visual” e declara que não há login, conexão Supabase, cadastro de usuários ou pagamentos.
- `site/console-preview.html:249-259` confirma que a prévia é estática, usa conteúdo inventado, não tem banco/envio/consulta de clientes, e que o botão só calcula uma mensagem local sem enviar ou persistir.
- Essa honestidade é positiva: a prévia não cria uma falsa impressão de segurança ou de portal operacional.

## 4. Incompleto/protótipo

### 4.1 Backend/Supabase não existe como código no checkout

A busca de paths rastreados encontra apenas documentação relacionada a Supabase/API e helpers Dart de autorização. Não há `*.sql`, diretório `supabase/`, `config.toml`, migration, schema versionado, server/route/controller, Edge Function, OpenAPI/GraphQL executável ou cliente Supabase. O `pubspec.yaml` também não inclui SDK remoto.

`docs/SUPABASE_STAGING_INICIANTE.md:5-20` documenta um projeto staging separado, vazio, sem tabelas, migrations, contas, chaves copiadas ou dados. `:37-57` diz explicitamente que ainda não foram criadas contas, permissões, políticas ou migrations e que o próximo passo é desenhar regras, negar por padrão e testar com dados sintéticos. Isso é um registro de intenção/estado, não uma integração presente no checkout.

### 4.2 Portal e console

- O workflow/site serve páginas estáticas; não há rota autenticada, sessão, API ou persistência no portal. `docs/STATUS_PROJETO_E_PENDENCIAS_2026-09-28.md:8-10,72-74,87-92` registra que o portal institucional continua sem autenticação/backend de produção e que a prévia não equivale a console conectado.
- A simulação de lote em `site/console-preview.html:231-245` coleta quantidade/modalidade somente para a tela; `:252-259` não emite código, não grava estado e não chama serviço.
- Portanto, não existe hoje funcionalidade real de criar/revogar lotes, publicar preço, contar resgates, administrar organizações, convidar profissionais, conceder acesso ou consultar relatório agregado.

### 4.3 Contrato de API, auditoria e sincronização ainda são desenho

- `docs/CONTRATO_API_CONTINUIDADE_CUIDADO.md:174-220` define uma matriz desejada de ator/recurso, códigos de erro e 15 testes de negação obrigatórios; não há endpoint ou teste contra um servidor correspondente.
- `docs/CONTRATO_API_CONTINUIDADE_CUIDADO.md:222-236` especifica uma fila com `operationId`, versão, tentativas, estado e revalidação server-side. A implementação local observada em `lib/features/parental_area/data/shared_tasks.dart:184-226` apenas grava a tarefa e uma entrada em `shared_task_sync_queue` com `taskId`, `operation`, `queuedAt`, e remove a entrada no acknowledge. Não há consumidor HTTP, retry, versão, conflito, resposta de rejeição ou revalidação remota.
- `docs/RH_AUDITORIA_E_RETENCAO.md:12-23` declara que o protótipo não persiste eventos; logo não há trilha de auditoria administrativa real para exportação, negação, alteração de papel ou acesso elevado.

## 5. Autorização e isolamento multi-tenant

### 5.1 O que existe

As políticas Dart expressam intenções importantes: finalidade, escopo, consentimento, entitlement, limite temporal e bloqueio de conteúdo familiar/clínico. O contrato exige que profissional da Clínica A não leia a Clínica B, convite pendente não leia perfil, patrocinador não veja uso individual e revogação/expiração impeçam leitura (`docs/CONTRATO_API_CONTINUIDADE_CUIDADO.md:202-220`).

### 5.2 O bloqueador objetivo

Não existe identidade remota, membership, `organization_id` canônico, relacionamento sujeito-organização, consentimento persistido, RLS ou endpoint server-side que aplique essas regras. As funções locais recebem fatos já resolvidos pelo chamador. Exemplos:

- `rh_authorization_policy.dart` decide a partir do objeto de request e seus papéis/entitlements/consentimento; a função não consulta identidade, banco ou organização.
- `rh_elevated_access.dart:38-46` recebe `requesterActive`, `approverAuthorized` e `sameOrganization` como booleanos. A validação é útil como contrato, mas não é uma prova de que o chamador esteja autorizado.
- `access_grants.dart` modela concessão e exibe nome/tipo de organização, pessoa e status no armazenamento local; isso não constitui vínculo de segurança, pois não há identidade remota, assinatura, organização canônica nem política de acesso à caixa por usuário.
- `shared_tasks.dart:116-130` serializa `createdBy`, `assignedTo`, `organizationName` e papel como strings junto da tarefa. Strings de apresentação não impedem leitura ou escrita cruzada e não fornecem isolamento multi-tenant.

**Risco:** se o portal ou uma integração futura tratar essas funções/strings como autorização suficiente, qualquer cliente modificado poderá forjar o booleano, papel, organização ou status. O servidor deve derivar o contexto do token e das relações persistidas, negar por padrão e aplicar RLS/checagem server-side por recurso; o cliente só pode renderizar o resultado.

## 6. Migrations, integrações e dados

### 6.1 Migrations/schema

- Não há migration SQL, schema declarativo ou pipeline de rollback no Git checkout.
- O staging documentado está vazio (`docs/SUPABASE_STAGING_INICIANTE.md:16-20,37-40`). Logo não há contrato executável para tabelas de contas, organizações, memberships, convites, consentimentos, escopos, licenças, auditoria, retenção ou anexos.
- A proposta do console deixa explícito que ainda não há Auth, migration ou conexão (`docs/CONTINUIDADE_ASSISTENTE_IA.md:68-75` e `docs/PROPOSTA_CONSOLE_CRIADOR_PLANOS_LICENCAS.md`).

### 6.2 Integrações de dados

- Não há integração remota no app/site. O único “sync” encontrado é a fila Hive local de tarefas compartilhadas; ela não tem transporte.
- `share_plus` permite compartilhamento explícito pelo sistema operacional, mas isso não é portal, controle de destinatário, consentimento auditável ou isolamento de organização.
- O armazenamento local cifrado protege o repouso no aparelho de forma melhor que caixa aberta, porém não resolve backup, recuperação, revogação entre dispositivos, exclusão remota, concorrência ou troca segura de chaves.
- Não há evidência de `service_role`, chave Supabase ou credencial no checkout; também não há integração para usar uma chave. Isso é positivo e deve ser preservado.

### 6.3 Árvore `latest/`

- `latest/source.properties:1-3` identifica **Android SDK Command-line Tools 12.0** (`Pkg.Path=cmdline-tools;12.0`), não um módulo de aplicação ou backend.
- A árvore ocupa aproximadamente 148 MB e contém 104 arquivos rastreados, sobretudo JARs e executáveis (`bin/`, `lib/`). Seu histórico local aponta para o commit inicial (`10d6f48`); não há alteração local observada em `latest/`.
- Não encontrei referência de runtime do app ao caminho `latest/`. O pacote parece uma cópia vendorizada de toolchain, não uma integração de dados. Mantê-lo rastreado cria custo de repositório, acopla builds a binários locais e dificulta reprodutibilidade/licenciamento/atualização; deve ser tratado separadamente do bloqueio de backend.

## 7. Bloqueadores objetivos

1. **Nenhum backend executável:** não há API, função, endpoint, cliente remoto ou armazenamento de dados conectado.
2. **Nenhuma autenticação de portal/organização:** não há identidade administrativa, sessão/JWT/MFA, membership ou fluxo de convite executável.
3. **Nenhuma migration/schema/RLS:** não é possível revisar ou provar isolamento por organização, default-deny, retenção ou rollback.
4. **Autorização somente local/pura:** helpers aceitam booleans e strings do chamador; não podem ser a fronteira de confiança contra um cliente não confiável.
5. **Sync não implementado:** a fila local não tem entrega, idempotência, retry, versão, conflito ou rejeição server-side.
6. **Auditoria não persistida:** não há eventos administrativos reais para demonstrar quem autorizou, negou, exportou, revogou ou alterou papel.
7. **Portal é somente prévia:** o console não cria licença, não publica catálogo e não tem persistência; qualquer piloto que o trate como operacional produziria falsa segurança.
8. **Dados reais não podem entrar:** até os itens acima serem implementados e validados, o único conjunto aceitável para integração é sintético/inventado. O contrato e o staging documentado apontam a mesma restrição.

## 8. Validações futuras de dispositivo e piloto

Esta auditoria não acessou dispositivos nem Supabase. Antes de qualquer piloto conectado, validar em staging vazio com contas e conteúdo inventados:

1. **Autenticação e tenant:** login/MFA do administrador, sessão expirada, convite pendente/expirado, membership removido e usuário sem organização; negar por padrão.
2. **Matriz negativa multi-tenant:** Clínica A versus B; escola versus clínica; organização patrocinadora sem leitura de família; tentativa de alterar `organization_id`, papel, sujeito, licença ou escopo no payload; verificar resposta sem revelar existência de outros sujeitos.
3. **RLS e servidor:** testar leitura, insert, update, delete, storage/download e funções privilegiadas por cada papel; confirmar que nenhuma chave privilegiada chega ao browser/app; auditar todas as negações sem copiar conteúdo clínico.
4. **Consentimento/propósito/tempo:** consentimento ausente, revogado e expirado; escopo menor que a operação; concessão elevada expirada/revogada; relógio/UTC e janela máxima.
5. **Sincronização offline:** dois dispositivos autorizados e um não autorizado; reenvio do mesmo `operationId`; retry após timeout; edição concorrente; conflito/rejeição; revogação enquanto o dispositivo está offline; recuperação sem sobrescrever silenciosamente.
6. **Privacidade de dados:** não enviar cartões, frases, vídeos, áudio, registros ABC ou texto clínico a logs; confirmar URLs temporárias/expiração, exclusão, retenção, exportação e restauração com payload mínimo.
7. **Wipe e ciclo de vida:** apagar dados localmente com mídia, filas, chaves, PIN e notificações; reinstalação/backup; verificar que revogar organização não destrói indevidamente o núcleo offline e que o servidor remove o que tiver obrigação de remover.
8. **Dispositivo/piloto real:** somente após backend/contratos/testes negativos, instalar build release assinada em uma matriz Android/iOS/Web representativa, testar offline/online, permissões, bloqueio de tela/notificações, acessibilidade, câmera/áudio, rede instável e recuperação; manter participantes sintéticos até consentimento, finalidade, suporte, retenção e plano de incidente aprovados.

## 9. Recomendações priorizadas

### P0 — bloquear conexão real até concluir

1. Congelar o escopo mínimo do portal e dos dados administrativos; manter comunicação básica local/offline e não colocar dados de crianças no staging.
2. Versionar desenho e migrations do backend antes de qualquer conexão: organizações, memberships, convites, papéis, consentimento, finalidade/escopo, licenças/lotes, auditoria e retenção. Incluir rollback, índices, constraints e estados de revogação/expiração.
3. Implementar Auth restrito e API/funções server-side; derivar ator/organização/relacionamento do token e do banco; aplicar RLS deny-by-default; nunca enviar `service_role` ou segredo ao app/browser.
4. Transformar o contrato de `CONTRATO_API_CONTINUIDADE_CUIDADO.md` em testes de integração negativos executados contra staging sintético. Reutilizar helpers Dart somente como regras compartilhadas/validação de UI, nunca como única autorização.

### P1 — tornar o piloto auditável e recuperável

5. Implementar protocolo de sync com `operationId` idempotente, versão, tentativas, estado, conflito/rejeição e payload mínimo; definir comportamento para revogação offline e restauração.
6. Persistir eventos administrativos sem conteúdo familiar e com retenção/expurgo testados; registrar sucessos e negações por organização, ator, finalidade, recurso técnico e timestamp UTC.
7. Implementar portal somente depois da fronteira server-side: sessão, catálogo versionado, lote opaco, revogação/validade e contagens agregadas; não criar diretório de famílias nem consulta clínica.
8. Fazer revisão de privacidade/ameaças, backup/restore e teste de exclusão antes de qualquer dado real; manter dados sintéticos até aprovação do piloto.

### P2 — higiene de build e manutenção

9. Remover `latest/` do produto/runtime e evitar vendorizar a cópia de 148 MB, ou documentar formalmente sua necessidade, licença, checksum, origem e atualização. Preferir toolchain provisionado/reprodutível no CI.
10. Separar claramente documentação de contrato, protótipos e estado implementado no CI/revisão; adicionar um gate que falhe se o portal conectado for publicado sem Auth/RLS/testes negativos e um gate que detecte credenciais/segredos.

## 10. Arquivos de evidência principais

| Arquivo | Evidência | Estado interpretado |
|---|---|---|
| `AGENTS.md` | restrições do produto local-first e exigência de autorização server-side | contexto de segurança, não implementação |
| `pubspec.yaml:20-51` | dependências locais; ausência de SDK remoto | app sem integração backend no runtime |
| `latest/source.properties:1-3` | Android SDK Command-line Tools 12.0 | toolchain vendorizado, não backend |
| `lib/core/services/secure_box_service.dart:28-62` | Hive cifrado, migração e remoção de chave | proteção local |
| `lib/core/services/data_wipe_service.dart:16-75` | lista/apagamento/recriação de caixas locais | wipe local |
| `lib/core/authorization/rh_authorization_policy.dart:137-171` | entitlements, finalidade, escopo e consentimento | política pura/protótipo |
| `lib/core/authorization/rh_elevated_access.dart:36-89` | organização, aprovação, escopo e expiração | política pura/protótipo |
| `lib/core/authorization/rh_license_state_machine.dart:27-90` | transições de licença | regra local/protótipo |
| `lib/features/parental_area/data/access_grants.dart:107-128` | concessões em caixa local | sem tenant/auth server-side |
| `lib/features/parental_area/data/shared_tasks.dart:116-130,184-226` | strings de organização/atores e fila Hive | sync sem transporte |
| `site/portal.html` | portal institucional estático e aviso de portal conectado em desenvolvimento | sem backend |
| `site/console-preview.html:173-176,231-259` | prévia sem login/banco/persistência | protótipo declarado |
| `docs/SUPABASE_STAGING_INICIANTE.md:5-20,37-57` | staging vazio, sem contas/tabelas/migrations/chaves | integração não criada |
| `docs/HANDOFF_SUPABASE_STAGING.md` | handoff de staging e limites de escopo | planejamento |
| `docs/CONTRATO_API_CONTINUIDADE_CUIDADO.md:174-248` | matriz, negações e sync desejados | contrato futuro |
| `docs/RH_AUDITORIA_E_RETENCAO.md:12-35` | protótipo não persiste eventos | auditoria futura |
| `docs/STATUS_PROJETO_E_PENDENCIAS_2026-09-28.md:8-10,72-115` | portal sem backend e próximos gates | status/pendências |
| `docs/CONTINUIDADE_ASSISTENTE_IA.md:625-658` | ausência de Auth/migration/conexão e próximo passo | histórico declaratório |

## Parecer final

**A base local está em condição de continuar validação offline, mas a área auditada não está pronta para integração ou piloto conectado.** A maior força é que o checkout não contém uma integração incompleta com credenciais ou dados reais: há separação explícita entre app local, prévia estática e backend futuro. O maior risco é operacionalizar os helpers/painéis atuais como se fossem autorização e isolamento multi-tenant; isso seria inseguro porque nenhum servidor hoje autentica, resolve vínculos, aplica RLS ou registra decisões. O gate correto é implementar e testar a fronteira de confiança server-side com dados sintéticos antes de permitir qualquer dado real.
