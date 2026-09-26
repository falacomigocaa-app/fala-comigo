# Avaliação e recomendação dos fluxos de autorização — Portal Fala Comigo

**Data:** 26/09/2026  
**Público:** proprietário do Fala Comigo  
**Decisão recomendada:** seguir com um portal web independente, começar por autorização e tarefas mínimas, e não liberar dados reais até que identidade, vínculo, consentimento, escopos, revogação e isolamento sejam aplicados e testados no servidor.

## 1. Recomendação executiva

O Fala Comigo deve manter a comunicação básica da criança local, acessível e independente de login. Para o portal, cada adulto deve ter **sua própria conta**; a criança deve ser um **sujeito/perfil distinto da conta** e não precisa de login infantil para o responsável criar ou usar o espaço familiar. Escola, clínica e família não devem compartilhar uma conta institucional ou credenciais.

Toda autorização deve ser específica à combinação **pessoa + sujeito (criança) + organização + finalidade + categoria de dados + ação + prazo**. Uma relação familiar, participação numa escola/clínica, aceite de convite ou pagamento de licença **não** equivale a permissão para ler dados. Um convite apenas inicia o cadastro/aceite; uma tarefa apenas permite uma ação limitada dentro de uma autorização existente.

Recomendo construir o produto em duas etapas distintas: (1) terminar e validar o portal sintético local que já consta no repositório, sem dados reais; (2) somente depois, implementar autenticação, e-mail, autorização server-side e um piloto real com escopo reduzido. O mock visual do portal não é um sistema conectado e não deve ser apresentado como se concedesse acesso.

## 2. Separe os seis conceitos no produto e no modelo

1. **Conta:** identidade individual autenticada de uma pessoa adulta (responsável, cuidadora, professor, terapeuta ou administrador). Confirma quem está usando o portal; não concede acesso a criança nem a uma organização por si só. A pessoa usa a mesma conta individual quando participa de mais de um contexto, mas cada contexto precisa de autorização própria.
2. **Família e sujeito:** o `FamilySpace` é o espaço administrativo da família; cada criança é um `ChildSubject` distinto associado a ele. O sujeito pode existir sem e-mail, login ou dispositivo próprio. Dados pessoais devem ser opcionais e mínimos; a criança não deve precisar criar conta para usar a comunicação básica.
3. **Organização:** entidade independente e verificada (por exemplo, escola ou clínica), com equipe e contexto próprios. A família pode selecionar uma organização já cadastrada ou solicitar que ela se cadastre; um nome digitado livremente não verifica a identidade da instituição.
4. **Vínculo:** registra relações separadas: conta adulta ↔ família/sujeito (responsável, cuidador delegado); conta adulta ↔ organização (membership/papel); e profissional ↔ sujeito dentro da organização (caso, turma ou relação de cuidado). Um vínculo pode estar pendente, ativo, expirado ou revogado. Um vínculo organizacional não autoriza acesso a todas as crianças daquela organização.
5. **Consentimento:** registro versionado de uma escolha afirmativa, informada e separada por finalidade/destinatário. Deve guardar quem autorizou, em nome de quem, versão do aviso, destinatário, propósito, escopos, data, validade e estado/revogação. Cadastro, aceite de termos, benefício, convite, consentimento e tarefa são registros diferentes. A representação e a participação da criança/adolescente dependem de política e revisão jurídica adequadas; um PIN ou posse do e-mail não prova guarda/responsabilidade.
6. **Escopo e tarefa:** escopo é a permissão de ler, criar, responder, editar, exportar ou baixar uma classe de dados para certa finalidade; deve ser uma lista enumerada, não texto livre. Uma tarefa (`SharedTask`) é um objeto operacional destinado a pessoas identificadas. Criar, aceitar, recusar ou concluir uma tarefa não amplia o grant e não substitui consentimento.

**Regra técnica:** a API deve recalcular autorização em cada leitura, gravação, exportação e download. A tela pode explicar ou ocultar opções, mas não é a fronteira de segurança. Licença ou patrocínio, se existir, fica em entidade separada e nunca libera conteúdo familiar.

## 3. Fluxo recomendado, do cadastro à revogação

1. **O responsável cria o espaço familiar e o sujeito.** No site/portal, cria uma conta adulta própria e, após autenticação, registra um espaço familiar e um perfil separado para cada criança. O fluxo infantil não pede e-mail ou login da criança. Nome completo, nascimento e outros dados identificadores devem ser opcionais, com explicação da necessidade; não pedir diagnóstico, laudo, biometria ou documento por padrão. A comunicação CAA no aplicativo continua local/offline, sem depender deste cadastro remoto.
2. **Confirme autoridade e convide outros responsáveis.** Antes de habilitar decisões de compartilhamento, defina uma verificação proporcional de quem se declara responsável e um processo para disputa, guarda compartilhada e correção. Não presumir representação legal com base apenas no vínculo de parentesco informado, num PIN local ou no recebimento de e-mail. Cada segundo responsável ou cuidador recebe conta própria, é convidado nominalmente pelo responsável autorizado e aceita seu próprio vínculo; os poderes (por exemplo, visualizar versus administrar autorizações) são configurados separadamente.
3. **Cadastre/identifique a escola ou clínica.** A família pesquisa organização verificada e unidade; se não existir, envia um convite de cadastro para um representante institucional. Verificar a organização por processo definido antes de entregar acesso. A organização cadastra usuários individuais, suas funções e memberships. Administrador institucional gerencia equipe, mas não vê automaticamente nenhum sujeito. Em produção, não deixar um convite de família para um nome de organização criar uma organização confiável sem validação.
4. **Identifique a pessoa que receberá o acesso.** Se a finalidade exige colaboração de uma pessoa, a família seleciona o usuário nominal (por exemplo, professora de uma turma ou terapeuta do caso). O nome genérico de “equipe da escola”, endereço compartilhado ou membership na clínica não é destinatário suficiente para dados da criança. Em modelo inicial sem diretório institucional, a pessoa pode criar sua própria conta ao aceitar e depois demonstrar a afiliação.
5. **Escolha o sujeito, a organização e a finalidade.** O responsável começa uma autorização para uma criança e uma organização específicas, como “apoio pedagógico” ou “coordenação da comunicação”. Escola e clínica permanecem contextos segregados. Não oferecer uma caixa ampla “compartilhar perfil inteiro”.
6. **Escolha dados e ações em linguagem concreta.** Mostrar categorias e capacidades independentes: resumo funcional publicado; tarefas e retornos; rotina; agenda; documentos publicados; leitura ou edição. Explicar exemplos do que entra e do que não entra. Um primeiro piloto pode permitir somente resumo funcional minimizado e tarefas, sem prontuário, diagnóstico, receitas, mídias ou exportação. A escola não herda dados clínicos por participar do cuidado; a clínica não ganha acesso ao conteúdo escolar por existir uma relação com a criança.
7. **Defina destinatário, prazo e revisão.** Exibir pessoa, organização, sujeito, finalidade, permissões, data de início, validade e data sugerida para revisão antes de confirmar. O padrão é mínimo acesso necessário e prazo limitado; não usar concessões sem vencimento. O prazo deve ser política explícita do produto e revisável conforme uso e risco, não um prazo supostamente universal imposto por fornecedores.
8. **Registre consentimento separado do convite e dos termos.** Apresentar aviso acessível indicando controlador/operador aplicável, dados, finalidade, destinatários e duração; pedir uma ação afirmativa para cada finalidade opcional. Salvar a versão exata do aviso e a decisão. Não usar caixas pré-marcadas, silêncio ou o aceite de benefício como consentimento para compartilhar conteúdo.
9. **Gere e entregue convite individual por e-mail (preferido) ou link controlado.** O convite fica pendente e não permite leitura. Enviar um link de resgate HTTPS com token aleatório de alta entropia, armazenando somente seu hash no servidor. Vincular o convite ao e-mail verificado e ao contexto (sujeito, organização, papel, finalidade, escopos e expiração). Usar uso único e expiração curta definida pelo produto; 24 horas pode ser um ponto inicial de avaliação, não uma regra OWASP/NIST. Reenvio deve gerar segredo novo e invalidar o anterior. Não incluir nomes, dados de saúde ou identificadores no URL. `GET` do link apenas abre a tela; a confirmação explícita ocorre depois, evitando aceite automático por leitores de e-mail. Rate limiting, mensagens neutras, HTTPS, domínio/redirecionamento allowlist e proteção contra tentativas são necessários.
10. **Trate link copiado como etapa de resgate, não como identidade.** Se a família optar por copiar/enviar link, ele ainda deve ser individual, de uso único, expirar e exigir que a pessoa entre/crie a própria conta e confirme o mesmo e-mail destinatário. Link/QR portador pode ser repassado; não comprova identidade, parentesco nem emprego. Não oferecer URL pública permanente ou QR genérico que revele perfil.
11. **A pessoa convidada acessa pelo site.** O destinatário abre o portal web responsivo em domínio oficial, autentica-se em conta própria (cria conta se necessário), verifica o e-mail esperado e vê uma tela com a organização, a criança, a finalidade, os dados/ações e o prazo pedidos. Pode aceitar ou recusar; recusa não prejudica a família ou o acesso local. Para conteúdo mais sensível ou alteração de autorização, exigir autenticação recente e MFA proporcional ao risco. Convite aceito ainda exige que o servidor confirme membership, relacionamento com o sujeito, consentimento vigente e escopo antes de ativar o grant.
12. **Decida quando o aplicativo é necessário.** Para cadastrar, aceitar convite, consultar dados compartilhados, gerenciar consentimentos, tarefas ou revogar, o **site autenticado deve bastar**; não exija instalação de app para um professor ou terapeuta. App nativo é opcional para notificações, uso móvel/offline, acessibilidade nativa ou integração escolhida pela família. O app CAA da criança segue sem login remoto. Notificações devem ocultar conteúdo sensível em tela bloqueada.
13. **Conceda acesso específico por papel, sem herança.** Cuidadora recebe concessão familiar individual e só os escopos necessários; docente recebe acesso pedagógico para sujeito(s) e turma(s) autorizados; terapeuta recebe escopo clínico/funcional apenas para o caso e finalidade definidos. A organização verifica sua equipe e membership, mas cada usuário precisa de vínculo ativo com a criança. O sistema mostra claramente o perfil/contexto ativo e atribui ações ao ator real.
14. **Crie e execute tarefas sob escopo vigente.** Uma tarefa registra autor, destinatário individual ou grupo explicitamente permitido, sujeito, organização/contexto, finalidade, estado, prazo e histórico. A pessoa só pode ver/responder a tarefa autorizada. “Aceitar tarefa” não é aceite de consentimento; recusar ou pedir ajuda não deve penalizar a criança/família. Revalidar o grant no servidor também em sincronização futura.
15. **Revise, expire ou revogue no painel familiar.** O responsável vê concessões, convites pendentes, destinatários, finalidade, escopos, prazo, aceite e eventos de leitura/alteração/download/exportação. Deve poder pausar ou revogar uma concessão, revogar um convite, retirar consentimento para uma finalidade e encerrar o vínculo com a organização como controles separados. O servidor bloqueia novas leituras imediatamente, invalida grants/links e URLs temporárias, revoga ou invalida sessões/tokens de aplicação quando possível e registra o evento. Remover alguém da equipe também encerra as relações correspondentes. Informar que uma cópia baixada/exportada antes da revogação não pode ser recolhida pelo portal; informar a organização e aplicar retenção/exclusão contratada quando couber.

## 4. Matriz textual de papéis e permissões

| Papel | O que pode fazer | Limites obrigatórios |
|---|---|---|
| Criança/adolescente (sujeito) | Usar a comunicação CAA local; quando apropriado, participar de escolhas com formato acessível. | Não precisa de conta para o uso básico; não herda sessão/poderes de adultos. Conta própria e autonomia progressiva ficam para fase posterior e política por idade/contexto. |
| Responsável com autoridade verificada | Administrar espaço familiar e sujeitos, convidar pessoas, escolher escopo/finalidade/prazo, revisar e revogar concessões, consultar auditoria permitida. | Cada decisão é específica; múltiplos responsáveis e eventuais conflitos precisam de regra definida; não presumir acesso a dados de outro sujeito. |
| Segundo responsável/delegado familiar | Acessar apenas crianças e funções delegadas individualmente, como ver tarefa ou apoiar rotina. | Não pode convidar/revogar terceiros ou mudar consentimento por padrão; elevar privilégio exige concessão explícita. |
| Cuidadora/convidado familiar | Ver ou responder tarefas, rotinas ou resumo expressamente concedidos para a criança, dentro do prazo. | Conta individual, convite aceito e grant específico; sem acesso por ser parente, conhecer link ou pertencer à família. Sem administração institucional. |
| Administrador da escola/clínica | Gerenciar a própria organização, unidades, membros e convites institucionais permitidos. | Não lê perfis, tarefas ou documentos da criança por ser administrador; não concede consentimento em nome da família. Benefício/licença também não concede dados. |
| Professor/AEE/apoio escolar | Ler o resumo funcional publicado e executar/responder tarefas escolares autorizadas para criança/turma e finalidade pedagógica. | Sem prontuário, dados de clínica, receita, documento não publicado ou exportação de mídia; co-docência não concede poderes globais. Membership escolar e relação com o sujeito são ambas necessárias. |
| Terapeuta/profissional clínico | Ler dados funcionais ou de cuidado publicados para a finalidade clínica autorizada; criar proposta/tarefa e responder conforme o escopo do caso. | Acesso individual e limitado à organização, sujeito, caso e período; sem acesso automático a outra clínica, escola, prontuário integral ou edição/publicação além do concedido. |
| Auditoria/suporte da plataforma | Consultar metadados operacionais mínimos; suporte excepcional pode ajudar a diagnosticar incidente. | Sem conteúdo por padrão; qualquer acesso excepcional deve ser justificado, autorizado, temporário, de menor privilégio e auditado. Auditoria não pode expor conteúdo sensível sem necessidade. |
| Patrocinador/licenciador (se aplicável) | Administrar estado de licença e métricas agregadas permitidas. | Sem nome, diagnóstico, tarefa, uso individual ou conteúdo da criança. Benefício não é grant. |

O backend sempre combina papel com organização, sujeito, relacionamento, finalidade, consentimento, ação, validade e estado. Papel de `owner` ou `admin` não é passe universal.

## 5. Padrões pesquisados: o que adaptar e o que não copiar

- **Acesso familiar contínuo em portais de saúde:** os exemplos da Cleveland Clinic/MyChart e do NHS usam conta própria do adulto, aceite explícito, contexto do paciente visível, permissões delimitadas e revogação. Isso informa o princípio de separar sujeito e usuário e deixar claro “estou agindo para”. Não se deve replicar regras de idade/configurações de uma clínica ou do NHS como regra global: variam por organização e jurisdição.
- **Compartilhamento pontual:** o Epic Share Everywhere usa código com uso único, expiração curta, escopo limitado e sessão temporária. A lição é distinguir partilha pontual de proxy contínuo; um token portador não prova que a pessoa é o profissional pretendido. Fala Comigo deve preferir convite nominal para acesso contínuo e nunca transformar um link em URL pública permanente.
- **Clínicas/terapia:** SimplePractice e TherapyNotes ilustram perfis de menores separados, contatos individualizados, destinatários por documento e trilhas de atividade. Adaptar seleção por objeto/destinatário e histórico; não assumir que seus papéis, fluxos ou controles cobrem os limites escola-clínica do Fala Comigo.
- **Escolas:** Classroom, ParentSquare e Seesaw mostram que aluno, professor e responsável são identidades/canais diferentes, que vínculo familiar pode exigir confirmação e que permissões de co-professor podem ser amplas. Adaptar associação por criança/organização e convite revogável. Não importar login escolar, sincronização de SIS, QR de turma ou poderes de co-docente sem revisão de escopo e identidade.
- **Convites e consentimento:** OWASP recomenda tokens imprevisíveis, uso único, expiração, limitação de tentativas e respostas que não revelem a existência de e-mail. NIST diferencia confirmação/recuperação por e-mail de autenticação forte. LGPD exige melhor interesse de crianças e cuidados próprios com consentimento/representação, sem transformar e-mail, parentesco declarado ou convite em prova suficiente.

Esses são padrões de desenho observados; a implementação não deve copiar marca, interface, código nem presumir capacidades uniformes entre organizações.

## 6. MVP seguro e o que deixar para depois

### MVP seguro, em gates

**Gate de validação atual (sintético, local/CI):** consolidar API, schema e testes com identidades/organizações fictícias somente. Cobrir allow/deny entre duas organizações, convite pendente/aceito/expirado, revogação, validade, idempotência, escopo, isolamento de benefícios e ausência de conteúdo em logs. Corrigir/expandir testes antes de declarar o gate concluído. Não publicar esta API de desenvolvimento nem inserir e-mails/pessoas reais.

**MVP de produção para piloto limitado (somente após decisão e revisão separadas):**

- portal web responsivo independente do site institucional; autenticação gerenciada, sessões revogáveis, recuperação sem enumeração, MFA para contas privilegiadas, HTTPS e e-mail transacional;
- contas individuais de adultos; família e sujeito distintos; organizações verificadas; membership, relacionamento por sujeito, convite, grant, consentimento versionado e auditoria em entidades e regras diferentes;
- convites de e-mail nominal, segredo de uso único guardado como hash, expiração curta, aceite autenticado, rate limit e processo de reenvio/revogação;
- autorização deny-by-default no servidor em cada chamada, isolamento por organização e sujeito, autorização de download, revogação eficaz e testes negativos automatizados;
- painel para aceitar/recusar convite, compreender escopo, ver concessões/eventos e revogar; não depender de app móvel;
- funcionalidade remota pequena e explicitamente permitida (por exemplo, tarefa e resumo funcional de campos pré-aprovados), sem prontuário, diagnóstico, receitas, mídia ou exportação no primeiro piloto;
- minimização de dados, retenção definida, auditoria de quem/quando/organização/finalidade/ação/resultado sem token, segredo, conteúdo clínico ou payload excessivo; notificação e canais acessíveis;
- operação independente: ambiente segregado, gestão de segredos, backups/restauração testados, alertas, plano de incidentes, política de retenção/exclusão e teste da invalidade de sessão após revogação.

**Critério de liberação:** não usar dados reais enquanto convite/resgate, identidade, autorização server-side, isolamento, consentimento, revogação de backend, sessões, logs e restauração não estiverem testados. A implementação de autenticação real e integração de e-mail são gates adicionais, não se consideram existentes porque há classes, telas ou migrations locais.

### Deixar para depois

- anexos, fotos, vídeos, áudio, documentos clínicos, prontuário, prescrição e exportações;
- sincronização offline de dados sensíveis, uploads e links de download; exige versão, conflito, criptografia, retenção e autorização por operação;
- cadastro/importação automática de diretório/SIS, convite em massa, organizações autoinscritas e QR compartilhável;
- gestão de profissionais por registros/licenças externos e federação entre instituições;
- app próprio obrigatório para familiares ou profissionais, push com detalhes e acesso offline de organizações;
- login próprio da criança/adolescente, autonomia granular, limites etários automáticos e regras de guarda não validadas;
- análise/IA, recomendações clínicas, métricas individuais e compartilhamento entre organizações;
- benefício corporativo e indicadores institucionais até definir proteção contra reidentificação e limites de privacidade.

Antes do piloto com menores e dados de saúde, obter revisão local jurídica/privacidade e uma política de representação, participação da criança/adolescente, guarda compartilhada, retenção, atendimento de direitos e incidente. Esta recomendação não é aconselhamento jurídico ou clínico.

## 7. Riscos que devem entrar no threat model

1. **Coerção ou abuso familiar:** alguém pode ser forçado a conceder acesso ou usar a conta sob vigilância. Permitir recusa, pausa, restrição, suporte confidencial e revisão; não exibir mensagens de forma que ampliem o risco. Não presumir consentimento livre só porque houve clique.
2. **Confusão de identidade ou vínculo errado:** endereço desatualizado/reciclado, duplicata, erro de sujeito, equipe antiga ou falsa representação de instituição pode expor outra criança. Verificar destinatário e organização, mostrar o contexto antes do aceite, enviar aviso de novo vínculo e permitir contestação.
3. **Escopo amplo/perpétuo e fronteira entre contextos:** permissões gerais, co-docência/administração, organização não verificada ou ausência de prazo podem expandir a exposição. Isolar escola, clínica, família e cada criança; minimizar, vencer e revisar grants.
4. **Link encaminhado/vazado:** URLs aparecem em histórico, analytics, referer e logs. Um link/QR pode ser copiado. Segredo de uso único, hash no servidor, baixa duração, e-mail autenticado correspondente, HTTPS, ausência de PII na URL e neutralização de scanner de e-mail reduzem risco, mas não tornam um token portador prova de identidade.
5. **Revogação incompleta:** apagar membership no provedor de identidade pode deixar sessão/cookie/token emitido pela aplicação ativo. A própria API deve checar grant/estado nas chamadas e aplicar revogação server-side; informar que cópias já obtidas não desaparecem.
6. **Notificação ou dispositivo compartilhado:** assunto de e-mail, push e tela bloqueada podem expor uso/saúde. Usar texto neutro e conteúdo privado atrás de login; app organizacional não é pré-requisito.
7. **Auditoria excessiva ou insuficiente:** logs sem leitura/download perdem rastreabilidade; logs com token, e-mail completo, conteúdo ou diagnóstico aumentam o impacto de vazamento. Registrar ator, organização, finalidade/versão, ação, recurso pseudonimizado, resultado e horário sob retenção e controle de acesso.
8. **Mudança de idade, função ou finalidade:** criança cresce, profissional sai, turma muda ou consentimento deixa de ser apropriado. Revalidar relação, escopo e validade; não converter um grant infantil em acesso adulto sem fluxo explícito.
9. **Confusão entre convite, adesão e autorização:** aceite de convite, tarefas ou benefício pode ser indevidamente interpretado como permissão ampla. Guardar transições distintas e negar conteúdo até todas as condições necessárias estarem ativas.

## 8. Lacunas atuais verificadas no repositório

A análise foi feita sobre os arquivos/documentação disponíveis no repositório `/home/ubuntu/fala-comigo`, especialmente `portal-api/`, `lib/features/parental_area/`, `site/portal.html` e `docs/`. Os documentos do projeto distinguem contrato/especificação de produto e implantação; não os trato como recursos conectados prontos.

1. **Existe uma API sintética local, não um portal de produção.** `portal-api/README.md` declara identidades sintéticas e ausência de login/OAuth, link mágico, e-mail ou sessão de produção; o servidor recusa `NODE_ENV=production` e escuta em loopback. A identidade vem do header `x-synthetic-user-id`, portanto não é autenticação real. Isso é apropriado para testes locais, não para publicação.
2. **Persistência e fluxo de convite são demonstrativos.** `portal-api/src/store.js` usa fixtures e armazenamento em memória, que se perde ao reiniciar. `portal-api/src/app.js` cria convite por `inviteeUserId` sintético e, na falta de prazo informado, usa validade em 2099; não gera nem entrega segredo/link por e-mail. O aceite cria membership organizacional. A integração PostgreSQL é opcional; a suíte executada aqui passou 12 testes e ignorou 1 teste PostgreSQL por ausência de `PGTEST_URL`.
3. **O schema não é o modelo suficiente do portal de cuidado.** `portal-api/migrations/001_initial.sql` inclui usuários, organizações, memberships, convites, grants, benefícios e auditoria, mas ainda não define família/sujeito, relação de cuidado, consentimento versionado, tarefas ou conteúdo. A API sintética exercita escopos organizacionais, mas não avalia grant por sujeito/finalidade/consentimento em cada chamada de dados; não há endpoint de conteúdo a provar esse fluxo. A mera existência da tabela `access_grants` não significa que grants estejam sendo aplicados.
4. **Não há identidade/entrega real.** No recorte observado, não há integração de provedor de identidade, autenticação externa, MFA, verificação de representante legal, e-mail transacional, token de convite ou recuperação de conta para usuários finais. `x-synthetic-user-id` não deve ser reutilizado como mecanismo de produção.
5. **Tela Flutter registra um rascunho local de vínculo, não um convite enviado.** `access_management_screen.dart` declara expressamente que o registro é local e que aceite remoto/sincronização virão no portal. O formulário pede nomes, não endereço de e-mail; atribui finalidade e papel genéricos e persiste em Hive protegida no aparelho. O `AccessGrantStore.revoke` muda apenas o estado local; não bloqueia sessão, token ou leitura remota.
6. **Não há prova de organização ou destinatário.** O cadastro local permite nome livre da organização e nome da pessoa. Não há diretório, verificação institucional, membro individual identificado ou vínculo de equipe/criança. Papéis locais de escola, cuidador e terapeuta ainda não existem como decisão server-side.
7. **Consentimento atual não equivale a autorização de compartilhamento.** A tela de perfil salva um `consentAccepted` booleano e horário para confirmação local de que a pessoa declara ser responsável/autorizada, sem versionar aviso, destinatário, finalidade, organização, escopo, prazo ou revogação. Isso não prova identidade/representação e não deve alimentar concessão remota.
8. **O HTML do portal é prévia estática.** `site/portal.html` mostra dados de exemplo e controles visuais, mas não integra API/autenticação. Os exemplos de clínica/escola e tarefas não são contas, vínculos ou registros remotos utilizáveis.
9. **Tarefas e PDFs não estão ligados a autorização server-side.** O modelo `SharedTask` usa nomes/labels como `organizationName` e `recipientRole` e armazenamento/fila local; a API observada não oferece sincronização de tarefa ou decisões de escopo por recurso. Exportações PDF e compartilhamento do dispositivo podem criar cópias que o controle local não consegue revogar.
10. **Cobertura limitada ao gate sintético.** Os testes atuais cobrem bem casos básicos de identidade sintética, escopo de organização, convite pendente/expirado, benefício e auditoria sem payload; não provam isolamento de sujeitos, consentimento, e-mail, token real, download, tarefa, sessões ou revogação em produção. O teste de PostgreSQL foi ignorado na execução atual.

**Conclusão sobre o repositório:** há um bom começo de contrato, uma API sintética e um modelo de concessão visual/local. Não há base para afirmar que família, escola ou clínica podem criar contas, mandar convites por e-mail/link, acessar o site ou revogar efetivamente permissões remotas. A próxima entrega deve continuar sintética, fechar testes/migração e definir o modelo de consentimento/relação; não ativar dados reais nem alterar a aparência do mock para sugerir acesso funcional.

## 9. Referências (URLs completas)

### Portais, partilha familiar, clínica e escola

- Cleveland Clinic — compartilhamento de registros MyChart: https://my.clevelandclinic.org/resources/mychart-record-sharing
- NHS — Family and carer access no NHS App: https://www.nhs.uk/nhs-app/help/profile/family-and-carer-access/
- NHS Digital — Family and carer proxy access: https://digital.nhs.uk/services/nhs-app/nhs-app-features/family-and-carer-access-in-the-nhs-app-proxy-access
- NHS — acesso a serviços de saúde para outra pessoa: https://www.nhs.uk/nhs-services/gps/health-services-for-someone-else-family-carer-access/give-someone-access-health-services/
- NHS Digital — acesso proxy proporcional e por prazo: https://digital.nhs.uk/services/national-proxy-service/proxy-advice-and-guidance-document/step-8-grant-proportionate-and-time-bound-proxy-access
- Epic Share Everywhere — FAQ de compartilhamento pontual: https://shareeverywhere.epic.com/FAQ
- SimplePractice — perfis de menores: https://support.simplepractice.com/hc/en-us/articles/360020093651-Adding-minor-clients
- SimplePractice — contatos e permissões: https://support.simplepractice.com/hc/en-us/articles/42001857971341-Managing-client-contacts
- TherapyNotes — acesso ao portal do cliente: https://support.therapynotes.com/hc/en-us/articles/30661314410779-Manage-Client-Portal-Access
- Google Classroom — resumos para responsáveis: https://support.google.com/edu/classroom/answer/6020273?hl=en&co=GENIE.Platform%3DDesktop
- Google Families — Family Link e contas escolares: https://support.google.com/families/answer/7103338?hl=en
- Seesaw — convites a familiares: https://help.seesaw.me/hc/en-us/articles/203012019-How-to-invite-family-members-to-Seesaw
- Seesaw — diferenças entre conta de aluno e de família: https://help.seesaw.me/hc/en-us/articles/25114624023821-Differences-between-a-Student-account-and-a-Family-account

### Segurança, autenticação e proteção de dados

- OWASP — Email Validation and Verification Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Email_Validation_and_Verification_Cheat_Sheet.html
- OWASP — Authentication Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html
- OWASP — Forgot Password Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html
- OWASP — Logging Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html
- NIST SP 800-63B Rev. 4: https://pages.nist.gov/800-63-4/sp800-63b.html
- Firebase — autenticação por link de e-mail: https://firebase.google.com/docs/auth/web/email-link-auth
- Supabase — autenticação passwordless por e-mail: https://supabase.com/docs/guides/auth/auth-email-passwordless
- Lei Geral de Proteção de Dados (LGPD), Lei nº 13.709/2018: https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm
- FTC — COPPA FAQs (referência dos EUA, contexto escolar limitado): https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions
- ICO — Children's Code, configurações padrão: https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/age-appropriate-design-a-code-of-practice-for-online-services/7-default-settings/

### Documentos do próprio repositório avaliados

- `portal-api/README.md`, `portal-api/src/app.js`, `portal-api/src/authorization.js`, `portal-api/src/store.js`, `portal-api/migrations/001_initial.sql` e testes em `portal-api/test/`.
- `docs/ADR-001-opcao-a-portal-independente.md`.
- `docs/ESPECIFICACAO_MVP_PORTAL_SINTETICO.md`.
- `docs/CONTRATO_PORTAL_CONECTADO.md` e `docs/CONTRATO_API_CONTINUIDADE_CUIDADO.md`.
- `docs/MODELO_AUTORIZACAO_CLINICAS_ESCOLAS.md` e `docs/PLANO_PORTAL_CUIDADO_CONECTADO.md`.
- `lib/features/parental_area/data/access_grants.dart`, `lib/features/parental_area/presentation/screens/access_management_screen.dart`, `lib/features/parental_area/presentation/screens/patient_profile_screen.dart`, `lib/features/parental_area/data/shared_tasks.dart` e `site/portal.html`.
