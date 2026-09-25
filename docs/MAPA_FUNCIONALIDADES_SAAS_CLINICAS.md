# Mapa de funcionalidades dos SaaS clínicos para o Fala Comigo

## Objetivo

Os SaaS de clínicas analisados oferecem agenda, cadastro de casos, prontuário, tarefas, documentos, comunicação, relatórios, permissões e administração. O Fala Comigo não deve copiar tudo indiscriminadamente: sua prioridade é melhorar a comunicação e a coordenação entre família, escola e rede de cuidado.

A pergunta de decisão é:

> **Esta funcionalidade ajuda a família a compreender, participar ou manter a continuidade do cuidado sem transformar a pessoa em um prontuário comercial?**

## O que o Fala Comigo já possui

A base atual já inclui uma área parental reformulada, perfil do paciente, privacidade, troca de PIN, plano e recursos, diário de vídeo, tendências, relatórios, lembretes locais, gerenciamento de acessos e tarefas compartilhadas com organização, aceite, status, retorno, histórico e fila offline.

Isso é importante porque o produto não começa do zero. O próximo salto deve conectar os dados que já existem a fluxos profissionais bem delimitados.

## Comparação de recursos

| Recurso observado em SaaS clínico | Valor real para a família | Situação atual | Recomendação |
|---|---|---|---|
| Cadastro por organização e equipe | Saber quem participa, por qual motivo e até quando | Acesso local já iniciado | **Prioridade alta**: evoluir para convite, vínculo e expiração no portal |
| Perfil único da pessoa | Evitar repetir informações e preservar preferências de comunicação | Perfil parental existe | **Prioridade alta**: criar perfil funcional compartilhável por escopo |
| Agenda e próximos atendimentos | Reduzir faltas e preparar a criança para mudanças | Não há agenda conectada | **Prioridade alta**, inicialmente simples e sem depender de prontuário |
| Confirmação e presença | Permitir que família avise cancelamento e registre o que ocorreu | Não há fluxo estruturado | **Prioridade alta**: presença, cancelamento, motivo simples e reposição |
| Tarefas e lembretes | Transformar orientação em uma ação possível em casa | Já implementado em modo local | **Prioridade máxima**: conectar à agenda e aos planos por contexto |
| Formulários pré-atendimento | Reduzir repetição e organizar dúvidas da família | Não há formulário conectado | **Prioridade alta**: formulários curtos, acessíveis e reutilizáveis |
| Nota de atendimento | Registrar orientação e próximo passo | Não há nota profissional conectada | **Prioridade alta**, mas como resumo publicado, não prontuário integral |
| Metas funcionais | Mostrar progresso em algo útil para a vida cotidiana | Há tendências, não metas por rede de cuidado | **Prioridade alta**: metas observáveis definidas com família e profissional |
| Coleta ABA/ABC | Ajudar o profissional a observar contexto, ação e consequência | Não há módulo estruturado | **Prioridade média**: formulário configurável, sem interpretação automática |
| Plano de comunicação fonoaudiológico | Alinhar vocabulário, símbolos, acesso e modelagem | Não há plano compartilhado | **Prioridade máxima** por ser núcleo do produto |
| Diário escolar | Fazer escola e família usarem o mesmo vocabulário funcional | Tarefas permitem parte do fluxo | **Prioridade alta**: resumo de rotina, apoio e retorno |
| Mensagens seguras | Substituir grupos dispersos e preservar contexto | Não há mensageria conectada | **Prioridade média**: mensagens ligadas a tarefa ou caso, não chat infinito |
| Documentos publicados | Entregar orientação, relatório, atestado ou receita com controle | Exportação existe, publicação profissional não | **Prioridade alta**, com versão, autoria, validade e escopo |
| Notificações | Lembrar ação sem depender de mensagens soltas | Lembretes locais existem | **Prioridade alta**: push, e-mail opcional, horário silencioso e fallback offline |
| Relatórios | Ajudar família e profissional a decidir próximos passos | Tendências e PDF já existem | **Prioridade alta**: relatórios diferentes por público, sem expor diagnóstico à escola |
| Assinatura e faturamento | Sustentar operação para clínicas e organizações | Não há portal comercial completo | **Prioridade posterior**: só depois de validar o cuidado e o contrato |
| Auditoria e permissões | Proteger a criança e dar confiança à família | Revogação local existe | **Prioridade máxima no backend** |
| Integrações | Evitar redigitação e permitir implantação institucional | Não há backend | **Posterior**, começando por exportação documentada e API controlada |

## Recursos com maior potencial de ajudar as famílias

### 1. Resumo vivo de comunicação

O cadastro mais valioso não é um prontuário gigante. É um resumo funcional que a família controla e pode compartilhar por finalidade:

- como a pessoa pede ajuda, pausa, dor, água e banheiro;
- quais símbolos, palavras, voz ou gestos utiliza;
- forma preferida de acesso ao dispositivo;
- sensibilidades e estratégias de preparação;
- o que costuma facilitar a participação;
- o que deve ser evitado;
- parceiros já treinados;
- plano de contingência quando o dispositivo não estiver disponível;
- data da última revisão;
- quem pode visualizar e por quanto tempo.

A família deve publicar uma versão para a escola, outra para a clínica e outra para um profissional específico. O conteúdo clínico integral não deve aparecer por padrão.

### 2. Plano de comunicação compartilhado

O fonoaudiólogo ou profissional autorizado pode propor um plano com:

- objetivo funcional;
- ambiente onde será praticado;
- vocabulário ou prancha usada;
- estratégia de modelagem;
- quantidade de oportunidades planejadas, sem transformar isso em cobrança por uso;
- apoio necessário;
- exemplo de sucesso;
- data de revisão;
- tarefa para família e escola.

A família aceita, comenta, pede adaptação ou registra que não funcionou. O profissional revisa antes de alterar o plano. O sistema não deve afirmar que a pessoa “regrediu” apenas porque uma tarefa não foi concluída.

### 3. Agenda acessível e preparação para transições

Uma agenda útil para famílias precisa mostrar:

- próxima sessão ou compromisso;
- local, profissional e organização;
- duração;
- preparação visual;
- o que levar;
- opção de confirmar, cancelar ou pedir remarcação;
- lembrete para responsável e profissional;
- período silencioso;
- funcionamento offline do cartão do compromisso.

Para uma pessoa autista, preparar a transição pode ser mais importante que simplesmente receber um horário. A agenda deve permitir um roteiro visual: “chegar”, “guardar”, “sessão”, “pausa” e “voltar”.

### 4. Registro simples de sessão para a família

Em vez de exibir um prontuário profissional, a família recebe um resumo publicado:

- o que foi trabalhado;
- o que funcionou;
- qual será o próximo passo;
- como praticar de maneira natural;
- que dificuldade foi observada;
- quando revisar;
- quem publicou e em que data.

O profissional mantém seu registro obrigatório no sistema apropriado. O Fala Comigo recebe apenas o conteúdo necessário para continuidade e comunicação.

### 5. Formulários adaptados por setor

Um formulário único para todos é ruim. A mesma conta deve apresentar perguntas diferentes conforme o vínculo:

| Setor | Formulários de alto valor |
|---|---|
| Família | preferências, comunicação, rotina, sensibilidades, rede de apoio e objetivos cotidianos |
| ABA | contexto da habilidade, oportunidade, apoio oferecido, resposta observável e pedido de ajuda |
| Fonoaudiologia | modalidade de comunicação, acesso, vocabulário, parceiros, ambientes e plano de modelagem |
| Escola | transições, participação, recursos de tecnologia assistiva, apoios e barreiras por contexto |
| Clínica multiprofissional | encaminhamento, equipe, finalidade, plano de cuidado e resumo autorizado |
| Medicina/psiquiatria | documentos publicados, orientações, receitas válidas e encaminhamentos, sempre com autoria profissional |
| Empresa patrocinadora | quantidade de licenças, período, custo e indicadores agregados, sem dados da criança |

Os formulários devem aceitar símbolo, áudio, texto, escolha simples e resposta por “não sei” ou “não quero responder”.

### 6. Central de documentos controlados

A família pode receber documentos sem misturar tudo no feed:

- orientação profissional;
- resumo escolar autorizado;
- relatório;
- atestado;
- receita ou prescrição publicada por profissional habilitado;
- anexos enviados pela família;
- versão, validade, assinatura, autoria e destinatários.

O documento deve seguir estados de rascunho, revisão, aprovado, publicado, corrigido, cancelado ou expirado. A família pode baixar e exportar. A escola recebe apenas o que foi publicado para ela.

O aplicativo nunca deve gerar receita, escolher medicamento ou converter sugestão de IA em prescrição.

### 7. Painel de continuidade quando a família troca de serviço

Este pode ser um dos maiores diferenciais do Fala Comigo. Quando a pessoa sai de uma clínica ou escola:

1. o acesso antigo é revogado;
2. os cartões, frases, preferências e exportações da família permanecem;
3. o resumo funcional continua na conta familiar;
4. a família escolhe o que levar para o novo profissional;
5. a nova organização recebe somente um convite e o escopo autorizado;
6. a licença patrocinada entra em transição sem bloquear o núcleo offline.

Assim, o Fala Comigo ajuda a família a não recomeçar do zero a cada troca de serviço.

## O que não deve ser copiado agora

### Prontuário clínico completo

Um prontuário traz obrigações legais, retenção, segurança, autoria, auditoria e responsabilidade profissional. O Fala Comigo deve começar com resumos publicados e planos funcionais, mantendo o prontuário obrigatório onde ele já existe.

### Cobrança por mensagem, palavra, registro ou uso

Isso pune justamente quem mais precisa se comunicar. O custo deve ser financiado por planos profissionais, organização, suporte, implantação e patrocínio.

### Interpretação automática de comportamento

Dados ABA, diário e tendências podem organizar observações. Não devem diagnosticar, prescrever, determinar causa ou sugerir punição. Toda interpretação clínica deve permanecer com profissional habilitado.

### Chat sem contexto

Um chat infinito gera ruído e dificulta auditoria. A comunicação deve estar ligada a tarefa, compromisso, documento, plano ou caso, com destinatários claros e retenção definida.

### Rastreamento invasivo

Localização contínua, gravação permanente, monitoramento oculto e telemetria sensível não são necessários para o núcleo de comunicação e criam risco desproporcional.

### Complexidade de faturamento antes da validação

Assinatura, nota fiscal, multiunidade, integração e cobrança por assento serão importantes para a sustentabilidade, mas devem entrar depois que os fluxos de cuidado tiverem uso real. Primeiro devemos provar que a família, o profissional e a escola conseguem concluir um ciclo de tarefa e retorno.

## Priorização proposta

### Fase 1 — continuidade familiar e profissional

1. Perfil funcional compartilhável por escopo.
2. Convite e vínculo de profissionais/organizações no portal.
3. Agenda simples com confirmação e lembrete.
4. Tarefa ligada a compromisso e plano de comunicação.
5. Resumo de sessão publicado para a família.
6. Auditoria de leitura, edição, exportação e revogação.

### Fase 2 — especialização sem prontuário completo

1. Plano de comunicação CAA/fonoaudiológico.
2. Formulário ABA de observação configurável.
3. Diário escolar e resumo de participação.
4. Central de documentos com versões e validade.
5. Relatórios diferentes para família, profissional e instituição.
6. Notificações conectadas com horário silencioso.

### Fase 3 — escala institucional

1. Equipes, unidades e substitutos.
2. Licenças patrocinadas e pool reassinável.
3. Painel administrativo com métricas agregadas.
4. Implantação, treinamento e suporte.
5. Exportação em lote e API documentada.
6. Contratos, faturamento e planos comerciais.

## Critério de sucesso

Uma melhoria deve ser considerada bem-sucedida quando:

- a família entende o que precisa fazer;
- o profissional recebe um retorno útil sem exigir prontuário integral;
- a escola consegue apoiar a comunicação sem receber dados desnecessários;
- a pessoa usuária não perde o acesso ao se desligar de uma organização;
- o modo offline continua funcional;
- o histórico informa quem publicou ou alterou algo;
- a revogação impede novos acessos;
- nenhuma cobrança é baseada em diagnóstico, mensagem ou frequência de comunicação.

## Próximo bloco recomendado

O próximo ciclo de desenvolvimento deve implementar o **Perfil funcional compartilhável + Plano de comunicação + Agenda simples**, porque esses três recursos conectam família, fonoaudiólogo, ABA e escola e aproveitam as tarefas já existentes. A central de documentos e as receitas devem vir depois que o controle de identidade, autoria, escopo, validade e auditoria estiverem implementados no backend.
