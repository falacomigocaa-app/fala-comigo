# Revisão Scrum Master — estabilidade do APK e gate do MVP

**ID:** 02-02  
**Papel:** Scrum Master  
**Data:** 24 de setembro de 2026  
**Escopo:** backlog, critérios de aceite, handoff, instruções do repositório, relatórios de build/segurança, checklists, matriz de fluxos e caminho de inicialização Flutter/Android.  
**Decisão:** **gate P0 bloqueado para declarar o MVP executável em Android**. O próximo ciclo deve ser de evidência e diagnóstico em aparelho real; não deve iniciar backend, portal RH, cobrança ou publicação ampla.

## Resumo executivo

O projeto tem um pipeline de engenharia com evidência registrada de formatação, análise estática, 84 testes Flutter, build Web, APK debug, APK release, AAB release e build limpa. Isso demonstra que a linha de empacotamento reproduzida compila; **não demonstra que o aplicativo abre e permanece utilizável em Android**.

O fato operacional relevante é que o APK instala, mas fecha ao abrir no telefone, conforme o relato do solicitante e o handoff/relatórios. Nesta revisão **não foi fornecido nem localizado um logcat do aparelho**. Portanto, a causa do encerramento permanece desconhecida. Não há base para atribuí-lo a TTS, notificações, Hive, tamanho do APK, fabricante, API ou ao emulador.

O backlog deve ser reordenado em torno de um único objetivo de Sprint: **provar abertura limpa e comunicação offline em pelo menos um celular e um tablet Android, com evidência sanitizada**. Até esse objetivo ser atingido, o critério de “build funcional” não está satisfeito. Build, testes automatizados e análise são pré-requisitos importantes, mas não substituem teste de experiência em dispositivo.

## Baseline e fonte de verdade

Na sessão desta revisão, o checkout observado foi `work/qa-observability-and-emulator`, em `c8fcab1` (`feat: finalize MVP startup and delivery package`). Os documentos, porém, citam vários pontos históricos ou operacionais — `40d9e53`, `5741575`, `40d9e53` no handoff e referências anteriores a `46` testes — enquanto o estado mais recente registrado aponta `84` testes. O handoff já recomenda tratar essas linhas antigas como histórico, mas a divergência ainda é um risco de coordenação.

A fonte de verdade do próximo ciclo deve registrar, no mesmo lugar, **branch, commit, SHA/artefato testado, versão do app, contagem de testes, dispositivo/API, conectividade, resultado e evidência**. Sem isso, a equipe pode fechar um item com um APK diferente daquele que foi instalado no aparelho.

## Fatos com evidência

1. **A compilação está verde nos relatórios consultados.** `docs/RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md` registra Flutter 3.38.0, Dart 3.10.0, Android SDK 36, análise sem falha bloqueadora, 84 testes e builds Web/APK/AAB concluídos. O workspace também contém `build/app/outputs/flutter-apk/app-release.apk` e `build/app/outputs/bundle/release/app-release.aab`. Isso é evidência de build, não de execução em aparelho.

2. **O fechamento no Android físico é um bloqueador de produto.** O primeiro valor do produto é abrir a grade CAA e comunicar sem conta, internet ou plano. Se o processo fecha na abertura, F01 e o núcleo de comunicação não podem ser considerados aceitos, independentemente da existência de telas ou testes de domínio.

3. **Não existe diagnóstico causal confirmado.** O relatório de build informa que a tentativa no AVD falhou porque o próprio serviço `package`/`system_server` do emulador morreu antes da instalação. Isso não é reprodução válida do app. O telefone físico precisa fornecer o logcat do próprio aparelho se o fechamento persistir.

4. **O caminho Dart de inicialização tem captura de falhas, mas ainda possui trabalho antes da interface pronta.** Em [`lib/main.dart`](../../lib/main.dart#L33-L169), `runApp` é chamado cedo e há captura de erros Dart/Flutter; entretanto, `_bootstrapApp` ainda executa bloqueio de orientação, `Hive.initFlutter`, registro do adapter, abertura/migração de três caixas protegidas, inicialização do diagnóstico e semeadura de cartões antes de marcar o estado como pronto. TTS e notificações foram adiados e têm captura própria. Isso é uma mitigação estrutural, não prova da causa original.

5. **O fallback de diagnóstico tem limite conhecido.** A tela `StartupFailureApp` só ajuda quando o processo chega ao Flutter e consegue renderizá-la. Um crash nativo anterior ao Flutter, em plugin, Android Keystore ou componente do processo, não pode ser confirmado por essa tela; requer logcat do dispositivo.

6. **A validação dos fluxos críticos Android ainda está pendente.** O checklist mantém sem validação manual a instalação limpa, grade offline, frase, fala/fallback, orientação, PIN, sessão, mídia, alertas, exclusão e acessibilidade. A matriz classifica F01–F07 como parciais e F21/F22 como pendentes manuais; os testes automatizados não cobrem `MainActivity`, instalação limpa, ciclo de vida e plugins em aparelho real.

7. **Os critérios de pré-lançamento explicitamente exigem celular e tablet.** O [`CHECKLIST_PRE_LANCAMENTO.md`](../CHECKLIST_PRE_LANCAMENTO.md#L23-L35) requer validação em pelo menos um celular e um tablet, offline, com permissões concedidas e negadas. O critério do primeiro build no [`PROJECT_HANDOFF.md`](../../PROJECT_HANDOFF.md#L156-L172) também exige abertura da grade, comunicação offline, proteção parental, persistência, tratamento de falhas e teste Android antes de publicação.

8. **Segurança e assinatura ainda são gates de distribuição, não diagnóstico do crash.** O MobSF registrou score 46, dois achados altos, warnings e hotspot de permissões; o APK analisado foi assinado com chave efêmera de teste. CBC/PKCS5/PKCS7, `minSdk=24`, receiver, armazenamento externo, arquivos temporários e permissões ainda requerem decisão/revisão. Esses fatos bloqueiam distribuição ampla, mas não permitem afirmar que são a causa do fechamento na abertura.

9. **O código aplica orientação exclusivamente paisagem e declara várias permissões/receivers Android.** O Manifest fixa `screenOrientation="landscape"` e declara câmera, imagens, áudio, notificações, tela cheia, alarme exato e boot; também há receivers de notificações. Isso amplia a matriz de compatibilidade e precisa ser validado em hardware, mas não é evidência de crash.

10. **O escopo futuro está maior que o gate do núcleo.** Vídeo, ABC/PDF, alertas, rotinas, tendências, recompensas, licença local, portal RH, backend e cobrança possuem documentação/código parcial ou local, mas não devem ser tratados como produção nem bloquear a prova do núcleo CAA. O checklist do piloto RH continua explicitamente em preparação e bloqueado sem backend real, isolamento, revisão LGPD e governança.

## Riscos, separados de hipóteses

### Riscos confirmados ou diretamente evidenciados

| Prioridade | Risco | Impacto | Estado de Scrum |
|---|---|---|---|
| P0 | O APK fecha ao abrir no telefone | Impede comunicação imediata e invalida F01 | Bloqueador do gate Android |
| P0 | Não há logcat do aparelho | Diagnóstico e correção podem virar tentativa e erro | Aguardando evidência mínima |
| P0 | F21/F22 e F01–F07 não têm evidência manual completa | Build verde pode mascarar falhas de ciclo de vida, plugin, orientação ou acessibilidade | Não pronto |
| P1 | Branch/commit e números de testes divergem entre documentos | Risco de testar e decidir sobre artefatos diferentes | Necessita fonte única |
| P1 | APK de teste usa assinatura temporária | Não é artefato de publicação | Bloqueia distribuição pública |
| P1 | MobSF tem achados altos e decisões pendentes | Risco de segurança/compatibilidade em distribuição | Gate de segurança aberto |
| P1 | Backlog mistura núcleo CAA com módulos de maior superfície | WIP alto, difícil triagem e maior risco de regressão | Requer fatiamento |
| P1 | Orientação, permissões e receivers ainda não foram observados em matriz real | Pode afetar compatibilidade e compreensão do uso | Validação manual necessária |
| P2 | Checklist e continuidade contêm registros históricos não claramente separados em todas as seções | Pode gerar falsa impressão de prontidão ou atraso | Higienização documental |

### Hipóteses de investigação — baixa confiança, não diagnósticos

As hipóteses abaixo são apenas caminhos para a coleta de evidência. **Nenhuma deve ser registrada como causa até haver logcat e reprodução controlada.**

1. **Armazenamento seguro/Hive/migração:** a abertura ou migração de caixas cifradas ocorre antes do estado pronto; chave indisponível, dados incompatíveis ou caixa legada podem ser relevantes.
2. **Plugin ou componente nativo:** apesar de TTS e notificações terem sido adiados, armazenamento seguro, orientação, receivers ou outro plugin podem falhar em determinada API/fabricante.
3. **Estado persistido da instalação:** dados antigos, atualização sobre versão anterior ou resíduos de instalação podem alterar o caminho de bootstrap.
4. **Incompatibilidade de aparelho/API:** `minSdk=24`, fabricante, versão do Android, política de energia ou implementação do Keystore podem influenciar o resultado.
5. **Falha logo após a primeira tela:** o processo pode chegar à UI e encerrar em widget, navegação, provider ou serviço acionado no primeiro frame.

Não há evidência suficiente para priorizar uma dessas hipóteses sobre as demais. Em particular, o tamanho menor do APK release em relação ao debug é esperado e **não** é evidência de recursos ausentes.

## Avaliação do backlog e dos critérios

O backlog técnico tem uma sequência coerente até o build, mas o incidente mudou a prioridade: a etapa de validação Android deixou de ser uma atividade posterior e passou a ser o caminho crítico. A equipe não deve continuar avançando em itens de produto periféricos enquanto não souber se o pacote abre em hardware real.

### Sprint recomendado: recuperar o primeiro valor

**Objetivo:** obter uma execução observável, limpa e reproduzível do APK release em um celular e um tablet Android, offline, sem dados reais.

| Ordem | Item | Prioridade | Critério de aceite |
|---|---|---:|---|
| 1 | Fixar artefato e baseline | P0 | Branch/commit, versão, SHA e caminho do APK registrados; todos os participantes usam o mesmo artefato |
| 2 | Reproduzir em celular | P0 | Desinstalação limpa, reinício, instalação, abertura sem internet e chegada à grade CAA permanecendo utilizável |
| 3 | Coletar diagnóstico se fechar | P0 | Logcat do aparelho no horário da tentativa, filtrado e sanitizado; sem nomes, frases, mídia ou tokens |
| 4 | Validar F01–F07 | P0 | Grade, cartões/categorias, modos de toque, frase, cartão personalizado, PIN e sessão executados com evidência |
| 5 | Repetir em tablet | P0 | F21/F22 verdes, incluindo orientação, responsividade, toque e retorno do segundo plano |
| 6 | Atualizar fonte única | P0 | Handoff, checklist e matriz com o mesmo estado; pendências e históricos rotulados |
| 7 | Fechar segurança de distribuição | P1 | Decisões sobre CBC/migração e `minSdk`, revisão de Manifest/permissões, novo MobSF e assinatura de produção protegida |
| 8 | Retomar módulos ampliados | P1/P2 | Somente depois do núcleo verde; cada módulo entra com evidência manual própria |

### Definição de pronto para o próximo gate

O item “MVP Android executável” só pode ser fechado quando houver, no mínimo:

- abertura limpa em um celular e um tablet reais;
- grade CAA e cartões padrão utilizáveis offline;
- montagem, remoção e limpeza de frase;
- fala ou fallback compreensível sem encerrar o app;
- PIN, sessão e retorno do segundo plano verificados;
- evidência de permissões concedidas e negadas nos fluxos aplicáveis;
- F01–F07, F21 e F22 aprovados na matriz, com dispositivo/API/versão/artefato registrados;
- se houver falha, logcat ou relatório técnico sanitizado anexado; sem log, a causa permanece “desconhecida”;
- nenhum dado real de criança utilizado em logs, screenshots, issues ou documentos.

Isso é um gate de **teste controlado técnico**, não autorização para piloto com dados reais ou publicação. O piloto RH continua bloqueado pelos critérios de backend, isolamento, autorização server-side, retenção, LGPD e governança.

## Plano de ações

### P0 — executar antes de qualquer nova expansão

1. **Preparar uma ficha de execução manual** com versão do APK, SHA-256, branch/commit, fabricante/modelo, Android/API, horário, conectividade e permissões.
2. **Desinstalar completamente a versão anterior**, reiniciar o aparelho, instalar o APK release mais recente e abrir offline. Registrar apenas observações técnicas e dados sintéticos.
3. **Se fechar novamente, capturar imediatamente o logcat do próprio aparelho**, filtrando pacote do app, `AndroidRuntime`, `FATAL EXCEPTION`, `flutter`, `libc` e `system_server`. Sanitizar qualquer conteúdo de usuário. Não tentar declarar causa sem esse artefato.
4. **Se aparecer a tela de diagnóstico Flutter, exportar o relatório técnico** e comparar com o horário do logcat. Se não aparecer, tratar como possível falha nativa/pre-Flutter, sem concluir qual componente falhou.
5. **Executar F01–F07 primeiro em celular e depois em tablet**, incluindo offline, orientação, segundo plano, PIN/sessão e recuperação de permissões. Atualizar a matriz com resultado pass/fail e evidência.
6. **Aplicar a regra de bloqueio:** não iniciar piloto com dados reais, publicação ampla, backend, sincronização, cobrança ou integração RH enquanto F01–F07/F21/F22 não estiverem verdes.

### P1 — após a evidência de execução

7. **Reconciliar o baseline documental** em `PROJECT_HANDOFF.md`, `docs/CHECKLIST_EXECUCAO_E_TESTES.md`, `docs/MATRIZ_FLUXOS_CRITICOS.md` e continuidade; marcar commits, contagens e resultados antigos como históricos.
8. **Abrir/acompanhar um item técnico de observabilidade do startup**, com reprodução, logcat sanitizado, dispositivo e hipótese testável. Não fazer correção por palpite nem atribuir a falha a TTS, Hive ou notificações sem evidência.
9. **Fechar os gates de segurança de distribuição:** revisar CBC/Hive e migração sem perda, decidir `minSdk` com matriz real, revisar receivers/permissões/arquivos temporários, repetir MobSF e executar análise dinâmica/manual MASVS/MASTG.
10. **Manter o núcleo local-first congelado** e separar módulos ampliados em itens independentes, cada qual com critério de aceite manual. Não usar documentos conceituais de portal/RH como evidência de implementação conectada.

## Confiança e limites

A confiança é **alta** para: o build ter evidência registrada de sucesso; a diferença entre compilação e execução em dispositivo; o fechamento ser um bloqueador P0; a ausência de logcat impedir diagnóstico causal; a necessidade de celular e tablet; e a manutenção do núcleo offline como prioridade.

A confiança é **média** para: a ordem exata do backlog após o incidente e a divisão entre núcleo e módulos ampliados, pois são decisões de gestão de escopo, embora estejam alinhadas aos critérios do handoff.

A confiança é **baixa** para qualquer causa técnica específica do fechamento. Nenhum logcat do aparelho foi inventado, e a tentativa no AVD não deve ser usada como reprodução do crash do aplicativo.

**Alterações realizadas nesta revisão:** somente este documento de revisão Scrum Master foi criado; nenhum código do aplicativo foi alterado.

## Referências

- [`AGENTS.md`](../../AGENTS.md)
- [`PROJECT_HANDOFF.md`](../../PROJECT_HANDOFF.md)
- [`docs/RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md`](../RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md)
- [`docs/AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md`](../AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md)
- [`docs/CHECKLIST_EXECUCAO_E_TESTES.md`](../CHECKLIST_EXECUCAO_E_TESTES.md)
- [`docs/CHECKLIST_PRE_LANCAMENTO.md`](../CHECKLIST_PRE_LANCAMENTO.md)
- [`docs/CHECKLIST_PILOTO_RH_CONTROLADO.md`](../CHECKLIST_PILOTO_RH_CONTROLADO.md)
- [`docs/MATRIZ_FLUXOS_CRITICOS.md`](../MATRIZ_FLUXOS_CRITICOS.md)
- [`docs/PLANO_SEQUENCIAL_ATE_BUILD.md`](../PLANO_SEQUENCIAL_ATE_BUILD.md)
- [`security/reports/MOBSF_2026-09-24.md`](../../security/reports/MOBSF_2026-09-24.md)
- [`lib/main.dart`](../../lib/main.dart)
- [`lib/core/services/secure_box_service.dart`](../../lib/core/services/secure_box_service.dart)
- [`android/app/src/main/AndroidManifest.xml`](../../android/app/src/main/AndroidManifest.xml)
- [`docs/team-review/01-01-product-manager.md`](01-01-product-manager.md)

---

## Registro estruturado

- **Fato:** build e testes automatizados possuem evidência registrada; execução Android em hardware real continua sem evidência suficiente.
- **Fato:** o APK instala e fecha ao abrir segundo o relato operacional e os documentos consultados.
- **Fato:** não há logcat do aparelho disponível nesta revisão.
- **Risco:** o crash bloqueia o primeiro valor e o gate de MVP executável.
- **Risco:** baselines divergentes podem levar a equipe a testar o artefato errado.
- **Hipótese:** Hive/Keystore/migração, plugin nativo, estado persistido, incompatibilidade de API/fabricante ou falha pós-UI; todas de baixa confiança até logcat.
- **Próximo compromisso:** teste limpo observável em celular e tablet, com F01–F07/F21/F22 e evidência sanitizada.
