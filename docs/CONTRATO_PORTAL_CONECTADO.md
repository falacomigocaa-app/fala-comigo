# Contrato único do portal conectado

## Objetivo

Este contrato é a referência comum para o aplicativo Flutter, o portal web e o futuro backend. O aplicativo pode permanecer offline-first e o portal pode usar outra tecnologia, mas ambos devem preservar os mesmos nomes, estados, escopos e regras de autorização.

> **Não duplicar regras em telas.** A interface mostra estados do contrato; ela não decide sozinha se um acesso é permitido.

## Entidades canônicas

| Entidade | Identificador | Finalidade |
|---|---|---|
| `Organization` | `organizationId` | Clínica, escola, empresa patrocinadora ou profissional independente |
| `User` | `userId` | Responsável, profissional, professor ou administrador |
| `ChildSubject` | `subjectId` | Pessoa usuária da comunicação, separada da conta familiar |
| `Membership` | `membershipId` | Usuário dentro de uma organização, com papel e validade |
| `CareRelationship` | `relationshipId` | Profissional e organização vinculados a uma pessoa por finalidade |
| `BenefitEntitlement` | `benefitId` | Licença pessoal ou patrocinada, sem liberar dados automaticamente |
| `AccessGrant` | `grantId` | Escopo de leitura, criação, edição, exportação ou convite |
| `Consent` | `consentId` | Finalidade, versão, escopo, prazo e revogação |
| `SharedTask` | `taskId` | Próximo passo entre família, escola e rede de cuidado |
| `TaskEvent` | `eventId` | Histórico imutável de criação, aceite, alteração e retorno |
| `Document` | `documentId` | Orientação ou documento publicado com classificação e validade |
| `AuditEvent` | `auditId` | Registro de acesso, alteração, exportação e revogação |

## Estados canônicos

### Vínculo de acesso

`pending` → `active` → `revoked` ou `expired`.

Um vínculo pendente não autoriza leitura de dados. A revogação deve invalidar novas leituras imediatamente. O histórico da autorização permanece auditável, mas não permite reativação silenciosa.

### Aceite de tarefa

`notRequired`, `pending`, `accepted` ou `declined`.

O aceite da tarefa é diferente do consentimento para acessar dados. Uma tarefa recusada deve continuar visível para quem tem acesso ao histórico, com o motivo opcional e sem penalizar a criança ou a família.

### Estado da tarefa

`pending`, `inProgress`, `completed`, `partiallyCompleted`, `needsHelp`, `declined` ou `cancelled`.

`declined` significa que a tarefa não foi realizada ou foi recusada no contexto apresentado. Não significa falha clínica, descumprimento ou diagnóstico.

## Escopos iniciais

Os escopos devem ser valores enumerados, não texto livre usado como regra de segurança:

- `tasks.read`: visualizar tarefas autorizadas;
- `tasks.create`: criar tarefas para destinatários permitidos;
- `tasks.update`: alterar status ou retorno da própria tarefa;
- `communication_profile.read`: visualizar o perfil funcional publicado;
- `routine.read`: visualizar rotina compartilhada;
- `documents.published.read`: visualizar documentos publicados para aquele destinatário;
- `benefit.manage`: administrar licença sem ler conteúdo familiar;
- `access.revoke`: revogar acesso da própria conta familiar;
- `audit.read`: consultar eventos da própria organização quando permitido.

O escopo da tarefa deve ser menor ou igual ao escopo do vínculo. A interface nunca deve acrescentar escopos por conveniência.

## Contrato mínimo de `SharedTask`

```json
{
  "taskId": "uuid",
  "subjectId": "uuid",
  "organizationId": "uuid|null",
  "createdBy": "userId",
  "assignedTo": "userId|family",
  "title": "string",
  "description": "string",
  "context": "CAA|school|ABA|speech|routine|other",
  "dueAt": "ISO-8601",
  "reminderEnabled": true,
  "status": "pending",
  "acceptance": "pending",
  "feedback": "string|null",
  "events": [],
  "createdAt": "ISO-8601",
  "updatedAt": "ISO-8601"
}
```

O aplicativo local atual usa `organizationName` e `recipientRole` para funcionar sem diretório remoto. Quando o backend existir, esses campos continuam como apresentação, enquanto `organizationId` e `userId` passam a ser as referências canônicas.

## Evento de tarefa

Cada mudança relevante adiciona um evento, sem apagar o anterior:

```json
{
  "eventId": "uuid",
  "taskId": "uuid",
  "type": "created|acceptance_changed|status_changed|feedback_added|cancelled",
  "actorId": "userId|local-family",
  "note": "string|null",
  "occurredAt": "ISO-8601"
}
```

## Fila offline

Toda gravação conectável gera uma operação local com `taskId`, `operation`, `queuedAt` e uma chave idempotente. A sincronização futura deverá:

1. revalidar autenticação, vínculo, consentimento, finalidade e prazo;
2. enviar operações em ordem por tarefa;
3. aceitar repetição sem duplicar evento;
4. manter a tarefa local quando a rede falhar;
5. mostrar conflito em vez de sobrescrever silenciosamente;
6. registrar sucesso ou erro técnico sem exibir conteúdo sensível em logs.

## Regras compartilhadas entre app e web

A família continua dona do espaço familiar. O patrocinador administra benefício, não conteúdo. O profissional acessa somente pessoas e recursos vinculados. Escola recebe resumo funcional necessário, não prontuário integral. Empresa recebe apenas informações administrativas agregadas. A comunicação básica não depende de internet ou aceite remoto.

A implementação web do primeiro piloto deve usar dados sintéticos e declarar visualmente que é uma prévia. O backend real só deve ser conectado depois de implementar autorização server-side, consentimento versionado, auditoria e testes de negação.

## Critério para considerar alinhado

App, web e backend estão alinhados quando um mesmo caso de teste usa o mesmo `taskId`, os mesmos estados, os mesmos escopos e a mesma transição de aceite. Se uma tela precisar inventar um estado que não existe neste contrato, o contrato deve ser revisado antes da implementação.
