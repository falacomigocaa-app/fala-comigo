# Revisão de Produto do MVP — Fala Comigo

**ID:** 01-01  
**Papel:** Product Manager  
**Data:** 24 de setembro de 2026  
**Escopo da revisão:** handoff, instruções do repositório, relatórios de build e segurança, checklists, matriz de fluxos e código do caminho de inicialização e da comunicação CAA.

## Decisão executiva

O escopo do Fala Comigo está coerente com um **MVP local-first de Comunicação Aumentativa e Alternativa (CAA)**: a comunicação básica deve funcionar sem conta, internet ou plano pago. O repositório já contém uma base ampla para esse objetivo, incluindo grade de pictogramas, montagem de frases, voz, cartões personalizados e área protegida do responsável [1] [3].

A recomendação é **manter o escopo local/offline congelado e não iniciar backend, portal RH, sincronização clínica, cobrança ou publicação ampla**. O APK instala, mas o fechamento ao abrir permanece um bloqueador P0 de experiência. Há evidência de compilação, testes automatizados e geração de artefatos, mas não há evidência suficiente de que uma instalação limpa funcione em aparelho físico. A causa do fechamento não deve ser atribuída a TTS, notificações, Hive ou outro componente sem logcat do aparelho; esses itens são hipóteses de investigação [4] [5].

Portanto, o produto deve ser tratado agora como **MVP técnico para validação controlada**, e não como versão pronta para piloto com dados reais ou distribuição comercial.

## Escopo avaliado

### Núcleo que pertence ao MVP

O núcleo mínimo recomendado é composto por quatro resultados de usuário:

1. **Abrir e comunicar:** uma instalação limpa chega à grade CAA sem exigir cadastro, assinatura ou conexão.
2. **Montar e falar:** a pessoa usuária seleciona cartões, filtra categorias, monta e limpa frases e usa os modos falar, adicionar ou falar + adicionar.
3. **Continuar offline:** cartões padrão, frase e voz disponível ou fallback compreensível continuam utilizáveis sem internet.
4. **Permitir cuidado responsável:** o adulto acessa configurações mediante PIN, tem sessão protegida, consegue administrar cartões e pode excluir os dados locais.

Esse recorte está alinhado à regra de produto do handoff e às prioridades do repositório: primeiro evitar interrupções da comunicação, depois proteger privacidade e armazenamento, e só então ampliar acessibilidade, cobertura e operação [1] [2].

### Funcionalidades implementadas, mas ainda não validadas como prontas

O código e a documentação também apresentam diário de vídeo, registros ABC e exportação, alertas de transição, rotinas visuais, lembretes, tendências, recompensas e estados locais de licença. Esses recursos podem compor um **MVP ampliado**, mas adicionam câmera, microfone, notificações, alarmes, arquivos, PDF e múltiplos estados de ciclo de vida. A existência de telas, serviços ou testes de domínio não equivale à validação do fluxo completo em aparelho [1] [7].

Minha recomendação de produto é não usar esses módulos para bloquear a primeira validação do caminho de comunicação. Eles devem entrar no gate do piloto somente quando houver evidência manual específica, ou permanecerem fora do primeiro pacote controlado. O vídeo diário, em particular, não é necessário para provar o valor central de comunicação e aumenta a superfície de privacidade.

### Fora do MVP atual

Backend conectado, portal multi-organização, autenticação remota, autorização server-side, sincronização clínica, cobrança real, painel corporativo de produção e publicação comercial estão explicitamente fora do pacote atual [1] [3]. Contratos, modelos e testes locais de RH são preparação de produto futuro; não devem ser apresentados como implementação conectada.

## Fatos observados

### 1. O pipeline de build não prova execução em Android

Os relatórios do projeto registram Flutter 3.38.0, análise sem falha bloqueadora, 84 testes, build Web, APK debug, APK release, AAB release e build limpa concluídos. O workspace também contém os artefatos atuais: APK debug de aproximadamente 159 MB, APK release de aproximadamente 57 MB e AAB release de aproximadamente 45 MB. A diferença entre Debug e Release é esperada e não é evidência de que recursos tenham sido removidos [3] [4] [5].

Isso prova uma linha de empacotamento reproduzível, não a experiência de abertura no aparelho do usuário. Não executei novamente a suíte nesta revisão; a contagem de 84 testes é a evidência registrada nos relatórios atuais.

### 2. O fechamento ao abrir é um incidente real, mas a causa não está identificada

O handoff e os relatórios registram que o APK instala, tenta abrir e fecha no telefone físico. O próprio material de continuidade afirma que ainda é necessário logcat do aparelho. Não existe, nesta revisão, um logcat que permita confirmar exceção, componente, versão do Android ou momento exato da falha [1] [4] [5].

O AVD da Manus não deve ser usado como reprodução do problema do aplicativo: o serviço `package` e o `system_server` do próprio emulador foram encerrados antes da instalação. Isso caracteriza uma limitação do ambiente, não uma execução válida do Fala Comigo [4].

### 3. O caminho crítico de inicialização ainda executa operações relevantes antes da tela principal

Em `lib/main.dart`, `runApp` é chamado cedo e há uma tela de carregamento/falha para erros Dart. Entretanto, `_bootstrapApp` ainda precisa, antes de marcar o app como pronto, travar orientação, inicializar Hive, registrar o adapter, abrir ou migrar as caixas cifradas de cartões, configurações e alertas, inicializar o diagnóstico e popular cartões padrão [10].

TTS e notificações foram movidos para depois da primeira tela e possuem captura independente de exceções. Essa é uma mitigação estrutural útil, mas não comprova que TTS ou notificações eram a causa original. Um crash nativo anterior ao Flutter continua fora do alcance da tela de fallback [5] [10].

### 4. A cobertura automatizada da abertura é limitada

O teste `splash_screen_test.dart` verifica a renderização da splash e a navegação para um destino após o tempo previsto. Ele não testa `MainActivity`, Android Keystore, migração de Hive, plugins nativos, instalação limpa, atualização sobre versão anterior, permissões ou execução em um dispositivo físico [11].

O checklist de execução mantém sem validação os fluxos de primeira abertura, cartões offline, frase, TTS, orientação, acessibilidade, PIN, sessão, mídia, alertas, exclusão e os testes de celular e tablet [6]. A matriz de fluxos classifica esses itens como parciais ou pendentes manuais [7].

### 5. Há risco de confusão de baseline documental

O workspace atual está na branch `work/qa-observability-and-emulator`, no commit `c8fcab1`, enquanto documentos recentes ainda citam commits de etapas anteriores, como `40d9e53`, `5741575` e uma matriz histórica com 46 testes. O handoff reconhece que linhas antigas devem ser lidas como histórico, mas a divergência ainda pode fazer uma equipe tomar decisão com números ou estado incorretos [1] [5] [7].

### 6. O APK de teste ainda não é um artefato de produção

A release local foi gerada com chave temporária de diagnóstico. A keystore de produção deve permanecer fora do Git e ser fornecida pelo fluxo protegido de distribuição. O AAB existente, portanto, não é evidência de prontidão para publicação [3] [4].

### 7. Segurança e governança ainda são gates de distribuição

A varredura MobSF do APK release de teste registrou score 46, dois achados altos, cinco warnings e um hotspot de permissões. Os achados altos incluem CBC com PKCS5/PKCS7 associado ao armazenamento Hive e `minSdk=24`; também há itens para revisar em receiver, arquivos temporários, armazenamento externo, strings e permissões [9].

Isso não invalida automaticamente o MVP local para uma validação técnica controlada, mas bloqueia a apresentação do APK como aprovado para distribuição ampla. Ainda faltam decisão de produto sobre `minSdk`, decisão técnica de migração/autenticidade do armazenamento, nova varredura, análise dinâmica e revisão manual MASVS/MASTG [6] [9].

## Riscos e hipóteses

### Riscos confirmados ou diretamente evidenciados

| Prioridade | Risco | Impacto de produto | Estado |
|---|---|---|---|
| P0 | O app fecha ao abrir no aparelho físico | Impede o primeiro valor: comunicação imediata | Bloqueia o gate de MVP executável |
| P0 | A causa do fechamento não tem logcat | Correções podem ser feitas por tentativa e aumentar regressão | Diagnóstico inconclusivo |
| P0 | Fluxos críticos Android não têm evidência manual | Build verde pode mascarar falha em ciclo de vida, permissões ou plugins | Gate pendente |
| P1 | MVP amplo inclui mídia, alertas, PDF, licença e tendências | Aumenta superfície de falha e custo de validação antes de provar o núcleo | Recomenda-se separar por prioridade |
| P1 | Achados MobSF altos e assinatura temporária | Risco de distribuição insegura ou decisão falsa de prontidão | Bloqueia release público |
| P1 | Baselines documentais divergentes | Relatórios e decisões podem usar evidência histórica | Precisa de fonte única |
| P1 | A experiência está travada em paisagem | Pode limitar aparelhos e uso em contextos reais | Requer validação de compatibilidade |

### Hipóteses que não devem ser tratadas como diagnóstico

As hipóteses abaixo vêm da análise registrada, mas precisam ser testadas com evidência do aparelho:

1. **Falha em armazenamento seguro ou migração Hive:** o serviço abre/migra caixas cifradas antes de o app ser marcado como pronto. Dados antigos incompatíveis ou uma chave indisponível poderiam interromper esse caminho.
2. **Falha nativa de plugin ou integração Android:** TTS e notificações já foram postergados, mas câmera, armazenamento seguro, orientação e outros componentes ainda participam da inicialização ou do primeiro fluxo.
3. **Estado antigo da instalação:** dados legados, atualização sobre outra assinatura ou resíduos de uma versão anterior podem alterar o comportamento.
4. **Incompatibilidade específica de Android, fabricante ou API:** `minSdk=24`, modelo do telefone e versão do Android podem influenciar plugins e armazenamento.
5. **Falha depois da inicialização:** o processo pode chegar à primeira tela e encerrar em um widget ou serviço acionado logo após a navegação.

Sem logcat, qualquer uma dessas hipóteses tem confiança baixa para causalidade. Não há base para afirmar que o problema é TTS, notificações, Hive, tamanho do APK ou o AVD.

## Ações recomendadas

### P0 — recuperar o primeiro valor

1. **Reproduzir em um aparelho físico com instalação limpa.** Desinstalar a versão anterior, reiniciar o aparelho, instalar o APK release mais recente, abrir offline e registrar fabricante, modelo, versão/API, versão do APK e horário aproximado. O critério de aprovação é chegar à grade CAA e permanecer utilizável.
2. **Se fechar novamente, coletar o logcat do próprio aparelho imediatamente.** Filtrar por `AndroidRuntime`, `FATAL EXCEPTION`, `flutter`, `libc`, `system_server` e o pacote do app. Não registrar nomes, frases, fotos, vídeos, tokens ou outros dados de criança. Sem esse artefato, manter a causa como desconhecida.
3. **Executar uma matriz mínima em celular e tablet.** Validar primeira abertura, grade offline, seleção de cartão, frase, fala/fallback, retorno do segundo plano, PIN e sessão. O APK não deve avançar para piloto se F01–F07, F21 ou F22 continuarem pendentes [7].
4. **Definir o critério de “primeiro build funcional” como experiência, não como compilação.** O gate precisa exigir abertura limpa, comunicação offline e recuperação compreensível de falhas; build, testes e análise são pré-requisitos, não substitutos [1] [8].

### P1 — reduzir risco e fechar o MVP controlado

5. **Congelar o escopo em duas camadas.** Tratar comunicação, frase, voz/fallback, PIN/sessão, persistência, exclusão e acessibilidade básica como núcleo. Tratar vídeo, ABC/PDF, alertas, tendências, recompensas e licença local como módulos condicionados à validação manual, sem deixar que documentos futuros pareçam promessas de produção.
6. **Atualizar uma fonte única de verdade.** Alinhar branch, commit, número de testes, artefato testado e estado dos gates em `PROJECT_HANDOFF.md`, checklist e matriz. Marcar números antigos como históricos ou removê-los da seção de estado atual.
7. **Fechar segurança antes de distribuição ampla.** Decidir `minSdk` com uma matriz real de aparelhos; revisar Hive/CBC e migração sem perda; revisar receiver, permissões e arquivos temporários; repetir MobSF; executar análise dinâmica e revisão manual MASVS/MASTG [6] [9].
8. **Concluir o contrato operacional de diagnóstico.** Aprovar consentimento, retenção, acesso e descarte dos relatórios locais. Instruir o piloto para compartilhar apenas relatório técnico sanitizado e passos de reprodução.
9. **Não iniciar backend ou RH como resposta ao incidente Android.** O fechamento do APK é um problema de estabilidade do app local; portal, sincronização e cobrança adicionariam risco sem resolver o gate do núcleo.

### Critério de saída do próximo gate

O MVP pode ser promovido a **teste controlado técnico** quando houver evidência de abertura limpa e uso offline em pelo menos um celular e um tablet, os fluxos F01–F07 estiverem verdes, o responsável conseguir concluir PIN/sessão e exclusão, e não houver bloqueador de comunicação. Para **piloto com dados reais** ou **publicação**, ainda são obrigatórios os gates de segurança, privacidade, acessibilidade, suporte, incidentes, assinatura de produção e governança previstos nos checklists [6] [8] [9].

## Confiança da análise

A confiança é **alta** para o enquadramento do produto como MVP local-first, para a inexistência de backend/cobrança real e para a diferença entre evidência de build e evidência de execução. A confiança é **alta** para afirmar que a causa do fechamento permanece não determinada, pois o próprio handoff exige logcat. A confiança é **média** para a recomendação de retirar temporariamente módulos periféricos do gate do MVP: trata-se de decisão de gestão de escopo, não de uma ausência de implementação. A confiança é **baixa** para qualquer hipótese específica de causa do crash até existir logcat do aparelho.

**Nenhum código foi alterado nesta revisão.**

## Referências

[1]: ../../PROJECT_HANDOFF.md "Documento de transferência do projeto Fala Comigo"
[2]: ../../AGENTS.md "Instruções de desenvolvimento do Fala Comigo"
[3]: ../ENTREGA_MVP_2026-09-24.md "Entrega do MVP Fala Comigo"
[4]: ../RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md "Diagnóstico de build e instalação Android"
[5]: ../AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md "Auditoria do handoff e artefatos Android"
[6]: ../CHECKLIST_EXECUCAO_E_TESTES.md "Checklist de execução, testes e prontidão"
[7]: ../MATRIZ_FLUXOS_CRITICOS.md "Matriz de fluxos críticos"
[8]: ../PLANO_SEQUENCIAL_ATE_BUILD.md "Plano sequencial até o build"
[9]: ../../security/reports/MOBSF_2026-09-24.md "Relatório MobSF do APK release de teste"
[10]: ../../lib/main.dart "Inicialização e bootstrap do aplicativo"
[11]: ../../test/splash_screen_test.dart "Teste automatizado da tela de abertura"
[12]: ../../android/app/src/main/AndroidManifest.xml "Manifest Android, permissões e receivers"
[13]: ../../lib/features/aac_grid/presentation/screens/aac_grid_screen.dart "Tela principal da grade CAA"
[14]: ../../lib/features/aac_grid/data/providers/cards_provider.dart "Estado de cartões e montagem de frases"
