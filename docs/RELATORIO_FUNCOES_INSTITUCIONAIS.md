# Relatório consolidado de funções institucionais — Fala Comigo

**Versão:** 1.0  
**Escopo:** ABA, fonoaudiologia e Comunicação Aumentativa e Alternativa (CAA), clínicas multiprofissionais, escolas e empresas patrocinadoras  
**Natureza:** consolidação de resultados de pesquisa para orientar produto, governança e priorização. Não é prescrição clínica, diagnóstico, garantia de eficácia ou aconselhamento jurídico.

## 1. Conclusão executiva

O Fala Comigo deve ser concebido como uma plataforma de **registro, planejamento, colaboração e acompanhamento centrados na pessoa**, e não como um mecanismo de diagnóstico ou de decisão terapêutica automática. O núcleo comum aos contextos pesquisados é um ciclo: compreender a pessoa e seu contexto; definir objetivos funcionais observáveis; planejar estratégias e responsáveis; registrar o que ocorreu; revisar a evolução com dados e contexto; generalizar ganhos para diferentes pessoas, ambientes e rotinas; e documentar transição, continuidade ou encerramento. Diretrizes profissionais, literatura científica e normas consultadas não sustentam uma carga horária única, um método universal, uma marca de CAA ou um software obrigatório. Intensidade, supervisão, participação da família e seleção de recursos devem responder às necessidades, preferências, riscos e resposta individual. [1] [2] [3] [4] [5] [8] [9] [11]

A recomendação de arquitetura é **local/offline-first no MVP**, com armazenamento local protegido, formulários estruturados, histórico versionado, exportação auditável e sincronização opcional apenas quando autorizada. Um portal futuro pode acrescentar colaboração entre família, escola, clínica e patrocinador, mas não deve tornar internet, smartphone ou conta digital pré-requisitos para acesso, comunicação ou continuidade do cuidado. A opção local reduz dependências de conectividade e limita o compartilhamento inicial; em contrapartida, exige criptografia, autenticação, backup e restauração testados, gestão de dispositivos e procedimento claro para perda ou troca de equipamento.

O produto precisa separar, na interface e no banco de dados, **fato observado**, **interpretação profissional**, **decisão registrada** e **recomendação futura**. Um gráfico pode mostrar tendência, variabilidade e ausência de dados, mas não deve transformá-las em diagnóstico, prescrição, promessa de eficácia ou classificação da pessoa. O mesmo princípio vale para CAA: o sistema pode apoiar avaliação e comparação de recursos, mas não escolher automaticamente dispositivo, vocabulário ou método. A tecnologia deve apoiar julgamento humano competente, decisão compartilhada, autonomia, dignidade, participação e segurança.

No Brasil, dados de saúde são dados pessoais sensíveis sob a Lei Geral de Proteção de Dados Pessoais (LGPD). A base legal, a finalidade, o prazo, os destinatários, os direitos do titular e os controles de segurança precisam ser registrados por contexto; consentimento não é a única base possível e não deve ser usado como substituto de análise jurídica. [6] Regras profissionais variam. A Resolução CFP nº 001/2009 é específica para serviços psicológicos abrangidos pelo Sistema Conselhos de Psicologia; regras do Conselho Federal de Medicina, do Conselho Federal de Fonoaudiologia e de outros conselhos não devem ser generalizadas entre profissões. [7] [10] [17] [18] A LBI e a Lei nº 15.249/2025 também estabelecem deveres públicos e educacionais específicos relacionados à acessibilidade e à CAA de baixa tecnologia, sem impor uma marca ou um aplicativo individual. [13] [14]

### Decisões de produto recomendadas

1. **Primeiro, integridade e continuidade:** ficha longitudinal, autoria, data e hora, histórico de alterações, metas, linha de base, sessões, evolução, reforçadores, tarefas, consentimentos e auditoria.
2. **Depois, colaboração controlada:** exportação legível e compartilhamento mínimo no MVP; no portal, permissões por função e caso, consentimentos versionados, mensagens assíncronas, plano compartilhado e transições.
3. **Sempre com supervisão humana:** alertas apoiam revisão; não alteram tratamento, selecionam punição, inferem diagnóstico ou bloqueiam atendimento.
4. **Acessibilidade como requisito de engenharia:** português claro, baixo consumo de dados, impressão, suporte multimodal e CAA, compatibilidade com tecnologia assistiva e testes com pessoas com deficiência e famílias.
5. **Sustentabilidade sem exploração de dados:** patrocinadores recebem indicadores agregados e previamente autorizados, nunca prontuários ou dados identificáveis por padrão; não deve haver venda de dados, publicidade comportamental ou condicionamento de apoio à autorização ampla.

## 2. Princípios, limites e vocabulário comum

### 2.1 Princípios orientadores

O sistema deve aplicar os seguintes princípios em todas as áreas:

- **Pessoa antes do indicador:** metas devem refletir comunicação, autonomia, participação, aprendizagem, bem-estar e qualidade de vida relevantes para a pessoa, sua família e sua rede.
- **Individualização:** diagnósticos, idade ou perfil de fala não determinam sozinhos objetivos, recursos, intensidade, supervisão ou tecnologia.
- **Evidência contextualizada:** dados precisam de unidade, período, observador, ambiente, procedimento e explicação para ausências ou mudanças.
- **Generalização e manutenção:** desempenho no treino não equivale automaticamente a uso funcional em casa, escola, trabalho, saúde ou comunidade.
- **Acessibilidade e equidade:** oferecer interfaces e materiais adequados a idioma, cultura, letramento, visão, audição, motricidade, conectividade, custo e disponibilidade.
- **Autonomia e comunicação:** não interpretar ausência de fala como ausência de compreensão; não retirar CAA como consequência de comportamento; não obrigar oralização como condição de participação.
- **Confidencialidade e menor privilégio:** cada perfil vê apenas o necessário para sua função e para a finalidade documentada.
- **Rastreabilidade:** nenhuma evolução, autorização, permissão, plano ou documento deve ser apagado silenciosamente.
- **Governança humana:** toda decisão clínica, educacional, ética, de segurança ou de financiamento permanece atribuída a uma pessoa ou instância responsável.

### 2.2 Limites de interpretação

No produto, **dado** é o registro bruto ou contextualizado de uma ocorrência. **Evolução** é a síntese de dados dentro de um período definido. **Interpretação clínica ou pedagógica** é uma hipótese ou análise assinada pelo profissional competente. **Recomendação** é uma proposta para revisão humana. Os campos devem deixar essa distinção explícita.

Uma porcentagem sem denominador, unidade, período, contexto ou método não é uma medida suficiente. A ausência de dado deve ter motivo, como indisponibilidade, recusa, interrupção, falha técnica ou não aplicabilidade. Uma alteração de plano deve preservar versão anterior, autor, data, motivo e relação com a evidência que a motivou.

## 3. Funções por domínio

### 3.1 ABA — análise do comportamento aplicada

A área de ABA precisa de um prontuário ou perfil de caso com papéis de equipe, responsáveis, ambientes, preferências, autorizações, consentimentos e histórico de alterações. Os campos administrativos, clínicos e sensíveis devem ser separados por finalidade e permissão. O construtor de objetivos deve exigir definição operacional, linha de base, unidade de medida, critério de domínio, manutenção, generalização, prompts, procedimento, responsáveis, data de revisão e status.

A coleta deve ser configurável por sessão e rotina. O profissional pode escolher presença/ausência, percentual de respostas independentes, frequência, duração, latência ou outra medida justificada. Cada registro deve conter observador, data e hora, contexto, notas, procedimento usado e motivo de dado ausente. Gráficos de série temporal e tabelas devem comparar com a linha de base, permitir anotações de mudança, filtros por pessoa e ambiente e exportação auditável. O sistema não deve converter tendência em diagnóstico ou promessa de eficácia. [1] [2] [3] [4]

O plano de procedimento pode conter antecedente, resposta, consequência, prompts, fading, programação de reforço, materiais e instruções por contexto. O módulo de preferências e reforçadores deve registrar método de amostragem, menu de opções, histórico de eficácia, disponibilidade, restrições e programação usada. A hipótese pode ser alterada pelo clínico com base nos dados; o software não deve fixá-la nem prescrever automaticamente uma intervenção.

A matriz de generalização deve cruzar habilidade ou objetivo com pessoas, ambientes, rotinas, materiais, instruções e horários. Sondagens de generalização e manutenção ficam separadas do desempenho adquirido no treino. Treino de responsáveis deve incluir materiais acessíveis, vídeo ou modelo quando apropriado, agenda, prática observada, checklist de fidelidade, feedback, barreiras e registro do que foi implementado em cada rotina. A participação da família deve ser individualizada e não pode ser transformada em pré-condição fixa para atendimento. [2] [3]

Checklists de implementação e supervisão devem cobrir preparação, execução, entrega de reforço, coleta de dados, integridade, assinatura ou identificação do implementador e ações corretivas, sem apagar versões anteriores. Relatórios para família, equipe e pagador devem separar fatos observados, interpretação clínica, limitações, decisões e plano seguinte. Alertas podem apontar objetivo sem linha de base, sessão sem medida, dado discrepante, plano vencido, baixa fidelidade, falta de revisão ou evento adverso, mas apenas apoiam o julgamento clínico.

A literatura encontrada recomenda comunicar incerteza. Revisões relatam efeitos possíveis e heterogêneos, riscos de viés, escassez de dados de longo prazo e necessidade de medir fidelidade, eventos adversos e resultados significativos para pessoas autistas. Portanto, o Fala Comigo não deve prometer cura, normalização ou resultado individual a partir de médias de estudos. [8] [9]

### 3.2 Fonoaudiologia e CAA

O módulo fonoaudiológico deve iniciar por uma avaliação estruturada e reavaliação contínua. Deve contemplar habilidades cognitivas, sensoriais, motoras, pré-linguísticas e linguísticas; fala; leitura e escrita; comunicação social; participação; contexto; preferências; qualidade de vida; visão; audição; posicionamento; fadiga; método de seleção e barreiras ambientais. A avaliação é fonoaudiológica e, quando necessário, transdisciplinar. O software registra e organiza informações, mas não realiza diagnóstico automático nem substitui a competência profissional. [10] [11] [12]

O construtor de metas deve apoiar necessidades e desejos, atenção, escolhas, pedido de ajuda, rejeição ou protesto, comentários, perguntas, troca de informação, interação social, alfabetização, participação e redução de rupturas comunicativas. Metas devem ser individualizadas pelo profissional, pela pessoa e pela equipe. O editor de vocabulário deve suportar vocabulário núcleo e periférico, palavras personalizadas, imagens, texto, voz, diferentes idiomas e variantes linguístico-culturais.

A ferramenta de correspondência de características deve organizar tipo e tamanho de símbolo, quantidade e organização do campo, tela estática ou dinâmica, seleção direta ou indireta, saída de voz, acessibilidade visual, auditiva e motora, posicionamento, switches, montagens, portabilidade, manutenção, custo e expansão. Testes comparativos devem incluir comunicação sem tecnologia, de baixa tecnologia e de alta tecnologia, registrando desempenho por ambiente e interlocutor. Esse recurso é apoio à avaliação e não indicação de produto específico.

O produto deve favorecer rotinas reais. Deve oferecer biblioteca de atividades e coaching de parceiros com modelagem de linguagem auxiliada, tempo de espera, oportunidades de escolha e registro de prática. Cópias de pranchas ou páginas devem ser exportáveis e acessíveis em casa, escola, transporte, saúde e comunidade. O sistema deve registrar barreiras, falhas, manutenção, bateria, conectividade, reparo e disponibilidade de suporte de baixa tecnologia. A ASHA recomenda disponibilidade consistente, uso em ambientes naturais e participação de família e parceiros. [11] [12]

No Brasil, a Resolução CFFa nº 799/2025 atribui ao fonoaudiólogo, respeitadas as competências de outras profissões, avaliação, diagnóstico fonoaudiológico, seleção e adaptação de sistemas e estratégias linguísticas, planejamento, monitoramento, reavaliação e capacitação de parceiros. A Lei nº 15.249/2025 criou deveres públicos específicos para CAA de baixa tecnologia e capacitação em serviços públicos de saúde e previu pranchas pictográficas em espaços públicos e no atendimento educacional especializado, observada a disponibilidade financeira e orçamentária. Essas normas não escolhem aplicativo, tablet, voz sintetizada ou dispositivo individual. [10] [14]

### 3.3 Clínicas multiprofissionais e prontuário

A clínica precisa de um prontuário longitudinal, sigiloso, íntegro e orientado à continuidade do cuidado. Cada registro deve guardar autoria, identificação profissional, data e hora, conteúdo, versão e relação com atendimento, avaliação, plano ou documento. O sistema deve permitir registros de diferentes profissões sem apagar a distinção entre exigências de cada conselho.

Quando houver assistência médica, a Resolução CFM nº 1.638/2002 define o prontuário como conjunto de informações, sinais e imagens que permite comunicação entre a equipe multiprofissional, lista conteúdo mínimo e exige Comissão de Revisão de Prontuários nos estabelecimentos onde há assistência médica. A Resolução CFM nº 1.821/2007 disciplina digitalização, guarda e gerenciamento de prontuários médicos. Essas regras não devem ser automaticamente aplicadas a serviços que não estejam no escopo médico. [17] [18]

O plano terapêutico compartilhado deve registrar necessidades, objetivos, intervenções por profissional, responsáveis, frequência, prazos, indicadores, riscos, benefícios, preferências e revisão. A pessoa deve poder saber o que é compartilhado com cada integrante. Família ou cuidador participam quando apropriado e conforme autorização ou representação. Modelos de declaração, atestado, relatório, laudo, parecer, encaminhamento e cópia do prontuário devem variar por profissão, finalidade, destinatário, mínimo necessário, assinatura, validade e histórico. Para Psicologia, o gerador deve contemplar as modalidades e limites da Resolução CFP nº 06/2019. [20]

A Comissão de Revisão de Prontuários, a revisão de qualidade, a resposta a incidentes e as decisões de responsável técnico permanecem processos institucionais. O produto pode fornecer fila, amostragem, achados, plano corretivo, atas e trilha, mas não substitui comissão, responsável técnico, encarregado ou avaliação jurídica.

### 3.4 Escolas e colaboração casa-escola

O hub casa-escola deve separar comunicação geral da escola de dados individualizados. Pode conter mensagens assíncronas, calendário, avisos de rotina, confirmação de leitura, tradução e formatos acessíveis. O registro versionado de plano de apoio ou AEE deve permitir necessidades funcionais, metas mensuráveis, estratégias, adaptações, recursos, responsável, frequência, local, duração, início, evidências e revisão. A interface deve ser configurável por rede e não deve presumir que um formato denominado PEI seja obrigação nacional única.

O fluxo de adaptações deve permitir solicitação, análise, aprovação, implementação e revisão de acessibilidade física, comunicacional, pedagógica, tecnologia assistiva, intérprete e apoio. O sistema deve registrar motivo pedagógico e efetividade sem transformar diagnóstico em requisito universal. O módulo de transição deve incluir escola de origem e destino, acolhimento, visita ou reunião, tarefas, prazos, transferência mínima de informações, confirmação de recebimento, voz, preferências, interesses e continuidade.

No Brasil, a LBI exige sistema educacional inclusivo, acesso, permanência, participação, aprendizagem, adaptações razoáveis e tecnologia assistiva. A Resolução CNE/CEB nº 4/2009 prevê articulação do AEE com a sala comum, participação das famílias e interface intersetorial; não demonstra, por si só, um formato nacional único de PEI. O guia brasileiro de transições é orientação de apoio, não uma obrigação de comprar ou usar software. [13] [28] [29]

O painel de rotina deve apoiar participação, não vigilância. Frequência, atividades, barreiras observadas, estratégias e feedback devem ser contextualizados. O sistema não deve inferir diagnóstico ou risco automaticamente. Internacionalmente, IDEA, SEND e os Disability Standards for Education oferecem referências de participação, metas, transição, ajustes razoáveis e consulta, mas dependem da jurisdição e não devem ser generalizados para escolas brasileiras. [30] [31] [32] [33]

### 3.5 Empresas patrocinadoras e financiadores

Empresas patrocinadoras podem apoiar acesso, pesquisa de uso, bolsas, capacitação e infraestrutura, mas não devem receber prontuários, avaliações identificáveis ou conteúdo de sessões por padrão. A função recomendada é um **painel de impacto agregado**, com indicadores de alcance, disponibilidade, participação, conclusão de capacitação, barreiras de acesso e continuidade. Cada indicador deve mostrar definição, denominador, período, cobertura, limitações e se foi calculado com dados agregados ou anonimizados.

O patrocinador deve ter perfil separado, sem acesso a ficha nominal, notas sensíveis, áudio, vídeo, localização ou comunicações privadas. Projetos de avaliação devem ter finalidade, base legal, escopo, prazo de retenção, governança, critérios de publicação e processo para retirada quando cabível. Não se deve condicionar atendimento, CAA, adaptação ou participação à autorização para uso promocional ou compartilhamento amplo.

A página pública de resultados deve ser revisada por governança e não pode usar relatos identificáveis sem autorização específica. Métricas de produto não podem ser apresentadas como eficácia clínica. Patrocinadores não devem influenciar seleção de objetivos, reforçadores, dispositivos ou procedimentos. A empresa pode financiar uma capacidade; a decisão continua com pessoa, família e equipe competente.

## 4. Matriz por perfil

| Perfil | Necessidades principais | Permissões recomendadas | Saídas e limites |
|---|---|---|---|
| Pessoa atendida/estudante | Comunicação, participação, autonomia, acesso a metas e preferências | Ver seus registros em formato acessível, registrar preferências, consentir ou recusar quando aplicável, solicitar correção e exportação conforme contexto | Nunca ser reduzida a pontuação; não receber decisão automatizada como diagnóstico ou tratamento |
| Familiar/cuidador autorizado | Rotinas, tarefas, CAA, plano, feedback, treinamento e comunicação | Ver apenas caso e escopo autorizados; registrar implementação, barreiras, observações e revogação de acesso | Não presumir acesso irrestrito; não condicionar cuidado a quantidade fixa de participação |
| Analista do comportamento/supervisor | Objetivos, linha de base, coleta, procedimento, reforço, generalização, supervisão | Criar ou revisar plano dentro de sua competência; registrar dados e decisões assinadas; acessar somente casos atribuídos | Alertas não mudam intervenção; não prometer eficácia nem converter tendência em diagnóstico |
| Fonoaudiólogo | Avaliação, metas funcionais, CAA, vocabulário, acesso, parceiros e reavaliação | Registrar avaliação e plano fonoaudiológico, testar opções, treinar parceiros e revisar sistema | Não selecionar dispositivo automaticamente; não extrapolar escopo profissional |
| Professor/equipe escolar/AEE | Barreiras, adaptações, rotina, participação, plano e transição | Acessar campos necessários à função educacional; registrar estratégias e progresso pedagógico | Não exibir saúde ou diagnóstico em mural; não bloquear matrícula, AEE ou adaptação por ausência de diagnóstico |
| Profissional médico ou de outra saúde | Anamnese, avaliação, evolução, plano, documentos e continuidade | Acessar conjunto mínimo necessário, com autoria e escopo profissional; gerar documentos parametrizados | Regras do CFM não são universais; decisões permanecem clínicas e institucionais |
| Gestor/responsável técnico | Qualidade, fila de revisão, incidentes, permissões e governança | Acessar metadados e registros necessários para supervisão; revisar amostras e incidentes | Não usar painel para vigilância indiscriminada; não apagar versões |
| Encarregado/privacidade/segurança | Bases legais, consentimentos, acessos, incidentes e titulares | Ver trilhas, configurações e fluxos de direitos conforme função | Não acessar conteúdo clínico além do necessário para a finalidade de governança |
| Empresa patrocinadora | Impacto, alcance, equidade e sustentabilidade | Ver somente painéis agregados ou dados explicitamente autorizados | Sem prontuário nominal, publicidade comportamental, venda de dados ou influência clínica |
| Administrador técnico | Disponibilidade, configuração e suporte | Gerenciar contas e infraestrutura sem acesso por padrão ao conteúdo; acesso excepcional justificado e auditado | Separação de funções, menor privilégio e quebra de vidro com motivo |

## 5. Arquitetura de entrega: MVP local/offline e portal futuro

### 5.1 MVP local/offline

O MVP deve funcionar sem conectividade contínua, em aparelho ou estação institucional controlada, com sincronização desativada por padrão. Deve conter:

- ficha estruturada da pessoa, contatos autorizados, idioma, preferências, ambientes, responsáveis e papéis;
- linha do tempo de atendimentos, avaliações, etapas, planos, revisões, documentos e encerramentos;
- objetivos e metas com definição, linha de base, unidade, critério, responsável, status e revisão;
- evolução por sessão ou rotina, com medida, contexto, observador, data e hora, notas e motivo de ausência;
- procedimentos, reforçadores, preferências, tarefas e materiais, sempre editáveis por profissional competente e com histórico;
- matriz inicial de generalização e manutenção;
- treino de cuidador ou parceiro, checklist de fidelidade, prática, feedback e barreiras;
- relatórios locais com separação entre fatos, interpretação, limitações e recomendações;
- consentimentos e autorizações versionados, com finalidade, base registrada, destinatários, prazo, revogação e impacto da revogação;
- perfis e menor privilégio, autenticação forte, bloqueio de sessão, criptografia local quando tecnicamente apropriada, backup e restauração testados;
- auditoria de leitura, inclusão, alteração, exportação, impressão, compartilhamento, permissão e consentimento;
- exportação legível e auditável, incluindo dados brutos, metadados, versões e limitações;
- materiais imprimíveis de CAA, planos, tarefas e rotinas para reduzir dependência de bateria, conta ou internet;
- acessibilidade de teclado e toque, foco visível, contraste, texto simples, leitor de tela, legendas, alvos grandes e configuração sensorial.

O MVP deve ter importação e exportação controladas, mas não deve criar uma falsa promessa de sincronização segura. O dispositivo precisa ter responsável, inventário, política de atualização, procedimento de perda e teste de restauração. Caso o MVP use servidor local, este deve permanecer segregado de ambientes de desenvolvimento e demonstração.

### 5.2 Portal futuro

O portal deve ser uma extensão governada, não uma substituição do modo local. Prioridades futuras:

1. colaboração casa-escola-clínica com mensagens assíncronas, calendário, tarefas, confirmação de leitura e tradução;
2. permissões por papel, caso, organização, finalidade, campo e prazo, com revisão e expiração;
3. consentimento e autorização digitais com versão, prova, revogação, escopo, destinatário e consequência operacional;
4. exportação CSV, PDF e API em formatos documentados, sem aprisionamento tecnológico;
5. fluxos de transição entre escola, clínica e equipe, compartilhando apenas o mínimo necessário;
6. painéis de qualidade e impacto agregados para gestores e patrocinadores;
7. integrações com diretórios, sistemas institucionais e recursos de CAA somente após avaliação de risco, contrato e testes;
8. fila de incidentes, solicitação do titular, revisão de acesso, quebra de vidro e auditoria centralizada;
9. relatórios configuráveis por família, equipe, pagador ou órgão, com linguagem e campos apropriados;
10. suporte a múltiplas organizações sem misturar dados, com segregação, retenção e encerramento por organização.

O portal deve oferecer canal alternativo presencial ou impresso para famílias sem conectividade. A sincronização deve ser explícita, mostrar destinatário e campos compartilhados, permitir revisão antes do envio e registrar falhas. O sistema não deve interpretar falha de sincronização como ausência de participação da família.

## 6. Fluxos funcionais essenciais

### 6.1 Ficha da pessoa e admissão

1. Criar registro com identificadores mínimos, nome preferido, idioma, acessibilidade e contatos.
2. Registrar responsável legal, representante, pessoas autorizadas, preferências de comunicação e limites de compartilhamento.
3. Definir finalidade do registro: assistência, educação, CAA, treinamento, gestão, pesquisa ou impacto agregado.
4. Registrar base legal aplicável, aviso apresentado, consentimento quando exigido, versão, data, prazo, destinatários e revogação.
5. Registrar prioridades da pessoa e da família, ambientes relevantes, barreiras, preferências e recursos já usados.
6. Definir equipe, papéis, responsável técnico, ambiente de atendimento e regras de acesso.
7. Abrir linha de base ou marcar que ainda não está disponível, indicando motivo e prazo para revisão.

A ficha não deve coletar diagnóstico como condição universal para acesso a comunicação, educação, CAA ou apoio. Se um campo for necessário para determinada finalidade, a interface deve explicar por quê, limitar quem vê e permitir correção.

### 6.2 Histórico longitudinal

O histórico deve funcionar como uma linha do tempo filtrável por pessoa, ambiente, objetivo, profissional e tipo de evento. Cada evento guarda autor, data, hora, versão e fonte. Tipos recomendados: admissão, avaliação, sessão, rotina, plano, revisão, consentimento, revogação, incidente, encaminhamento, transição, documento, treinamento e encerramento.

Correções devem ser feitas por adendo ou nova versão, com motivo e vínculo ao original. O sistema não deve permitir alterar retroativamente um dado sem mostrar a mudança. Exportações devem incluir histórico de alterações e marcação de registros incompletos, ausentes ou contestados.

### 6.3 Etapas de avaliação e planejamento

A etapa de avaliação registra contexto, habilidades, preferências, barreiras, comunicação atual, ambiente, prioridades e linha de base. A etapa de planejamento converte necessidades em objetivos funcionais mensuráveis, procedimentos, responsáveis, frequência, materiais, riscos, apoio e data de revisão. A etapa de implementação registra o que foi feito, por quem, com quais prompts, reforços, adaptações ou recursos de CAA. A etapa de revisão compara dados com o objetivo e registra manter, adaptar, intensificar, reduzir, pausar, encaminhar ou encerrar, sempre com justificativa humana.

Para CAA, o ciclo deve permitir testes de símbolos, vocabulário, acesso e saída em mais de um ambiente. Para ABA, deve permitir medidas e procedimentos definidos pelo analista. Para escola, deve permitir adaptações e participação. Para clínica multiprofissional, deve permitir planos por profissão e visão compartilhada mínima.

### 6.4 Evolução e decisão baseada em dados

A tela de evolução deve mostrar período, objetivo, medida, denominador, linha de base, contexto, observador, tendência, variabilidade, dados ausentes e mudanças de procedimento. Anotações devem distinguir fato, interpretação e próximo passo. Alertas devem ser explicáveis, configuráveis e revisáveis.

Exemplos de alerta: objetivo sem linha de base; sessão sem medida; mudança abrupta; excesso de dados ausentes; baixa fidelidade; plano vencido; ausência de revisão; incidente ou efeito indesejável; CAA indisponível; baixa generalização; barreira de acesso; consentimento vencido ou revogado. O alerta nunca deve iniciar uma alteração terapêutica ou educacional sem revisão e registro humano.

### 6.5 Reforços, preferências e tarefas

O módulo de reforço deve registrar preferência declarada ou observada, método de amostragem, opção disponível, restrição, programação usada, resposta observada, contexto e revisão da hipótese. Deve permitir alterar opções, registrar recusas e evitar assumir que uma preferência permanece estável. O sistema não deve liberar, retirar ou prescrever reforçador automaticamente como decisão clínica.

Tarefas para casa, escola ou rotina devem conter objetivo, instrução acessível, modelo, materiais, frequência opcional, responsável, local, duração aproximada, observação, dificuldade, barreira e feedback. O sistema deve permitir marcar “não realizado” sem punição ou inferência moral. Lembretes são opcionais e não podem transformar família, estudante ou cuidador em fiscal de conformidade. Treino de parceiros deve registrar prática observada, fidelidade, feedback e o que foi implementado, sem apagar tentativas anteriores.

### 6.6 Generalização, manutenção e transição

O produto deve separar aquisição em treino, generalização, manutenção e participação funcional. A matriz deve cruzar pessoa, ambiente, rotina, material, instrução, horário e interlocutor. Cada sondagem precisa identificar contexto e método. A transição deve registrar destino, necessidades de acolhimento, campos compartilhados, autorização, confirmação de recebimento, pendências e contato responsável.

## 7. Privacidade, consentimento, finalidade, prazo, revogação e auditoria

### 7.1 Modelo mínimo de governança de dados

Para cada fluxo, o sistema deve registrar:

- **Finalidade:** por que o dado é usado, com linguagem compreensível e separação entre atendimento, educação, CAA, gestão, pesquisa e impacto.
- **Base aplicável:** hipótese da LGPD ou regra institucional/profissional pertinente. Consentimento específico e destacado é uma possibilidade, não uma exigência universal.
- **Dados e minimização:** quais campos são necessários, quais são opcionais e quais não devem ser coletados.
- **Destinatários:** pessoa, responsável, equipe, escola, outro serviço, fornecedor ou patrocinador; indicar campos, prazo e canal.
- **Prazo e retenção:** período definido por finalidade e obrigação aplicável, com revisão e descarte seguro; não inventar prazo universal.
- **Revogação e oposição:** como retirar autorização quando possível, o que deixa de ser compartilhado, o que precisa ser preservado por obrigação e quem revisa exceções.
- **Direitos e representação:** acesso, correção, informação, portabilidade ou eliminação quando aplicáveis; autenticar solicitante e verificar representação.
- **Segurança:** identidade individual, autenticação forte, menor privilégio, criptografia quando apropriada, backups testados, logs, gestão de incidentes e segregação de ambientes.

A LGPD exige finalidade, adequação, necessidade, transparência, segurança, prevenção, não discriminação e responsabilização. Dados de saúde são sensíveis; dados de crianças e adolescentes devem observar o melhor interesse. A solução concreta depende do papel de controlador e operador, do contexto e da orientação institucional competente. [6]

### 7.2 Consentimento e autorização

O produto deve separar, quando aplicável, autorização para atendimento ou educação; compartilhamento com família; envio a escola, serviço de saúde ou outro terceiro; uso de imagem, áudio ou vídeo; pesquisa; comunicação promocional; e painel de impacto. Cada autorização deve conter finalidade, dados, destinatário, prazo, versão do texto, forma de prova, data, responsável, revogação e consequência operacional.

A revogação deve interromper usos futuros compatíveis com ela, sinalizar compartilhamentos pendentes e preservar registros que devam ser mantidos por obrigação ou integridade documental. O sistema deve explicar essa diferença sem prometer apagamento absoluto. Para crianças, adolescentes, pessoas sob representação ou pessoas com apoio para tomada de decisão, a plataforma deve verificar contexto, melhor interesse, capacidade, representação e participação da própria pessoa quando possível.

### 7.3 Auditoria e resposta

A trilha de auditoria deve registrar usuário, papel, paciente ou caso, operação, data e hora, IP ou dispositivo quando apropriado, resultado, justificativa e versão. Operações relevantes incluem leitura, pesquisa, inclusão, alteração, adendo, exportação, impressão, compartilhamento, mudança de permissão, consentimento, revogação, quebra de vidro, restauração e exclusão.

A trilha deve ser resistente a adulteração e revisável por função. Alertas podem apontar acesso fora da equipe, consulta em massa, alteração retroativa, compartilhamento incomum, conta desligada ou tentativa repetida. A resposta a incidente deve cobrir detecção, classificação, contenção, preservação de evidências, comunicação quando aplicável e documentação das decisões. A LGPD demanda medidas de segurança e resposta adequada; não se deve prometer prazo ou rito sem validação normativa vigente. [6] [21]

## 8. Itens proibidos ou que exigem bloqueio de produto

O Fala Comigo deve bloquear ou não oferecer, por padrão:

- diagnóstico automático, classificação de deficiência ou inferência de condição de saúde a partir de gráfico, áudio, comportamento, uso ou ausência de resposta;
- seleção automática de tratamento, intensidade, punição, contenção, prompt, reforçador ou mudança de plano;
- promessa de cura, normalização, fala, independência, eficácia garantida ou resultado individual;
- apresentação de correlação, tendência ou pontuação como prova clínica sem contexto, unidade, período, limitações e revisão profissional;
- acesso amplo de família, escola, patrocinador, fornecedor ou administrador sem representação, finalidade e escopo;
- compartilhamento em mural, grupo ou relatório público de diagnóstico, saúde, comportamento, plano individual, áudio, vídeo ou localização;
- eliminação silenciosa de evolução, consentimento, versão, adendo, documento, permissão ou dado bruto;
- condicionar atendimento, matrícula, AEE, CAA, adaptação ou participação à existência de diagnóstico, conectividade, assinatura digital ou quantidade fixa de participação do cuidador;
- retirada de CAA, comunicação ou apoio como punição, ou tratamento da ausência de fala como ausência de compreensão;
- publicidade comportamental, venda de dados, ranking de crianças, gamificação coercitiva ou uso promocional sem autorização específica;
- usar dados de patrocinadores para escolher objetivos, reforçadores, dispositivos ou procedimentos;
- ocultar indisponibilidade, dados ausentes, falha de sincronização, perda de dispositivo ou baixa fidelidade;
- operar integração ou função clínica regulada sem triagem de finalidade, risco e análise regulatória aplicável.

A finalidade declarada é determinante para a análise de eventual software como dispositivo médico. No Brasil, uma aplicação que diagnostica, trata, mitiga ou influencia decisões clínicas pode exigir análise regulatória específica; uma ferramenta educacional, de organização ou de bem-estar não deve fazer alegações clínicas sem base. [40] [41] [42]

## 9. Riscos e controles

| Risco | Exemplo | Controle prioritário | Indicador de acompanhamento |
|---|---|---|---|
| Exposição de dados sensíveis | Exportação com diagnóstico para destinatário errado | Mínimo necessário, confirmação, expiração, criptografia e auditoria | Exportações por escopo e incidentes confirmados |
| Decisão automatizada indevida | Alerta altera plano ou classifica risco | Revisão humana obrigatória e registro de decisão | Alertas aceitos, rejeitados e justificados |
| Dados incompletos | Sessões sem medida ou denominador | Campo de motivo, validação contextual e relatório de lacunas | Percentual de registros completos por objetivo |
| Generalização falsa | Êxito na clínica interpretado como uso em casa | Sondagens por ambiente e matriz de manutenção | Objetivos com dados fora do treino |
| Abandono de CAA | Bateria, custo, baixa participação de parceiros | Backup de baixa tecnologia, treino e reavaliação | Disponibilidade e uso por ambiente |
| Sobrecarga familiar | Tarefas extensas ou coercitivas | Tarefas curtas, opcionais, acessíveis e com feedback | Tarefas iniciadas, barreiras relatadas e revogação |
| Acesso indevido interno | Conta de ex-funcionário ou consulta em massa | Desligamento automático, menor privilégio, alertas | Acessos fora do escopo e tempo de correção |
| Perda ou corrupção | Dispositivo perdido ou backup inválido | Criptografia, backup versionado e restauração testada | Testes de restauração e perda de registros |
| Estigmatização | Diagnóstico em mural ou ranking de turma | Segmentação, linguagem simples e revisão de destinatário | Compartilhamentos bloqueados |
| Aprisionamento tecnológico | Impossibilidade de exportar ou migrar | CSV/PDF/API documentados e dados legíveis | Exportações bem-sucedidas e solicitações atendidas |
| Uso promocional indevido | Patrocinador publica relato identificável | Dados agregados, autorização específica e revisão | Campanhas aprovadas e retiradas |
| Enquadramento regulatório errado | App faz alegação clínica sem análise | Triagem por finalidade e revisão de risco | Funcionalidades liberadas após análise |

## 10. Roadmap sugerido

### Fase 0 — governança e descoberta

Definir público inicial, controlador e operadores por cenário, responsável técnico, papéis, modelo de dados mínimo, políticas de retenção, fluxo de direitos, critérios de incidente e escopo de finalidade. Validar com pessoas autistas, usuários de CAA, familiares, profissionais, escolas e especialistas em acessibilidade. Não liberar alegações clínicas ou patrocinadores antes da revisão de finalidade e risco.

### Fase 1 — MVP local/offline seguro

Entregar ficha, histórico, etapas, objetivos, linha de base, evolução, reforços, tarefas, CAA imprimível, consentimentos, permissões, auditoria, exportação e backup. Realizar testes de usabilidade com baixa conectividade, letramento diverso, leitores de tela, switches, toque, teclado e diferentes perfis de comunicação. Verificar restauração, correção de versão, revogação, exportação e ausência de diagnóstico automático.

### Fase 2 — piloto controlado

Piloto com poucos serviços e casos não identificáveis em demonstrações. Medir completude, tempo de registro, acessibilidade, generalização, disponibilidade de CAA, carga do cuidador, qualidade da exportação e incidentes. Comparar o funcionamento local com procedimentos atuais sem afirmar eficácia terapêutica. Revisar alertas com supervisores e eliminar qualquer alerta que possa ser confundido com decisão automática.

### Fase 3 — portal de colaboração

Adicionar contas institucionais, sincronização explícita, casa-escola-clínica, revisão antes do compartilhamento, tarefas, transições, consentimentos digitais, direitos dos titulares e exportação em formatos abertos. Manter canal alternativo e modo local. Implementar segregação por organização, revisão de permissões e gestão de fornecedores.

### Fase 4 — qualidade, impacto e patrocinadores

Criar painéis agregados para gestores e patrocinadores, com metodologia, limitações, denominadores, cobertura, período e revisão de equidade. Permitir somente dados autorizados, sem prontuário nominal. Publicar resultados sem transformar indicadores de uso em eficácia clínica. Estabelecer conselho de usuários e revisão periódica de riscos.

### Fase 5 — integrações e reavaliação regulatória

Somente após evidência de segurança, governança e necessidade, avaliar integrações com sistemas institucionais, APIs e funções que possam alterar o enquadramento regulatório. Reavaliar cada nova funcionalidade por finalidade, risco, dados, impacto em crianças e possibilidade de decisão automatizada. Rever políticas quando mudarem lei, norma profissional ou contexto de operação.

## 11. Checklist de aceite antes de cada lançamento

- A funcionalidade declara se é produto, obrigação normativa, recomendação profissional ou hipótese experimental?
- O fluxo separa dado observado, interpretação, decisão e recomendação?
- Há finalidade, base aplicável, minimização, destinatário, prazo e revogação?
- A permissão está limitada por função, caso, campo e tempo?
- O registro preserva autor, data, hora, versão e motivo de correção?
- A pessoa ou representante consegue acessar, corrigir e exportar o que é aplicável?
- O recurso funciona com conectividade limitada e oferece alternativa imprimível quando necessário?
- O conteúdo é acessível e foi testado com usuários reais?
- A função impede diagnóstico e prescrição automática?
- O patrocinador recebe apenas dados agregados ou explicitamente autorizados?
- Existe auditoria, backup, restauração e plano de incidente testados?
- O texto de interface evita promessa de eficácia, cura, normalização ou resultado individual?

## 12. Caveats de interpretação

Este relatório consolida os resultados fornecidos e transforma achados em recomendações de produto. Fontes legais brasileiras definem obrigações apenas dentro de seus âmbitos; fontes internacionais, códigos profissionais e guias clínicos não se tornam automaticamente lei brasileira. A aplicação concreta depende da profissão, do serviço, da jurisdição, do contrato, do papel de controlador ou operador, da idade e representação da pessoa, da finalidade do tratamento e das políticas institucionais vigentes.

O relatório não substitui análise jurídica, responsável técnico, avaliação fonoaudiológica, análise do comportamento, avaliação médica, decisão educacional ou consulta à autoridade competente. Nenhuma funcionalidade deve ser apresentada como capaz de diagnosticar, prescrever ou garantir resultado. Antes de produção, o Fala Comigo deve validar o desenho com profissionais habilitados, pessoas usuárias, famílias, escolas, especialistas de segurança e acessibilidade e, quando aplicável, assessoria jurídica e regulatória.

## References

[1]: https://www.bacb.com/ethics-information/ethics-codes/ "BACB — Ethics Codes"
[2]: https://assets.bacb.com/wp-content/uploads/2020/05/Clarifications_ASD_Practice_Guidelines_2nd_ed.pdf "BACB — Clarifications Regarding Applied Behavior Analysis Treatment of Autism Spectrum Disorder: Practice Guidelines for Healthcare Funders and Managers"
[3]: https://afirm.fpg.unc.edu/wp-content/uploads/Parent-Implemented-Intervention-Brief-Packet-Amsbary-AFIRM-Team-Updated-2025.pdf "AFIRM/UNC — Parent-Implemented Intervention Brief Packet"
[4]: https://afirm.fpg.unc.edu/wp-content/uploads/Reinforcement-Introduction-Practice-Packet-Sam-et-al-Updated-2024.pdf "AFIRM/UNC — Reinforcement: Introduction & Practice"
[5]: https://www.scielo.br/j/ptp/a/VYGp5KQGdpsTHPj8LpHNdBM/?lang=pt "Gomes et al. — Efeitos de Intervenção Comportamental Intensiva Realizada por Meio da Capacitação de Cuidadores de Crianças com Autismo"
[6]: https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm "Brasil — Lei nº 13.709/2018, Lei Geral de Proteção de Dados Pessoais"
[7]: https://site.cfp.org.br/wp-content/uploads/2009/04/resolucao2009_01.pdf "Conselho Federal de Psicologia — Resolução CFP nº 001/2009"
[8]: https://pmc.ncbi.nlm.nih.gov/articles/PMC8108110/ "Rodgers et al. — Intensive behavioural interventions based on applied behaviour analysis for autistic children"
[9]: https://pmc.ncbi.nlm.nih.gov/articles/PMC7265021/ "Efficacy of interventions based on applied behavior analysis for autism spectrum disorder: a meta-analysis"
[10]: https://www.fonoaudiologia.org.br/resolucoes/resolucoes_html/CFFa_N_799_25.htm "Conselho Federal de Fonoaudiologia — Resolução CFFa nº 799/2025"
[11]: https://www.asha.org/practice-portal/professional-issues/augmentative-and-alternative-communication/ "ASHA — Practice Portal: Augmentative and Alternative Communication"
[12]: https://www.asha.org/practice/early-intervention-provider-support/augmentative-and-alternative-communication-in-early-intervention/ "ASHA — Augmentative and Alternative Communication in Early Intervention"
[13]: https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2015/lei/l13146.htm "Brasil — Lei nº 13.146/2015, Lei Brasileira de Inclusão"
[14]: https://www.planalto.gov.br/ccivil_03/_ato2023-2026/2025/lei/l15249.htm "Brasil — Lei nº 15.249/2025, Comunicação Aumentativa e Alternativa de baixa tecnologia"
[15]: https://www.who.int/news-room/fact-sheets/detail/assistive-technology "Organização Mundial da Saúde — Assistive technology"
[16]: https://www.un.org/development/desa/disabilities/convention-rights-persons-with-disabilities/article-21-freedom-expression-and-opinion-and-access-information.html "Nações Unidas — Convenção sobre os Direitos das Pessoas com Deficiência, Artigo 21"
[17]: https://sistemas.cfm.org.br/normas/visualizar/resolucoes/BR/2002/1638 "Conselho Federal de Medicina — Resolução CFM nº 1.638/2002"
[18]: https://sistemas.cfm.org.br/normas/visualizar/resolucoes/BR/2007/1821 "Conselho Federal de Medicina — Resolução CFM nº 1.821/2007"
[19]: https://portal.cfm.org.br/artigos/prontuario-medico/ "Conselho Federal de Medicina — Prontuário médico"
[20]: https://site.cfp.org.br/wp-content/uploads/2019/09/Resolu%C3%A7%C3%A3o-CFP-n-06-2019-comentada.pdf "Conselho Federal de Psicologia — Resolução CFP nº 06/2019 comentada"
[21]: https://www.gov.br/anpd/pt-br/centrais-de-conteudo/materiais-educativos-e-publicacoes/guia-orientativo-sobre-seguranca-da-informacao-para-agentes-de-tratamento-de-dados-pessoais-de-pequeno-porte "ANPD — Guia orientativo sobre segurança da informação para agentes de tratamento de pequeno porte"
[22]: https://www.gov.br/anpd/pt-br/centrais-de-conteudo/materiais-educativos-e-publicacoes/guia_seguranca_da_informacao_para_atpps___defeso_eleitoral.pdf/@@display-file/file "ANPD — Guia de segurança da informação para agentes de tratamento"
[23]: https://www.hhs.gov/hipaa/for-professionals/security/laws-regulations/index.html "HHS — HIPAA Security Rule"
[24]: https://www.hhs.gov/hipaa/for-professionals/faq/disclosures-to-family-and-friends/index.html "HHS — HIPAA: disclosures to family and friends"
[25]: https://www.hhs.gov/hipaa/for-professionals/faq/personal-representatives-and-minors/index.html "HHS — HIPAA: personal representatives and minors"
[26]: https://www.hhs.gov/hipaa/for-professionals/faq/right-to-access-and-research/index.html "HHS — HIPAA: right of access and research"
[27]: https://www.who.int/health-topics/integrated-people-centered-care "WHO — Integrated people-centred care"
[28]: https://www.gov.br/mec/pt-br/cne/pdf/resolucoes-do-cne/ceb/2009/rceb004_09.pdf "Brasil — Resolução CNE/CEB nº 4/2009"
[29]: https://www.gov.br/mec/pt-br/escola-das-adolescencias/guias-de-apoio-tecnico/arquivos/guia-de-apoio-as-transicoes-e-alocacoes-de-matriculas "MEC — Guia de apoio às transições e alocações de matrículas"
[30]: https://sites.ed.gov/idea/regs/b/d/300.321 "IDEA — 34 CFR §300.321, IEP team"
[31]: https://sites.ed.gov/idea/regs/b/d/300.320 "IDEA — 34 CFR §300.320, IEP contents"
[32]: https://www.gov.uk/government/publications/send-code-of-practice-0-to-25 "England — SEND Code of Practice: 0 to 25 years"
[33]: https://www.education.gov.au/disability-standards-education-2005/educators "Australia — Disability Standards for Education: educators"
[34]: https://www.unicef.org/lac/media/7741/file "UNICEF — Material sobre educação inclusiva e participação"
[35]: https://www.bacb.com/wp-content/ethics-code-for-behavior-analysts/ "BACB — Ethics Code for Behavior Analysts"
[36]: https://www.who.int/teams/mental-health-and-substance-use/treatment-care/who-caregivers-skills-training-for-families-of-children-with-developmental-delays-and-disorders "WHO — Caregiver Skills Training"
[37]: https://www.nice.org.uk/guidance/cg170/chapter/recommendations "NICE — Autism spectrum disorder in under 19s: support and management"
[38]: https://www.w3.org/TR/WCAG22/ "W3C — Web Content Accessibility Guidelines 2.2"
[39]: https://www.unicef.org/eca/media/30671/file/Teacher's%20guide%20for%20building%20capacity%20for%20assistive%20technology.pdf "UNICEF — Teacher's guide for building capacity for assistive technology"
[40]: https://www.ftc.gov/legal-library/browse/rules/childrens-online-privacy-protection-rule-coppa "FTC — Children's Online Privacy Protection Rule"
[41]: https://www.hhs.gov/hipaa/for-professionals/special-topics/health-apps/index.html "HHS — HIPAA and health apps"
[42]: https://www.gov.br/anvisa/pt-br/centraisdeconteudo/publicacoes/produtos-para-a-saude/manuais/software-como-dispositivo-medico-perguntas-e-respostas "ANVISA — Software como dispositivo médico: perguntas e respostas"
[43]: https://www.fda.gov/medical-devices/digital-health-center-excellence/device-software-functions-including-mobile-medical-applications "FDA — Device software functions and mobile medical applications"
[44]: https://www.ohchr.org/en/instruments-mechanisms/instruments/convention-rights-persons-disabilities "OHCHR — Convention on the Rights of Persons with Disabilities"
[45]: https://www.who.int/publications/i/item/9789240049451 "WHO — Caregiver skills training for families of children with developmental delays and disorders"
[46]: https://www.nice.org.uk/guidance/ng197/resources/shared-decision-making-pdf-66142087186885 "NICE — Shared decision making"
