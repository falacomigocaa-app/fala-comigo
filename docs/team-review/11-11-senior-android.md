# Revisão Senior Android — Manifest e fechamento na abertura

**ID:** 11-11  
**Papel:** Senior Android Developer  
**Data:** 24 de setembro de 2026  
**Escopo:** Manifest Android, Activity, componentes mesclados, caminho de inicialização Flutter, artefato APK e incidente de fechamento na abertura.

> **Integridade da revisão:** nenhum arquivo de código foi alterado. O relato disponível é que o APK instala, mas fecha ao abrir. Não há logcat do aparelho físico, relatório técnico sanitizado, fabricante, modelo, versão/API, horário ou confirmação de que o aparelho instalou o mesmo APK atualmente presente neste checkout. Nenhuma exceção, stack trace ou causa de crash foi inventada.

## Conclusão executiva

O pipeline Android está saudável como **compilação e empacotamento**, mas a disponibilidade do aplicativo no aparelho físico permanece não demonstrada. Os documentos registram análise estática, 84 testes, build Web, APK debug, APK release, AAB release e build limpa aprovados [1] [2]. Isso não prova que a `MainActivity` cria o engine, que o primeiro frame é exibido ou que a grade CAA permanece aberta no telefone afetado.

A leitura estática do Manifest principal e da Activity não encontrou uma configuração inequivocamente inválida que explique o fechamento. A Activity está exportada como launcher, usa o embedding Flutter 2 e o pacote da classe coincide com o `applicationId` efetivo. As permissões e receivers declarados ampliam a superfície de compatibilidade, mas a declaração deles, isoladamente, não é evidência de crash.

O ponto de maior risco no código é o **caminho de startup ainda obrigatório antes do estado `ready`**. Depois de `runApp`, o bootstrap fixa paisagem, inicializa Hive, lê ou cria a chave em `flutter_secure_storage`, abre ou migra três caixas, inicializa diagnóstico e semeia cartões. TTS e notificações foram adiados para depois dessa etapa [3] [4]. Portanto, a hipótese de um erro Dart em TTS/notificações bloquear o primeiro frame ficou menos provável; ainda assim, o registro nativo de plugins ocorre quando o engine Flutter é criado e pode morrer antes de qualquer captura Dart útil.

A próxima ação correta é **fixar o APK e obter logcat do próprio aparelho se o fechamento persistir**. Não é responsável trocar algoritmo criptográfico, remover permissões, alterar orientação ou substituir plugins sem antes separar falha nativa, falha Dart capturável, estado persistido e incompatibilidade do dispositivo.

## Fatos confirmados

### 1. Build, artefato e incidente

A branch efetivamente auditada é `work/qa-observability-and-emulator`, no commit atual `c8fcab1` (`feat: finalize MVP startup and delivery package`). O workspace contém o APK release em `build/app/outputs/flutter-apk/app-release.apk`, com 57.279.118 bytes e SHA-256 `310b47377933f970b763d5fa9ce2de088d20b512ffdd79c49ea0effa50323503`. O mesmo arquivo aparece no diretório de saída Android convencional. Esse hash identifica o artefato disponível neste checkout; não demonstra que seja o arquivo instalado no telefone.

Os relatórios registram `applicationId` `com.falacomigo.fala_comigo`, `versionName` `1.0.0`, `versionCode` `1`, `minSdk` 24 e `targetSdk` 36 [1]. O README ainda informa `com.falacomigo.caa`, o que é uma inconsistência documental e pode induzir suporte, instalação ou filtragem de logs ao pacote errado. Não é, por si só, uma causa de fechamento, pois Gradle, Manifest mesclado e metadados do APK usam `com.falacomigo.fala_comigo`.

O handoff afirma que o APK instala e fecha ao abrir, mas não fornece logcat do telefone [2]. O AVD usado na tentativa local perdeu o serviço Android `package` e o `system_server` antes de uma execução confiável; o erro `Broken pipe` observado ali é evidência de infraestrutura do emulador, não de execução do Fala Comigo [1].

### 2. Manifest principal e Activity

O Manifest principal declara as permissões `CAMERA`, `READ_MEDIA_IMAGES`, `RECORD_AUDIO`, `POST_NOTIFICATIONS`, `USE_FULL_SCREEN_INTENT`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED` e `VIBRATE`. A aplicação usa `android:name="${applicationName}"`, ícones próprios e regras de backup com `android:allowBackup="false"`. A Activity `.MainActivity` está `android:exported="true"`, possui os filtros `MAIN` e `LAUNCHER`, usa `launchMode="singleTop"`, `hardwareAccelerated="true"` e fixa `screenOrientation="landscape"` [5].

A `MainActivity` está no pacote `com.falacomigo.fala_comigo`, herda de `FlutterActivity`, chama `super.onCreate()` e depois configura `setShowWhenLocked`, `setTurnScreenOn` e `FLAG_KEEP_SCREEN_ON`. Não há, nessa leitura, uma customização de engine ou uma chamada nativa complexa que identifique uma falha determinística na abertura [6]. A orientação também é solicitada pelo Dart, criando uma decisão duplicada entre Manifest e `SystemChrome`; isso exige teste de ciclo de vida, mas não confirma crash.

O Manifest de debug e o de profile adicionam `INTERNET` para as ferramentas Flutter. O Manifest principal não declara `INTERNET`, o que é coerente com o núcleo local-first e não explica, sozinho, o fechamento do APK release [7].

### 3. Manifest efetivamente mesclado

A variante release inclui, além dos componentes declarados pelo aplicativo, providers privados de `image_picker`, `printing` e `share_plus`, a `WebViewActivity` privada do `url_launcher`, `androidx.startup.InitializationProvider` e componentes do `profileinstaller`. Os providers observados estão com `android:exported="false"` e concessão de URI controlada [8].

Os receivers próprios de notificações, `ScheduledNotificationBootReceiver` e `ScheduledNotificationReceiver`, estão com `android:exported="false"`. Isso reduz a superfície de intents externas, mas ainda requer teste de reinicialização e de atualização do pacote. O componente `androidx.profileinstaller.ProfileInstallReceiver` aparece exportado, protegido por `android.permission.DUMP`, por ser trazido pela dependência AndroidX. Esse item deve permanecer no inventário de segurança e ser revisado no APK final; não há evidência de que ele seja a causa do fechamento na abertura [8] [9].

O Manifest mesclado também contém permissões e componentes de bibliotecas AndroidX. A presença de `ProfileInstallReceiver`, providers ou permissões não deve ser tratada como diagnóstico sem um log de runtime que mostre a falha correspondente.

### 4. Caminho de startup observado

`main()` instala `FlutterError.onError` e `PlatformDispatcher.onError`, chama `runApp` imediatamente com `BootstrapApp` e inicia `_startApp` em uma zona protegida [3]. Isso permite que uma tela de carregamento Dart exista antes da conclusão do bootstrap. Entretanto, `StartupState.ready` só é publicado depois de `_bootstrapApp()`.

Antes de liberar `CaaApp`, `_bootstrapApp()` executa `SystemChrome.setPreferredOrientations`, `Hive.initFlutter()`, registra `PictogramCardAdapter`, abre ou migra `pictogram_cards`, `app_settings` e `transition_alerts`, inicializa `DiagnosticsService` e semeia os cartões padrão quando a caixa está vazia [3]. A própria `DiagnosticsService` abre uma quarta caixa cifrada, embora trate sua falha internamente como não bloqueadora [10].

O método `openSecureBoxWithMigration()` captura qualquer erro ao abrir a caixa cifrada. Em seguida, tenta fechar a caixa, abrir a mesma caixa sem cifra, copiar valores, apagar a caixa do disco e recriá-la com cifra [4]. O código não diferencia explicitamente caixa legada válida, chave incompatível, corrupção, formato inválido e erro transitório. Essa ordem é um risco de recuperação e disponibilidade, não uma confirmação da causa do incidente.

A inicialização de TTS e notificações foi movida para uma tarefa não aguardada no fim do bootstrap, com `try/catch` independente para cada serviço [3]. Essa mudança reduz a chance de uma exceção Dart nesses serviços impedir a primeira interface. Ela não impede que os plugins nativos sejam registrados no engine Flutter; o registrador gerado inclui TTS, notificações, secure storage, image picker, impressão, gravação, compartilhamento, URL launcher e outros plugins [11].

`StartupFailureApp` só aparece se o processo Flutter/Dart continuar vivo e uma falha alcançar os handlers. Morte do processo antes do Dart, erro de carregamento de biblioteca, falha JNI, erro durante a criação da Activity ou encerramento nativo não é coberto de modo confiável por essa tela [3].

## Riscos classificados

### R-01 — P0: disponibilidade Android não está provada

O APK compilar e instalar não demonstra primeiro frame, permanência, entrada na grade, comunicação offline ou recuperação de ciclo de vida no telefone afetado. Enquanto o usuário observa fechamento na abertura e não há logcat do próprio aparelho, a comunicação básica não pode ser considerada operacional [1] [2].

### R-02 — P0/P1: persistência segura está acoplada ao primeiro valor

Keystore/`flutter_secure_storage`, Hive, migração e semeadura precedem a grade CAA. Um problema de chave, diretório, estado antigo ou formato de caixa pode impedir a primeira tela funcional. Isso transforma uma dependência de armazenamento em um bloqueador potencial do núcleo de comunicação. O código sustenta o risco; não identifica qual operação falhou no telefone.

### R-03 — P1: migração ampla e potencialmente destrutiva

O fallback trata qualquer falha na abertura cifrada como possível legado. Se a abertura sem cifra for bem-sucedida, a caixa original é removida antes de a migração ter um protocolo explícito de versão, rollback, checksum ou recuperação após falha parcial [4]. Atualizar o algoritmo ou apagar dados como tentativa de corrigir o crash seria uma ação especulativa e poderia piorar a perda de dados.

### R-04 — P1: registro nativo e superfície de plugins

O adiamento de TTS e notificações atua no nível da chamada Dart, mas os plugins são registrados quando o engine é criado. A superfície nativa inclui áudio, notificações, secure storage, seleção de imagem, impressão, gravação e compartilhamento [11]. Uma falha nativa nessa fase não será capturada pela tela de diagnóstico. Sem logcat, não há base para apontar TTS, notificações ou qualquer outro plugin individual.

### R-05 — P1: Manifest e permissões precisam de validação dinâmica

Câmera, microfone, fotos, notificações, alarme exato, tela cheia e boot receiver ampliam a matriz de versões e fabricantes. O uso de `SCHEDULE_EXACT_ALARM` e `USE_FULL_SCREEN_INTENT` também depende de políticas e estados do sistema. O Manifest não solicita essas permissões silenciosamente durante o startup, segundo o serviço de alertas; elas são pedidas em contexto de tela [12]. Ainda assim, é necessário testar permissões concedidas e negadas, atualização, reinicialização, modo offline e Android API 24 em diante.

O `ProfileInstallReceiver` exportado pela dependência, embora protegido por `DUMP`, permanece como item de revisão de release. Esse risco é de superfície de plataforma e segurança; não deve ser convertido em explicação do crash sem evidência temporal e stack nativa.

### R-06 — P1: baseline de suporte está ambígua

Há divergências entre documentos quanto a branch, commit, hash do APK e estado da toolchain. O relatório de auditoria registra um hash anterior (`5f602b...`), enquanto o APK presente agora tem hash `310b473...`; revisões anteriores também registram artefatos diferentes [1] [13]. Sem fixar artefato, pacote, dispositivo e horário, um resultado de teste pode ser atribuído ao binário errado.

O `minSdk` 24 e os achados altos do MobSF sobre CBC/PKCS5/PKCS7 e mínimo de API permanecem gates de segurança e compatibilidade [14]. Eles não são evidência causal do fechamento observado.

### R-07 — P2: documentação de suporte pode filtrar o pacote errado

O README usa `com.falacomigo.caa`, enquanto o binário efetivo usa `com.falacomigo.fala_comigo`. Isso pode fazer comandos de instalação, coleta de `logcat` ou triagem procurarem o identificador errado. A correção documental deve ser feita em tarefa própria, sem modificar código como parte desta revisão.

## Hipóteses sobre o fechamento

As hipóteses abaixo orientam a investigação. Todas têm **confiança causal baixa** porque não existe logcat do aparelho físico.

1. **Morte nativa antes ou durante a criação do engine.** Carregamento de biblioteca, JNI, criação da Activity ou registro de plugin pode encerrar o processo antes de os handlers Dart e a tela de falha funcionarem. A superfície de plugins torna a hipótese plausível, mas não identifica um componente.

2. **Falha no Android Keystore ou `flutter_secure_storage`.** A leitura/criação da chave acontece antes da abertura das caixas e da grade. Uma incompatibilidade do fabricante, chave inválida ou estado do Keystore pode ser relevante. Se a falha for uma exceção Dart capturável, a tela de startup deveria ser uma possibilidade; se for morte nativa, somente o logcat separará os casos.

3. **Falha em Hive, caixa corrompida ou migração de dados legados.** A abertura cifrada e o fallback sem cifra acontecem no caminho obrigatório. Instalação sobre dados antigos, chave trocada, corrupção ou formato incompatível são cenários sustentados pela implementação. Não há evidência de qual cenário ocorre no telefone.

4. **Incompatibilidade específica de fabricante, API ou política do dispositivo.** `minSdk=24`, orientação fixa, Keystore, permissões, tela cheia e alarmes criam variações de plataforma. Sem fabricante, modelo e API não é possível priorizar essa hipótese.

5. **Falha após o bootstrap, na splash ou na primeira tela.** O relato “fecha ao abrir” não informa se o processo morre na tela de carregamento, no primeiro frame, durante a splash ou ao entrar na grade. Providers, assets e widgets só são exercitados depois do bootstrap e precisam ser separados no teste.

6. **TTS ou notificações como bloqueador inicial.** É menos provável no nível Dart porque foram adiados e possuem captura independente. Continua possível uma falha nativa no registro do plugin ou quando o serviço é usado. Não há base para atribuir o incidente a esses serviços.

7. **Tamanho do APK release ou assinatura temporária.** A diferença de aproximadamente 159 MB no debug para aproximadamente 57 MB no release é compatível com modos de build diferentes [1]. A assinatura temporária limita distribuição e atualização, mas não demonstra que recursos foram removidos nem que causou o fechamento.

## Ações recomendadas

### P0 — obter evidência do aparelho

1. Fixar antes do teste o commit `c8fcab1`, o SHA-256 `310b473...`, o pacote `com.falacomigo.fala_comigo`, a versão `1.0.0+1`, fabricante/modelo, versão Android/API, estado de conectividade e horário. Confirmar que o APK instalado é exatamente esse arquivo.

2. Repetir em instalação limpa: desinstalar a versão anterior, reiniciar o aparelho, instalar o APK release fixado e abrir offline. Registrar se aparece a tela de carregamento, a splash, a grade ou nenhuma UI. Repetir em um segundo dispositivo, idealmente um tablet. O AVD quebrado não substitui esse teste.

3. Se fechar, limpar o buffer imediatamente antes da tentativa e coletar o logcat do telefone. Filtrar pelo pacote efetivo, `AndroidRuntime`, `FATAL EXCEPTION`, `flutter`, `libc`, `ActivityTaskManager`, `PackageManager` e `system_server`. Preservar horário e versão, mas remover nomes, frases, imagens, áudios, vídeos, tokens e qualquer conteúdo de criança.

4. Separar estado de dados com fixtures sintéticas: instalação limpa; `pm clear`/limpeza dos dados; e atualização sobre uma versão anterior compatível. Comparar o resultado e os logs sem alterar a migração entre os cenários.

5. Se aparecer `StartupFailureApp`, copiar o relatório técnico sanitizado e correlacioná-lo com o horário do fechamento. Se não aparecer nenhuma UI de falha, tratar como possível morte nativa ou encerramento anterior ao Flutter, não como falha Dart confirmada.

### P1 — validar Manifest e caminho crítico

6. Imprimir e arquivar o Manifest mesclado do APK release com `apkanalyzer` ou ferramenta equivalente. Confirmar `applicationId`, Activity launcher, receivers de notificação, providers, `ProfileInstallReceiver`, permissões, `exported`, backup e regras de URI. Repetir a revisão no APK final de distribuição, não apenas na build de diagnóstico.

7. Executar matriz Android em pelo menos um celular e um tablet: offline, orientação paisagem, primeira abertura, retorno do segundo plano, permissões concedidas e negadas, TTS indisponível, notificações bloqueadas, reinicialização e atualização. Confirmar que seleção de cartão, montagem/limpeza de frase e comunicação visual continuam funcionando quando áudio ou alertas falham.

8. Adicionar, em etapa posterior e somente após a evidência do aparelho, testes de integração de startup para caixa ausente, legado válido, chave inválida, caixa corrompida, falha de permissão, engine TTS indisponível e primeira renderização. A revisão atual não modifica o código.

9. Revisar a migração Hive com estados explícitos para legado, chave incompatível, corrupção e erro inesperado. Definir migração idempotente, preservação de dados e recuperação após interrupção antes de qualquer troca criptográfica.

10. Reavaliar cada permissão no contexto do recurso. Manter armazenamento privado e receivers não exportados quando possível; registrar a justificativa do `ProfileInstallReceiver` protegido por `DUMP`; e repetir análise MobSF depois das decisões. O score do scanner não substitui teste dinâmico.

### P2 — reduzir ambiguidade operacional

11. Reconciliar documentação, principalmente `applicationId`, branch, commit, hash do APK e diferença entre APK de teste e chave de produção. Comandos de suporte devem usar o pacote efetivo `com.falacomigo.fala_comigo`.

12. Manter backend, portal RH, sincronização clínica, cobrança e publicação ampla fora do escopo do incidente. O fechamento é local ao app Android e deve ser resolvido com evidência de runtime antes de iniciar mudanças de produto ou infraestrutura.

## Confiança

A confiança é **alta** nos fatos de build documentados, no Manifest e nos componentes mesclados observados, no caminho de startup lido no código, no adiamento Dart de TTS/notificações e na ausência de logcat no checkout. É **média-alta** nos riscos derivados diretamente de Keystore/Hive/migração, registro de plugins e matriz de permissões. É **baixa** para qualquer hipótese causal específica sobre o fechamento, pois não há evidência do processo no aparelho afetado.

## Referências

[1]: ../RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md "Diagnóstico de build e instalação Android"

[2]: ../../PROJECT_HANDOFF.md "Documento de transferência do projeto Fala Comigo"

[3]: ../../lib/main.dart "Inicialização Flutter e tela de diagnóstico"

[4]: ../../lib/core/services/secure_box_service.dart "Armazenamento seguro e migração Hive"

[5]: ../../android/app/src/main/AndroidManifest.xml "Manifest principal Android"

[6]: ../../android/app/src/main/kotlin/com/falacomigo/fala_comigo/MainActivity.kt "Activity Android principal"

[7]: ../../android/app/src/debug/AndroidManifest.xml "Manifest Android de debug"

[8]: ../../build/app/outputs/logs/manifest-merger-release-report.txt "Relatório do Manifest mesclado da release"

[9]: ../PLANO_SEGURANCA_OWASP_MASVS_MOBSF.md "Plano de segurança móvel OWASP MASVS e MobSF"

[10]: ../../lib/core/services/diagnostics_service.dart "Serviço de diagnóstico sanitizado"

[11]: ../../android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java "Registrador de plugins Android gerado"

[12]: ../../lib/core/services/transition_alert_service.dart "Serviço de alertas e permissões Android"

[13]: ../AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md "Auditoria do handoff e artefatos Android"

[14]: ../CHECKLIST_EXECUCAO_E_TESTES.md "Checklist de execução, testes e prontidão"

**Resultado da revisão:** relatório criado sem alteração de código.
