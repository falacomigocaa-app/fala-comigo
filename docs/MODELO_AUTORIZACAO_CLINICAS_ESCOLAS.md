# Modelo de autorização para clínicas e escolas

## Objetivo

O portal futuro do Fala Comigo deverá tratar cada clínica, escola, empresa patrocinadora ou equipe como uma organização isolada. O aplicativo local continuará funcionando offline e não deverá se transformar automaticamente em um prontuário compartilhado. A sincronização somente poderá ser ativada quando o servidor aplicar as regras deste documento.

A regra principal é **negação por padrão**: uma solicitação somente é permitida quando a identidade, a organização, o vínculo com a criança, o papel profissional, a finalidade e o prazo de retenção forem compatíveis.

## Entidades mínimas

| Entidade | Finalidade | Regra de isolamento |
| --- | --- | --- |
| `User` | Identidade de uma pessoa que acessa o portal | Não existem contas compartilhadas. Cada pessoa usa uma identidade própria. |
| `Organization` | Clínica, escola, empresa patrocinadora ou organização familiar | Cada recurso compartilhado pertence a uma organização. O tipo da organização limita os papéis disponíveis. |
| `ChildSubject` | Referência pseudonimizada da criança ou adolescente | O identificador não deve ser usado sozinho como autorização. |
| `Membership` | Vínculo entre usuário e organização | Define o papel, o estado e a data de validade do acesso. |
| `Relationship` | Relação entre usuário e criança | Registra responsável legal, terapeuta, professor ou outro vínculo autorizado. |
| `Role` | Conjunto de permissões | Exemplos: responsável, administrador, terapeuta, professor, leitura e suporte. |
| `Permission` | Ação mínima sobre um recurso | Exemplos: ler, criar, editar, excluir, exportar e convidar. |
| `Purpose` | Motivo declarado para o acesso | O motivo deve ser compatível com o consentimento e com o tipo de dado. |
| `Consent` | Autorização registrada pelo responsável e, quando cabível, participação do adolescente | Deve indicar escopo, finalidade, organização, versão do texto, data, revogação e prazo. |
| `Retention` | Prazo de retenção de um recurso | Dados expirados deixam de ser acessíveis e entram em processo de exclusão. |
| `AuditEvent` | Trilha de segurança | Registra quem acessou o quê, por qual finalidade, quando, de qual organização e com qual resultado. Não registra conteúdo clínico desnecessário. |

## Decisão de autorização

O backend deve avaliar cada leitura, gravação, exportação, convite, download de mídia e alteração de consentimento. O filtro não pode existir apenas no Flutter, porque um cliente modificado poderia ignorá-lo.

Uma decisão deve seguir esta ordem:

1. validar a sessão do usuário e o estado da conta;
2. verificar que o usuário pertence à organização solicitante;
3. verificar que o recurso pertence à mesma organização;
4. verificar que existe relação ativa entre o usuário e a criança;
5. verificar o papel e a permissão específica para a ação;
6. verificar a finalidade declarada e o tipo de dado;
7. verificar consentimento vigente, prazo de retenção e eventual revogação;
8. registrar uma auditoria mínima e retornar somente o escopo autorizado.

A ausência de qualquer requisito resulta em `deny`. A API não deve revelar se outra organização possui uma criança, uma mídia ou um relatório quando a pessoa não tem autorização para saber disso.

## Papéis iniciais

O **responsável legal** pode gerenciar o vínculo da criança, conceder e revogar acessos, revisar exportações e solicitar exclusão. O **administrador da organização** administra usuários e configurações da própria clínica ou escola, mas não recebe acesso automático a crianças. O **terapeuta** pode acessar somente crianças vinculadas ao seu atendimento e apenas os tipos de registro necessários à finalidade informada. O **professor** recebe o menor escopo compatível com a atividade educacional. O papel de **leitura** não pode exportar nem baixar mídia. O papel de **suporte** não acessa conteúdo por padrão; quando houver atendimento técnico autorizado, o acesso deve ser temporário, justificado e auditado.

Nenhum papel concede acesso global por si só. A permissão sempre precisa ser combinada com organização, criança, relação, finalidade, consentimento e prazo.

## Compartilhamento e exportação

Convites devem ser individuais, expirar automaticamente e exigir autenticação forte. Links permanentes, contas compartilhadas e tokens sem prazo são proibidos. Exportações devem mostrar ao responsável quais campos e mídias serão enviados, permitir selecionar o escopo e gerar um evento de auditoria. O sistema deve preferir relatórios minimizados em vez de exportar toda a caixa de dados.

Mídias não devem ser incluídas em exportações por padrão. Quando forem necessárias, o sistema deve registrar o tipo, a finalidade, o destinatário e o prazo de validade do artefato. O download deve usar URLs temporárias e revogáveis, nunca caminhos permanentes do armazenamento.

## Consentimento e participação

O consentimento não deve ser inferido apenas pela existência de um PIN. O produto deve apresentar linguagem simples, finalidade, campos envolvidos, destinatários, retenção e opção de revogação. Quando a idade e a situação permitirem, o adolescente deve receber informação adequada e participar da decisão. A implementação final deve ser revisada juridicamente para definir a base legal, o controlador, os operadores e os requisitos aplicáveis ao caso concreto.

A revogação interrompe novos acessos e exportações. O servidor deve preservar somente o recibo mínimo necessário para demonstrar o estado da autorização, sem manter conteúdo clínico depois do prazo de retenção.

## Separação entre aplicativo local e portal

O aplicativo local deve continuar com caixas e chaves próprias do dispositivo. A sincronização futura deve usar registros versionados com `organizationId`, `childSubjectId`, `createdBy`, `purpose`, `consentId`, `retentionExpiresAt` e `classification`. Nenhuma caixa local deve ser tratada como cache de várias organizações sem criptografia, escopo e política de expiração.

Antes de liberar a sincronização, serão necessários testes de autorização negativa. Esses testes devem comprovar que um terapeuta não consegue consultar outra organização, que um professor não consegue exportar mídia, que um acesso revogado falha imediatamente e que uma URL expirada não permite download.

## Fluxo operacional obrigatório do portal

O portal deve ser acessível pelo **site autenticado**. Escola, clínica, cuidadora, professor e terapeuta não devem ser obrigados a instalar o aplicativo CAA da criança para aceitar convite ou consultar o escopo autorizado. Um aplicativo complementar pode existir depois para notificações e acessibilidade, mas não é a autoridade de acesso.

O fluxo mínimo é: responsável adulto cria sua conta e um `FamilySpace`; cadastra cada criança como `ChildSubject`; pesquisa uma organização verificada ou solicita o cadastro de uma escola/clínica; identifica uma pessoa adulta nominal; escolhe finalidade, categorias de dados, ações e prazo; registra consentimento; gera convite individual; o destinatário entra/cria sua própria conta no site; revisa e aceita ou recusa; o servidor cria o vínculo e o `AccessGrant` somente depois de revalidar identidade, organização, relação, consentimento, escopo e validade.

O link é somente um **resgate de convite**, nunca uma autorização ampla. Deve ser HTTPS, individual, de uso único, com expiração, token aleatório armazenado apenas como hash, sem nome ou dado sensível na URL. O portal deve exigir conta própria do destinatário e confirmação explícita. O responsável pode revogar convite, consentimento, grant e vínculo organizacional separadamente. A revogação bloqueia novas leituras e downloads no servidor; cópias já baixadas precisam ser tratadas pela política de retenção e pela organização.

Para o primeiro piloto, permitir somente `communication_profile.read` minimizado e `tasks.read/create/update` conforme finalidade. Escola recebe contexto pedagógico autorizado; clínica recebe contexto funcional autorizado; cuidadora recebe rotina/tarefas delegadas. Nenhum desses papéis recebe prontuário integral, diagnóstico, mídia ou exportação por padrão. Administrador da organização gerencia membros da própria organização, mas não vê crianças automaticamente.

## Referências

[1]: ../RELATORIO_AUDITORIA_SEGURANCA_PROFUNDA.md "Relatório de auditoria de segurança profunda"
