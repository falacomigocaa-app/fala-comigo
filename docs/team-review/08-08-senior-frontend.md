# Revisão Senior Front-End — Flutter e CAA

**ID:** 08-08  
**Papel:** Senior Front-End Developer  
**Data:** 24 de setembro de 2026  
**Escopo:** inicialização Flutter/Android, caminho até a primeira tela CAA, persistência local, serviços nativos opcionais, acessibilidade e disponibilidade da comunicação offline.

> **Integridade da revisão:** o APK instala, mas fecha ao abrir segundo o handoff e os relatos disponíveis. Não há logcat, relatório técnico sanitizado do aparelho, fabricante/modelo, versão Android ou horário do fechamento neste checkout. Nenhuma exceção nativa, linha de log ou causa específica foi inventada. O código não foi alterado; somente este relatório foi criado.

## Resumo executivo

O pipeline documentado está saudável como **compilação e empacotamento**, mas a disponibilidade do aplicativo Android ainda não está provada. Os relatórios registram formatação, análise Flutter, 84 testes, build Web, APK debug, APK release, AAB release e build limpa aprovados. Esses resultados demonstram que o código compila e que a lógica coberta pelos testes passa; não demonstram que o processo permanece vivo no aparelho físico, chega à grade CAA ou funciona offline [1] [2].

A alteração mais relevante no caminho de abertura já foi feita: `runApp` ocorre antes do bootstrap, e TTS e notificações foram adiados para depois da primeira tela, cada um com captura independente de erro Dart. Ainda assim, a grade só é liberada depois de orientação, Hive, `flutter_secure_storage`, migração de caixas, inicialização do diagnóstico e semeadura de cartões. Portanto, o caminho crítico foi reduzido, mas continua incluindo armazenamento seguro e migração antes do primeiro uso CAA [3] [4].

A causa do fechamento permanece **desconhecida**. A hipótese prioritária de engenharia é obter evidência do próprio aparelho e comparar instalação limpa, limpeza de dados e atualização sobre dados sintéticos. Não é responsável atribuir o incidente a TTS, notificações, tamanho do APK, assinatura temporária, Hive ou a uma versão Android específica sem logcat ou relatório técnico correspondente.

Do ponto de vista de CAA, este é um bloqueador P0 de disponibilidade: enquanto uma instalação limpa não chega à grade e não permanece utilizável offline em celular e tablet, a comunicação básica não pode ser considerada operacional. A arquitetura e o fluxo visual estão alinhados ao requisito de comunicação local-first, mas o gate humano previsto no handoff ainda não foi concluído [5].

## Fatos confirmados

1. **O checkout analisado é uma branch de trabalho, não uma publicação final.** O checkout atual está em `work/qa-observability-and-emulator`, no commit `c8fcab1`. Há documentos históricos com outros commits e estados; os artefatos devem ser fixados por hash antes do próximo teste. O APK release local tem aproximadamente 57 MB e o debug aproximadamente 159 MB; essa diferença entre Debug e Release é esperada e não prova perda de telas ou recursos [3] [6].

2. **A matriz documentada de build passou.** `flutter analyze --no-fatal-infos --no-fatal-warnings`, 84 testes, Web release, APK debug, APK release, AAB release e build limpa foram registrados como aprovados. A documentação também registra que o APK release de teste não usa a chave oficial de produção [1] [3].

3. **O AVD da Manus não reproduziu o aplicativo.** O serviço Android `package` e o `system_server` do AVD morreram antes de uma instalação/execução confiável. O erro `Broken pipe` desse ambiente é evidência de infraestrutura do emulador, não de um crash do Fala Comigo [1].

4. **A captura Dart não cobre todas as mortes possíveis.** `main.dart` registra `FlutterError.onError`, `PlatformDispatcher.onError` e uma zona protegida, chama `runApp` e depois executa o bootstrap. Isso permite mostrar `StartupFailureApp` para falhas Dart capturáveis. Não cobre, porém, falha de linker/JNI, carregamento de biblioteca, criação da Activity, morte nativa de plugin ou encerramento do processo antes de o engine Flutter continuar executando [4].

5. **O caminho que antecede a grade CAA ainda é síncrono do ponto de vista da disponibilidade.** Antes de marcar o estado como pronto, `_bootstrapApp()` fixa orientação paisagem, inicializa Hive, registra o adapter, abre ou migra `pictogram_cards`, `app_settings` e `transition_alerts`, inicializa o diagnóstico e popula os cartões padrão. Só então `CaaApp` mostra `SplashScreen`, que espera aproximadamente 1,8 segundo antes de navegar para `AACGridScreen` [4] [7].

6. **TTS e notificações já não bloqueiam deliberadamente o primeiro estado pronto.** `_initializeOptionalServices()` é disparado sem ser aguardado depois do bootstrap. As duas inicializações têm `try/catch` separado e registram falhas. Isso reduz a plausibilidade de uma falha Dart desses serviços como causa do bloqueio inicial, mas não elimina um crash nativo de plugin ou uma falha posterior quando o recurso for usado [4].

7. **A grade CAA depende de caixas abertas previamente.** `cardsBoxProvider` obtém `Hive.box<PictogramCard>('pictogram_cards')`, e `CardTapBehaviorNotifier` lê `app_settings` durante a criação do provider. O desenho é válido se o bootstrap terminar; se uma caixa não estiver disponível, uma falha de primeira renderização ainda é possível. A grade contém cartões seed locais e o Manifest principal não declara `INTERNET`, coerente com o requisito offline [7] [8] [9].

8. **O serviço de migração usa uma recuperação ampla.** `openSecureBoxWithMigration()` trata qualquer exceção ao abrir a caixa cifrada como sinal de uma caixa legada, tenta abrir a mesma caixa sem cifra, copia os valores, remove o arquivo legado e recria a caixa cifrada. Esse caminho pode ser necessário para compatibilidade, mas mistura chave incompatível, corrupção, formato inválido e legado real na mesma decisão. A chamada ocorre antes da grade CAA [10].

9. **A tela de diagnóstico é útil, mas sua persistência é limitada durante o próprio bootstrap.** `DiagnosticsService.init()` só é chamado depois das três caixas principais. Antes disso, os eventos ficam em memória; uma morte de processo não permite exportação pela tela. O serviço também captura apenas falhas que deixam o Flutter vivo [11].

10. **Os fluxos centrais de CAA estão implementados no código.** A tela principal oferece categorias, barra de frase, cartões, rotinas visuais, acesso parental e indicação de funcionamento offline. O toque pode falar, adicionar à frase ou fazer ambos; a lógica de estado possui testes unitários e de widgets relacionados. A existência dessas implementações e testes não equivale à validação manual de áudio, orientação, contraste, foco, tamanho de toque ou permanência da tela em Android [2] [7] [12].

## Riscos técnicos e de produto

### R-01 — P0: o primeiro valor de comunicação não está validado em Android

O relato de fechamento impede afirmar que a criança consegue abrir a prancha. O impacto é maior que uma falha cosmética: indisponibilidade no primeiro uso interrompe a comunicação alternativa. O gate deve permanecer bloqueado até uma instalação limpa abrir a grade, manter-se estável e permitir o fluxo básico sem internet em pelo menos um celular e um tablet [2] [5].

### R-02 — P0/P1: armazenamento seguro permanece no caminho crítico

Hive e `flutter_secure_storage` são acessados antes da grade. Em instalação nova, atualização ou estado corrompido, a chave do Keystore, a abertura cifrada e a migração podem falhar de maneiras diferentes. O código não demonstra, neste ponto, uma tela CAA independente da persistência; portanto, uma falha local pode impedir todo o primeiro uso. Isso é um risco sustentado pelo código, não uma causa confirmada do fechamento.

O MobSF também reportou CBC com padding PKCS5/PKCS7 associado à dependência usada pelo armazenamento Hive. O achado exige decisão criptográfica, migração e teste de recuperação, mas não deve ser tratado como explicação automática do crash [13].

### R-03 — P1: fallback de migração pode mascarar corrupção como legado

O `catch (_) ` da migração não distingue uma caixa legada de uma chave errada, corrupção ou incompatibilidade de formato. A sequência de abrir sem cifra, copiar e apagar o arquivo pode produzir perda de dados ou outro erro em uma atualização. Para um app de CAA, a recuperação deve preservar cartões e configurações ou apresentar uma falha compreensível ao responsável; não deve transformar um problema de integridade em tentativa destrutiva silenciosa.

### R-04 — P1: falhas de TTS precisam ser isoladas da ação comunicativa

Na grade, o toque chama `TtsService.instance.speak(card.label)` sem aguardar o Future e depois atualiza a barra de frase. Isso favorece a continuidade da seleção mesmo se o áudio falhar. Contudo, o serviço tenta inicializar TTS sob demanda quando ainda não estiver pronto, e a chamada não possui fallback de voz visível no próprio gesto. A matriz ainda não validou idioma pt-BR ausente, engine sem voz, volume desligado, permissão/política do dispositivo ou erro de plugin. A seleção e a montagem da frase devem continuar funcionando independentemente de áudio; o áudio é reforço, não autoridade do fluxo CAA [2] [7].

### R-05 — P1: orientação fixa em paisagem precisa de validação de uso real

A orientação é fixada tanto no bootstrap quanto no Manifest. Isso pode ser adequado ao uso como prancha, mas a checklist ainda não comprova layout em celulares estreitos, tablets, rotação inicial, retomada após segundo plano e acessibilidade em paisagem. Um layout tecnicamente renderizado pode reduzir a comunicação se chips, barra de frase ou cartões ficarem cortados ou pequenos [2] [4] [14].

### R-06 — P1: permissões e componentes Android ainda têm gates abertos

O Manifest declara câmera, imagens, áudio, notificações, tela cheia, alarme exato, boot e vibração. Essas permissões são coerentes com funcionalidades previstas, mas a checklist ainda marca revisão de Manifest, receivers, armazenamento, permissões negadas e análise dinâmica como pendente. O MobSF reportou, entre outros pontos, `ProfileInstallReceiver`, armazenamento externo, arquivos temporários e hotspot de permissões. São riscos de release e privacidade; sem logcat não são causa do fechamento [2] [13] [14].

### R-07 — P1: diagnóstico local não substitui observabilidade nativa

A tela de falha Dart e o relatório sanitizado são boas medidas de suporte, especialmente porque não incluem conteúdo de cartões, frases, fotos, áudio ou vídeo por desenho. Porém, elas dependem de o processo Flutter chegar a uma tela utilizável. A coleta do próximo incidente deve vir do aparelho e conter apenas metadados técnicos. A política de consentimento e retenção do diagnóstico continua pendente na checklist [2] [11].

### R-08 — P1: a diferença entre build de teste e release de produção pode confundir o teste

A assinatura local é temporária e o projeto bloqueia a release sem `key.properties`/keystore de produção. Instalar uma build assinada por chave diferente sobre outra versão pode produzir comportamento de atualização ou impedir instalação, mas não há evidência de que isso ocorreu no aparelho. O teste deve registrar `applicationId`, `versionCode`, `versionName`, SHA-256, assinatura, desinstalação prévia e estado dos dados [1] [3] [6].

## Hipóteses sobre o fechamento

As hipóteses a seguir são **investigáveis, não diagnósticos**. A confiança causal é baixa na ausência de logcat do telefone.

1. **Falha nativa antes ou durante o engine Flutter.** Um problema de biblioteca, JNI, Activity ou plugin poderia matar o processo antes de `StartupFailureApp`. Esta hipótese explica por que a captura Dart pode não aparecer, mas não identifica o componente.

2. **Falha no Keystore, `flutter_secure_storage`, Hive ou migração.** O código acessa esses componentes obrigatoriamente antes da grade e possui fallback de migração amplo. Uma chave incompatível, caixa corrompida, estado de atualização ou comportamento específico do fabricante é plausível. Não há evidência que escolha uma dessas variantes.

3. **Estado persistido incompatível ou atualização sobre instalação anterior.** Dados de uma versão, assinatura ou formato diferente podem alterar a abertura. Deve ser separado em instalação limpa, `pm clear` e atualização sobre fixtures sintéticas; dados reais de criança não devem ser usados.

4. **Incompatibilidade específica de aparelho/API.** `minSdk=24`, target SDK 36, orientação fixa, Keystore, permissões e componentes de notificação podem interagir com o fabricante ou versão Android. O modelo e a API do aparelho não estão documentados, então não é possível priorizar esse cenário.

5. **Falha após o bootstrap, na splash ou na primeira renderização CAA.** O relato “fecha ao abrir” não informa se o usuário vê a tela nativa, a tela de carregamento, a splash ou a grade. Providers que dependem de Hive, imagens, Riverpod e layout só são exercitados depois do bootstrap.

6. **TTS ou notificações.** A hipótese ficou menos provável como bloqueador do primeiro frame porque os serviços foram adiados e têm captura Dart separada. Ainda pode ocorrer falha nativa quando o plugin é carregado ou usado, e isso só pode ser excluído com teste e log do aparelho.

7. **Tamanho do APK, redução de Debug para Release ou chave temporária.** A diferença de tamanho é compatível com os modos de build. A chave temporária limita o uso como distribuição de produção e pode afetar atualização, mas não prova que o APK perdeu recursos nem que causa o fechamento.

## Ações recomendadas

### P0 — reproduzir com evidência do aparelho

1. Fixar o artefato testado: APK release mais recente, SHA-256, `applicationId`, `versionName`, `versionCode`, assinatura, branch e commit.
2. Registrar fabricante/modelo, versão Android/API, orientação configurada, instalação usada e horário aproximado da tentativa.
3. Desinstalar completamente a versão anterior, reiniciar o aparelho, instalar o APK release e testar primeiro a abertura offline.
4. Repetir separadamente com três estados de dados sintéticos: instalação limpa, `pm clear` e atualização sobre dados compatíveis. Registrar se o fechamento ocorre antes da tela de carregamento, durante a splash ou ao abrir a grade.
5. Se fechar, coletar imediatamente o logcat do aparelho filtrando pacote, `AndroidRuntime`, `FATAL EXCEPTION`, `flutter`, `libc`, `ActivityTaskManager`, `PackageManager` e `system_server`. Enviar apenas metadados técnicos; nunca enviar frases, imagens, áudio, vídeo, nomes ou tokens.
6. Se aparecer `StartupFailureApp`, copiar o relatório técnico sanitizado pela Área do Responsável e correlacioná-lo com o horário do teste. Se não aparecer, tratar como possível falha nativa ou morte do processo, não como falha Dart confirmada.

### P1 — proteger a disponibilidade CAA

7. Manter TTS, notificações, mídia, permissões e alertas fora do caminho necessário para exibir e usar a grade básica. Uma falha de áudio não pode impedir selecionar cartão, montar frase ou limpar a frase.
8. Adicionar testes de integração/startup em Android para caixas ausentes, dados legados válidos, chave inválida, caixa corrompida, permissão negada, engine TTS indisponível, orientação paisagem e primeira renderização da grade.
9. Revisar a migração Hive com distinção explícita entre legado, chave incompatível, corrupção e erro inesperado. Definir backup/rollback local, preservação de dados, migração idempotente e mensagem segura ao responsável antes de qualquer remoção de arquivo.
10. Executar a matriz manual CAA: abrir offline, falar/adicionar/adicionar e falar, remover e limpar frase, filtrar categorias, persistir cartões, usar sem TTS e permanecer utilizável em celular e tablet. Registrar evidência de semântica, foco, contraste, tamanho de toque e layout em paisagem [2].
11. Revisar o Manifest final, receivers, permissões contextuais, armazenamento privado, arquivos temporários e o achado `minSdk=24`. Reexecutar MobSF depois das decisões; não usar o score como substituto de teste dinâmico [13].

### P2 — melhorar diagnóstico e release

12. Definir consentimento, retenção e fluxo de triagem para relatórios técnicos antes do piloto. A captura local deve continuar minimizada e sem conteúdo da criança.
13. Acrescentar a versão do app, commit/build flavor, fase de startup e último marco concluído ao diagnóstico sanitizado. Isso deve ajudar a diferenciar falha antes do Flutter, bootstrap, splash e primeira tela sem registrar conteúdo sensível.
14. Separar no checklist as evidências de compilação, instalação, primeiro frame, permanência, comunicação offline, atualização e permissões negadas. Não marcar o gate Android como concluído somente porque o APK foi gerado.

## Conclusão e confiança

A base Flutter/CAA está organizada e contém o núcleo local-first necessário, mas a disponibilidade Android continua não demonstrada. O build verde é um fato; o fechamento no aparelho é um incidente real relatado; a causa é desconhecida. O risco mais importante é deixar armazenamento seguro e migração como pré-requisitos absolutos antes da primeira comunicação sem ter uma reprodução instrumentada. A próxima decisão correta é técnica e reversível: validar um APK fixado em aparelho físico saudável e coletar logcat se o processo morrer. Não iniciar backend, cobrança, sincronização clínica ou alteração criptográfica como correção especulativa do fechamento.

**Confiança:** alta nos fatos de build documentados, no escopo local-first, no caminho crítico observado no código, na limitação da captura Dart e na ausência de evidência do aparelho; média-alta nos riscos derivados diretamente da migração, persistência e gates Android; baixa para qualquer hipótese causal específica sobre o fechamento.

## Referências

[1]: ../RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md "Diagnóstico de build e instalação Android"
[2]: ../CHECKLIST_EXECUCAO_E_TESTES.md "Checklist de execução, testes e prontidão"
[3]: ../AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md "Auditoria do handoff e artefatos Android"
[4]: ../../lib/main.dart "Inicialização Flutter e tela de diagnóstico"
[5]: ../../PROJECT_HANDOFF.md "Documento de transferência do projeto Fala Comigo"
[6]: ../../AGENTS.md "Instruções de desenvolvimento do Fala Comigo"
[7]: ../../lib/features/aac_grid/presentation/screens/aac_grid_screen.dart "Tela principal da grade CAA"
[8]: ../../lib/features/aac_grid/data/providers/cards_provider.dart "Providers de cartões e frase"
[9]: ../../android/app/src/main/AndroidManifest.xml "Manifest principal Android"
[10]: ../../lib/core/services/secure_box_service.dart "Armazenamento seguro e migração Hive"
[11]: ../../lib/core/services/diagnostics_service.dart "Serviço de diagnóstico sanitizado"
[12]: ../../lib/features/onboarding/presentation/screens/splash_screen.dart "Splash e navegação para a grade CAA"
[13]: ../../security/reports/MOBSF_2026-09-24.md "Relatório MobSF do APK release de teste"
[14]: ../../android/app/src/main/kotlin/com/falacomigo/fala_comigo/MainActivity.kt "Activity Android e orientação/tela ligada"
[15]: 07-07-pleno-backend.md "Revisão anterior sobre fechamento Android e fronteiras de confiança"

**Resultado da revisão:** relatório criado sem alteração de código.
