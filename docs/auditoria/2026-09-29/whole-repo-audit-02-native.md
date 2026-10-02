# Auditoria técnica nativa e de entrega — Fala Comigo

**Área:** Android, iOS, macOS, Windows, Linux, Codemagic, build, signing e distribuição\
**Modo:** somente leitura\
**Checkout auditado:** `/home/ubuntu/fala-comigo`\
**Branch/HEAD observados:** `audit/creator-privacy-alignment` / `cc96eaf`\
**Data da auditoria:** 2026-09-29

## 1. Escopo, método e limites

Foram lidos `AGENTS.md`, os diretórios nativos (`android/`, `ios/`, `macos/`, `windows/`, `linux/`), `codemagic.yaml`, configurações de build/signing, workflows locais de CI, documentação de build e o histórico Git local. Foram usados apenas `find`, `rg`, `git status`, `git log`, `git show`, `git diff`, `git ls-files` e leitura de arquivos. Não houve edição no checkout, commit, merge, deploy, acesso ao GitHub/Supabase/API remota ou execução de build.

A toolchain nativa não está disponível nesta sessão: `flutter`, `dart`, `adb`, `sdkmanager`, `xcodebuild`, `pod`, `cmake` e `msbuild` não foram encontrados. Portanto, esta auditoria confirma configuração e evidência documental, mas **não confirma que o estado atual compila**.

O worktree já estava sujo antes do relatório. Dentro do escopo há alterações não commitadas em `android/gradle/wrapper/gradle-wrapper.properties` e nos registrants/listas gerados de Linux, macOS e Windows. Essas alterações não foram feitas por esta auditoria.

## 2. Resumo executivo

A base nativa contém um caminho Android plausível para teste e publicação: projeto Flutter/Gradle com namespace e `applicationId` definidos, guard explícito para impedir release sem `android/key.properties`, workflow Codemagic que gera APK e AAB assinados quando a identidade externa está configurada, workflow separado para APK de teste com chave efêmera e verificação `apksigner`, permissões/receivers de notificações e regras Android que excluem dados locais de backup.

O projeto **não está pronto para declarar publicação multiplataforma**. O único workflow Codemagic de release é Android; o segundo é Web. Não há pipeline de iOS, macOS, Windows ou Linux, nem configuração de upload para lojas, metadata de loja, instaladores desktop ou assinatura/notarização desktop. No iOS não há `DEVELOPMENT_TEAM`/provisioning configurados no projeto nem `Podfile`/`Podfile.lock`; no macOS o target usa signing automático, mas não há equipe/certificado configurado no checkout. No macOS, o entitlements de release declara somente sandbox, enquanto o registrant inclui gravação de áudio e outras capacidades; faltam evidências de que essas funções funcionarão sob sandbox.

O APK/AAB de produção ainda não está demonstrado no estado auditado: a keystore de produção não está no checkout por desenho, a identidade `fala-comigo-release` do Codemagic é uma dependência externa não verificável por leitura local e a toolchain não está instalada nesta sessão. A documentação registra um APK debug histórico e um APK de teste histórico, mas isso não é evidência de release/AAB atual nem de funcionamento em aparelho.

Os principais gates antes de qualquer distribuição são: (1) build Android release e AAB em um commit revisado, com identidade de produção e hash/certificado registrados; (2) instalação e atualização em celular e tablet reais, offline e com permissões concedidas/negadas; (3) revisão de políticas para `USE_FULL_SCREEN_INTENT`, `SCHEDULE_EXACT_ALARM` e `READ_MEDIA_IMAGES`; (4) definição de signing/CI para Apple; e (5) definição de empacotamento, assinatura e suporte para desktop.

## 3. Estado do checkout e histórico relevante

### 3.1 Estado atual

`git status --short` mostrou, dentro da área auditada:

- `M android/gradle/wrapper/gradle-wrapper.properties`
- `M linux/flutter/generated_plugin_registrant.cc`
- `M linux/flutter/generated_plugins.cmake`
- `M macos/Flutter/GeneratedPluginRegistrant.swift`
- `M windows/flutter/generated_plugin_registrant.cc`
- `M windows/flutter/generated_plugins.cmake`

As mudanças são em grande parte arquivos gerados. Ainda assim, enquanto não forem revisadas e integradas de forma rastreável, o checkout não representa uma linha de build limpa e reproduzível.

### 3.2 Histórico local

O histórico mostra decisões intencionais de endurecimento, mas também que a integração nativa vem evoluindo:

- `f247d6a` — adicionou os workflows Codemagic Android.
- `39713e5` — adicionou a política de falhar release sem signing de produção.
- `8b2fca3` — adiou o guard de signing para tarefas release, preservando o build debug.
- `959a0f8` — adicionou um `proguard-rules.pro` explícito.
- `e1757bd` — alinhou o target JVM do Kotlin.
- `70537c7` — integrou a correção Android/área parental.
- `159ca6e` — iniciou alertas agendados em tela cheia.

O histórico confirma intenção e evolução, mas não substitui build/artefato verificável no commit atual.

## 4. O que está implementado agora

### 4.1 Android: fundamentos de build e signing

- `android/settings.gradle.kts:20-24` fixa os plugins Android `9.1.0` e Kotlin `2.4.0` e carrega o Flutter Gradle plugin.
- `android/gradle/wrapper/gradle-wrapper.properties:5-6` fixa Gradle `9.3.1` e adiciona SHA-256 do distribution ZIP. O checksum está em uma alteração não commitada do worktree.
- `android/app/build.gradle.kts:30-50` define namespace/application ID `com.falacomigo.fala_comigo`, usa SDK/version vindos do Flutter e Java/Kotlin 17 (`:35-42` e `:85-89`).
- `android/app/build.gradle.kts:13-28` documenta e carrega `android/key.properties` somente se existir. `:63-69` só associa a configuração de release quando a keystore existe; `:72-79` falha `assembleRelease`/`bundleRelease` sem signing de produção. Isso evita fallback silencioso para chave debug.
- `.gitignore:42-48` e `android/.gitignore:12` excluem `android/key.properties`, `.jks` e `.keystore`. Não há keystore ou `key.properties` rastreado.
- `android/app/src/main/res/` contém ícones launcher nos densities mdpi a xxxhdpi, ícone round, adaptive XML e splash resources.

### 4.2 Android: workflow de teste e workflow Codemagic

- `.github/workflows/android-test-apk.yml:18-25` fixa Flutter `3.38.0` e instala dependências.
- `.github/workflows/android-test-apk.yml:27-46` cria uma chave efêmera, escreve `android/key.properties` temporário e gera `flutter build apk --release`; isso é um APK de teste não produtivo.
- `.github/workflows/android-test-apk.yml:48-55` exige APK não vazio, registra SHA-256 e executa `apksigner verify --verbose`.
- `.github/workflows/android-test-apk.yml:65-78` publica o APK de teste por 14 dias e remove os arquivos de signing.
- `.github/workflows/flutter.yml:29-46` cobre formatação, análise, política que impede uso de signing debug, testes Flutter e build Web. Não cobre APK/AAB, iOS ou desktop.
- `codemagic.yaml:2-31` define `android-release`, Flutter `3.38.0`, instância Linux, identidade Codemagic `fala-comigo-release`, análise/testes e os comandos `flutter build apk --release` e `flutter build appbundle --release`. Publica `build/app/outputs/flutter-apk/*.apk`, `build/app/outputs/bundle/release/*.aab` e possíveis `mapping.txt`.
- `codemagic.yaml:34-50` contém somente um segundo workflow Web. Não há workflow Apple ou desktop.
- `docs/BUILDS_CODEMAGIC.md:7-40` documenta corretamente a dependência externa da keystore, os artefatos esperados, versionCode e o checklist de aparelho. A própria documentação declara em `:42-44` que o sandbox não executou APK e que Codemagic é o ambiente destinado ao signing.

### 4.3 Android: permissões, alarmes e privacidade de backup

- `android/app/src/main/AndroidManifest.xml:3-14` declara câmera, `READ_MEDIA_IMAGES`, microfone, `POST_NOTIFICATIONS`, `USE_FULL_SCREEN_INTENT`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED` e vibração.
- `android/app/src/main/AndroidManifest.xml:16-23` usa `allowBackup="false"`, `dataExtractionRules` e `fullBackupContent`; `:24-42` define activity Flutter exportada, launcher e embedding v2.
- `android/app/src/main/AndroidManifest.xml:44-55` declara os receivers de notificações agendadas/boot com `exported="false"`.
- `android/app/src/main/res/xml/backup_rules.xml:3-7` exclui file, database, shared preferences, external e root de backup; `data_extraction_rules.xml:3-16` repete exclusão para cloud backup e device transfer.
- `android/MainActivity.kt:12-25` implementa `setShowWhenLocked`, `setTurnScreenOn` e `FLAG_KEEP_SCREEN_ON` para o alerta em lock screen.
- `lib/core/services/transition_alert_service.dart:94-113` solicita notificações, alarmes exatos, full-screen intent e permissões Darwin a partir de fluxo de tela; `:115-128` verifica notificações e alarmes exatos; `:130-165` usa prioridade alta, categoria alarm, full-screen e visibilidade privada.

### 4.4 iOS

- `ios/Runner.xcodeproj/project.pbxproj:490-495` e `:542-550` fixam deployment target iOS `15.0` e famílias `1,2` (iPhone/iPad).
- `ios/Runner.xcodeproj/project.pbxproj:576-595` configura target Release com `Info.plist`, bundle ID `com.falacomigo.falaComigo`, version number via Flutter e Swift 5.0.
- `ios/Runner/Info.plist:27-32` declara textos de uso para câmera, microfone e biblioteca de fotos; `:62-74` declara orientações para telefone/tablet.
- `ios/Runner/GeneratedPluginRegistrant.m:9-81` registra plugins de áudio, notificações, secure storage, TTS, image picker, path provider, PDF, record, share e URL launcher.
- `ios/Runner/AppDelegate.swift:4-15` usa `FlutterImplicitEngineDelegate` e registra plugins no engine implícito.
- Há target `RunnerTests` no Xcode, embora `ios/RunnerTests/RunnerTests.swift:5-10` seja apenas scaffold sem teste funcional.

### 4.5 macOS, Windows e Linux: base nativa

- macOS tem target release/debug/profile, deployment `12.0` e app identity em `macos/Runner/Configs/AppInfo.xcconfig:7-14`. O release target referencia `Runner/Release.entitlements` e signing automático em `macos/Runner.xcodeproj/project.pbxproj:634-650`.
- macOS registra plugins de áudio, notificações, secure storage, TTS, path provider, PDF, record, share e URL launcher em `macos/Flutter/GeneratedPluginRegistrant.swift:8-29`.
- Windows tem CMake para Debug/Profile/Release e C++17 em `windows/CMakeLists.txt:13-46`, instalação de runtime/data em `:61-108`, DPI PerMonitorV2 e Windows 10/11 em `windows/runner/runner.exe.manifest:3-12`, e metadados/ícone/versionamento no `windows/runner/Runner.rc:53-99`.
- Linux tem CMake com C++14, `-Wall -Werror`, otimização release e bundle relocável em `linux/CMakeLists.txt:29-47` e `:78-128`; exige GTK 3 em `:53-55`.
- Windows registrou áudio, file selector, secure storage, TTS, printing, record, share e URL launcher em `windows/flutter/generated_plugin_registrant.cc:9-34`; notificações locais aparecem como FFI plugin em `windows/flutter/generated_plugins.cmake:16-19`.
- Linux registrou áudio, file selector, secure storage, printing, record e URL launcher em `linux/flutter/generated_plugin_registrant.cc:9-34`. Não há registrant para TTS, image picker, share ou notificações locais nesse conjunto gerado.

## 5. Incompleto, protótipo ou sem prova suficiente

1. **Apenas Android/Web têm CI declarada.** `codemagic.yaml` não possui iOS, macOS, Windows ou Linux. A existência de CMake/Xcode files não é pipeline de release.
2. **Signing Apple não está fechado.** Não há ocorrência de `DEVELOPMENT_TEAM`, provisioning profile ou identidade de distribuição no projeto iOS. O iOS usa `iPhone Developer` em configuração genérica (`project.pbxproj:470` e `:528`), mas isso não demonstra archive App Store assinado. macOS usa signing automático, mas não há team/certificado no checkout nem workflow macOS.
3. **iOS não tem Podfile/Podfile.lock.** O projeto usa referências Flutter/Swift Package geradas, mas não há lockfile CocoaPods nem pipeline que prove resolução, archive e export. Isso deve ser uma decisão explícita de SPM versus CocoaPods, não uma suposição de reprodutibilidade.
4. **macOS media/sandbox está inconsistente com as capacidades registradas.** `macos/Runner/Release.entitlements:5-7` declara somente `com.apple.security.app-sandbox`; não há entitlement de entrada de áudio/câmera. `macos/Runner/Info.plist:1-32` também não tem usage descriptions de câmera/microfone. Ao mesmo tempo, o registrant inclui `record_macos` (`GeneratedPluginRegistrant.swift:15,27`). Se gravação for uma feature de release, ela precisa de entitlement, texto de permissão e teste em app sandboxed; se não for suportada, a UI deve declarar a limitação.
5. **Paridade desktop é parcial.** Linux não registra TTS, share, image picker ou local notifications no conjunto gerado; macOS não registra image picker. Windows lista notificações como FFI, sem evidência de smoke test. Isto caracteriza protótipo/paridade não comprovada, não falha do build Android.
6. **Não há empacotamento/assinatura desktop.** Não foram encontrados MSIX/installer, DMG/pkg, notarização, deb/AppImage/Flatpak, certificados ou workflows de publicação. CMake gera bundle de execução, não distribuição de loja.
7. **Release Android não define explicitamente otimização.** `android/app/build.gradle.kts:63-69` só configura signing no `release`; não há `minifyEnabled`, `shrinkResources` ou estratégia explícita de R8. `android/app/proguard-rules.pro:1-5` é apenas um placeholder conservador. O artifact glob de `codemagic.yaml:32` espera `mapping.txt`, mas não há evidência local de que R8 esteja ativado ou que esse arquivo seja produzido.
8. **Validação de permissões de alerta é incompleta na UI.** `checkPermissionStatus()` retorna notificações e alarme exato (`transition_alert_service.dart:115-128`), mas não informa o estado do full-screen intent, embora `requestPermissions()` o solicite (`:98-105`). A aprovação do fluxo precisa verificar o comportamento real, especialmente em Android 14+.
9. **Versionamento ainda está no primeiro valor.** `pubspec.yaml:1-4` está em `1.0.0+1`. A documentação alerta que o `versionCode` após `+` deve aumentar (`docs/BUILDS_CODEMAGIC.md:32-36`), mas não existe automação de versionamento/release notes.
10. **Targets nativos de teste são scaffolds.** `ios/RunnerTests/RunnerTests.swift:5-10` e `macos/RunnerTests/RunnerTests.swift:5-10` não exercitam permissões, lifecycle, signing ou plugins. Não há evidência de testes de dispositivo/desktop no repositório.

## 6. Bloqueadores objetivos

### Bloqueadores de build/artefato nesta sessão

- Não é possível reproduzir localmente APK/AAB, archive Apple ou bundle desktop neste ambiente: não há Flutter/Dart/Android SDK/ADB/Xcode/CocoaPods/CMake/MSBuild no PATH. `android/local.properties:1-5` aponta para paths locais de Flutter/SDK, mas esses binários não estão disponíveis nesta sessão.
- A keystore de produção e `android/key.properties` estão ausentes por desenho seguro. Isso é correto para o Git, porém impede validar signing de produção localmente. O Codemagic só funcionará se a identidade externa `fala-comigo-release` existir e corresponder aos valores esperados (`codemagic.yaml:8-20`); essa configuração não pode ser confirmada por leitura do checkout.
- O worktree scoped está sujo com mudanças geradas e checksum do Gradle. Até que sejam revisadas e fixadas em um commit, não há uma referência limpa para chamar de build candidato.

### Bloqueadores de publicação/loja

- Não há fluxo Apple para archive/export/distribution signing. O iOS não possui team/provisioning no projeto; macOS não possui team/certificado configurado no checkout.
- Não há workflow/artefato de distribuição Windows/Linux/macOS nem instalador assinado/notarizado.
- As permissões Android de tela cheia e alarme exato são sensíveis a políticas de plataforma; `USE_FULL_SCREEN_INTENT` e `SCHEDULE_EXACT_ALARM` exigem justificativa, comportamento de alarme válido e verificação em versões atuais. `READ_MEDIA_IMAGES` também exige revisão de necessidade e declaração de uso na loja.
- Não existe configuração de upload Google Play/App Store Connect ou metadata de loja no checkout. O AAB pode ser gerado, mas a publicação continua manual e não auditada.

## 7. Riscos críticos

1. **Assinatura errada ou não verificável:** um APK de teste assinado pela chave efêmera não pode ser promovido como produção. O certificado do AAB/APK de produção deve ser comparado com a identidade registrada e preservado em inventário seguro.
2. **Falso positivo de build:** documentação registra builds históricos, mas não há execução nesta sessão nem prova de release/AAB atual. Instalar não é o mesmo que abrir e executar o fluxo CAA.
3. **Falha em alertas após publicação:** notificações, exact alarm, full-screen intent, lock screen, reboot, DND, OEM battery restrictions e timezone podem variar por versão/fabricante. O código solicita permissões, mas o status e a experiência completa ainda não foram testados em aparelho.
4. **Rejeição ou comportamento inesperado de loja:** a combinação de full-screen intent, exact alarm e `READ_MEDIA_IMAGES` pode exigir revisão ou limitar a aprovação se o caso de uso não for documentado como permitido.
5. **Perda de funcionalidade no macOS sandbox:** o release entitlements não mostra autorização de entrada de áudio/câmera, apesar de existir plugin de gravação. A feature pode falhar silenciosamente ou ser bloqueada pelo sistema.
6. **Paridade desktop enganosa:** o registrant não inclui o mesmo conjunto de plugins em cada sistema. Sem matriz explícita de capability, uma tela compartilhada pode oferecer ação que não funciona em Linux/macOS/Windows.
7. **Reprodutibilidade comprometida:** arquivos gerados e checksum do wrapper estão modificados sem commit dentro do checkout auditado; build local/CI baseado em outro commit pode resolver plugins ou Gradle de forma diferente.

## 8. Validações futuras obrigatórias

### Android/APK/AAB

1. Em commit limpo e revisado, rodar análise/testes e `flutter build apk --release`/`flutter build appbundle --release` no Codemagic com `fala-comigo-release`; guardar logs, SHA-256, versão, `applicationId` e fingerprint do certificado.
2. Verificar APK com `apksigner`; verificar AAB com ferramenta de bundle/Play internal testing; confirmar que não há signing debug, que o `versionCode` é novo e que o artefato esperado é o produzido pelo commit auditado.
3. Instalar APK em **celular e tablet Android reais**, primeiro instalação limpa e depois atualização sobre a versão anterior. Testar Android em versões que cubram o comportamento de permissões modernas, inclusive Android 13/14+.
4. Repetir offline: primeira execução, grade CAA, fala, montagem/limpeza de frase, PIN/sessão, cartões e mídia. Testar câmera, galeria, microfone, áudio, vídeo, permissões concedidas/negadas e falhas de arquivo.
5. Testar alertas: notificação com app aberto/fechado, lock screen, tela apagada, reboot, horário/ timezone, DND, bateria restrita, alarme exato permitido/negado, full-screen permitido/negado e fallback de áudio. Confirmar que nenhuma notificação expõe dados sensíveis.
6. Executar TalkBack, orientação, foco, alvos de toque, contraste e recuperação após segundo plano. Registrar modelo, Android, build, conectividade e resultado sem dados reais de crianças.

### iOS

1. Em macOS com Xcode, decidir e documentar SPM versus CocoaPods, fixar dependências e configurar equipe, bundle ID, certificados e provisioning de distribuição em CI seguro.
2. Gerar archive/export de Release para iPhone e iPad. Testar câmera, microfone, biblioteca de fotos, notificações, áudio/TTS, share, VoiceOver, offline e retorno de background.
3. Confirmar que os textos de uso correspondem exatamente às telas que solicitam cada permissão e revisar a ficha de privacidade da App Store.

### macOS

1. Gerar Release sandboxed em máquina Apple, verificar assinatura/notarização e executar fora do Xcode.
2. Validar gravação de áudio, notificações, TTS, share, impressão e acesso a arquivos; ajustar ou retirar features cuja entitlement/usage description não esteja suportada.
3. Testar Apple Silicon/Intel conforme matriz de suporte escolhida e definir DMG/pkg/auto-update, se o produto for distribuído fora da Mac App Store.

### Windows/Linux

1. Definir produto de distribuição (MSIX/instalador Windows; deb/AppImage/Flatpak ou equivalente Linux), assinatura, versionamento e runtime/dependências.
2. Produzir bundles Release em máquinas limpas e testar instalação/execução sem IDE. Verificar TTS, gravação, secure storage, share, impressão, notificações e fallback de cada capability.
3. Formalizar uma matriz de capacidades por plataforma para que a UI não exponha controles não implementados.

### Piloto controlado

O piloto deve usar dados sintéticos ou explicitamente consentidos, checklist de suporte/incidentes e observação por responsáveis e profissionais de CAA/TEA. Deve abranger offline, acessibilidade, interrupções e exclusão local. Nenhuma validação documental de plataforma substitui a observação humana prevista em `docs/CHECKLIST_PRE_LANCAMENTO.md:23-53`.

## 9. Recomendações priorizadas

### P0 — antes de chamar qualquer artefato de release

1. Limpar/revisar o worktree scoped e separar as alterações geradas do candidato; confirmar que o checksum do Gradle e os registrants foram gerados pela mesma versão do Flutter e estão no commit que será construído.
2. Executar o workflow de APK de teste no commit candidato, baixar o artefato, verificar hash/assinatura e instalar em aparelho real. Depois executar o `android-release` do Codemagic somente após confirmar a keystore `fala-comigo-release` e registrar o AAB/APK de produção.
3. Criar um gate explícito de release que registre `versionName`, `versionCode`, `applicationId`, SHA-256, fingerprint de signing, resultado `apksigner` e resultado de instalação/abertura em celular e tablet.
4. Fazer revisão de loja para full-screen intent, exact alarm, media permissions, política de privacidade, Data Safety e justificativa de cada permissão antes de enviar o AAB.

### P1 — fechar Apple e desktop

5. Adicionar CI macOS para iOS/macOS com versões de Xcode/Flutter fixadas, resolução de dependências reproduzível, signing seguro e archive/export de distribuição; não armazenar certificados ou profiles no Git.
6. Corrigir a decisão macOS de mídia: adicionar entitlements/usage descriptions/fluxo de permissão se gravação/câmera fizerem parte do produto, ou esconder/desabilitar a capability no macOS até existir suporte testado.
7. Definir e automatizar artefatos Windows/Linux/macOS, instaladores, assinatura/notarização e retenção; sem isso, classificar desktop como build de desenvolvimento, não entrega de loja.
8. Publicar uma matriz de capabilities por plataforma e adicionar smoke tests nativos/integração para os plugins essenciais.

### P1/P2 — robustez do Android release

9. Decidir explicitamente se Release terá `minifyEnabled`/`shrinkResources`, ativar e testar R8 se desejado, ou remover a expectativa de `mapping.txt`; adicionar regras somente quando um teste demonstrar necessidade.
10. Automatizar incremento de `versionCode`, release notes e conferência de artifact paths, evitando que `1.0.0+1` seja reutilizado em atualização da Play.
11. Fazer a UI de diagnóstico exibir também a situação relevante do full-screen intent ou, no mínimo, registrar claramente essa limitação e cobri-la no teste de dispositivo.

## 10. Conclusão por categoria

| Categoria | Parecer |
| --- | --- |
| Android debug/test APK | **Infraestrutura preparada; evidência histórica existe, mas não foi reexecutada nesta sessão.** |
| Android production APK/AAB | **Incompleto:** workflow e guard existem; keystore/execução/artefato/fingerprint/dispositivo ainda não estão comprovados. |
| iOS | **Protótipo de projeto:** target, Info.plist e registrant existem; signing/CI/archive/loja não estão fechados. |
| macOS | **Protótipo de projeto:** CMake/Xcode/registrant existem; sandbox/media/signing/distribuição não estão comprovados e há gap de entitlement. |
| Windows | **Build base:** CMake/runner/manifest/registrants existem; installer, signing, CI e testes de capability não existem. |
| Linux | **Build base:** CMake/GTK/bundle/registrants existem; paridade de plugins, empacotamento, signing, CI e testes não existem. |
| Codemagic | **Parcialmente implementado:** Android APK+AAB e Web; nenhum workflow Apple/desktop/upload de loja. |
| Pronto para publicação ampla | **Não.** Faltam os gates objetivos de signing, artefato, loja, dispositivo, acessibilidade e distribuição multiplataforma. |

## Evidências principais

- `AGENTS.md:30-43`
- `android/app/build.gradle.kts:13-28,30-79,81-89`
- `android/settings.gradle.kts:20-26`
- `android/gradle/wrapper/gradle-wrapper.properties:5-6`
- `android/app/src/main/AndroidManifest.xml:3-55`
- `android/app/src/main/res/xml/backup_rules.xml:3-7`
- `android/app/src/main/res/xml/data_extraction_rules.xml:3-16`
- `android/app/src/main/kotlin/com/falacomigo/fala_comigo/MainActivity.kt:12-25`
- `codemagic.yaml:1-50`
- `.github/workflows/android-test-apk.yml:18-79`
- `.github/workflows/flutter.yml:20-47`
- `ios/Runner/Info.plist:27-74`
- `ios/Runner.xcodeproj/project.pbxproj:470-550,576-595`
- `ios/Runner/GeneratedPluginRegistrant.m:9-81`
- `ios/Runner/AppDelegate.swift:4-15`
- `macos/Runner/Release.entitlements:5-7`
- `macos/Runner/DebugProfile.entitlements:5-10`
- `macos/Runner/Info.plist:1-32`
- `macos/Runner.xcodeproj/project.pbxproj:474-498,606-650`
- `macos/Flutter/GeneratedPluginRegistrant.swift:8-29`
- `windows/CMakeLists.txt:13-46,61-108`
- `windows/runner/runner.exe.manifest:3-12`
- `windows/runner/Runner.rc:53-99`
- `windows/flutter/generated_plugin_registrant.cc:9-34`
- `windows/flutter/generated_plugins.cmake:5-19`
- `linux/CMakeLists.txt:29-55,78-128`
- `linux/flutter/generated_plugin_registrant.cc:9-34`
- `linux/flutter/generated_plugins.cmake:5-16`
- `lib/core/services/transition_alert_service.dart:94-165`
- `docs/BUILDS_CODEMAGIC.md:7-44`
- `docs/CHECKLIST_PRE_LANCAMENTO.md:23-53`
- `docs/PLANO_SEQUENCIAL_ATE_BUILD.md:143-161,202-204`
- `docs/HANDOFF_TELA_BRANCA_APK.md:128-165`
