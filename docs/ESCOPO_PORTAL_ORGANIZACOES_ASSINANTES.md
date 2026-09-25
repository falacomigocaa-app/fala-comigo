# Fala Comigo — Escopo profissional do portal, organizações e assinantes

**Versão:** 1.0 — 25/09/2026
**Status:** escopo para aprovação; não representa backend ou cobrança em produção.

## 1. Diagnóstico atual

O aplicativo Flutter já possui a base local para:

- organizações por tipo: clínica, escola, patrocinador e profissional;
- concessões locais de acesso com status `pending`, `active`, `revoked` e `expired`;
- escopos locais, finalidade e prazo;
- tarefas compartilhadas e fila offline;
- revogação local;
- área parental com gerenciamento de acessos.

Entretanto, o acesso atual ainda é **local-first**. A estrutura `AccessGrant` guarda o nome da organização, pessoa, função, escopos e validade, mas não cria identidade remota, não confirma o destinatário e não envia um convite real.

A Web atual em `site/` é um site institucional estático hospedado no GitHub Pages. `site/portal.html` é uma **prévia com dados sintéticos**: seus botões não criam convites, não autenticam pessoas, não persistem permissões e não processam assinaturas.

Conclusão: um link copiado hoje não deve ser tratado como autorização real. Para convite e assinatura reais, é necessário um portal com autenticação, banco, API e autorização no servidor.

## 2. Objetivo do produto Web

Criar duas superfícies separadas:

1. **Site público:** apresentação, privacidade, planos, instituições, suporte e interesse comercial. Não recebe dados de crianças.
2. **Portal conectado:** área autenticada para famílias, organizações e profissionais. Trabalha com convites, vínculos, consentimentos, tarefas, licenças e auditoria.

O portal não pode bloquear o modo offline do aplicativo. O benefício patrocinado nunca concede permissão automática sobre dados familiares.

## 3. Fluxo profissional do convite

### 3.1 Família convidando uma organização ou profissional

1. Responsável entra em **Área Parental → Pessoas e organizações → Convidar**.
2. Escolhe:
   - organização existente ou convite para nova organização;
   - pessoa ou função destinatária;
   - finalidade: `communication_support`, `school_support`, `routine` ou outra finalidade prevista;
   - escopos exatos;
   - prazo de validade;
   - se pode ler, criar, atualizar ou exportar.
3. O servidor cria um convite individual com:
   - `invitationId`;
   - organização e destinatário;
   - `subjectId` pseudonimizado;
   - finalidade, escopos e prazo;
   - versão do texto de consentimento;
   - expiração curta, por exemplo 72 horas;
   - uso único e estado `pending`.
4. O sistema envia ou permite copiar um link de convite. O link contém apenas um token aleatório de uso único; não contém diagnóstico, nome da criança, permissões em texto aberto ou dados clínicos.
5. O destinatário abre o link, autentica a própria conta e confirma identidade, organização e função.
6. O portal mostra exatamente o que será compartilhado, por quanto tempo e para qual finalidade.
7. O destinatário aceita ou recusa.
8. O responsável confirma o consentimento final quando o fluxo exigir dupla confirmação.
9. O vínculo passa de `pending` para `active` somente após todas as confirmações necessárias.
10. Cada etapa gera `AuditEvent`.

### 3.2 Organização convidando uma família

1. Organização inicia um convite de benefício ou de participação.
2. O convite explica separadamente:
   - benefício ou licença oferecida;
   - período;
   - suporte incluído;
   - dados administrativos necessários;
   - o que a organização não poderá acessar.
3. A família aceita ou recusa sem perder a comunicação local.
4. O aceite do benefício cria `BenefitEntitlement`; não cria `AccessGrant` clínico.
5. Qualquer acesso a perfil, tarefa, plano ou documento exige uma segunda solicitação de acesso, com consentimento e escopo próprios.

### 3.3 Regras do link

- expiração automática;
- uso único ou revogável;
- token armazenado no servidor somente como hash;
- autenticação antes de revelar detalhes do convite;
- convite recusado não cria vínculo;
- convite expirado não pode ser aceito;
- reenvio invalida o token anterior;
- não usar links permanentes;
- não colocar dados pessoais na URL;
- registrar criação, envio, abertura, aceite, recusa, expiração e revogação.

## 4. Matriz inicial de permissões

Permissão é sempre combinada com organização, sujeito, finalidade, consentimento e prazo. Um papel sozinho nunca concede acesso global.

| Perfil | Pode fazer | Não pode fazer por padrão |
|---|---|---|
| Responsável/família | convidar, revisar, aceitar, revogar, escolher escopos, exportar visão autorizada e solicitar exclusão | perder controle para uma organização ou liberar tudo por um único aceite |
| Administrador da organização | gerenciar usuários e configurações da própria organização, acompanhar convites da própria organização | visualizar criança ou conteúdo sem vínculo e consentimento |
| Profissional/terapeuta | ler ou atualizar os recursos explicitamente vinculados à sua finalidade | acessar outra organização, exportar mídia ou ler prontuário fora do escopo |
| Professor/AEE | acessar resumo funcional e tarefas escolares autorizadas | acessar receita, diagnóstico detalhado, mídia clínica ou prontuário integral |
| Leitura | visualizar recursos publicados no escopo | editar, convidar, exportar ou baixar mídia |
| Suporte | atender conta sem conteúdo por padrão; acesso excepcional temporário e auditado | navegar livremente por dados familiares |
| Patrocinador/empresa | administrar licenças, período e indicadores agregados | saber nome da criança, diagnóstico, cartões, uso individual, fotos, vídeos ou relatórios |
| Proprietário da plataforma | governança, planos, licenças, segurança e auditoria mínima | acessar conteúdo familiar ou clínico por padrão |

### Escopos canônicos iniciais

- `tasks.read`, `tasks.create`, `tasks.update`;
- `communication_profile.read`, `communication_profile.write`, `communication_profile.publish`;
- `communication_plan.read`, `communication_plan.create`, `communication_plan.update`, `communication_plan.respond`;
- `appointments.read`, `appointments.create`, `appointments.update`, `appointments.respond`;
- `routine.read`;
- `documents.published.read`;
- `benefit.manage`;
- `access.invite`, `access.read`, `access.revoke`;
- `audit.read`.

## 5. Modelo Web para assinantes

### 5.1 Separar três coisas

1. **Catálogo:** quais planos existem e seus limites.
2. **Assinatura:** contrato e estado de pagamento no provedor.
3. **Licença/entitlement:** quais recursos o sistema libera.

Uma assinatura ativa não libera conteúdo clínico. Uma licença patrocinada não concede `communication_profile.read` automaticamente.

### 5.2 Planos de produto

| Plano | Público | Recursos conectados | Regra de privacidade |
|---|---|---|---|
| Essencial | famílias | comunicação local, cartões, frases, voz e controles parentais | gratuito, sem servidor obrigatório |
| Família | famílias que optarem por conveniência | restauração e sincronização selecionada, dentro de limites | família escolhe o que sai do dispositivo |
| Cuidado conectado | famílias com rede autorizada | tarefas, perfil funcional, planos e agenda com escopo | cada vínculo precisa de consentimento |
| Patrocinado | famílias beneficiadas | licença paga por parceiro | patrocinador não vê conteúdo familiar |
| Organização | clínicas e escolas | gestão de equipe, convites e casos autorizados | isolamento por organização |

### 5.3 Estados comerciais

`pending`, `trialing`, `active`, `past_due`, `grace`, `suspended`, `canceled`, `expired`, `refunded`, `disputed` e `revoked`.

Cada mudança precisa guardar data, origem, identificador externo, versão e motivo. Webhooks repetidos devem ser idempotentes.

O Essencial continua funcionando após cancelamento, suspensão ou término do benefício.

## 6. Arquitetura Web comparada

| Abordagem | Trade-offs | Custo | Complexidade |
|---|---|---|---|
| Portal full-stack com autenticação, banco, API e storage gerenciado | Permite convites reais, RBAC/ABAC, auditoria, assinaturas e evolução; exige schema, testes de negação e operação cuidadosa | custo inicial baixo no piloto; custo variável conforme usuários, banco, storage e mensagens | média/alta |
| Site GitHub Pages + backend gerenciado separado | Mantém o site público barato e adiciona autenticação/banco fora dele; exige integração, domínios e configuração de chaves | site barato; backend e mensagens pagos conforme uso | média |
| Protótipo Web estático com dados sintéticos | Rápido para validar telas, fluxos e linguagem; não serve para convites reais, assinantes ou dados pessoais | baixo | baixa |

**Limite importante:** não é seguro transformar o atual `portal.html` em portal real apenas com JavaScript e links. O navegador não pode ser a autoridade de permissão.

## 7. Fases de entrega

### Fase A — contrato e protótipo

- telas de convite, aceite, recusa, revogação e assinatura;
- dados sintéticos;
- matriz de permissões visível;
- textos de consentimento;
- estados vazios, erro, expiração e conflito;
- validação de acessibilidade.

### Fase B — fundação autenticada

- login individual;
- usuários, organizações, memberships e papéis;
- banco multi-organização;
- API tipada;
- auditoria;
- convites expirareis;
- testes de negação.

### Fase C — portal de cuidado

- família e organizações vinculadas;
- consentimentos versionados;
- tarefas compartilhadas;
- perfil funcional publicado;
- planos de comunicação;
- revogação imediata;
- exportação minimizada;
- sincronização offline com idempotência.

### Fase D — assinaturas em sandbox

- catálogo de planos;
- checkout de teste;
- webhook assinado;
- idempotência;
- entitlements;
- cancelamento, reembolso e expiração simulados;
- painel administrativo sem conteúdo clínico.

### Fase E — produção controlada

Somente depois de revisão jurídica, fiscal, de privacidade, retenção, suporte, incidentes, segurança, custos e confirmação explícita para ativar cobrança real.

## 8. Testes de aceite obrigatórios

1. convite pendente não permite leitura;
2. convite expirado não pode ser aceito;
3. convite de uma organização não aparece para outra;
4. professor não lê documento clínico;
5. patrocinador não vê uso individual;
6. revogação bloqueia nova leitura imediatamente;
7. `tasks.read` não permite editar plano;
8. reenvio invalida o token anterior;
9. repetição de webhook não duplica licença;
10. cancelamento não bloqueia comunicação offline;
11. usuário sem vínculo não descobre se uma criança está cadastrada;
12. exportação mostra o escopo antes do envio;
13. URL temporária expirada não baixa mídia;
14. suporte excepcional expira e fica auditado;
15. app e portal exibem os mesmos estados e identificadores canônicos.

## 9. Decisões que precisam ser confirmadas antes da implementação real

1. O convite será enviado prioritariamente por e-mail, WhatsApp, ou ambos?
2. A primeira versão conectada será somente para famílias e clínicas/escolas, deixando patrocinadores para a segunda etapa?
3. O portal autenticado ficará em endereço separado do site público?
4. O primeiro piloto usará somente dados sintéticos, como definido nos contratos?
5. Qual provedor comercial será avaliado quando chegar a fase de cobrança sandbox?

Até essas decisões, a entrega segura é atualizar o protótipo e o contrato, sem ativar convite real, armazenamento clínico ou cobrança.
