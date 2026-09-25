# API local sintética do portal

Esta pasta contém a implementação mínima do **Gate 2** da Opção A. Ela existe para testar autorização, isolamento entre organizações, convites, benefícios sintéticos, auditoria e idempotência sem criar contas externas ou conectar um provedor.

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

- `src/store.js`: fixtures determinísticas e armazenamento em memória;
- `src/authorization.js`: autenticação sintética, membership, escopos, erros estáveis e auditoria;
- `src/app.js`: rotas `/v1` e idempotência;
- `src/server.js`: adaptador HTTP local;
- `migrations/001_initial.sql`: schema PostgreSQL portátil para a próxima integração;
- `test/authorization.test.js`: casos permitidos e negados do Gate 1A.

## Limites

O armazenamento em memória é descartado ao reiniciar. O SQL ainda não foi executado contra PostgreSQL neste ambiente porque `psql` e Docker não estão disponíveis. Isso é uma limitação registrada, não uma aprovação de banco.

Não adicionar senhas, tokens, nomes reais, dados de crianças, conteúdo clínico, fotos, vídeos, áudios ou credenciais a esta pasta.
