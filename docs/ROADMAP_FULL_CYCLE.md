# Fala Comigo — Roadmap Full-Cycle

## Propósito

Este documento transforma a visão do Fala Comigo em um plano de execução incremental. O objetivo é evoluir o produto sem perder a premissa central: a criança deve conseguir se comunicar com previsibilidade, enquanto a família mantém controle sobre seus dados e sobre qualquer compartilhamento.

O roadmap separa o aplicativo local-first do portal conectado. A comunicação básica não dependerá de internet. Recursos clínicos, educacionais e corporativos somente serão ativados quando houver um servidor com autorização por recurso, consentimento compreensível, auditoria e isolamento entre organizações.

A estratégia financeira complementar está documentada em [`MODELO_CUSTOS_E_PLANOS.md`](MODELO_CUSTOS_E_PLANOS.md). Ela prioriza um núcleo gratuito e offline, serviços conectados sob demanda, planos acessíveis e aquisição do domínio somente na etapa de lançamento público.

## Estado atual

A branch `main` contém uma base Flutter multiplataforma com suporte de projeto para Android, iOS, Web, Windows, macOS e Linux. A implementação existente inclui a grade de comunicação, cartões com mídia, montagem de frases, síntese de voz, área parental, PIN protegido, sessão parental, armazenamento local cifrado, registros ABC, diário de vídeo, alertas de transição, exportação minimizada e exclusão local.

O GitHub Actions executa formatação, análise estática, verificação da política de assinatura e testes automatizados. O último CI observado para a `main` foi concluído com sucesso no commit `299cb9e`.

A validação local neste ambiente ainda depende da instalação do Flutter. Portanto, o CI é a evidência atual para as verificações automatizadas, enquanto os testes de experiência e acessibilidade continuam dependendo de dispositivos reais.

## Princípios de engenharia

1. **Offline-first:** a criança deve continuar usando a comunicação sem internet, login ou acesso à Área do Responsável.
2. **Privacidade por padrão:** dados, mídias, registros e credenciais permanecem locais até uma escolha explícita de compartilhamento.
3. **Negações são requisitos:** cada recurso protegido precisa de testes que comprovem o bloqueio de acessos indevidos.
4. **Acessibilidade é funcionalidade:** tamanho dos alvos, foco, semântica, contraste, áudio e ausência de surpresas serão tratados como critérios de aceite.
5. **Escopo mínimo:** profissionais, escolas e patrocinadores recebem somente o mínimo necessário para uma finalidade autorizada.
6. **Sem promessas clínicas:** o produto apoia comunicação e organização do cuidado, mas não diagnostica, mede valor da criança nem promete evolução terapêutica.
7. **Entrega reversível:** mudanças serão feitas em branches, com testes, revisão e histórico claro antes de chegar à `main`.

## Fases de entrega

### Fase 0 — Base de produto e engenharia

A primeira fase organiza o trabalho antes de ampliar o escopo. Ela inclui inventário de telas e fluxos, matriz de requisitos, instalação reprodutível, cobertura mínima de testes e uma decisão explícita sobre a arquitetura do portal web.

**Critérios de aceite:** qualquer colaborador consegue preparar o projeto; os fluxos críticos estão documentados; cada risco conhecido possui uma issue ou tarefa; a `main` permanece reproduzível pelo CI.

### Fase 1 — Experiência CAA confiável

Esta fase aperfeiçoa o que a criança usa diretamente. O foco será tornar a grade previsível, rápida e personalizável, com cartões, categorias, frase, voz e modos de toque coerentes em telas pequenas e grandes.

O trabalho deverá incluir testes de interação, persistência, estados vazios, falhas de mídia, rotação suportada, escalonamento de texto, TalkBack e VoiceOver. A experiência não deve exigir que a criança atravesse a Área do Responsável para comunicar-se.

**Critérios de aceite:** os fluxos principais funcionam offline; uma falha de permissão ou mídia não encerra o app; os controles importantes têm semântica acessível; a configuração parental não altera acidentalmente o modo de comunicação em uso.

### Fase 2 — Área familiar e validação de campo

Esta fase consolida configurações, perfil, registros ABC, diário de mídia, alertas de transição, exportação e exclusão. Também prepara um roteiro de teste com famílias, usuários de CAA e profissionais com experiência em TEA e comunicação alternativa.

Nenhum dado real de criança deverá entrar em issues, commits, screenshots ou testes automatizados. Os testes de campo devem avaliar compreensão, tempo de resposta, sobrecarga, previsibilidade, recuperação após interrupções e controle familiar.

**Critérios de aceite:** os fluxos críticos têm casos de sucesso, erro e cancelamento; a exportação informa o escopo; a exclusão explica seus limites; a política de privacidade corresponde ao comportamento real.

### Fase 3 — Portal web seguro

O portal será uma superfície separada de administração e cuidado conectado. Ele não deverá transformar caixas locais em um prontuário compartilhado nem conceder acesso por papel de forma global.

O backend deverá modelar usuário, organização, vínculo, relação com a criança, papel, permissão, finalidade, consentimento, retenção e auditoria. Toda leitura, gravação, exportação, convite, download de mídia e alteração de consentimento deverá ser autorizada no servidor.

A primeira entrega web recomendada é um portal administrativo de baixo risco, com organizações e convites individuais. O compartilhamento de registros clínicos e mídias ficará bloqueado até que os testes de autorização negativa estejam implementados.

**Critérios de aceite:** isolamento entre organizações; consentimento versionado; revogação imediata; convites com expiração; URLs temporárias para mídia; auditoria mínima; testes que comprovem negação para organização, papel, finalidade, consentimento e prazo inválidos.

### Fase 4 — Benefício corporativo responsável

O benefício corporativo deverá começar por licenças patrocinadas, adesão voluntária e painel administrativo mínimo. A empresa poderá administrar licença, período e métricas agregadas, mas não terá acesso automático ao conteúdo familiar.

A troca ou encerramento do vínculo empregatício não deverá apagar conta, mídias ou dados locais. O fluxo deverá oferecer transição clara para conta pessoal, outro patrocinador ou encerramento voluntário.

**Critérios de aceite:** o empregador não consegue inferir diagnóstico ou uso individual; a licença possui estados claros; a família mantém o modo offline; a revogação administrativa não apaga conteúdo familiar; os eventos administrativos são auditáveis.

### Fase 5 — Publicação, suporte e evolução

Antes do lançamento amplo, serão necessários build assinado, política de privacidade publicada, suporte definido, resposta a incidentes, processo de exclusão e teste fechado. A operação deverá acompanhar falhas técnicas sem coletar conteúdo sensível desnecessário.

**Critérios de aceite:** o pacote de distribuição é reproduzível; permissões estão revisadas; o checklist de pré-lançamento está preenchido; existe canal de suporte; os limites clínicos e legais estão explícitos; o plano de rollback foi testado.

## Backlog priorizado

| Prioridade | Entrega | Motivo | Dependência |
| --- | --- | --- | --- |
| P0 | Instalar Flutter no ambiente de desenvolvimento e reproduzir CI localmente | Reduz o risco de alterar sem validação local | Ambiente |
| P0 | Criar matriz dos fluxos críticos do app | Define o que precisa ser testado antes de novas telas | Fase 0 |
| P0 | Expandir testes de domínio e serviços | Protege segurança, persistência, exclusão e exportação | Fase 1 |
| P0 | Testar a experiência em Android e tablet | O uso real não pode ser inferido somente pelo CI | Dispositivos |
| P1 | Revisar acessibilidade da grade e dos cartões | Comunicação é o núcleo do produto | Fase 1 |
| P1 | Melhorar estados de erro, vazio e recuperação | Evita bloqueios em momentos de necessidade | Fase 1 |
| P1 | Definir contrato do backend e modelo de autorização | Impede que o portal comece com regras frágeis | Fase 3 |
| P1 | Protótipo navegável do portal sem dados clínicos | Valida papéis e fluxos com baixo risco | Fase 3 |
| P2 | Implementar organizações, convites e consentimentos no servidor | Base para cuidado conectado | Fase 3 |
| P2 | Implementar benefício corporativo patrocinado | Expande acesso sem expor conteúdo familiar | Fase 4 |
| P3 | Sincronização seletiva de registros e mídias | Alto risco; só após autorização e testes negativos | Fases 3 e 4 |

## Primeiro ciclo de implementação

O primeiro ciclo depois deste roadmap deve entregar uma matriz executável dos fluxos críticos e ampliar a cobertura de testes dos serviços que protegem dados. Em seguida, a equipe poderá corrigir os bloqueadores encontrados sem misturar validação do produto com a construção prematura do portal.

Cada mudança deverá seguir este fluxo:

```text
issue clara → branch de trabalho → implementação pequena → testes → análise → revisão do diff → commit → push → Pull Request
```

A `main` somente receberá alterações que tenham evidência adequada para o risco envolvido. Para recursos de segurança, privacidade ou autorização, a evidência deverá incluir testes de negação, não apenas o caminho feliz.

## Definição de pronto

Uma entrega só será considerada pronta quando o comportamento estiver implementado, documentado, testado no nível apropriado e revisado contra acessibilidade e privacidade. A existência de uma tela não será considerada evidência de que o fluxo está seguro ou adequado para uso por famílias.

## Referências

[1]: ../README.md "README do aplicativo Fala Comigo"
[2]: CHECKLIST_PRE_LANCAMENTO.md "Checklist de pré-lançamento do Fala Comigo"
[3]: MODELO_AUTORIZACAO_CLINICAS_ESCOLAS.md "Modelo de autorização para clínicas e escolas"
[4]: MODELO_BENEFICIO_CORPORATIVO_PCD.md "Modelo de benefício corporativo para pessoas com deficiência"
