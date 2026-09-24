# Modelo separado: portal RH e benefício familiar

**Status:** decisão arquitetural para protótipo e piloto controlado
**Escopo:** empresas patrocinadoras, administradores de benefícios e famílias
**Regra:** este documento não substitui revisão jurídica, de privacidade ou de recursos humanos.

## 1. Decisão de produto

O Fala Comigo terá duas ofertas independentes para uma empresa:

1. **Portal RH/benefícios:** serviço administrativo para configurar programas, controlar licenças, convites, validade, contrato e indicadores agregados.
2. **Benefício patrocinado à família:** concessão opcional de recursos para uma família, sem dar à empresa acesso ao conteúdo de comunicação, aos dados clínicos ou à atividade individual.

Uma empresa pode contratar somente o portal RH. Nesse caso, ela não recebe nenhuma licença familiar automaticamente e não obtém acesso a qualquer conta, dispositivo ou conteúdo de criança.

Uma empresa pode também patrocinar licenças familiares sem contratar recursos de colaboração clínica. O benefício patrocinado continua separado do portal administrativo.

## 2. Separação técnica

O catálogo comercial deve tratar os recursos como entitlements independentes:

| Produto | Recursos permitidos | Recursos proibidos por padrão |
| --- | --- | --- |
| Portal RH/benefícios | organização, administração de benefício, convites administrativos, validade, suporte administrativo e métricas agregadas | conteúdo familiar, conteúdo clínico, mídia, exportação individual e frequência individual |
| Benefício patrocinado | licença familiar patrocinada, recursos explicitamente contratados e continuidade do núcleo offline | portal RH, administração da organização e relatórios para o empregador |
| Cuidado conectado | vínculos autorizados pela família, com finalidade, escopo, prazo, revogação e auditoria | acesso corporativo automático ou prontuário global |
| Essencial | comunicação local, acessibilidade, controle parental e armazenamento local | recursos remotos pagos |

A presença de uma licença do portal RH não deve liberar `sponsoredLicense`, `careNetwork`, `remoteBackup` ou qualquer dado familiar. A presença de uma licença patrocinada não deve liberar `organizationPortal`, `benefitAdministration` ou `aggregateReporting`.

## 3. Dados administrativos mínimos

O portal RH pode guardar somente o necessário para administrar o contrato e a licença, como:

- identificador da organização patrocinadora;
- identificador do programa;
- identificador técnico do beneficiário, sem diagnóstico;
- estado da licença;
- datas de convite, ativação, validade, transição e revogação;
- quantidade de licenças e valores do contrato;
- eventos de suporte e auditoria administrativa;
- métricas agregadas com limiar mínimo para evitar reidentificação.

O identificador técnico do beneficiário não deve ser apresentado ao gestor como uma ficha de criança ou como uma indicação clínica. O portal não deve permitir busca por nome da criança, diagnóstico, cartão, frase, mídia, escola, clínica ou frequência de uso.

## 4. Dados que não devem sair da família

Por padrão, o portal RH não pode receber:

- diagnóstico, nível de suporte ou classificação clínica;
- nome, imagem, voz ou data de nascimento da criança;
- frases, cartões, preferências ou registros de comunicação;
- registros ABC, vídeos, áudios, relatórios ou documentos;
- profissionais consultados ou escola frequentada;
- horários, frequência individual ou métricas de uso;
- qualquer indicador que permita inferir a identidade da criança em grupo pequeno.

O aceite do benefício patrocinado não é consentimento para compartilhar dados clínicos. Qualquer colaboração com clínica, escola ou profissional exige autorização separada, específica, versionada, com finalidade, escopo, prazo e revogação.

## 5. Fluxo de contratação e adesão

1. A empresa contrata o portal RH, o benefício patrocinado ou ambos.
2. O administrador configura quantidade, período e regras administrativas.
3. O colaborador recebe um convite individual e discreto, sem mencionar diagnóstico.
4. O colaborador aceita ou recusa sem consequência funcional e sem notificação ao gestor sobre a decisão individual.
5. A licença familiar é criada somente após a adesão, quando aplicável.
6. A família usa o aplicativo local e decide se deseja qualquer compartilhamento posterior.
7. A saída do colaborador suspende ou encerra a licença patrocinada, mas não apaga conta, cartões, mídias ou dados locais.
8. A família recebe uma transição clara para o plano Essencial, licença pessoal ou outro patrocinador.

## 6. LGPD e governança

A implementação deve aplicar, desde o protótipo funcional, os princípios de finalidade, adequação, necessidade, segurança, prevenção, não discriminação e responsabilização. A definição de controlador, operador, encarregado, bases legais, retenção e atendimento aos titulares precisa ser revisada com assessoria jurídica e de privacidade antes de produção.

A empresa patrocinadora não deve ser tratada como controladora do conteúdo clínico ou de comunicação da família apenas porque financia uma licença. O contrato deve separar claramente:

- administração do programa e faturamento;
- operação técnica da plataforma;
- conteúdo familiar local;
- eventual compartilhamento autorizado com profissionais ou escolas.

O sistema deve manter trilhas de auditoria para convites, alterações de licença, acessos administrativos, exportações e revogações. Não deve registrar conteúdo clínico em logs de suporte. Métricas agregadas só podem ser mostradas quando houver quantidade mínima de participantes e baixo risco de reidentificação.

## 7. Critérios de aceite antes de backend real

- Uma licença apenas de portal RH não libera qualquer dado familiar.
- Uma licença patrocinada não libera o painel administrativo da organização.
- Recusar o benefício não revela diagnóstico ou uso ao empregador.
- Revogar ou expirar a licença não bloqueia comunicação offline.
- Encerrar o vínculo empregatício não apaga dados locais.
- O patrocinador não consegue exportar mídia ou conteúdo individual.
- Cada convite é individual, expira e pode ser revogado.
- Qualquer acesso de suporte é temporário, justificado e auditado.
- Testes negativos cobrem organização, papel, finalidade, escopo, prazo e consentimento inválidos.
- Os dados sintéticos do protótipo não são tratados como prova de conformidade jurídica ou clínica.

## 8. Ordem segura de implementação

1. Modelar entitlements independentes no catálogo local.
2. Testar negações entre portal RH e benefício familiar.
3. Criar protótipo do console RH sem conteúdo clínico.
4. Definir contrato de identidade, organização, convite, licença e auditoria.
5. Implementar backend multi-organização com autorização no servidor.
6. Simular pagamentos e reembolsos em sandbox, sem cobrança real.
7. Fazer revisão de privacidade, LGPD, contratos e suporte.
8. Executar piloto com dados sintéticos antes de qualquer sincronização real.

A comunicação CAA offline permanece fora desse ciclo comercial e nunca pode depender da assinatura da empresa, de login, de internet ou da continuidade do vínculo empregatício.
