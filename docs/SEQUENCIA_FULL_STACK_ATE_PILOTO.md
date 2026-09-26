# Fala Comigo — Sequência Full-Stack até o piloto institucional

**Versão:** 1.0 — 22 de setembro de 2026  
**Objetivo:** conduzir o aplicativo, o site e o futuro portal conectado até um teste controlado com o colégio e a clínica disponíveis, sem ativar cobrança real ou compartilhar dados clínicos antes de existirem autorização, isolamento e validação adequados.

## 1. Decisão de arquitetura

O produto será dividido em quatro superfícies relacionadas, mas independentes:

| Superfície | Função | Regra de dados |
| --- | --- | --- |
| Aplicativo Flutter | Comunicação básica, uso offline e área local do responsável | Funciona sem conta, internet ou plano pago |
| Site institucional | Explicar o produto, privacidade, planos e áreas para instituições | Não recebe dados de crianças |
| Portal institucional | Colaboração autorizada entre família, clínica e escola | Autoriza cada leitura no servidor |
| Console do proprietário | Governança, organizações, planos, licenças, suporte e auditoria | Não concede acesso automático ao conteúdo clínico |

A comunicação básica nunca dependerá do portal, de pagamentos, de conexão ou de aprovação de uma instituição. O portal será uma extensão opcional para colaboração autorizada.

**Regra de não bloqueio:** o login do portal institucional não é login do aplicativo da criança/adolescente. O app deve abrir rápido e manter comunicação básica, acessibilidade e uso offline sem conta ou Internet. Logout, expiração ou falha do portal não pode deslogar, apagar ou restringir o núcleo local.

O login poderá ser usado para controlar e administrar usuários, responsáveis, organizações, dispositivos e recursos conectados. Essa governança não é uma restrição de uso: a vinculação opcional do responsável pode persistir no dispositivo, enquanto cartões, frases, acessibilidade e comunicação básica permanecem disponíveis.

## 2. Fluxo do proprietário do aplicativo

O proprietário terá uma área administrativa separada da Área do Responsável. Ela não deve ser colocada dentro do aplicativo da criança.

### 2.1 Primeiro acesso do proprietário

1. Criar a organização proprietária da plataforma.
2. Confirmar identidade e e-mail administrativo.
3. Ativar autenticação forte e recuperação segura.
4. Aceitar os termos administrativos e a política de tratamento de dados.
5. Cadastrar dados da empresa ou entidade responsável pela operação.
6. Definir o responsável técnico de privacidade e o canal de suporte.
7. Criar perfis internos com menor privilégio.
8. Registrar todas as ações administrativas em auditoria.

A tela do proprietário deve deixar claro que a pessoa administradora gerencia a plataforma, mas não deve acessar conteúdo familiar ou clínico por padrão. O acesso excepcional precisa ter motivo, prazo, aprovação quando aplicável e registro.

### 2.2 Perfis administrativos

- **Proprietário:** governança geral, contratos e configurações críticas.
- **Administrador de produto:** planos, recursos, versões e conteúdo público.
- **Suporte:** atendimento sem acesso ao conteúdo clínico por padrão.
- **Privacidade e segurança:** auditoria, consentimentos, incidentes e solicitações de titulares.
- **Financeiro:** faturas, pagamentos, licenças e conciliação.
- **Administrador de instituição:** somente a própria organização e os vínculos autorizados.

Nenhum perfil deve receber acesso global a todas as crianças por causa do cargo. O sistema deve autorizar por organização, vínculo, finalidade, prazo, tipo de dado e operação.

## 3. Fluxo de assinatura, pagamento e licença

O produto terá três estados diferentes, que não devem ser misturados:

1. **Catálogo:** quais planos existem e quais recursos cada um descreve.
2. **Assinatura comercial:** contrato e estado de pagamento com o provedor.
3. **Licença de produto:** direito administrativo de ativar recursos opcionais.

### 3.1 Fluxo após a assinatura

O fluxo planejado é:

```text
Instituição escolhe plano
→ vê preço, período e limites
→ aceita termos e política
→ inicia pagamento no provedor
→ provedor confirma pagamento por webhook assinado
→ servidor valida o evento e evita duplicidade
→ assinatura é registrada
→ licença é emitida
→ recursos opcionais são habilitados
→ instituição recebe comprovante e status
```

A licença **não** será ativada somente porque o navegador voltou para uma página de sucesso. A ativação dependerá da confirmação verificada do provedor de pagamento.

### 3.2 Estados necessários

A assinatura deve suportar, no mínimo:

- `pending`: checkout iniciado, sem confirmação;
- `active`: pagamento confirmado e licença válida;
- `trialing`: período de teste explicitamente definido;
- `past_due`: cobrança pendente;
- `grace`: período de transição documentado;
- `suspended`: recurso conectado temporariamente suspenso;
- `canceled`: cancelada pelo cliente ou administrador;
- `expired`: validade encerrada;
- `refunded`: pagamento estornado;
- `disputed`: pagamento contestado;
- `revoked`: licença retirada por regra administrativa ou fraude confirmada.

Qualquer mudança deve guardar evento, origem, data, identificador externo, versão e motivo. Eventos repetidos do provedor não podem duplicar licenças.

### 3.3 O que permanece gratuito

Mesmo com assinatura vencida, suspensa ou cancelada, a família mantém:

- comunicação básica;
- cartões locais;
- montagem de frases;
- acessibilidade;
- controle parental;
- dados locais;
- uso offline.

A licença controla apenas recursos opcionais conectados ou administrativos.

### 3.4 Pagamento real

A integração real de pagamento fica bloqueada até:

- escolha do provedor;
- comparação de taxas, portabilidade e cancelamento;
- definição de preços;
- revisão jurídica e fiscal;
- política de reembolso;
- teste em ambiente sandbox;
- verificação de webhooks;
- reconciliação de eventos;
- confirmação explícita do proprietário para ativação em produção.

Até lá, serão usados catálogo, licenças fictícias e ambiente de teste. Nenhuma cobrança será ativada automaticamente.

## 4. Sequência de programação

### Sequência 00 — Linha de base e governança

**Entrega:** documentação, matriz de riscos, ambientes e critérios de aceite.

**Implementar:** atualizar handoff, separar app/site/portal/console, definir ambiente de desenvolvimento, testes e produção, registrar responsáveis e política para dados sintéticos.

**Testar:** CI, análise, testes, build Web, estado limpo do Git, ausência de segredos e checklist de riscos.

**Pronto quando:** qualquer colaborador consegue entender o escopo e executar a validação básica.

### Sequência 01 — Site institucional completo

**Entrega:** página pública com áreas para famílias, clínicas, fonoaudiologia, escolas e empresas patrocinadoras.

**Implementar:** benefícios, limites, FAQ, privacidade, contato, planos, chamada para teste institucional e aviso de que o portal conectado ainda está em desenvolvimento.

**Testar:** responsividade, teclado, leitor de tela, links, linguagem sem promessa clínica, navegação sem dados pessoais e publicação no GitHub Pages.

**Pronto quando:** o site explica o produto sem prometer portal, pagamento ou resultado terapêutico inexistente.

### Sequência 02 — Console do proprietário sem dados clínicos

**Entrega:** protótipo autenticado do console do proprietário.

**Implementar:** organizações, usuários administrativos, papéis, planos, licenças de teste, configurações públicas, suporte e auditoria.

**Não implementar ainda:** consulta ampla a fichas, fotos, vídeos, receitas ou registros de terapia.

**Pronto quando:** o proprietário consegue administrar a plataforma sem receber conteúdo clínico por padrão.

### Sequência 03 — Contrato de identidade e organização

**Entrega:** modelo de backend para identidade e multi-organização.

**Entidades:** usuário, organização, vínculo, relação com a pessoa, papel, permissão, finalidade, consentimento, prazo, auditoria e incidente.

**Testes negativos:** organização errada, vínculo inexistente, papel insuficiente, convite expirado, conta desativada, finalidade incompatível e sessão inválida.

**Pronto quando:** toda autorização é decidida no servidor e não apenas escondida na interface.

**Gate 3A concluído em 26/09/2026:** a API sintética agora testa sujeito infantil, consentimento, convite ligado ao consentimento, grant por pessoa+sujeito+organização e revogação. O próximo Gate 3B deve integrar identidade real, banco persistente e portal web mínimo, ainda com dados sintéticos.

### Sequência 04 — Convites e autorização do responsável

**Entrega:** fluxo para responsável autorizar clínica ou escola.

**Implementar:** convite individual, validade, confirmação do destinatário, escopo de dados, finalidade, prazo, aceite, recusa, revogação e histórico.

**Exemplo:** o responsável compartilha somente “tarefas de comunicação e relatório do período” com uma clínica até uma data definida.

**Pronto quando:** revogar o acesso impede novas leituras e downloads imediatamente, respeitando registros de auditoria e obrigações de retenção.

**Fluxo obrigatório antes da implementação real:** o responsável usa o site autenticado; cadastra `FamilySpace` e `ChildSubject`; escolhe organização verificada e pessoa nominal; seleciona finalidade, categorias de dados, ações e prazo; confirma consentimento; envia convite por e-mail ou link de resgate. Escola, clínica, cuidadora, professor e terapeuta acessam pelo site com contas individuais. O app CAA infantil não é necessário para o portal e nunca pode ser bloqueado por login, sessão ou revogação remota.

**Não está pronto:** a API local usa identidade sintética e memória/fixtures; ainda não há e-mail, token de convite real, consentimento versionado, verificação de organização, sujeito infantil conectado a grants, sessão real ou revogação de conteúdo em produção.

### Sequência 05 — Modelos locais no aplicativo

**Entrega:** base local preparada para futura colaboração, sem sincronização automática.

**Implementar:** perfil mínimo, objetivos, linha de base, evolução, tarefas, preferências, reforçadores, documentos locais, consentimentos e histórico de alterações.

**Regra:** esses modelos devem funcionar offline e não devem exigir diagnóstico para permitir comunicação básica.

**Testar:** persistência, exclusão local, versões, dados ausentes, cancelamento, exportação minimizada e recuperação após erro.

### Sequência 06 — Ficha, histórico e objetivos

**Entrega:** telas locais na Área do Responsável para organizar a jornada.

**Implementar:** ficha, linha do tempo, etapas de avaliação, planejamento, implementação e revisão; separar dado observado, interpretação profissional e recomendação.

**Pronto quando:** uma clínica consegue testar a organização usando dados sintéticos sem precisar de portal.

### Sequência 07 — Evolução, reforço e tarefas

**Entrega:** registro local de evolução e tarefas para responsáveis.

**Implementar:** medidas configuráveis, contexto, observador, reforçadores, barreiras, tarefa, prazo, resposta do responsável, feedback e revisão humana.

**Não implementar:** diagnóstico, prescrição, punição automática ou recomendação clínica autônoma.

### Sequência 08 — Área pública para instituições

**Entrega:** site com páginas específicas para clínicas, fonoaudiólogos, escolas e patrocinadores.

**Implementar:** casos de uso, limites de acesso, convite para piloto, FAQ institucional e formulário de interesse sem coleta clínica.

**Pronto quando:** as instituições entendem o benefício sem acreditar que já existe sincronização clínica em produção.

### Sequência 09 — Portal de teste sem dados clínicos

**Entrega:** portal conectado com organizações, convites e consentimentos usando dados sintéticos.

**Implementar:** login, organização, papéis, convite, consentimento, revogação, auditoria, exportação e isolamento.

**Pronto quando:** os testes de negação passarem antes de qualquer documento clínico real.

### Sequência 10 — Documentos e comunicação autorizada

**Entrega:** envio controlado de relatório, tarefa ou documento já emitido por clínica ao responsável.

**Implementar:** arquivo original, remetente, destinatário, finalidade, validade, acesso, download, revogação e auditoria.

**Limite:** não emitir receita, não editar documento médico, não diagnosticar e não validar conteúdo clínico. A clínica continua responsável pelo documento.

### Sequência 11 — Piloto com clínica e colégio

**Entrega:** teste controlado com dados sintéticos ou dados reais somente após aprovação documental.

**Participantes:** proprietário, um administrador da clínica, um profissional, um representante do colégio e responsáveis convidados.

**Cenários:** convite, recusa, aceite, tarefa, relatório, transição, revogação, acesso indevido, expiração, exportação e exclusão.

**Métricas:** compreensão, tempo para completar tarefa, falhas de autorização, acessibilidade, carga para responsáveis, clareza das mensagens e incidentes.

**Pronto quando:** não há bloqueador de segurança, privacidade ou comunicação básica.

### Sequência 12 — Licenças patrocinadas

**Entrega:** benefício corporativo sem acesso da empresa ao conteúdo familiar.

**Implementar:** lote de licenças, convite, ativação voluntária, transferência, encerramento, painel agregado e reconciliação.

**Testar:** empregador não identifica uso individual, revogação não apaga dados locais e a família mantém o plano Essencial.

### Sequência 13 — Pagamento sandbox e emissão automática de licença

**Entrega:** ciclo comercial em ambiente de teste.

**Implementar:** checkout de teste, webhook assinado, idempotência, estados, fatura de teste, cancelamento, reembolso simulado, renovação e emissão de licença.

**Pronto quando:** todo evento de pagamento produz estado previsível, auditável e reversível.

### Sequência 14 — Revisão jurídica, fiscal e de suporte

**Entrega:** termos, privacidade, DPA/contratos institucionais, política de reembolso, retenção, incidentes e suporte.

**Pronto quando:** há responsáveis definidos para tratamento de dados, atendimento, incidentes, exclusão e encerramento de organização.

### Sequência 15 — APK/AAB e validação em aparelhos

**Entrega:** build Android de teste e, depois, release.

**Testar:** celular, tablet, offline, TalkBack, permissões, mídia, voz, exportação, exclusão, link do site e retorno após abrir o navegador.

### Sequência 16 — Entrada controlada em produção

**Entrega:** primeiro lançamento limitado.

**Critérios:** CI verde, APK/AAB assinado, portal isolado, testes negativos verdes, política publicada, suporte pronto, piloto concluído e aprovação explícita para publicação ampla.

## 5. Ordem imediata de execução

A ordem escolhida é:

```text
00 governança
→ 01 site institucional
→ 02 console do proprietário
→ 03 identidade e organizações
→ 04 autorização do responsável
→ 05 modelos locais
→ 06 ficha e objetivos
→ 07 evolução e tarefas
→ 08 áreas institucionais do site
→ 09 portal sem dados clínicos
→ 10 documentos autorizados
→ 11 piloto clínica + colégio
→ 12 licenças patrocinadas
→ 13 pagamentos sandbox
→ 14 revisão legal e suporte
→ 15 APK/AAB e aparelhos
→ 16 entrada controlada
```

O aplicativo CAA e o uso offline continuam protegidos durante todas as etapas. O portal, pagamentos e licenças nunca podem bloquear a comunicação básica.

## 6. Critérios de aceite do piloto

O piloto somente começa quando:

- todos os participantes usam contas individuais;
- não há dados reais em desenvolvimento ou demonstração;
- existe responsável pelo tratamento em cada organização;
- convites expiram;
- permissões são específicas;
- consentimentos têm finalidade e prazo;
- revogação bloqueia novos acessos;
- ações ficam auditadas;
- organizações ficam isoladas;
- relatórios não prometem eficácia clínica;
- o patrocinador não vê conteúdo familiar;
- o aplicativo básico funciona sem internet;
- existe procedimento para incidente, exclusão e suporte;
- o colégio e a clínica revisaram os fluxos com dados sintéticos antes de qualquer uso real.

## 7. Decisões que exigirão confirmação posteriormente

A implementação pode avançar sem decisão para tarefas reversíveis. Será necessário confirmar antes de ações externas de alto impacto:

- ativar um provedor de pagamento em produção;
- contratar serviço pago;
- comprar domínio;
- publicar amplamente o aplicativo;
- iniciar sincronização com dados reais;
- assinar contrato institucional;
- definir preço final e política de reembolso.

Até essas decisões, o sistema deve permanecer em modo gratuito, local-first, sandbox ou piloto controlado.

## 8. Checkpoint de execução — 25/09/2026

A Opção A foi confirmada e o ADR de arquitetura foi criado. O site institucional oficial permanece no GitHub Pages em <https://falacomigocaa-app.github.io/fala-comigo/>; o login e o portal futuro serão independentes do Pages e do Manus.

O Gate 1A foi concluído documentalmente em `docs/ESPECIFICACAO_MVP_PORTAL_SINTETICO.md`. Ele define o MVP sintético, as entidades mínimas, papéis, escopos, endpoints, fixtures, auditoria e testes de negação. Nenhum backend, login, banco remoto, provedor, cobrança ou dado real foi criado.

A próxima atividade é o **Gate 2 — implementação local**: criar API modular, PostgreSQL descartável, migrations reproduzíveis, fixtures sintéticas e testes automatizados de isolamento e autorização. A comparação de provedores fica depois da validação local; a troca do link do Criador fica depois da publicação e validação do destino independente.

O Gate 2 foi dividido para evitar mistura de responsabilidades. O **Gate 2A** criou a API local sintética, fixtures, autorização, auditoria, idempotência e testes sem dependências externas. O **Gate 2B** foi concluído com migration e teste de integração contra PostgreSQL 16.15 descartável; a instância foi encerrada e removida. O próximo passo é o **Gate 3 — segurança e operação**, antes de qualquer identidade real ou provedor externo.

### Pesquisa comparativa de CAA — 26/09/2026

Foi consolidada a comparação de Proloquo, TD Snap, Grid for iPad, TouchChat HD, CoughDrop, Cboard, Avaz AAC e Fala Comigo. O documento `docs/AVALIACAO_COMPARATIVA_CAA_E_FILA_MELHORIAS.md` é a fonte da fila de aperfeiçoamento. A conclusão não é um ranking clínico: os concorrentes estão à frente em distribuição e maturidade operacional, enquanto o Fala Comigo tem diferenciação potencial em português brasileiro, privacidade local, custo do núcleo essencial e independência de conta/portal.

Antes de qualquer portal ou login real, executar os bloqueadores **P0** e a validação **P1**: aparelho Android real, abertura/offline, TTS pt-BR, acessibilidade, armazenamento seguro, identidade de distribuição, política coerente e testes participativos. O controle de usuários permanece separado da comunicação infantil e não pode transformar melhorias conectadas em restrição do app.

### Decisão de autenticação para etapa posterior

Depois do Gate 2, a integração de identidade deverá priorizar autenticação sem senha: Google OAuth/OpenID Connect e link mágico por e-mail. O primeiro aceita contas Google; o segundo aceita endereços de qualquer provedor. Nenhuma dessas opções concede autorização automaticamente: convite, organização, papel, finalidade, escopo, prazo e revogação continuam sob decisão da API. A integração real será um gate separado, em ambiente de teste e sem dados reais.
