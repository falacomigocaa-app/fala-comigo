# Contrato API da continuidade do cuidado

## Status

**Especificação de fase 1.** Este documento não representa backend implementado nem autorização em produção. O aplicativo e o portal web devem usar os mesmos nomes e estados quando a API for construída.

## Princípios obrigatórios

1. A conta familiar é portátil e continua funcionando offline.
2. Benefício patrocinado não concede acesso a dados.
3. Toda leitura ou alteração remota exige usuário autenticado, organização, vínculo, finalidade, consentimento, escopo e validade compatíveis.
4. O servidor é a autoridade final. Esconder um botão no aplicativo não é controle de segurança.
5. Professor recebe conteúdo escolar publicado; não recebe prontuário clínico por herança do vínculo.
6. Empresa patrocinadora recebe licença e métricas agregadas; não recebe conteúdo individual.
7. Revogação bloqueia novas leituras imediatamente.
8. O conteúdo local não é apagado quando um vínculo expira ou é revogado.

## Identidade e contexto de autorização

Toda requisição autenticada deve possuir ou resolver:

| Campo | Descrição |
|---|---|
| `userId` | Conta autenticada que faz a requisição |
| `organizationId` | Organização ativa no contexto, quando aplicável |
| `subjectId` | Pessoa usuária da comunicação, nunca inferida apenas pelo nome |
| `membershipId` | Vínculo do usuário com a organização |
| `relationshipId` | Relação profissional-organização-sujeito-finalidade |
| `consentId` | Consentimento da família/responsável para aquele uso |
| `purpose` | Finalidade enumerada, por exemplo `communication_support` ou `school_support` |
| `scopes` | Permissões enumeradas, nunca texto livre de tela |
| `validUntil` | Prazo efetivo do vínculo e do consentimento |
| `requestId` | Identificador idempotente para auditoria e sincronização |

Se algum campo obrigatório não puder ser resolvido, a resposta deve ser `403 FORBIDDEN` com código estável, sem revelar se outro sujeito ou organização existe.

## Endpoints da fase inicial

### Convites e vínculos

| Método | Rota | Finalidade | Escopo mínimo |
|---|---|---|---|
| `POST` | `/v1/invitations` | Criar convite para profissional ou organização | `access.invite` |
| `GET` | `/v1/invitations/{invitationId}` | Visualizar convite recebido pelo destinatário | convite pertence ao usuário |
| `POST` | `/v1/invitations/{invitationId}/accept` | Aceitar convite e criar vínculo pendente/ativo conforme o fluxo | aceite do convidado |
| `POST` | `/v1/invitations/{invitationId}/decline` | Recusar convite sem alterar dados familiares | convite pertence ao usuário |
| `GET` | `/v1/subjects/{subjectId}/grants` | Listar acessos da conta familiar | `access.read` do próprio sujeito |
| `POST` | `/v1/subjects/{subjectId}/grants/{grantId}/revoke` | Revogar acesso | `access.revoke` |

Um patrocinador pode criar um convite de benefício sem criar permissão clínica. O aceite do benefício e o consentimento de compartilhamento são objetos diferentes.

### Perfil funcional

| Método | Rota | Finalidade | Escopo |
|---|---|---|---|
| `GET` | `/v1/subjects/{subjectId}/communication-profile` | Ler versão publicada para o contexto | `communication_profile.read` |
| `PUT` | `/v1/subjects/{subjectId}/communication-profile/drafts/{draftId}` | Editar rascunho da família ou profissional autorizado | `communication_profile.write` |
| `POST` | `/v1/subjects/{subjectId}/communication-profile/versions/{versionId}/publish` | Publicar versão para destinatários definidos | `communication_profile.publish` + consentimento |
| `POST` | `/v1/subjects/{subjectId}/communication-profile/versions/{versionId}/revoke` | Retirar uma versão publicada | autor da publicação ou família |

A API deve devolver apenas campos autorizados para o `purpose` da requisição. Uma versão escolar pode conter comunicação, acessibilidade e apoios, mas não diagnóstico ou prontuário.

### Plano de comunicação

| Método | Rota | Finalidade | Escopo |
|---|---|---|---|
| `GET` | `/v1/subjects/{subjectId}/communication-plans` | Listar planos visíveis ao solicitante | `communication_plan.read` |
| `POST` | `/v1/subjects/{subjectId}/communication-plans` | Criar proposta de plano | `communication_plan.create` |
| `PATCH` | `/v1/communication-plans/{planId}` | Alterar proposta ou plano ativo | `communication_plan.update` |
| `POST` | `/v1/communication-plans/{planId}/accept` | Aceitar participação/ação do destinatário | `communication_plan.respond` |
| `POST` | `/v1/communication-plans/{planId}/request-review` | Pedir adaptação ou revisão | `communication_plan.respond` |
| `POST` | `/v1/communication-plans/{planId}/archive` | Encerrar plano sem apagar histórico | autor ou família |

O plano é funcional e colaborativo. Não pode conter uma interpretação clínica automática nem alterar prescrição. Cada mudança deve gerar `AuditEvent` e uma versão do plano.

### Agenda

| Método | Rota | Finalidade | Escopo |
|---|---|---|---|
| `GET` | `/v1/subjects/{subjectId}/appointments` | Listar compromissos autorizados | `appointments.read` |
| `POST` | `/v1/subjects/{subjectId}/appointments` | Criar compromisso ou proposta | `appointments.create` |
| `PATCH` | `/v1/appointments/{appointmentId}` | Confirmar, cancelar ou alterar preparação | `appointments.update` |
| `POST` | `/v1/appointments/{appointmentId}/attendance` | Registrar presença, cancelamento ou pedido de remarcação | `appointments.respond` |

O cartão offline do compromisso deve conter apenas o necessário para a preparação. Notificações não devem expor diagnóstico, terapia ou conteúdo sensível na tela bloqueada.

## Payloads canônicos

### `CommunicationProfileVersion`

```json
{
  "versionId": "uuid",
  "subjectId": "uuid",
  "purpose": "communication_support",
  "communicationModes": ["symbols", "gestures"],
  "preferredAccess": "Touch with extra response time",
  "facilitators": ["visual anticipation", "two choices"],
  "avoid": ["rushing", "touching without warning"],
  "contingencyPlan": "Printed pause cards",
  "partners": ["family", "school"],
  "audience": ["family", "school-organization-id"],
  "status": "published",
  "consentId": "uuid",
  "publishedBy": "user-id",
  "reviewAt": "2026-10-20T00:00:00Z",
  "createdAt": "2026-09-23T20:00:00Z"
}
```

### `CommunicationPlan`

```json
{
  "planId": "uuid",
  "subjectId": "uuid",
  "organizationId": "uuid|null",
  "context": "school",
  "title": "Pedido de pausa na chegada",
  "functionalGoal": "Pedir pausa antes de sair da atividade",
  "strategy": "Modelar o cartão sem exigir repetição",
  "familyAction": "Praticar em uma rotina natural",
  "schoolAction": "Disponibilizar o cartão na chegada",
  "status": "active",
  "reviewAt": "2026-10-20T00:00:00Z",
  "version": 1,
  "createdBy": "user-id",
  "updatedAt": "2026-09-23T20:00:00Z"
}
```

### `Appointment`

```json
{
  "appointmentId": "uuid",
  "subjectId": "uuid",
  "organizationId": "uuid|null",
  "title": "Sessão de fonoaudiologia",
  "professionalId": "uuid",
  "startsAt": "2026-09-24T14:00:00-03:00",
  "durationMinutes": 45,
  "preparation": "Levar a prancha de pausa",
  "status": "confirmed",
  "reminderEnabled": true,
  "createdBy": "user-id",
  "updatedAt": "2026-09-23T20:00:00Z"
}
```

## Consentimento

O consentimento deve ser versionado e separado por finalidade:

```json
{
  "consentId": "uuid",
  "subjectId": "uuid",
  "grantedBy": "guardian-user-id",
  "recipient": "school-organization-id",
  "purpose": "school_support",
  "scopes": ["communication_profile.read", "tasks.read", "tasks.update"],
  "documentClasses": ["published_functional_summary"],
  "version": "2026-09-23.v1",
  "grantedAt": "2026-09-23T20:00:00Z",
  "validUntil": "2027-02-28T23:59:59-03:00",
  "revokedAt": null,
  "status": "active"
}
```

O aceite de benefício deve usar outro `purpose`, por exemplo `sponsored_access`, e não pode incluir automaticamente `communication_profile.read`.

## Matriz de autorização e negação

| Ator | Recurso | Permitido quando | Negar quando |
|---|---|---|---|
| Família/responsável | Perfil funcional | É responsável pelo sujeito ou possui delegação válida | vínculo expirado, sujeito incorreto ou consentimento ausente |
| Profissional | Perfil funcional | Relação ativa, finalidade compatível e escopo publicado | convite pendente, organização errada ou perfil não publicado |
| Professor | Resumo escolar | Escola ativa, finalidade escolar e versão destinada à escola | documento clínico, escopo clínico ou consentimento revogado |
| Organização patrocinadora | Benefício | Contrato e licença válidos | qualquer tentativa de ler conteúdo familiar ou uso individual |
| Clínica | Plano de comunicação | Profissional vinculado, caso autorizado e plano dentro da validade | profissional substituído, caso encerrado ou escopo somente leitura |
| Família | Agenda | Compromisso pertence ao sujeito ou foi compartilhado | compromisso de outro sujeito ou organização sem vínculo |
| Qualquer ator | Documento | Classe, destinatário, finalidade e validade coincidem | URL expirada, documento cancelado ou classe não autorizada |

## Respostas de erro estáveis

A API deve usar códigos sem exposição de existência indevida:

- `AUTH_REQUIRED`: autenticação ausente ou inválida;
- `RELATIONSHIP_REQUIRED`: vínculo inexistente, pendente ou encerrado;
- `CONSENT_REQUIRED`: consentimento ausente, incompatível ou revogado;
- `SCOPE_DENIED`: escopo insuficiente;
- `PURPOSE_MISMATCH`: finalidade da requisição não corresponde à finalidade autorizada;
- `EXPIRED`: vínculo, consentimento, licença ou documento expirado;
- `REVOKED`: autorização revogada;
- `VERSION_CONFLICT`: alteração concorrente exige revisão;
- `IDEMPOTENCY_REPLAY`: operação já processada, retornando o resultado original sem duplicar evento.

Para recursos sensíveis, não diferenciar `subjectId` inexistente de `subjectId` existente sem acesso. Registrar o detalhe somente no log interno protegido.

## Testes de negação obrigatórios

Antes de sincronizar dados reais, o backend deve automatizar pelo menos:

1. profissional da Clínica A não lê perfil da Clínica B;
2. profissional com convite pendente não lê perfil;
3. professor não lê receita nem prontuário;
4. empresa patrocinadora não lê nome, diagnóstico, uso individual ou conteúdo;
5. família revoga vínculo e a leitura seguinte falha;
6. consentimento expirado impede leitura mesmo com licença ativa;
7. escopo `tasks.read` não permite editar plano;
8. documento publicado para escola não aparece para outra escola;
9. URL de anexo expirada não baixa conteúdo;
10. conflito de versão não sobrescreve atualização de outro usuário;
11. repetição do mesmo `requestId` não duplica evento;
12. encerramento de clínica não remove cartões ou perfil local da família;
13. convite expirado não cria vínculo ao ser aceito;
14. notificação de compromisso não revela conteúdo sensível na tela bloqueada;
15. usuário sem autorização não descobre se outro sujeito está cadastrado.

## Sincronização offline

O aplicativo deve manter uma fila local com:

- `operationId` idempotente;
- tipo de recurso;
- operação;
- payload mínimo;
- versão local;
- criado em;
- tentativas;
- estado `queued`, `sent`, `accepted`, `conflict` ou `rejected`;
- código de erro sem conteúdo sensível.

Antes de aceitar a operação, o servidor revalida autenticação, relação, consentimento, escopo e versão. Em `rejected`, o dado local permanece e a pessoa recebe uma explicação simples. Em `conflict`, a interface oferece revisar e escolher, nunca sobrescrever silenciosamente.

## Critério de saída desta especificação

A fase de contrato estará pronta para implementação quando:

- cada endpoint tiver finalidade e escopo;
- cada payload tiver identificadores canônicos;
- o consentimento estiver separado do benefício;
- a matriz de negação tiver testes automatizáveis;
- app e web puderem renderizar os mesmos estados;
- não houver endpoint que exponha prontuário por padrão;
- a conta familiar puder continuar offline após revogação ou fim de benefício.
