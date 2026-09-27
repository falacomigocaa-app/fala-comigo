# Handoff — staging Supabase

**Data:** 27/09/2026.
**Projeto:** `Fala Comigo Staging`
**Ref:** `gojqeaontgshikdqlpfn`
**Organização:** `falacomigocaa-app's Org`
**Região:** `sa-east-1` (São Paulo).
**Custo oficial consultado na criação:** US$ 0/mês; o usuário autorizou projeto vazio após confirmar essa estimativa.
**Branch de documentação:** `docs/supabase-staging-created`, baseada em `main` `1281c39`.

## Estado verificado depois da criação

O Supabase retornou `ACTIVE_HEALTHY`. Consulta somente leitura confirmou: schema `public` sem tabelas; nenhuma migration; nenhuma branch de database; zero avisos no Security Advisor naquele momento. Nenhuma linha de dados foi consultada. Nenhuma tabela da aplicação, usuário de Auth, credencial, segredo, política RLS da aplicação ou chave de API foi criada ou alterada por esta etapa.

O projeto antigo `Fala comigo CAA` em `us-east-1` continua intocado. O staging novo ocupa a segunda vaga de projeto Free no momento. O conector Supabase do ambiente Manus está habilitado para chamadas administrativas, mas **isso não configura conexão entre o aplicativo/site e o Supabase**.

## Estado do produto

- O aplicativo CAA básico permanece local-first, sem conta ou internet obrigatória.
- Handoff anterior já definiu o desejo do proprietário por acesso próprio, sem Manus Space, usando `falacomigocaa@gmail.com`. Não há login próprio implementado no app nem no site.
- A primeira superfície remota deve ser o Espaço do Criador/proprietário sem conteúdo clínico, distinto da Área do Responsável e do futuro portal clínica/escola.
- Usar apenas dados sintéticos até passar pelos controles de autorização, consentimento, revogação, auditoria e testes de negação.
- Não ativar signup público por padrão. Auth identifica uma pessoa; não concede sozinho papel administrativo nem autorização clínica.
- Nunca colocar `service_role` ou chave secreta no navegador, app, Git, screenshot, issue ou chat. A chave pública não substitui RLS: cada tabela, view, função e objeto de Storage precisa da política apropriada.

## Limites atuais do plano Free

A página oficial atual informa até 2 projetos gratuitos ativos, 500 MB de banco por projeto, até 50.000 MAU, 1 GB de file storage e 5 GB de egress. As cotas e bases variam; a página de cobrança explica como uso agregado ou excedentes podem funcionar. Projetos Free podem ser pausados depois de 7 dias de atividade de banco baixa. A documentação oficial não oferece backups automáticos para download no Free; não tratar isso como ambiente de produção ou cópia de segurança. A estimativa de US$ 0/mês é o valor recebido no momento da criação, não garantia de preço permanente.

- [Preços Supabase](https://supabase.com/pricing)
- [Cobrança e cotas](https://supabase.com/docs/guides/platform/billing-on-supabase)
- [Pausa por inatividade](https://supabase.com/docs/guides/platform/free-project-pausing)
- [Chaves de API](https://supabase.com/docs/guides/api/api-keys)
- [Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)

## Próximos passos — ainda não autorizados por esta criação

1. Confirmar quais ações o proprietário precisa realizar primeiro no Espaço do Criador.
2. Desenhar o fluxo de login exclusivo do proprietário: sem signup aberto; a senha deve ser criada pelo proprietário no fluxo seguro do provedor, nunca enviada em chat nem guardada no Git.
3. Revisar e mostrar qualquer migration e regra RLS antes de aplicar ao projeto remoto.
4. Testar anônimo, proprietário e usuário sem papel com conteúdo fictício, negando acesso por padrão. Revisar Storage, RPC/functions e exportações; manter segredo privilegiado apenas server-side.
5. Só avaliar portal clínico/dados reais depois dos gates de consentimento, finalidade, vínculo, escopos, prazo, revogação, auditoria, exclusão, suporte e aprovação do responsável.

A criação do projeto **não** foi aprovação para criar contas, tabelas, migrations, login, serviço server-side, publicar portal, sincronizar dados reais, mudar plano ou habilitar itens pagos. Essas decisões precisam de etapas próprias e, quando aplicável, aprovação explícita.

## Situação das outras frentes

A PR pública do site [#83](https://github.com/falacomigocaa-app/fala-comigo/pull/83) tem os dois checks verdes, mas segue aberta e não foi mesclada. Seu merge altera o GitHub Pages público e depende de autorização separada. As PRs Android #79–#81 ainda exigem revalidação, APK identificado por commit e teste em dispositivo; PR #82 apenas corrigiu a assinatura de mídia Web e não valida Android em aparelho.
