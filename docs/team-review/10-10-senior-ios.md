# Revisão Senior iOS — plataforma e plugins

**ID:** 10-10  
**Papel:** Senior iOS Developer  
**Data:** 24 de setembro de 2026  
**Escopo:** configuração nativa iOS, ciclo de vida Flutter, registro de plugins, caminho de inicialização, permissões, iPhone/iPad e relação com o fechamento relatado no Android.

> **Integridade da revisão:** nenhum código do aplicativo foi alterado. O relato disponível é que o APK Android instala e fecha ao abrir. Não há logcat do aparelho, relatório técnico sanitizado, fabricante, modelo, versão/API ou horário do fechamento neste checkout. Também não há execução iOS verificável: este ambiente é Linux e não possui `xcodebuild`, CocoaPods, `ios-deploy` ou um dispositivo Apple. Nenhuma exceção, stack trace ou causa de crash foi inventada.

## Conclusão executiva

O gate iOS permanece **bloqueado por falta de evidência de build e execução em macOS com iPhone/iPad**. A leitura estática não encontrou uma falha inequívoca no `AppDelegate`, no `SceneDelegate`, no storyboard principal ou no registro gerado de plugins. O projeto usa `IPHONEOS_DEPLOYMENT_TARGET = 15.0`, Swift 5, uma cena Flutter baseada em `Main.storyboard` e registro de plugins quando o engine implícito é inicializado [1] [2] [3] [4]. Isso é uma base plausível, mas não é prova de que o app compile, instale, permaneça aberto ou funcione em iOS.

A causa do fechamento relatado também permanece **desconhecida**. O incidente descrito é Android, enquanto esta revisão analisa iOS e código compartilhado. O build Android documentado e a instalação do APK não provam disponibilidade no aparelho; o AVD da Manus morreu antes de executar o aplicativo; e os relatórios não contêm logcat do telefone [5] [6]. Portanto, não é responsável atribuir o fechamento a um plugin específico, ao tamanho do APK, ao Hive, ao Keychain/Keystore ou a notificações.

Há dois pontos técnicos relevantes para a próxima validação. Primeiro, `flutter_secure_storage` e `path_provider` participam do caminho que precisa terminar antes de o estado `ready`: o app inicializa Hive, lê ou cria uma chave no Keychain via `flutter_secure_storage`, abre ou migra três caixas cifradas e semeia cartões antes de liberar a aplicação principal [7] [8]. Segundo, a configuração de notificações observada é essencialmente Android: `TransitionAlertService` cria apenas `AndroidInitializationSettings` e só solicita permissões por meio da implementação Android. O registrador iOS inclui o plugin, mas o código não demonstra notificações locais funcionais no iOS [9] [10].

A prioridade correta é produzir uma execução iOS real e uma reprodução Android com artefato fixado e log do aparelho. Não se deve trocar plugins, algoritmo criptográfico, orientação ou assinatura como correção especulativa do fechamento.

## Fatos confirmados no checkout

### 1. O artefato do incidente é Android; iOS ainda não tem evidência de execução

O handoff e os relatórios registram que o APK instala e fecha ao abrir, mas explicitamente informam que não existe logcat do telefone físico. Os testes Flutter, a análise estática, os builds Android e a instalação do pacote não demonstram que a Activity permanece viva no aparelho [5] [6]. O AVD utilizado no ambiente perdeu o serviço `package` e o `system_server` antes de uma execução confiável; seu erro `Broken pipe` não é um crash do Fala Comigo [5].

Para iOS, o checkout contém projeto Xcode, arquivos Swift/Objective-C, storyboards e configurações geradas. Contudo, o host atual é Linux e não oferece Xcode nem um simulador ou aparelho Apple. Assim, não há fato local que confirme `flutter build ios`, archive, instalação, primeiro frame, VoiceOver, permissões ou retorno do segundo plano.

### 2. A integração de cena e engine é convencional, sem erro estático inequívoco

`AppDelegate` herda de `FlutterAppDelegate` e implementa `FlutterImplicitEngineDelegate`. Quando o engine implícito é inicializado, ele chama `GeneratedPluginRegistrant.register(with:)`. `SceneDelegate` herda de `FlutterSceneDelegate` sem customização adicional. O `Info.plist` declara uma cena de aplicação com `SceneDelegate`, `UISceneStoryboardFile = Main` e `Main.storyboard` usa `FlutterViewController` como controlador inicial [2] [3] [4].

A combinação não prova runtime, mas não há, por leitura estática, uma chamada duplicada evidente de registro de plugins ou uma Activity/Scene customizada complexa que explique sozinha o fechamento. A validação ainda deve confirmar que a versão do Flutter usada no Mac gera o mesmo modelo de engine e que o projeto abre pelo `.xcworkspace` ou pelo projeto gerado conforme a ferramenta atual.

### 3. O registrador nativo inclui dez superfícies de plugin Darwin/iOS

O `GeneratedPluginRegistrant.m` registra `audioplayers_darwin`, `flutter_local_notifications`, `flutter_secure_storage`, `flutter_tts`, `image_picker_ios`, `path_provider_foundation`, `printing`, `record_ios`, `share_plus` e `url_launcher_ios` [2]. As versões resolvidas no `pubspec.lock` incluem, entre outras, `flutter_secure_storage 9.2.4`, `flutter_tts 4.2.5`, `flutter_local_notifications 19.5.0`, `image_picker_ios 0.8.13+3`, `path_provider_foundation 2.5.1`, `record_ios 1.2.1`, `share_plus 10.1.4`, `url_launcher_ios 6.3.6`, `audioplayers_darwin 6.4.0` e `hive 2.2.3` [2] [11].

A presença no registrador significa que os módulos nativos entram no engine quando o plugin é registrado. Ela não significa que cada recurso tenha sido exercitado. A maioria dos plugins só é chamada em telas parentais ou em ações explícitas, mas o carregamento/registro nativo ocorre no ciclo de criação do engine e precisa ser validado em uma build iOS real.

### 4. O caminho de startup compartilhado ainda depende de Keychain, path provider e migração

`main()` instala os handlers Dart, chama `runApp` com uma tela de bootstrap e inicia `_startApp` em uma zona protegida. Entretanto, o estado só passa a `ready` depois de `_bootstrapApp()`. Esse método fixa a orientação, executa `Hive.initFlutter()`, registra o adapter, abre ou migra `pictogram_cards`, `app_settings` e `transition_alerts`, inicializa o diagnóstico e popula os cartões padrão [7].

`Hive.initFlutter()` depende do caminho de armazenamento da plataforma. A chave das caixas é lida ou criada por `flutter_secure_storage`; no iOS, a implementação nativa correspondente é o Keychain. Portanto, uma falha de Keychain, de armazenamento de arquivos ou da migração pode impedir a primeira tela funcional antes da grade CAA. A captura `StartupFailureApp` cobre falhas Dart que deixam o Flutter vivo, mas não cobre de modo confiável morte nativa, linker/JNI equivalente, falha de carregamento de biblioteca ou encerramento do processo antes de a UI continuar [7] [8].

### 5. A orientação está inconsistente entre a política do app e o `Info.plist` iOS

O Dart chama `SystemChrome.setPreferredOrientations` para permitir apenas `landscapeLeft` e `landscapeRight`, e o Android também fixa paisagem no Manifest. No iOS, porém, `Info.plist` declara portrait e as duas paisagens para iPhone, além das quatro orientações para iPad [7] [4]. O código pode restringir a orientação depois que o engine inicia, mas a tela nativa de lançamento e o primeiro ciclo de cena continuam sujeitos à configuração declarada no plist.

Isso é um risco de previsibilidade e layout, não uma causa confirmada de fechamento. É necessário decidir se a prancha deve iniciar exclusivamente em paisagem também no iOS ou se iPhone/iPad terão políticas diferentes. A decisão deve ser validada no primeiro frame, na retomada do segundo plano, no split view do iPad quando aplicável e com VoiceOver.

### 6. As descrições de privacidade iOS básicas estão presentes

`Info.plist` contém `NSCameraUsageDescription`, `NSMicrophoneUsageDescription` e `NSPhotoLibraryUsageDescription`, com textos que relacionam câmera, gravação e seleção de fotos às ações do responsável [4]. Isso atende à existência das chaves básicas para os usos observados em `image_picker` e `record`.

A presença das chaves não prova que o fluxo trate cancelamento, permissão negada, revogação posterior, ausência de câmera, microfone ocupado ou arquivo inválido. A matriz de fluxos ainda marca câmera/galeria, áudio, permissões negadas e mídia como validação manual pendente [12]. Não há necessidade demonstrada, no código lido, de declarar acesso de escrita à fototeca, pois o fluxo seleciona ou captura mídia e a persiste na área privada do app.

### 7. Notificações locais não estão configuradas para iOS

`TransitionAlertService.init()` inicializa o fuso horário e chama o plugin com `InitializationSettings(android: androidInit)`. O serviço manipula `AndroidFlutterLocalNotificationsPlugin` para notificações, alarmes exatos, notificações em tela cheia e permissões. Não há `DarwinInitializationSettings`, solicitação de autorização iOS, categorias/ações iOS ou tratamento específico de `UNUserNotificationCenter` no código observado [9] [10].

O serviço é inicializado depois do bootstrap, e suas exceções Dart são capturadas separadamente. Isso reduz o risco de uma falha Dart de notificações bloquear o primeiro estado visual. Não elimina, porém, a lacuna funcional de iOS nem exclui uma falha nativa de registro ou uso do plugin sem log de aparelho. Os comentários do serviço também descrevem explicitamente um mecanismo Android, enquanto o registrador é multiplataforma [9].

### 8. Plugins de mídia são acionados sob demanda, mas têm riscos iPhone/iPad

A câmera e a galeria são chamadas apenas em telas parentais por `ImagePicker`. A gravação usa `record`, grava inicialmente em `getTemporaryDirectory()` e depois cifra a mídia antes de persistir. A reprodução usa `audioplayers`, e o compartilhamento de vídeo usa `share_plus` [13] [14] [15]. Nenhum desses fluxos é chamado diretamente por `_bootstrapApp()`.

A exportação de PDF usa `Printing.sharePdf`. O compartilhamento de vídeo chama `Share.shareXFiles` sem fornecer `sharePositionOrigin` [13]. No iPad, a folha de compartilhamento é apresentada como popover em muitos contextos e requer uma âncora de origem para comportamento correto. A ausência desse dado é um **risco específico de iPad** que precisa de teste; não é evidência de que o fechamento aconteça na abertura.

### 9. Arquivos iOS gerados não são uma linha de build completa por si só

`GeneratedPluginRegistrant.h`, `GeneratedPluginRegistrant.m`, `Generated.xcconfig`, o ambiente Flutter e o pacote Swift em `ios/Flutter/ephemeral` aparecem como arquivos gerados/ignorados. O projeto Xcode referencia o registrador e o pacote Swift gerado, mas o checkout não contém `Podfile` nem `Podfile.lock` [2] [16]. O pacote Swift gerado declara plataforma iOS 13.0 e nenhum dependency explícito; o target do app declara iOS 15.0 [2].

Isso não prova uma configuração inválida: projetos Flutter atuais podem regenerar artefatos e integrar plugins por mecanismo diferente de um Podfile. Significa, porém, que uma revisão apenas do checkout não confirma a resolução dos módulos nativos. Um clone limpo precisa executar a versão correta do Flutter em macOS e regenerar os arquivos antes de abrir, compilar e arquivar o app.

### 10. As identidades de plataforma devem ser fixadas no suporte

O bundle ID iOS no Xcode é `com.falacomigo.falaComigo`, enquanto o `applicationId` Android documentado é `com.falacomigo.fala_comigo` [2] [5]. IDs diferentes por plataforma são permitidos e não demonstram erro. Contudo, scripts de instalação, coleta de logs, inventário de releases e instruções de suporte precisam registrar ambos. O handoff, o README e alguns relatórios históricos já alternam branch, commit, pacote e hash de artefato [5] [6] [17]. Isso aumenta a chance de testar um binário diferente daquele analisado ou filtrar o pacote errado.

## Matriz dos plugins relevantes

| Plugin/superfície | Versão resolvida | Relação com startup | Avaliação iOS atual |
|---|---:|---|---|
| `flutter_secure_storage` / Keychain | 9.2.4 | **Obrigatória** para abrir as caixas cifradas antes de `ready` | Risco de compatibilidade e estado persistido; sem teste em Keychain real, atualização, restauração ou reinstalação. |
| `hive` / `hive_flutter` | 2.2.3 / 1.1.0 | **Obrigatória** para caixas e cartões antes da grade | Migração captura erro amplo e tenta abrir caixa legada sem cifra; risco de corrupção ser tratada como legado. |
| `path_provider_foundation` | 2.5.1 | Indireta no `Hive.initFlutter`; usada também para temporários | Precisa validar diretórios, sandbox, atualização e limpeza no iOS. |
| `flutter_tts` | 4.2.5 | Adiada após o bootstrap; também acionada ao tocar cartão | Voz pt-BR e disponibilidade de engine são dependentes do aparelho; falha não pode impedir seleção visual. |
| `flutter_local_notifications` | 19.5.0 | Adiada após o bootstrap | Código observado só configura Android; notificações/agendamento iOS não estão demonstrados. |
| `image_picker_ios` | 0.8.13+3 | Sob demanda na Área do Responsável | Chaves de câmera/fototeca existem; falta teste de permissão, cancelamento e captura em iPhone/iPad. |
| `record_ios` | 1.2.1 | Sob demanda na gravação de alertas | Chave de microfone existe; falta teste de interrupção, permissão negada e arquivo temporário. |
| `audioplayers_darwin` | 6.4.0 | Sob demanda na reprodução de mídia/alerta | Falhas de áudio devem ser isoladas da comunicação; falta teste com áudio inválido e rota de saída. |
| `share_plus` | 10.1.4 | Sob demanda no compartilhamento de vídeo | `Share.shareXFiles` não fornece âncora de popover; risco de apresentação no iPad. |
| `printing` | 5.14.3 | Sob demanda na exportação PDF | Falta teste de folha de compartilhamento e cancelamento em iPad. |
| `url_launcher_ios` | 6.3.6 | Sob demanda em links de suporte/política | Sem indício estático de bloqueio; validar retorno quando não há app capaz de abrir o URL. |

## Riscos classificados

### R-01 — P0: disponibilidade iOS não foi provada

Não há build, instalação, primeiro frame, entrada na grade ou uso offline confirmados em iPhone/iPad. O critério do handoff exige validação em celular e tablet antes de tratar o primeiro build como funcional [5] [12]. O risco é de indisponibilidade da comunicação básica, não apenas de acabamento visual.

### R-02 — P0/P1: persistência segura continua no caminho crítico

Keychain, path provider, Hive e migração são pré-requisitos para a tela principal. Uma incompatibilidade de dispositivo, chave persistida, caixa corrompida ou erro de diretório pode impedir o primeiro uso. Esse é um risco sustentado pela ordem do código, não uma causa confirmada do fechamento Android ou de qualquer crash iOS [7] [8].

### R-03 — P1: fallback de migração pode destruir ou mascarar estado local

`openSecureBoxWithMigration` captura qualquer exceção da abertura cifrada e tenta abrir a mesma caixa sem cifra. Depois de copiar os valores, remove a caixa legada e recria a caixa cifrada [8]. O fluxo não distingue no ponto de decisão entre legado válido, chave incompatível, corrupção, formato inválido e falha inesperada. Em iOS, isso precisa ser exercitado com Keychain limpo, atualização, restauração e dados sintéticos incompatíveis. Não se deve mudar o algoritmo ou apagar dados em produção como tentativa de corrigir o fechamento.

### R-04 — P1: notificações iOS têm configuração ausente

O plugin é registrado, mas a inicialização observada fornece somente parâmetros Android. Sem uma configuração Darwin e um fluxo explícito de autorização, não há evidência de que alertas locais funcionem em iOS. O problema afeta o recurso de alertas, não prova um crash de abertura, especialmente porque a inicialização foi adiada e encapsulada em `try/catch` Dart [9] [10].

### R-05 — P1: compartilhamento de vídeo pode falhar na apresentação do iPad

O caminho `Share.shareXFiles` não informa `sharePositionOrigin`. Em iPad, a folha de compartilhamento precisa ser testada em contexto de popover e com cancelamento. O risco aparece quando o responsável compartilha um vídeo, depois da abertura; não deve ser usado para explicar o fechamento inicial sem evidência de etapa e log.

### R-06 — P1: orientação declarada e orientação efetiva não estão alinhadas

O Dart restringe o app a paisagem após o início do bootstrap, enquanto o `Info.plist` permite retrato e paisagem. Isso pode produzir uma primeira cena, transição ou retorno do segundo plano diferente entre iPhone e iPad. A matriz ainda não cobre essa combinação com escala de fonte, VoiceOver e interrupções [4] [7] [12].

### R-07 — P1: reprodutibilidade de plugins nativos depende de geração em macOS

O registrador e o pacote Swift são gerados/ignorados. Sem a geração do Flutter e sem resolver as dependências em macOS, não é possível afirmar que os imports Darwin correspondem ao lockfile ou que o archive foi produzido com o mesmo conjunto de plugins. Esse é um risco de processo e release, não uma prova de erro no projeto Xcode.

### R-08 — P1/P2: áudio não possui validação de fallback equivalente entre plataformas

TTS é inicializado após o primeiro estado pronto, mas `_tts.setLanguage('pt-BR')` e a fala sob demanda dependem das vozes instaladas. Reprodução e gravação também dependem de sessão de áudio, interrupções e permissões do aparelho. O cartão deve continuar selecionável, adicionável à frase e removível mesmo quando o áudio falhar. A matriz de testes ainda não contém a evidência iOS necessária [7] [12] [14].

## Hipóteses sobre o fechamento relatado

As hipóteses abaixo são **investigáveis, não diagnósticos**. A confiança causal é baixa porque não existe logcat do Android nem relatório de crash iOS.

1. **Morte nativa durante criação do engine ou registro de plugin.** O registrador carrega várias superfícies nativas. Um problema de biblioteca, ABI, resolução de dependência ou inicialização nativa poderia encerrar o processo antes de `StartupFailureApp`. Não há log que identifique um plugin, e a leitura estática não prova que isso ocorreu.

2. **Falha no armazenamento seguro, path provider, Hive ou migração.** Esses componentes são efetivamente acessados antes da grade. Uma chave incompatível, caixa corrompida, diretório indisponível ou estado de atualização é plausível. A hipótese é sustentada pelo caminho do código, mas não há evidência que escolha Keychain, Keystore, Hive ou outro componente.

3. **Estado persistido incompatível após atualização ou assinatura diferente.** O projeto tem build de teste e documentos com hashes/commits diferentes. Atualização sobre dados ou binário diferentes deve ser separada de instalação limpa e `pm clear`. Esse cenário não pode ser confirmado sem o artefato instalado, estado do pacote e logs.

4. **Falha no primeiro frame ou provider depois do bootstrap.** O relato não informa se a pessoa vê o loading, a splash ou a grade. Providers dependem de caixas abertas, e a primeira renderização pode expor uma falha distinta da abertura nativa. É necessário registrar a última etapa visual alcançada.

5. **TTS ou notificações.** A hipótese de bloqueio Dart inicial ficou menos provável porque ambos foram adiados para depois do bootstrap e têm captura separada. Ainda existe risco ao registrar ou usar os plugins nativos, principalmente no iOS onde notificações não estão configuradas, mas isso requer teste e log.

6. **Orientação ou compatibilidade específica do aparelho.** A política efetiva de orientação difere entre código e plist, e o app depende de Keychain, áudio, permissões e vários plugins. Sem modelo, versão do sistema e etapa do fechamento, não é possível priorizar esse cenário.

7. **Tamanho do APK, diferença Debug/Release ou chave temporária.** A diferença de tamanho é compatível com modos de build. A chave temporária limita distribuição e atualização, mas não demonstra perda de recursos nem explica o fechamento. Não há base para tratar qualquer um desses fatores como causa.

## Ações recomendadas sem alterar código nesta revisão

### P0 — obter evidência de plataforma e artefato

1. **Executar a validação iOS em macOS**, fixando Flutter 3.38.0, Xcode, commit, `pubspec.lock`, bundle ID iOS, configuração Release e hash do archive. Rodar `flutter pub get`, gerar os artefatos iOS e abrir o projeto pelo fluxo gerado pela versão usada, sem criar um Podfile especulativo apenas para contornar a ausência local.
2. **Testar pelo menos um iPhone e um iPad**, em instalação limpa e atualização sobre dados sintéticos. Registrar primeiro frame, chegada à grade CAA, uso offline, encerramento, reabertura e retorno do segundo plano. Executar em paisagem e registrar o comportamento de orientação.
3. **Para o APK Android, repetir com o arquivo efetivamente instalado**, registrando SHA-256, `applicationId`, versão, assinatura, branch, commit, fabricante/modelo, Android/API e estado de dados. Se fechar, coletar o logcat do aparelho imediatamente. Sem esse artefato, manter a causa como desconhecida.
4. **Quando houver falha iOS**, coletar o crash report do dispositivo ou logs do Xcode/Console imediatamente após a tentativa. Enviar somente metadados técnicos; não incluir frases, nomes, fotos, vídeos, áudio ou tokens.

### P1 — fechar plugins e primeiro uso

5. **Configurar e testar notificações iOS de forma explícita**, usando a inicialização Darwin compatível com a versão resolvida do plugin, autorização contextual, categorias necessárias e comportamento quando a permissão é negada. Separar alertas iOS da promessa Android de tela cheia e alarme exato.
6. **Testar `share_plus` no iPad** a partir de um botão real, com âncora de origem, orientação e cancelamento. Repetir para exportação PDF e compartilhamento de vídeo. Um compartilhamento cancelado ou indisponível não pode encerrar o app.
7. **Exercitar Keychain/Hive em quatro estados sintéticos:** primeira instalação, atualização compatível, chave ausente/incompatível e caixa corrompida. Confirmar que o app preserva ou recupera dados de modo definido, que a migração é idempotente e que o responsável recebe uma mensagem segura.
8. **Validar permissões iOS sob demanda:** câmera, fototeca e microfone concedidos, negados, revogados depois do primeiro uso e interrompidos por outro app. Confirmar que cancelar o seletor ou a gravação não deixa arquivos temporários indevidos nem altera cartões.
9. **Testar áudio isoladamente:** voz pt-BR ausente, volume silenciado, interrupção por chamada/áudio externo, arquivo de alerta corrompido e engine indisponível. A grade deve continuar permitindo selecionar, adicionar e limpar frases.
10. **Revisar a política de orientação.** Decidir se o suporte iOS é sempre paisagem ou se iPhone e iPad têm regras próprias. Alinhar o comportamento declarado no plist com o comportamento esperado e validar primeiro frame, rotação/interrupção permitida e VoiceOver.

### P2 — fortalecer release e suporte

11. Gerar um clone limpo em macOS e confirmar que o Flutter recria o registrador, o `Generated.xcconfig` e o pacote Swift com versões coerentes com `pubspec.lock`. Registrar o comando e a versão de Xcode usados no CI ou no procedimento de release.
12. Fixar no checklist os dois identificadores de plataforma: `com.falacomigo.falaComigo` no iOS e `com.falacomigo.fala_comigo` no Android. Cada suporte deve também guardar versão, build number, commit, hash e assinatura do binário.
13. Adicionar ao diagnóstico sanitizado os marcos de startup — orientação, armazenamento, cada caixa, migração, diagnóstico, seed e primeiro frame — sem registrar conteúdo da criança. Essa observabilidade deve ser complementar, nunca substituta do crash report nativo.
14. Executar revisão de privacidade e segurança iOS separada do MobSF Android. Confirmar sandbox, arquivos temporários, Keychain, compartilhamento explícito e exclusão local. Não tratar o score MobSF do APK como evidência de segurança ou compatibilidade do iOS.

## Confiança da revisão

A confiança é **alta** nos fatos derivados diretamente do checkout: configuração de cena, deployment target, bundle ID iOS, permissões declaradas, plugins registrados, ordem do bootstrap, ausência de configuração Darwin visível para notificações e ausência de ferramentas iOS no ambiente. É **média-alta** nos riscos derivados do caminho de persistência, da migração ampla, da orientação inconsistente e do compartilhamento sem âncora explícita no iPad. É **baixa** para qualquer hipótese causal sobre o fechamento Android ou para afirmar que o iOS compila e executa, porque não existe teste em macOS, dispositivo Apple, logcat Android ou crash report nativo.

## Referências

[1]: ../../ios/Runner.xcodeproj/project.pbxproj "Configuração Xcode do target Runner"
[2]: ../../ios/Runner/GeneratedPluginRegistrant.m "Registro gerado dos plugins iOS"
[3]: ../../ios/Runner/AppDelegate.swift "AppDelegate e inicialização do engine Flutter"
[4]: ../../ios/Runner/Info.plist "Info.plist, cenas, orientações e descrições de privacidade"
[5]: ../AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md "Auditoria do handoff e artefatos Android"
[6]: ../RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md "Diagnóstico de build e instalação Android"
[7]: ../../lib/main.dart "Inicialização Flutter, bootstrap e captura de falhas"
[8]: ../../lib/core/services/secure_box_service.dart "Armazenamento seguro e migração Hive"
[9]: ../../lib/core/services/transition_alert_service.dart "Serviço de alertas e notificações"
[10]: ../../pubspec.yaml "Dependências declaradas do aplicativo"
[11]: ../../pubspec.lock "Versões resolvidas das dependências"
[12]: ../MATRIZ_FLUXOS_CRITICOS.md "Matriz de fluxos críticos e validação manual"
[13]: ../../lib/features/parental_area/presentation/screens/video_diary_screen.dart "Diário de vídeo, câmera e compartilhamento"
[14]: ../../lib/features/parental_area/presentation/screens/transition_alert_edit_screen.dart "Gravação, reprodução e temporários de alertas"
[15]: ../../lib/core/services/media_storage_service_io.dart "Persistência cifrada de mídia e diretórios privados"
[16]: ../../ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift "Pacote Swift gerado pelo Flutter"
[17]: ../../PROJECT_HANDOFF.md "Documento de transferência do projeto"

**Resultado da revisão:** relatório criado sem alteração de código.
