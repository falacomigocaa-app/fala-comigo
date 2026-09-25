# ADR-001 — Opção A: site institucional no GitHub Pages e portal independente

- **Status:** Aceito para especificação; implementação ainda não iniciada
- **Data:** 25/09/2026
- **Decisor:** proprietário do Fala Comigo
- **Escopo:** Espaço do Criador, site público e futuro portal conectado
- **Repositório:** `falacomigocaa-app/fala-comigo`
- **URL pública oficial:** <https://falacomigocaa-app.github.io/fala-comigo/>

## 1. Contexto

O projeto possui um aplicativo Flutter local-first e um site institucional publicado no GitHub Pages. Também existem contratos e protótipos documentais para um futuro portal com organizações, convites, licenças, autorizações e auditoria.

O proprietário decidiu retirar o Espaço do Criador do Manus Space e iniciar uma migração gradual para uma infraestrutura independente. O início deve priorizar baixo custo, usando camadas gratuitas quando forem suficientes, com possibilidade de evolução para planos pagos quando houver necessidade real.

A decisão não autoriza, por si só, contratação de serviços, criação de contas externas, ativação de cobrança, coleta de dados pessoais reais ou troca imediata do link público atual.

## 2. Decisão

Adotar a **Opção A**:

1. **GitHub Pages** continuará hospedando o site institucional público, políticas, contatos, conteúdo informativo e o ponto de encaminhamento para o portal.
2. **Login e portal autenticado** serão hospedados em uma origem independente do GitHub Pages e do Manus Space.
3. **Backend próprio** será a autoridade para autenticação de sessão, autorização, organizações, convites, licenças, auditoria e demais operações conectadas.
4. **Banco relacional**, preferencialmente PostgreSQL, será usado como modelo de persistência para manter compatibilidade com organizações, vínculos, consentimentos, escopos e auditoria.
5. O desenvolvimento inicial será feito localmente e em CI, com banco descartável e fixtures sintéticas. Uma camada gratuita externa só será usada depois da especificação e apenas para protótipo sem dados reais.
6. A arquitetura deverá usar contratos versionados, migrations reproduzíveis e adaptadores para reduzir dependência de um provedor específico.
7. O aplicativo CAA continuará independente: comunicação básica, acessibilidade, modo offline e dados locais não dependerão de conta, Internet, assinatura, API ou portal.

### Fronteira obrigatória entre Pages e portal

O GitHub Pages é hospedagem estática. Portanto, ele **não** será usado para:

- receber ou validar senhas;
- manter sessões seguras;
- executar autorização server-side;
- armazenar banco de dados;
- hospedar o portal SaaS autenticado como se fosse um backend;
- guardar chaves privilegiadas ou segredos.

O Pages poderá apresentar um link de encaminhamento para a origem independente somente quando o destino estiver publicado e validado. O navegador poderá acessar a origem independente, mas a autoridade de segurança permanecerá no backend.

## 3. Arquitetura alvo inicial

```text
Visitante
   |
   v
GitHub Pages — site institucional, políticas, contatos e entrada pública
   |
   | encaminhamento somente após o portal independente ser validado
   v
Origem independente — interface do portal autenticado
   |
   | HTTPS
   v
API REST própria /v1 — autenticação de sessão e autorização server-side
   |                         |
   |                         +--> adaptador de identidade
   v
Adaptador de persistência
   |
   v
PostgreSQL — schema e migrations versionados
```

### Desenvolvimento local e CI

```text
API + PostgreSQL descartável + fixtures sintéticas
                 |
                 +--> testes allow/deny entre organizações
                 +--> testes de sessão, revogação e escopo
                 +--> exportação/restauração
```

A primeira versão deve ser um **monólito modular**, não uma arquitetura de microserviços. A separação por módulos e adaptadores será suficiente para permitir evolução sem criar complexidade operacional prematura.

## 4. Escopo inicial permitido

O primeiro MVP conectado poderá conter somente dados sintéticos para demonstrar:

- usuário administrativo fictício;
- organizações fictícias;
- memberships e papéis;
- convites fictícios;
- licenças e estados de plano fictícios;
- auditoria sem conteúdo sensível;
- fluxos de autorização e negação.

O MVP inicial **não poderá conter**:

- crianças ou famílias reais;
- nomes reais ou e-mails reais de usuários finais;
- perfis comunicacionais reais;
- frases, pictogramas personalizados ou conteúdo produzido por uma criança;
- fotos, vídeos, áudios ou diário;
- registros ABC ou dados clínicos;
- sincronização clínica;
- pagamento real;
- armazenamento de arquivos;
- importação de dados do portal Manus.

O e-mail `falacomigocaa@gmail.com` é uma decisão de contato e futuro acesso administrativo, não uma senha nem uma credencial a ser colocada em código, fixture ou documentação técnica.

## 5. Contratos e regras de autorização

A API deve ser versionada em `/v1` e documentada antes da implementação das telas. Cada operação protegida deverá validar no servidor, no mínimo:

- identidade autenticada;
- vínculo com a organização;
- papel e permissão;
- finalidade da operação;
- escopo do recurso;
- consentimento aplicável;
- prazo de validade;
- revogação;
- isolamento entre organizações.

A identidade do usuário não é autorização suficiente. JWT, cookie ou sessão não substituem vínculo, escopo, finalidade, consentimento e revogação.

PostgreSQL deverá usar grants mínimos e poderá usar Row-Level Security como defesa adicional. RLS não substitui a validação explícita da API nem os testes negativos.

## 6. Identidade, sessão e segredos

A implementação de produção deverá usar um provedor de identidade gerenciado ou um componente auditado, escolhido em etapa própria. Não criar autenticação artesanal no JavaScript público.

### Decisão de autenticação inicial

Para reduzir complexidade e evitar armazenamento de senhas, o portal adotará como direção de autenticação sem senha:

1. **Google OAuth/OpenID Connect** como opção de entrada rápida para o proprietário e administradores que utilizarem uma conta Google;
2. **link mágico por e-mail** como alternativa para endereços de qualquer provedor, sem exigir Gmail;
3. um adaptador de identidade no backend, para que a aplicação não fique presa ao Google ou a um único fornecedor de e-mail;
4. criação ou ativação de acesso somente após o backend validar convite, organização, papel, finalidade, escopos, validade e revogação.

Google ou o provedor de e-mail confirmam a identidade, mas não concedem autorização de negócio. O backend continua sendo a autoridade final. O primeiro acesso administrativo não será liberado somente porque o e-mail corresponde a um texto conhecido no cliente; ele deverá passar por uma regra de bootstrap protegida no servidor e por MFA do provedor quando disponível.

Essa decisão é de desenho e não habilita OAuth real nesta etapa. O Gate 2 usará identidades sintéticas; a integração real será um gate separado, com ambiente de teste, callback HTTPS, PKCE, tokens nunca persistidos em Git e testes de revogação e sessão.

Antes de qualquer piloto real, a solução deverá definir e testar:

- MFA para contas privilegiadas;
- sessões com expiração, logout e revogação server-side;
- recuperação de conta sem revelar se um e-mail existe;
- rate limiting e proteção contra abuso;
- e-mail transacional confiável;
- rotação e armazenamento seguro de segredos;
- logs sem senhas, tokens, payloads clínicos ou conteúdo familiar.

Nenhum segredo, token, senha, chave privada ou cookie será versionado no Git, no site, no bundle Flutter, em issue, log ou screenshot.

## 7. Escolha de provedor e evolução de custo

A escolha comercial do provedor ainda é um gate separado. Antes de criar uma conta ou ativar cobrança, comparar fontes oficiais atualizadas sobre:

- camada gratuita, limites e dormência;
- disponibilidade, pausa e expiração;
- backups, retenção, RPO e RTO;
- e-mail transacional;
- MFA e gerenciamento de sessões;
- região e requisitos de privacidade;
- exportação e migração de identidade;
- `pg_dump`/`pg_restore` e portabilidade do banco;
- egress, armazenamento, compute e custo total;
- caminho de upgrade e alertas de orçamento.

A camada gratuita será tratada como **sandbox descartável**. Não é garantia de continuidade e não autoriza dados reais. Antes de dados pessoais reais, será necessário migrar para uma configuração com continuidade adequada, backup e restauração ensaiada, e-mail confiável, monitoramento e critérios de gasto aprovados.

Uma composição candidata para protótipo sintético é API TypeScript/Hono em Cloudflare Workers com Supabase Auth/Postgres. Isso **não é uma decisão de contratação**. O código deverá preservar uma API própria e migrations portáveis para permitir comparação ou troca futura.

## 8. Decisões adiadas

As seguintes decisões permanecem abertas e não bloqueiam a criação deste ADR:

- provedor final do backend;
- provedor final de identidade;
- provedor e plano do PostgreSQL;
- região de hospedagem;
- domínio próprio;
- e-mail transacional;
- armazenamento de arquivos;
- política final para recuperação administrativa;
- orçamento e teto de gasto;
- data e critérios do piloto com pessoas reais;
- importação de qualquer dado existente.

Essas decisões exigem comparação, evidência e, quando envolverem contratação, cobrança ou dados reais, aprovação específica do proprietário.

## 9. Sequência de implementação

### Gate 0 — documentação e fronteira

- manter este ADR e os handoffs atualizados;
- distinguir site institucional de portal autenticado;
- registrar que o portal independente ainda não existe;
- manter a `main` protegida e trabalhar por branch e PR.

### Gate 1 — contrato e modelo

- delimitar o MVP sintético;
- revisar os contratos existentes;
- criar OpenAPI inicial `/v1`;
- criar modelo PostgreSQL e migrations;
- classificar campos permitidos e proibidos;
- definir matriz de papéis e permissões.

### Gate 2 — implementação local

- criar API modular local;
- conectar PostgreSQL descartável;
- usar fixtures sintéticas;
- implementar autorização server-side;
- testar duas organizações fictícias;
- testar casos permitidos e negados;
- adicionar CI reproducível.

### Gate 3 — operação e segurança

- testar sessão, revogação e limites;
- testar exportação e restauração;
- revisar logs e segredos;
- criar threat model;
- revisar privacidade e retenção;
- definir runbook, rollback e alertas.

### Gate 4 — protótipo remoto sintético

- somente após os Gates 1–3;
- escolher provedor com base em fontes oficiais;
- criar ambiente separado;
- não inserir dados reais;
- verificar custos, limites e portabilidade;
- registrar evidências do ambiente e dos testes.

### Gate 5 — publicação do portal

Somente depois de o portal independente ter HTTPS, autenticação, autorização, testes negativos, recuperação, operação e restauração validadas. A troca do CTA no site será feita em PR separada, publicada pelo `site-pages.yml` e conferida em:

<https://falacomigocaa-app.github.io/fala-comigo/>

O link provisório do Manus não será usado como arquitetura-alvo nem como rollback após o corte independente.

## 10. Critérios de aceite desta decisão

Este ADR será considerado corretamente aplicado quando:

- o site institucional continuar acessível na URL oficial;
- nenhum login ou segredo estiver implementado no GitHub Pages;
- o portal e a API estiverem separados do site institucional;
- o aplicativo CAA continuar funcionando sem Internet, conta ou assinatura;
- o MVP inicial usar somente dados sintéticos;
- a API for a autoridade de autorização;
- houver migrations reproduzíveis e testes de isolamento entre organizações;
- a escolha de provedor estiver documentada separadamente;
- nenhum serviço pago tiver sido contratado sem autorização;
- o link do Criador só for trocado após validação do destino independente.

## 11. Consequências

### Benefícios

- preserva o site público e o aplicativo existentes;
- evita autenticação falsa ou insegura no GitHub Pages;
- permite começar com custo baixo e dados sintéticos;
- mantém o backend e o banco substituíveis;
- cria uma base compatível com organizações, permissões e auditoria futuras;
- reduz o risco de misturar dados locais do CAA com o portal conectado.

### Custos e limitações

- o portal real exigirá uma origem adicional ao GitHub Pages;
- camadas gratuitas podem pausar, limitar e não oferecer backup adequado;
- a migração de identidade pode ser mais complexa que a migração do banco;
- haverá trabalho adicional de segurança, privacidade, e-mail e operação;
- a troca do link público deverá esperar a validação do novo destino.

## 12. Histórico de revisão

- **25/09/2026:** Opção A aceita pelo proprietário. ADR criado para separar site institucional, portal autenticado, API e banco; implementação, contratação, cobrança e coleta real continuam pendentes.
- **25/09/2026:** autenticação sem senha escolhida como direção: Google OAuth/OIDC e link mágico por e-mail, com autorização sempre no backend e integração real adiada para gate próprio.
