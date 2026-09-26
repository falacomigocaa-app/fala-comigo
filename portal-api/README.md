# API local sintética do portal

Esta pasta contém a implementação sintética do **Gate 3A** da Opção A. Ela testa autorização, isolamento entre organizações, sujeito infantil, consentimento, convites, grants, revogação, benefícios, auditoria e idempotência sem criar contas externas ou conectar um provedor.

## Executar

Requer Node.js 22 ou superior:

```bash
cd portal-api
npm test
npm start
```

O servidor local inicia em `http://127.0.0.1:8787`. A identidade de desenvolvimento é informada pelo header sintético `x-synthetic-user-id`, por exemplo:

```bash
curl -H 'x-synthetic-user-id: user-admin-alpha' \\
  http://127.0.0.1:8787/v1/me
```

Esse header e o servidor atual são somente para desenvolvimento local. Não há login real, OAuth, link mágico, e-mail, banco remoto ou sessão de produção. O servidor não deve ser publicado.

## Conteúdo

- `src/store.js`: fixtures determinísticas, sujeito infantil, consentimentos, relações e armazenamento em memória;
- `src/authorization.js`: autenticação sintética, membership, escopos, erros estáveis e auditoria;
- `src/app.js`: rotas `/v1` e idempotência;
- `src/server.js`: adaptador HTTP local;
- `migrations/001_initial.sql`: schema PostgreSQL portátil de identidade, organização, sujeito, consentimento e autorização;
- `test/authorization.test.js`: casos permitidos e negados dos Gates 2 e 3A.
- `test/postgres.integration.test.js`: verificação do schema e isolamento contra PostgreSQL quando `PGTEST_URL` está definido.

## Limites

O armazenamento em memória é descartado ao reiniciar. A migration foi validada contra uma instância PostgreSQL 16.15 descartável. Na validação de 26/09/2026, os **18 testes passaram**, incluindo o PostgreSQL descartável. Sem `PGTEST_URL`, o teste PostgreSQL é marcado como ignorado e os testes locais continuam executáveis.

## Fluxos sintéticos disponíveis

- `POST /v1/subjects/{subjectId}/consents`: cria consentimento com finalidade, destinatário, escopos, versão do aviso e validade;
- `POST /v1/organizations/{organizationId}/invitations`: cria convite organizacional e exige consentimento quando ligado a uma criança;
- `POST /v1/invitations/{invitationId}/accept`: aceita convite e cria membership, relação e grant sintéticos;
- `GET /v1/subjects/{subjectId}`: proprietário lê o perfil; convidado só lê com `communication_profile.read` vigente;
- `POST /v1/subjects/{subjectId}/grants/{grantId}/revoke`: proprietário revoga grant, consentimento e relação.

Esses fluxos ainda usam identidade sintética por header e não são produção. O próximo bloco é trocar o adaptador de identidade por autenticação real, sem alterar a decisão server-side de organização, sujeito, finalidade, escopo, consentimento e prazo.

Não adicionar senhas, tokens, nomes reais, dados de crianças, conteúdo clínico, fotos, vídeos, áudios ou credenciais a esta pasta.
