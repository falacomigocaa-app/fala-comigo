# Supabase de teste — guia simples

**Atualizado:** 27 de setembro de 2026. Este documento explica o estado atual sem exigir conhecimento técnico.

## O que foi preparado

Criamos um projeto vazio chamado **Fala Comigo Staging** no Supabase, na região de São Paulo. É um ambiente separado para construir e testar o Espaço do Criador; ainda não é o backend em produção.

| Item | Estado |
|---|---|
| Projeto | `Fala Comigo Staging` |
| Referência do projeto | `gojqeaontgshikdqlpfn` |
| Região | São Paulo (`sa-east-1`) |
| Situação técnica | Ativo e saudável |
| Preço estimado pelo Supabase no momento da criação | US$ 0 por mês |
| Tabelas públicas | Nenhuma |
| Migrations (alterações planejadas/aplicadas no banco) | Nenhuma |
| Contas do aplicativo | Nenhuma |
| Chaves copiadas para o app/site | Nenhuma |
| Dados pessoais ou de crianças | Nenhum |

O projeto anterior **Fala comigo CAA**, na Virgínia (`us-east-1`), continua separado e não foi alterado. O projeto novo ocupa a segunda vaga gratuita ativa atualmente disponível na conta.

## O que “plano grátis” significa hoje

A página oficial do Supabase lista para o plano Free: até **dois projetos ativos gratuitos**, até **500 MB de banco por projeto**, **50.000 usuários ativos mensais**, **1 GB de arquivos** e **5 GB de tráfego de saída**, com cotas e condições do provedor. O custo que o Supabase estimou para este projeto foi **US$ 0/mês**, mas preço, limites e regras podem mudar.

Dois pontos importantes para um projeto gratuito:

- Se ficar com pouca atividade no banco por sete dias, o projeto pode ser pausado automaticamente. Nesse caso, o responsável precisa reativá-lo pelo painel do Supabase. Um staging parado não é uma hospedagem com disponibilidade garantida.
- O plano Free não inclui backups diários automáticos do banco; a documentação informa que backups do banco não podem ser baixados. Por isso, não vamos colocar dados importantes nem dados reais de crianças nesse ambiente.

Também não devemos ativar complementos, mudar de plano, criar projetos adicionais nem habilitar algo que possa gerar cobrança sem explicar o custo e obter autorização antes.

Fontes oficiais: [preços do Supabase](https://supabase.com/pricing), [cobrança e limites](https://supabase.com/docs/guides/platform/billing-on-supabase) e [pausa por inatividade](https://supabase.com/docs/guides/platform/free-project-pausing).

## O que ainda NÃO foi feito

Criar o projeto não criou o login do Fala Comigo. Ainda não foram criadas contas de pessoas, tabelas, permissões, políticas de segurança ou migrations. Nenhuma senha, chave de API ou segredo foi copiado para o código.

A comunicação CAA básica do aplicativo deve continuar funcionando **sem internet, sem conta e sem plano pago**. O futuro login é para o Espaço do Criador/proprietário, separado da Área do Responsável e de qualquer dado clínico. Uma conta conectada identifica quem entrou; não concede por si só autorização para ler dados de crianças.

## Como vamos seguir sem colocar dados em risco

1. Manter o projeto vazio enquanto revisamos a primeira função do Espaço do Criador.
2. Preparar um plano curto de login restrito ao proprietário; não abrir cadastro público por padrão.
3. Antes de alterar o banco, mostrar o desenho das tabelas e regras de acesso. Essas regras devem negar acesso por padrão e ser conferidas também no servidor (RLS).
4. Testar com contas e conteúdo inventados, incluindo tentativas de acesso sem login e com uma conta sem permissão. Não usar dados reais de crianças.
5. Só criar a primeira conta do proprietário depois de confirmar o fluxo. A senha deve ser escolhida pelo responsável no fluxo oficial do provedor, nunca enviada no chat ou guardada no GitHub.
6. Separar ações que exigem privilégio administrativo num servidor/função protegida. Nunca colocar `service_role` nem outra chave secreta no navegador, app ou repositório; o código público pode ser inspecionado por qualquer visitante.
7. Antes de qualquer piloto com dados reais, revisar consentimento, finalidade, prazo, revogação, exclusão, auditoria, recuperação, suporte e todos os testes de negação.

## Próximo ponto de decisão

A primeira decisão de produto ainda é: **o que o Espaço do Criador precisa permitir no primeiro acesso do proprietário?** Podemos começar somente com um painel de acesso e informações não sensíveis, sem contas de famílias, clínicas ou escolas. O escopo precisa estar escrito antes de criar tabelas ou ligar usuários.

O usuário quer usar infraestrutura própria, sem depender do Manus Space. Este projeto Supabase foi escolhido para **staging**, mas isso não significa aprovação para produção, sincronização clínica, cobrança ou publicação ampla. O site público continua separado no GitHub Pages.
