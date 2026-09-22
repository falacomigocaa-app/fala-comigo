# Modelo de benefício corporativo para pessoas com deficiência

## Resumo

O Fala Comigo pode ser oferecido por empresas como um benefício de inclusão e apoio às famílias de colaboradores. A empresa financia o acesso, mas não recebe automaticamente dados da criança, diagnóstico, registros de uso, vídeos, áudios ou conteúdo clínico.

A separação essencial é esta:

> **A empresa paga ou subsidia o benefício; a família controla os dados e escolhe qualquer compartilhamento.**

Esse desenho permite apoiar colaboradores que têm filhos ou dependentes autistas sem transformar o empregador em gestor de informações clínicas.

## Formas de oferta

| Programa | O que a empresa oferece | O que a família controla |
| --- | --- | --- |
| Acesso patrocinado | Licenças gratuitas ou subsidiadas do aplicativo | Cadastro, conteúdo, PIN, mídias e exclusão |
| Bolsa de apoio | Crédito para recursos opcionais ou atendimento parceiro | Uso do crédito e compartilhamento de informações |
| Convênio de cuidado | Acesso voluntário a clínicas, fonoaudiologia ou terapia ocupacional conveniadas | Aceite do profissional, escopo, finalidade e revogação |
| Programa de inclusão | Materiais para responsáveis, gestores e equipes, sem conteúdo clínico individual | Participação e dados pessoais fornecidos |
| Conta institucional separada | Recursos administrativos para o programa de benefícios | Nenhuma visualização automática do perfil da criança |

A primeira versão deve começar pelo **acesso patrocinado**, porque oferece valor à família com menor risco de governança. Convênios clínicos e acompanhamento compartilhado devem ser etapas posteriores.

## Organizações e papéis

A empresa patrocinadora deve ser um tipo de `Organization` diferente de clínica, escola e família. Ela administra elegibilidade do benefício, orçamento, período de cobertura e quantidade de licenças. Ela não administra prontuários, cartões, registros ABC ou mídias.

Os papéis mínimos são:

- **Administrador do benefício:** configura o programa e acompanha somente dados administrativos agregados, como licenças emitidas e período de validade.
- **Colaborador beneficiário:** recebe um convite privado e decide se aceita o benefício. A empresa não deve descobrir o diagnóstico por uma recusa ou ausência de adesão.
- **Responsável familiar:** controla o perfil da criança, o conteúdo e qualquer autorização para terceiros.
- **Clínica ou escola convidada:** acessa somente os recursos explicitamente autorizados pelo responsável, com vínculo e prazo próprios.
- **Suporte técnico:** atende problemas de acesso sem visualizar conteúdo. Qualquer acesso excepcional precisa ser temporário, justificado e auditado.

Não devem existir contas compartilhadas. O convite deve ser individual, expirar e não revelar à empresa quais crianças pertencem a cada colaborador.

## Dados que a empresa pode receber

A empresa pode receber dados necessários para administrar o contrato, como identificador do programa, estado da licença, data de início, data de expiração e informações financeiras do próprio contrato. Ela pode receber métricas agregadas e não identificáveis quando forem necessárias para avaliar o programa.

Por padrão, a empresa não deve receber:

- diagnóstico, nível de suporte ou classificação clínica;
- nome, imagem, voz ou data de nascimento da criança;
- frases, cartões, preferências ou registros de comunicação;
- registros ABC, vídeos, áudios ou relatórios;
- profissionais consultados ou escola frequentada;
- frequência individual de uso ou horários de utilização;
- informação que permita inferir a identidade da criança a partir de um grupo pequeno.

O painel corporativo deve mostrar, no máximo, indicadores administrativos e agregados com limiar mínimo de participantes. O produto não deve criar relatórios de “produtividade”, “evolução” ou “adesão” de uma família para o empregador.

## Fluxo recomendado

1. A empresa contrata o programa e define a quantidade de licenças.
2. O colaborador recebe uma comunicação discreta, sem mencionar diagnóstico ou condição da criança.
3. O colaborador abre uma página de adesão e lê finalidade, dados administrativos, prazo e canal de suporte.
4. A família aceita ou recusa sem consequência funcional ou exposição ao gestor.
5. O sistema cria o benefício, mas mantém os dados de comunicação no dispositivo e na conta familiar.
6. A família pode convidar uma clínica ou escola separadamente.
7. A família pode revogar o benefício ou os vínculos sem perder o controle sobre seus dados locais.
8. No fim do contrato, o benefício expira, mas a família recebe instruções claras sobre exportação e continuidade do uso local.

O benefício corporativo não deve exigir que o colaborador informe o diagnóstico ao gestor. A implementação final do fluxo deve ser revisada por especialistas em privacidade, recursos humanos e inclusão.

## Segurança e consentimento

O benefício corporativo não substitui o consentimento para compartilhamento clínico. O aceite do programa autoriza apenas a administração da licença. Um segundo consentimento, separado e específico, é necessário para qualquer clínica, escola ou profissional.

A autorização deve registrar `sponsorOrganizationId`, `benefitProgramId`, `beneficiaryUserId`, `purpose`, `issuedAt`, `expiresAt`, `revokedAt` e `auditEventId`. O servidor deve aplicar autorização por organização e impedir que um administrador corporativo consulte recursos de uma organização clínica.

O sistema deve negar por padrão qualquer acesso que não tenha finalidade, vínculo e escopo válidos. Exportações e downloads não devem ser permitidos pelo papel corporativo. Mídias devem usar URLs temporárias somente quando o responsável tiver autorizado um destinatário específico.

## Modelo sustentável e acessível

Para manter o preço baixo para famílias, o programa pode usar cobrança por licença ativa, subsídio parcial ou lotes anuais. O produto não deve vender dados nem condicionar o benefício à autorização para publicidade. A empresa paga pelo serviço e pela governança do programa, não pelo acesso ao conteúdo da família.

A contratação deve prever acessibilidade, suporte em linguagem simples, canal para revogação, prazo de retenção, tratamento de incidentes e procedimento de encerramento. Uma empresa não deve ser apresentada como clínica e não deve receber ferramentas para interpretar registros clínicos.

## Fases de implementação

A **Fase 1** deve oferecer licenças patrocinadas, adesão voluntária, painel administrativo mínimo e isolamento total do conteúdo familiar.

A **Fase 2** pode oferecer diretório de parceiros, sempre com convite e autorização independentes. A família escolhe a clínica e os dados compartilhados.

A **Fase 3** pode oferecer tarefas e acompanhamento entre família, clínica e escola. Essa fase exige backend com autorização por recurso, consentimento versionado, auditoria, retenção, exclusão e testes de negação.

A integração não deve começar com prontuário corporativo. O primeiro produto corporativo deve ser um benefício de acesso seguro para a família.

## Referências

[1]: MODELO_AUTORIZACAO_CLINICAS_ESCOLAS.md "Modelo de autorização para clínicas e escolas"
[2]: CHECKLIST_PRE_LANCAMENTO.md "Checklist de pré-lançamento do Fala Comigo"
[3]: ../RELATORIO_PESQUISA_RECURSOS_TEA.md "Relatório de pesquisa sobre recursos para TEA"
