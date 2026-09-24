# Revisão Pleno Front-End — telas, estados e abertura Android

**ID:** 09-09  
**Papel:** Pleno Front-End Developer  
**Data:** 24 de setembro de 2026  
**Escopo:** handoff, `AGENTS.md`, checklists, relatórios, revisões anteriores, telas Flutter, estados de inicialização, grade CAA, barra de frase, Área do Responsável, acessibilidade e configuração Android.

> **Integridade da revisão:** nenhum código do aplicativo foi alterado. O APK instala e fecha ao abrir conforme o relato recebido e o handoff, mas este checkout não contém logcat, fabricante/modelo, versão/API do aparelho ou horário do fechamento. Nenhuma exceção nativa, stack trace ou causa específica foi inventada.

## Decisão executiva

O gate de Front-End para Android permanece **bloqueado em P0**. O pipeline documentado compila, os testes automatizados registrados passam e os artefatos Android são gerados. Isso prova a construção do pacote e parte da lógica isolada; não prova que uma instalação limpa chega à grade CAA, permanece aberta e permite comunicação offline em aparelho físico [1] [2].

A causa do fechamento é **desconhecida**. O código atual melhorou a abertura ao chamar `runApp` antes do bootstrap e ao adiar TTS e notificações para depois da primeira tela. Ainda assim, a grade depende de orientação, Hive, `flutter_secure_storage`, migração de caixas, diagnóstico e semeadura de cartões antes de o estado ficar pronto [3]. Uma falha Dart capturável deveria exibir `StartupFailureApp`; uma morte nativa anterior ao Flutter, no carregamento de biblioteca, na Activity ou em plugin pode não alcançar essa tela [3] [4].

A recomendação imediata não é trocar plugins, criptografia ou layout por suposição. É fixar o APK realmente testado, reproduzir em aparelho físico saudável com instalação limpa e coletar o logcat do próprio aparelho se o fechamento persistir. Em paralelo, a equipe deve manter o núcleo visual CAA independente de TTS, notificações, mídia e Área do Responsável.

## Linha de base observada

O checkout analisado está na branch `work/qa-observability-and-emulator`, no commit `c8fcab1`. O handoff e alguns relatórios registram commits intermediários, como `40d9e53` e `5741575`, e devem ser tratados como histórico quando divergirem do checkout atual [2] [5].

Os documentos registram `flutter analyze` sem falha bloqueadora, 84 testes aprovados, build Web, APK debug, APK release, AAB release e build limpa aprovados. Esses são fatos de compilação e validação automatizada documentada. O checklist mantém sem evidência os itens de primeira abertura, grade offline, falhas de áudio, acessibilidade Android, celular e tablet [1].

No checkout há um APK release de aproximadamente 57 MB e um debug de aproximadamente 159 MB. A diferença é compatível com Debug versus Release e não demonstra perda de telas ou recursos. O APK release local disponível nesta análise tem SHA-256 `310b47377933f970b763d5fa9ce2de088d20b512ffdd79c49ea0effa50323503`; a auditoria documenta outro hash (`5f602b...`) para um artefato anterior. Portanto, o próximo teste precisa registrar o hash do arquivo efetivamente instalado, e não apenas o nome `app-release.apk` [2] [6].

O pacote configurado no Gradle é `com.falacomigo.fala_comigo`, com `versionName` `1.0.0` e `versionCode` `1`. O README ainda menciona `com.falacomigo.caa`. Essa divergência é operacionalmente perigosa para instalação, atualização, `pm clear` e filtragem de logcat, mas não é evidência de crash [7] [8].

## Leitura das telas e estados

| Superfície | Estados existentes observados | Avaliação Front-End e lacuna de evidência |
|---|---|---|
| Bootstrap | `loading`, `failure` e `ready` em `ValueNotifier` | Existe uma tela mínima de preparação e uma tela Dart de falha. O carregamento é indeterminado, não mostra etapa, timeout, tentativa novamente ou cancelamento. Nenhum desses estados foi validado em Activity Android real. |
| Splash | Fade de 900 ms, espera fixa de 1,8 s e transição de 500 ms para a grade | Há uma espera adicional depois do bootstrap. O teste existente verifica apenas texto e navegação com tempo simulado; não mede primeiro cartão, retorno do segundo plano, redução de movimento ou aparelho real [9]. |
| Grade CAA | Cartões filtrados, categoria vazia e grade responsiva de 3 a 8 colunas | O estado vazio orienta que o responsável adicione cartões. A grade depende de `pictogram_cards` e `app_settings` já abertos. Não há evidência manual de layout em celular estreito, tablet, fonte ampliada ou orientação real [10] [11]. |
| Barra de frase | Vazia, com cartões, remover item, limpar frase e botão `Falar` desabilitado quando vazia | O núcleo de estado é simples e possui testes. A visualização usa altura fixa de 96 px, itens de 72 px e rótulos truncados em uma linha. Frases longas e escala de fonte ainda não foram exercitadas em dispositivo [12] [13]. |
| Cartão | Estado normal, pressionado por cerca de 120 ms, semântica de botão e erro visual de asset | A ação de toque pode falar, adicionar ou fazer ambos conforme configuração. A seleção/adição continua síncrona mesmo que TTS falhe, o que protege a comunicação. A imagem padrão usa `errorBuilder`; a imagem da barra de frase não tem fallback equivalente explícito, deixando o tratamento visual inconsistente [11] [12]. |
| Área do Responsável | Loading do PIN, criação inicial, PIN inválido, bloqueio temporário e sucesso | O gate distingue primeiro uso de uso posterior e informa erros básicos. `hasPin()` não possui tratamento local de exceção; uma falha de armazenamento nessa tela pode produzir estado sem mensagem específica. Os testes não substituem a validação de teclado, foco, segundo plano e retorno em Android real [14]. |
| Configurações | Painel carregado com controles de escala, comportamento, tema e navegação para módulos | A tela oferece os ajustes necessários ao modo de comunicação. A maioria dos dados vem de providers locais e não tem estados de erro ou salvamento visível. A exclusão local tem confirmação, mas o resultado não apresenta uma confirmação de conclusão antes de navegar. |
| Falha de inicialização | Mensagem, detalhes técnicos expansíveis e cópia do relatório | É uma mitigação útil para exceções Dart. Não há retry seguro nem confirmação visual de cópia. Além disso, `message` e `stackTrace` são exibidos diretamente na UI; o relatório exportado é sanitizado, mas a tela pode expor detalhes técnicos ou caminhos se a exceção original os contiver [3] [4]. |

## Achados classificados

### F-01 — P0, fato: o primeiro valor de comunicação não está validado no Android

O relato é que o APK instala e fecha ao abrir. O checklist mantém a primeira abertura e a grade offline pendentes. Portanto, o produto não pode ser tratado como MVP Android funcional apenas com base em build, instalação ou testes unitários. O impacto é de disponibilidade da comunicação, não de cosmética [1] [2].

### F-02 — P0/P1, fato + risco: persistência segura continua antes da grade

Antes de `StartupState.ready`, `_bootstrapApp()` fixa paisagem, inicializa Hive, registra o adapter, lê ou cria a chave no armazenamento seguro, abre ou migra `pictogram_cards`, `app_settings` e `transition_alerts`, inicializa diagnóstico e semeia cartões. A grade só é alcançada depois desse caminho [3].

Isso é uma **superfície de risco**, não uma causa confirmada. Uma chave incompatível, caixa corrompida, migração inesperada ou comportamento específico do Keystore pode impedir o primeiro uso. A migração captura qualquer erro ao abrir a caixa cifrada e tenta tratá-lo como legado sem distinguir explicitamente corrupção, chave errada e formato incompatível [15].

### F-03 — P0, fato: a observabilidade Dart não cobre todas as mortes

O app registra `FlutterError.onError`, `PlatformDispatcher.onError` e uma zona protegida. Isso cobre falhas Dart que deixam o engine Flutter ativo. Não cobre de modo confiável falha de linker/JNI, `SIGABRT`/`SIGSEGV`, criação da Activity, carregamento de biblioteca nativa ou encerramento do processo antes de a UI ser renderizada [3] [4]. A ausência de `StartupFailureApp` não provaria uma falha Dart específica; indicaria apenas que a camada de observabilidade alcançada foi insuficiente.

### F-04 — P1, fato + risco reduzido: TTS e notificações foram retirados do bloqueio deliberado inicial

`_initializeOptionalServices()` é iniciado sem `await` depois do bootstrap e cada serviço possui seu próprio `try/catch`. Isso reduz a plausibilidade de uma exceção Dart desses serviços como causa do bloqueio inicial. Ainda existe risco quando o plugin nativo é carregado ou usado, e a alteração não prova que TTS ou notificações tenham causado o incidente anterior [3].

Na grade, o toque chama TTS sem aguardar e atualiza a frase independentemente do retorno. Essa escolha favorece a continuidade da seleção. Porém, não há fallback visual explícito para engine sem voz, idioma pt-BR indisponível, volume desligado ou erro de reprodução. A validação deve confirmar que a comunicação visual continua utilizável nesses cenários.

### F-05 — P1, risco de experiência: a abertura tem espera redundante e recuperação limitada

A pessoa pode ver o carregamento do bootstrap e, depois que o estado fica pronto, uma splash com espera fixa de 1,8 s e mais uma transição. O fluxo não oferece progresso, limite de espera, retry ou atalho para a grade. Se o bootstrap ficar lento por armazenamento, a UI parece parada; se concluir, ainda há atraso antes do primeiro cartão. A duração pode ser aceitável como decisão visual, mas precisa ser medida no aparelho e comparada ao critério de primeiro uso [9].

### F-06 — P1, fato mensurável + risco: contraste, escala e movimento ainda têm pendências

A revisão UX/UI calculou contraste aproximado de 2,53:1 para texto branco sobre `AppTheme.accentGreen` no botão `Falar`, abaixo do objetivo AA documentado. O par deve ser revisado também em estados desabilitado, pressionado, foco e temas de hiperfoco [12].

Cartões e itens da frase usam rótulos em uma linha com ellipsis, largura fixa de 72 px e fontes pequenas na barra. A grade também usa alturas e proporções fixas. Não há evidência de teste com fonte ampliada, rótulos personalizados longos, frases extensas, TalkBack, foco por teclado ou tablet [10] [12].

A splash usa `FadeTransition` e não foi encontrada uma condicional explícita para redução de movimento. Isso é um risco de acessibilidade e previsibilidade, não uma explicação do fechamento.

### F-07 — P1, risco de feedback competir com comunicação

A grade mostra SnackBars de recompensa por 2,2 segundos, com emoji e mensagem, após escolhas de categoria, toques e frases faladas. O feedback não bloqueia o provider, mas pode cobrir a barra, competir com TTS ou aumentar estímulo no modo infantil. É necessário testar se ele é secundário, não anunciado de forma repetitiva e configurável ou silencioso quando apropriado [10].

### F-08 — P2, fato documental: identidade do pacote e artefatos estão desalinhados

O Gradle e o Manifest usam `com.falacomigo.fala_comigo`; o README usa `com.falacomigo.caa`. A documentação também alterna branch, commit, contagem de testes e hash de APK. Isso não demonstra causa técnica, mas aumenta o risco de instalar um artefato diferente do analisado, limpar o pacote errado ou filtrar o logcat errado. O próximo registro de teste deve fixar pacote, versão, SHA-256, assinatura, branch e commit [2] [6] [7] [8].

### F-09 — P1, risco independente de runtime: superfície Android ainda não foi validada manualmente

O Manifest declara câmera, imagens, áudio, notificações, tela cheia, alarme exato, boot e vibração, além de receivers de notificações. Essas declarações podem ser necessárias para recursos previstos, mas permissões negadas, receivers, armazenamento, Profile Installer e componentes mesclados continuam pendentes de revisão dinâmica. Não há base para dizer que qualquer um desses itens causou o fechamento [1] [4] [16].

## Hipóteses sobre o fechamento

As hipóteses abaixo são **investigáveis e não diagnósticos**. A confiança causal é baixa sem logcat do aparelho.

1. **Encerramento nativo na Activity, engine Flutter ou registro de plugin.** Explica um fechamento sem `StartupFailureApp`, mas não identifica o componente.
2. **Falha no Keystore, `flutter_secure_storage`, Hive ou migração.** Esses componentes estão obrigatoriamente antes da grade e são sensíveis a estado persistido, fabricante e chave. A hipótese é sustentada pelo caminho do código, não por log.
3. **Dados antigos incompatíveis ou atualização sobre outra instalação.** Deve ser separado de instalação limpa, `pm clear` e atualização sobre fixtures sintéticas.
4. **Incompatibilidade de API, fabricante, orientação ou política de segurança do aparelho.** `minSdk=24`, `targetSdk=36`, paisagem fixa e permissões ampliam a matriz de compatibilidade. O aparelho afetado não está identificado.
5. **Falha na primeira renderização, provider ou asset depois do bootstrap.** O relato “ao abrir” não informa se o usuário vê o loading, a splash ou a grade; a etapa exata precisa ser registrada.
6. **TTS ou notificações.** Ficou menos provável como bloqueador Dart inicial porque foram adiados, mas um crash nativo no carregamento/uso ainda requer teste e log.
7. **Tamanho do APK release ou chave temporária.** A diferença Debug/Release é esperada. A chave temporária limita atualização/distribuição, mas não demonstra que o pacote perdeu telas ou que a chave causou o fechamento.

## Ações recomendadas sem alteração de código nesta revisão

### P0 — produzir evidência do aparelho afetado

1. Fixar o arquivo release realmente testado e registrar SHA-256, `applicationId`, `versionName`, `versionCode`, assinatura, branch e commit.
2. Registrar fabricante, modelo, versão/API Android, orientação, conectividade, permissões, horário aproximado e se houve desinstalação anterior.
3. Desinstalar completamente o pacote correto, reiniciar o aparelho, instalar o APK release e abrir offline. Observar se o processo chega ao loading, à splash, à grade ou fecha antes de qualquer tela.
4. Repetir com dados sintéticos em três estados: instalação limpa, `pm clear` e atualização compatível. Não usar nomes, frases, fotos, vídeos ou outros dados reais de crianças.
5. Se fechar novamente, coletar imediatamente o logcat do aparelho, filtrando o pacote efetivo, `AndroidRuntime`, `FATAL EXCEPTION`, `flutter`, `libc`, `ActivityTaskManager`, `PackageManager` e `system_server`. Se aparecer `StartupFailureApp`, copiar somente o relatório técnico sanitizado. Sem esse artefato, manter a causa como desconhecida.

### P1 — preservar o primeiro uso e fechar os estados de tela

6. Adicionar um smoke test de lançamento em dispositivo físico ou emulador saudável para instalação, primeiro frame, entrada na grade, reabertura, atualização e retorno do segundo plano. Testes unitários de widgets não substituem essa evidência.
7. Separar no bootstrap os marcos de orientação, Hive, chave, cada caixa, migração, diagnóstico, seed e primeiro frame. Isso permite correlacionar o incidente sem registrar conteúdo da criança.
8. Revisar a migração para distinguir legado válido, chave incompatível, corrupção e erro inesperado. Não apagar dados nem trocar algoritmo criptográfico como correção especulativa do fechamento.
9. Garantir que TTS, notificações, mídia e permissões não sejam pré-requisitos para exibir ou usar a grade. Testar engine de voz ausente, áudio indisponível, permissão negada e arquivo de imagem inválido.
10. Revisar a UX de loading e falha: progresso ou etapa compreensível, limite de espera, retry seguro quando aplicável, instrução curta de suporte e confirmação de cópia. Evitar exibir stack trace bruto ou caminhos na superfície destinada à pessoa usuária.
11. Corrigir ou justificar o contraste de `Falar` e validar TalkBack, ordem de foco, teclado, fonte de 1,3x e 2x, rótulos longos, frases longas, brilho baixo, redução de movimento, celular e tablet.
12. Testar SnackBars e recompensas no modo infantil para confirmar que não cobrem a frase, não interrompem a voz e não criam pressão de desempenho. Considerar configuração silenciosa ou opt-in.

### P2 — reduzir ambiguidade operacional

13. Alinhar README, handoff, scripts de suporte e relatórios ao `applicationId` efetivo `com.falacomigo.fala_comigo`.
14. Atualizar hash, branch, commit, tamanho e assinatura sempre que o APK mudar. Não usar a redução de Debug para Release como evidência de regressão.
15. Manter o gate de distribuição, backend conectado, sincronização clínica e cobrança fechados até a validação Android, segurança, acessibilidade e governança previstas. Esses trabalhos não explicam nem resolvem o crash físico sem evidência.

## Confiança

A confiança é **alta** nos fatos de que o build foi documentado como aprovado, que o caminho de bootstrap contém persistência antes da grade, que TTS/notificações foram adiados e que não existe logcat no checkout. É **média-alta** nos riscos derivados diretamente do código, como espera fixa, truncamento, contraste, observabilidade limitada e migração ampla. É **baixa** para qualquer hipótese causal específica sobre o fechamento, porque não há logcat, dispositivo identificado ou etapa visual reproduzida.

## Referências

[1]: ../CHECKLIST_EXECUCAO_E_TESTES.md "Checklist de execução, testes e prontidão"
[2]: ../RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md "Relatório de diagnóstico de build e instalação Android"
[3]: ../../lib/main.dart "Inicialização Flutter, bootstrap e estados de falha"
[4]: ../AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md "Auditoria do handoff e artefatos Android"
[5]: ../../PROJECT_HANDOFF.md "Documento de transferência do projeto Fala Comigo"
[6]: ../RELATORIO_CONTINUIDADE_2026-09-24.md "Relatório de continuidade do projeto Fala Comigo"
[7]: ../../README.md "README e identidade documentada do projeto"
[8]: ../../android/app/build.gradle.kts "Configuração Gradle do aplicativo Android"
[9]: ../../lib/features/onboarding/presentation/screens/splash_screen.dart "Tela de abertura e transição para a grade"
[10]: ../../lib/features/aac_grid/presentation/screens/aac_grid_screen.dart "Tela principal da grade CAA"
[11]: ../../lib/features/aac_grid/presentation/widgets/grid_card.dart "Cartão CAA e semântica de toque"
[12]: ../../lib/features/aac_grid/presentation/widgets/sentence_bar_widget.dart "Barra de frase e botão de fala"
[13]: ../../test/sentence_bar_widget_test.dart "Teste automatizado da barra de frase"
[14]: ../../lib/features/parental_area/presentation/screens/parental_gate_screen.dart "Gate da Área do Responsável"
[15]: ../../lib/core/services/secure_box_service.dart "Caixas Hive protegidas e migração"
[16]: ../../android/app/src/main/AndroidManifest.xml "Manifest principal Android"

**Resultado da revisão:** relatório criado sem alteração de código.
