# Especificação do MVP do portal sintético — Gate 1A

- **Status:** especificação para revisão; não implementado
- **Data:** 25/09/2026
- **Decisão relacionada:** [`ADR-001-opcao-a-portal-independente.md`](ADR-001-opcao-a-portal-independente.md)
- **Superfície:** portal independente do Criador, separado do GitHub Pages
- **Ambiente:** local e CI com dados sintéticos

## 1. Objetivo

Definir o menor recorte funcional que permita implementar e testar a base do portal sem escolher provedor, criar contas externas, receber senhas reais ou armazenar qualquer dado de criança, família ou saúde.

O MVP não é um portal de produção. Ele deve comprovar somente que organizações fictícias, usuários fictícios, papéis, convites, vínculos, licenças administrativas e auditoria podem ser isolados e autorizados no servidor.

## 2. Limites do MVP

### Incluído

O MVP terá duas organizações fictícias, usuários sintéticos, memberships, papéis administrativos, convites, vínculos de acesso, licenças fictícias, contexto de organização, eventos de auditoria sem payload sensível e respostas de autorização estáveis.

Também terá uma API local versionada em `/v1`, banco PostgreSQL descartável, migrations repetíveis, fixtures determinísticas e testes positivos e negativos entre organizações.

### Excluído

Ficam fora desta etapa: login de produção, recuperação de senha real, MFA real, e-mail transacional, dados pessoais reais, crianças, famílias, perfis funcionais, planos clínicos, agendas, fotos, vídeos, áudios, documentos, sincronização offline, pagamentos, armazenamento de arquivos, importação do Manus, domínio, deploy público e troca do CTA do site.

A UI pode existir futuramente como cliente de demonstração, mas não é necessária para considerar este Gate 1A especificado. A segurança não pode depender de esconder elementos de uma tela.

## 3. Fixture sintética canônica

Os dados devem ser determinísticos e claramente fictícios:

| Item | Valor sintético | Finalidade |
|---|---|---|
| Organização A | `org-demo-alpha` / “Clínica Aurora Demo” | testar isolamento e acesso autorizado |
| Organização B | `org-demo-beta` / “Escola Horizonte Demo” | testar negação entre organizações |
| Administrador A | `user-admin-alpha` | administrar a organização A |
| Profissional A | `user-professional-alpha` | testar papel restrito na organização A |
| Administrador B | `user-admin-beta` | administrar a organização B |
| Usuário sem vínculo | `user-outsider` | testar ausência de organização e autorização |
| Convite pendente | `invite-alpha-pending` | provar que convite pendente não autoriza leitura |
| Convite expirado | `invite-alpha-expired` | provar que expiração impede aceite |
| Licença sintética | `benefit-demo-alpha` | provar que benefício não concede dados |

Nenhum desses identificadores deve representar pessoa ou organização real. Senhas, tokens e chaves não entram nas fixtures. Para testes, a identidade pode ser injetada por um adaptador sintético de desenvolvimento que nunca seja habilitado em produção.

## 4. Entidades mínimas

O primeiro schema implementará somente o necessário para autorização e auditoria:

| Entidade | Campos essenciais | Regra |
|---|---|---|
| `users` | `id`, `external_subject`, `status`, timestamps | identidade sintética; sem senha local |
| `organizations` | `id`, `name`, `status`, timestamps | tenant isolado |
| `memberships` | `id`, `user_id`, `organization_id`, `role`, `status`, validade | vínculo obrigatório para contexto |
| `invitations` | `id`, organização, destinatário sintético, papel, estado, expiração | pendente não autoriza leitura |
| `access_grants` | `id`, usuário, organização, finalidade, escopos, validade, status | autorização explícita |
| `benefit_entitlements` | `id`, organização, licença, estado, validade | nunca libera conteúdo familiar |
| `audit_events` | `id`, ator, organização, ação, resultado, request id, timestamp | sem payload sensível |

As entidades de sujeito, perfil funcional, plano, tarefa, agenda e documento permanecem previstas nos contratos gerais, mas não entram no schema do MVP até a matriz de autorização básica passar.

## 4.1 Direção de autenticação futura

Para o primeiro login real, a direção escolhida é autenticação sem senha por meio de **Google OAuth/OpenID Connect** e **link mágico por e-mail**. O Google será uma opção de conveniência; o link mágico permitirá endereços de qualquer provedor. Nenhuma dessas integrações entra no Gate 1A.

No Gate 2, identidades sintéticas serão injetadas por um adaptador de desenvolvimento. Depois, um gate separado deverá integrar um provedor gerenciado com callback HTTPS, PKCE, expiração e revogação de sessão, recuperação sem enumeração e auditoria. O provedor de identidade confirma a identidade; a API continua decidindo organização, papel, convite, finalidade, escopo e prazo.

## 5. Papéis e escopos do MVP

### Papéis

| Papel | Organização | Capacidades do MVP |
|---|---|---|
| `owner` | própria | consultar e administrar configuração sintética da organização, convites e memberships permitidos |
| `org_admin` | própria | consultar organização e convidar dentro dos limites definidos |
| `professional` | própria | consultar apenas seu contexto de vínculo sintético; não administra tenant |
| `outsider` | nenhuma | nenhuma operação protegida |

O papel não substitui escopo, finalidade, validade ou vínculo. Uma conta com papel alto em uma organização não recebe acesso a outra organização.

### Escopos

O recorte inicial usa apenas escopos necessários para o console sintético:

- `organization.read`
- `membership.read`
- `access.invite`
- `access.read`
- `access.revoke`
- `benefit.read`
- `audit.read`

Os escopos de conteúdo (`communication_profile.*`, `communication_plan.*`, `appointments.*`, `tasks.*`) ficam fora do MVP e só serão habilitados em uma etapa posterior, com finalidade e consentimento próprios.

## 6. Contexto obrigatório da requisição

Toda requisição protegida deve resolver:

- `userId` autenticado pelo adaptador sintético;
- `organizationId` ativo, quando a rota for organizacional;
- `membershipId` válido;
- papel e escopo requeridos;
- finalidade enumerada;
- validade temporal;
- estado de revogação;
- `requestId` idempotente para operações mutáveis.

Quando um requisito não puder ser resolvido, a API deve responder `403 FORBIDDEN` com código estável, sem revelar detalhes de outra organização ou usuário.

## 7. Endpoints mínimos do MVP

Estes endpoints são o recorte inicial; eles não representam backend implementado:

| Método | Rota | Escopo | Resultado |
|---|---|---|---|
| `GET` | `/v1/me` | identidade autenticada | contexto sintético mínimo do usuário |
| `GET` | `/v1/organizations/{organizationId}` | `organization.read` | organização do membership válido |
| `GET` | `/v1/organizations/{organizationId}/memberships` | `membership.read` | memberships da própria organização |
| `POST` | `/v1/organizations/{organizationId}/invitations` | `access.invite` | cria convite sintético com expiração |
| `GET` | `/v1/invitations/{invitationId}` | destinatário ou organização autorizada | convite sem dados de terceiros |
| `POST` | `/v1/invitations/{invitationId}/accept` | destinatário do convite | aceita somente convite válido |
| `POST` | `/v1/invitations/{invitationId}/decline` | destinatário do convite | recusa sem criar vínculo ativo |
| `GET` | `/v1/organizations/{organizationId}/benefits` | `benefit.read` | licença administrativa sem conteúdo familiar |
| `POST` | `/v1/subjects/{subjectId}/grants/{grantId}/revoke` | `access.revoke` | rota contratual reservada; MVP usa sujeito sintético sem conteúdo |
| `GET` | `/v1/organizations/{organizationId}/audit-events` | `audit.read` | eventos permitidos sem payload sensível |

A rota de revogação só será implementada se houver fixture de grant correspondente. Não criar uma entidade de conteúdo apenas para preencher uma tela.

## 8. Matriz de autorização

| Caso | Identidade | Contexto | Operação | Resultado esperado |
|---|---|---|---|---|
| 1 | `user-admin-alpha` | `org-demo-alpha` | ler organização A | permitir |
| 2 | `user-admin-alpha` | `org-demo-alpha` | ler memberships A | permitir |
| 3 | `user-admin-alpha` | `org-demo-alpha` | criar convite em A | permitir |
| 4 | `user-admin-alpha` | `org-demo-beta` | ler organização B | negar `RELATIONSHIP_REQUIRED` ou resposta equivalente sem revelar existência |
| 5 | `user-professional-alpha` | `org-demo-alpha` | administrar configuração de A | negar `SCOPE_DENIED` |
| 6 | `user-outsider` | qualquer organização | ler organização | negar `RELATIONSHIP_REQUIRED` |
| 7 | qualquer usuário | convite pendente | ler conteúdo protegido | negar; convite não é grant |
| 8 | destinatário sintético | convite expirado | aceitar convite | negar `EXPIRED` |
| 9 | patrocinador sintético | organização A | ler conteúdo familiar | negar; benefício não concede conteúdo |
| 10 | `user-admin-alpha` | organização A | consultar benefícios A | permitir sem conteúdo familiar |
| 11 | `user-admin-alpha` | organização B | ler auditoria B | negar `RELATIONSHIP_REQUIRED` |
| 12 | usuário autorizado | organização A | repetir mesma mutação com `requestId` | retornar resultado idempotente, sem duplicar evento |
| 13 | membership revogado | organização A | nova leitura | negar `REVOKED` |
| 14 | membership expirado | organização A | nova leitura | negar `EXPIRED` |
| 15 | sessão sintética inválida | qualquer organização | qualquer rota protegida | negar `AUTH_REQUIRED` |

Os testes devem verificar tanto o status HTTP quanto o código estável e a ausência de vazamento de identificadores, nomes, contagens ou existência de outra organização.

## 9. Eventos de auditoria

Toda operação mutável ou tentativa protegida relevante deve registrar, sem payload sensível:

- `auditId`;
- `requestId`;
- ator sintético;
- organização contextual;
- ação;
- resultado `allowed` ou `denied`;
- código de negação, quando aplicável;
- timestamp;
- versão da API.

O log de auditoria não deve guardar senha, token, cookie, payload de conteúdo, perfil, frase, foto, vídeo, áudio ou dado clínico.

## 10. Critérios de saída do Gate 1A

O Gate 1A estará pronto para virar implementação quando:

1. o escopo incluído e excluído estiver aprovado e não misturar conteúdo clínico;
2. as entidades mínimas tiverem campos e relações definidos;
3. os papéis e escopos estiverem enumerados;
4. cada endpoint tiver finalidade, contexto e escopo;
5. a matriz de autorização tiver casos permitidos e negados;
6. as fixtures forem determinísticas e sintéticas;
7. os códigos de erro forem estáveis;
8. o plano de auditoria não guardar payload sensível;
9. não houver dependência de provedor externo;
10. os handoffs e a sequência de continuidade registrarem a etapa e o próximo gate.

## 11. Próxima etapa depois deste documento

Somente após revisão desta especificação, a próxima branch poderá criar o esqueleto local da API, o schema PostgreSQL, migrations, fixtures e testes. Essa será uma etapa nova e separada, correspondente ao Gate 2 do ADR.

Não implementar login real, não conectar Supabase, Cloudflare, Render, Railway ou outro provedor, não publicar portal e não alterar o CTA do site como parte deste Gate 1A.
