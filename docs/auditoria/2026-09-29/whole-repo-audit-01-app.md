# Auditoria técnica — Aplicativo Flutter, funcionalidades, acessibilidade e testes

**Área:** aplicativo Flutter (`lib/`), testes (`test/`, `tests/`) e assets (`assets/`)

**Checkout auditado:** `/home/ubuntu/fala-comigo`

**Momento da auditoria:** 2026-09-29

## 1. Escopo, método e estado do checkout

A revisão foi somente de leitura: inspeção de arquivos, busca textual e histórico Git. Não foram acessados GitHub, Supabase ou APIs remotas; não foram feitos commits, merges, deploys ou edições no checkout. Também não foram executados `flutter test`, `flutter analyze` ou testes em dispositivo, pois o pedido restringiu a auditoria a comandos de leitura/search e histórico. Portanto, as conclusões abaixo são evidência estática, não um atestado de compilação ou de funcionamento em aparelho.

O checkout está na branch `audit/creator-privacy-alignment`, no commit `cc96eaf` (`feat: preview Espaço do Criador`), exatamente o mesmo commit apontado por `main`/`origin/main`. O worktree, porém, está sujo. No escopo desta auditoria há arquivos Dart alterados e dois conjuntos não rastreados relevantes: `test/data_wipe_service_test.dart` e `tests/creator-console.test.mjs`. Esses arquivos e alterações **não estão no commit `cc96eaf`/`main`**.

Inventário observado:

- `lib/`: 67 arquivos Dart.
- `test/`: 28 arquivos Dart.
- `tests/`: 1 teste Node/MJS, voltado ao site/preview do Creator, não ao app Flutter.
- `assets/`: 16 arquivos, sendo 15 PNGs de cartões e `assets/icons/.gitkeep`.
- `pubspec.yaml` declara Hive/Hive Flutter, `flutter_secure_storage`, `cryptography`, TTS, image picker, compartilhamento/PDF, notificações locais, gravação e reprodução de áudio.
- CI declarada em `.github/workflows/flutter.yml:29-46` exige formatação, análise, `flutter test` e build Web; isso existe como gate configurado, mas não foi executado nesta auditoria.

## 2. Resumo executivo

A base do app tem uma implementação consistente do **núcleo local-first de comunicação**: inicia Hive, semeia cartões, apresenta uma grade CAA, monta frases, fala em português e mantém o modo básico sem conta, rede ou plano pago. O gate parental, o armazenamento cifrado e a separação visual entre área infantil e parental são pontos fortes reais.

A segurança local é melhor que um protótipo puramente demonstrativo: boxes são abertas pela camada cifrada, mídias nativas novas usam AES-GCM, o PIN usa PBKDF2 com salt e há bloqueio progressivo. Exportação e compartilhamento exigem ação explícita do responsável e há avisos sobre cópias que deixam o app.

O produto ainda não deve ser descrito como uma solução conectada completa. Acesso de organizações, tarefas compartilhadas e coordenação são **modelos e armazenamento locais**, com fila de sincronização sem consumidor remoto; o próprio UI registra que aceite/sincronização virão depois. Mídia personalizada Web está deliberadamente bloqueada. Há também três problemas objetivos que precisam de correção antes de um piloto que dependa de previsibilidade: o wipe não cancela alarmes já agendados; a orientação escolhida não é aplicada no cold start; e planos salvos na aba de continuidade não são carregados de volta na tela.

O worktree contém uma correção pequena para o wipe: reabre `parent_reminders` depois da limpeza (`lib/core/services/data_wipe_service.dart:60-62`) e um teste novo. A `main` em `cc96eaf` **não contém essa reabertura**; a correção está somente no worktree, não deve ser reportada como entregue em `main`. Ela melhora o reset em processo, mas não resolve o cancelamento das notificações do sistema.

## 3. Funcionando agora — evidência estática

### 3.1 Fluxo primário da criança

- `lib/main.dart:22-54` inicializa Flutter/Hive, registra o adapter de `PictogramCard`, abre as boxes principais cifradas e semeia `SeedCards.defaultCards()` quando a box está vazia.
- `lib/main.dart:161-175` oferece estado de carregamento, erro recuperável com “Tentar novamente” e só então abre o `SplashScreen`.
- `lib/features/onboarding/presentation/screens/splash_screen.dart:36-45` navega para a grade inicial após a abertura; a grade em si está em `lib/features/aac_grid/presentation/screens/aac_grid_screen.dart:62-275`.
- `lib/features/aac_grid/presentation/screens/aac_grid_screen.dart:217-265` calcula colunas responsivas, filtra categorias e conecta cada cartão a TTS e/ou à barra de frase de acordo com `CardTapBehavior`.
- `lib/features/aac_grid/data/providers/cards_provider.dart:126-145` mantém a frase em ordem, gera texto falado, remove por índice com guarda contra índice obsoleto e limpa a frase.
- `lib/features/aac_grid/presentation/widgets/sentence_bar_widget.dart:51-60` expõe cada cartão da frase como ação acessível de remover; `:104-146` oferece “Falar” e “Limpar frase”.
- A rotina visual é persistida por `VisualRoutineStore` em `lib/features/aac_grid/data/providers/visual_routine_provider.dart:47-72`, com tela infantil somente leitura e edição parental em `visual_routine_screen.dart:85-139`.

### 3.2 Gate parental e estado de sessão

- `lib/features/parental_area/presentation/screens/parental_gate_screen.dart:40-93` diferencia primeiro uso de autenticação, exige PIN de quatro dígitos e limpa o campo após falha.
- `lib/core/services/parental_pin_service.dart:7-11,47-123` usa PBKDF2-HMAC-SHA256 com 100.000 iterações, salt aleatório, comparação em tempo constante, atraso progressivo e bloqueio após cinco falhas.
- `lib/core/services/parental_session_service.dart:5-41` não persiste a sessão, expira em dez minutos e invalida ao ir para segundo plano; `lib/main.dart:135-151` força nova passagem pelo gate ao retornar.
- `lib/features/parental_area/presentation/screens/parental_area_transition_screen.dart:31-59` libera as orientações para o painel e mantém uma transição separada para a área adulta.

### 3.3 Armazenamento e privacidade local

- `lib/core/services/secure_box_service.dart:6-56` usa uma chave Hive AES guardada em `flutter_secure_storage` e tem migração de boxes legadas sem cifra, removendo a cópia legada somente após criar/preencher a box cifrada.
- `lib/core/services/media_storage_service_io.dart:9-69` grava mídias nativas na pasta privada do app, limita a 100 MB, valida extensões e cifra novas mídias com AES-GCM-256; `:144-167` autentica a descriptografia usando chave no cofre do sistema.
- `lib/core/services/parental_pin_service.dart:75-80` tem limpeza explícita de credenciais.
- Perfil, ABC, diário de vídeo, rotina, acessos, tarefas, fila local, coordenação e licença passam por boxes abertas com `SecureBoxService`; exemplos: `patient_profile_screen.dart:43-57`, `behavior_log_screen.dart:42-47`, `care_coordination.dart:227-259`, `shared_tasks.dart:184-227`.
- A tela de privacidade comunica corretamente limites relevantes em `lib/features/parental_area/presentation/screens/privacy_settings_screen.dart:45-95`: armazenamento local, compartilhamento não automático, exportação fora do armazenamento protegido e impossibilidade de apagar cópias já exportadas.
- Perfil sensível só é salvo após confirmação de responsável/autorizado em `lib/features/parental_area/presentation/screens/patient_profile_screen.dart:69-102`; os valores são gravados na box cifrada.
- PDFs são construídos localmente e compartilhados somente após ação do usuário: `data_export_screen.dart:122-163,166-235` e `behavior_log_screen.dart:109-162,169-241`. O perfil identificador fica desmarcado por padrão no exportador (`data_export_screen.dart:309-317`).

### 3.4 Acessibilidade já presente

- `lib/features/aac_grid/presentation/widgets/grid_card.dart:59-75` transforma cada cartão em um único nó semântico acionável, com rótulo, hint de ação e guarda de toque; `:72-75` impõe dimensões mínimas de toque.
- Categorias usam `ChoiceChip` e controles do Material em `aac_grid_screen.dart:278-311`; a barra de frase usa `Semantics` explícita, em vez de deixar a imagem interna competir com a ação.
- Há tooltips em ações relevantes da grade, rotina, exportação, limpeza da frase, teste de alerta e controles de mídia selecionados.
- Os controles parentais usam botões com altura mínima de 52–56 px em vários fluxos; exemplos `add_card_screen.dart:290-311`, `care_coordination_screen.dart:574-585` e `parental_gate_screen.dart:262-277`.
- Existem preferências de orientação e de tema de hiperfoco persistidas no `app_settings`: `app_orientation_service.dart:13-27,50-64` e `hyperfocus_theme.dart:87-106`.

### 3.5 Testes e reprodutibilidade já presentes

- Há cobertura unitária/modelo para PIN, sessão, autorização RH, licença, cartões, frase, rotina, alertas, lembretes, tarefas, coordenação, tendências e planos.
- Há testes widget específicos para semântica do cartão (`test/grid_card_semantics_test.dart:16-52`), remoção acessível da frase (`test/sentence_bar_widget_test.dart`), splash, transição parental, status do plano, privacidade e fallback Web.
- O teste semântico do cartão verifica label, flag de botão, ação de toque e ausência de filhos semânticos (`grid_card_semantics_test.dart:44-51`), que é uma boa proteção contra regressão de dupla leitura/dupla ação.
- O CI exige `dart format`, análise, testes e build Web (`.github/workflows/flutter.yml:29-46`), e a configuração Codemagic exige análise/testes antes de APK/AAB (`codemagic.yaml:21-28`).

### 3.6 Assets

- `assets/images/cards/` contém 15 imagens PNG 400×400: `agua`, `ajuda`, `beber`, `bravo`, `brincar`, `comer`, `dormir`, `feliz`, `maca`, `mamae`, `nao`, `pao`, `papai`, `sim`, `triste`.
- O `pubspec.yaml` inclui a pasta de cartões e `assets/icons/`; a pasta de ícones está vazia além de `.gitkeep`.
- A grade tem `errorBuilder` para asset ausente em `grid_card.dart:48-55`, evitando uma exceção visual imediata e exibindo placeholder.

## 4. Incompleto, protótipo ou dependente de decisão de produto

### 4.1 Rede de cuidado e portal

- `lib/features/parental_area/presentation/screens/access_management_screen.dart:35-47,351-365` cria convite local com status `pending`; não há envio, aceite remoto, autenticação de organização ou atualização para `active` no app.
- A própria tela declara que o registro é local e que sincronização/aceite remoto virão no portal (`access_management_screen.dart:383-388`). O modelo e a box (`access_grants.dart:104-129`) persistem apenas o espelho local.
- `lib/features/parental_area/data/shared_tasks.dart:202-214` grava tarefa e uma fila local `shared_task_sync_queue`, mas não há consumidor dessa fila nem transporte remoto em `lib/`. O formulário confirma que o agendamento será conectado na próxima etapa (`shared_tasks_screen.dart:604-612`).
- As políticas RH em `lib/core/authorization/rh_authorization_policy.dart:42-171` e `rh_elevated_access.dart:33-90` são bons contratos de decisão, mas não são uma integração de autorização de servidor; não se deve tratá-las como enforcement remoto implementado.

### 4.2 Coordenação do cuidado

- O perfil funcional carrega e salva (`care_coordination_screen.dart:62-109`), e a agenda carrega e exibe compromissos (`:393-405,505-555`).
- A aba de plano cria e salva `CommunicationPlan` (`care_coordination_screen.dart:219-276`), mas não tem `initState`/`loadPlans` nem lista de planos. Depois de sair e voltar à aba/tela, o plano salvo não é carregado nem mostrado. O store tem `loadPlans` em `lib/features/parental_area/data/care_coordination.dart:240-248`, mas a UI não o usa.
- “Lembrar no aparelho” na agenda apenas grava `reminderEnabled` (`care_coordination_screen.dart:494-500`, `:430-441`); não chama `TransitionAlertService` nem agenda uma notificação. É um campo de produto ainda não conectado, não um lembrete funcional.

### 4.3 Mídia Web e compatibilidade

- `lib/core/services/media_storage_service_web.dart:3-36` bloqueia persistência, leitura e materialização de mídia privada Web com `UnsupportedError`; o fallback de imagem é intencional, testado em `test/media_web_fallback_test.dart:9-47`.
- Isso é uma decisão de privacidade coerente, mas significa que adicionar cartões com foto, diário de vídeo e áudio gravado não é paridade Web. O build Web pode passar enquanto esses fluxos permanecem indisponíveis.
- No nativo, a compatibilidade com arquivos legados permite materializar bytes sem o magic `FCM1` como plaintext (`media_storage_service_io.dart:121-141`). Não há re-cifra automática dessa mídia no acesso; a migração de arquivos legados precisa ser explicitada antes de afirmar que todo arquivo histórico está cifrado em repouso.

### 4.4 Preferências e previsibilidade

- O slider de tamanho dos botões muda apenas o `StateProvider` (`settings_screen.dart:134-146`); `buttonScaleProvider` inicia sempre em `1.0` (`cards_provider.dart:148-149`) e não salva em `app_settings`. A preferência desaparece após reinício do processo.
- `main.dart:27-35` força paisagem no bootstrap. Apesar de `AppOrientationService` guardar `child_orientation` e saber aplicá-la, o bootstrap não chama `applyChildOrientation()` nem lê a preferência. Assim, uma escolha persistida de vertical não é respeitada no cold start; ela só volta a ser aplicada quando o responsável altera a opção ou ao sair do painel.
- O `settingsLockedProvider` declarado em `cards_provider.dart:179-180` não tem consumidores na aplicação; não constitui uma proteção efetiva.

## 5. Bloqueadores objetivos e riscos críticos

### R1 — wipe local não cancela notificações do sistema (alta prioridade)

`DataWipeService.deleteAllLocalData()` fecha/apaga as boxes, limpa diretórios de mídia, remove chaves e PIN e reabre boxes vazias (`lib/core/services/data_wipe_service.dart:33-73`). Entretanto, não chama nenhum cancelamento global do plugin de notificações. `TransitionAlertService` só expõe cancelamento por alerta/lembrete (`transition_alert_service.dart:188-192,237-243`); não existe `cancelAll` usado pelo wipe. As entradas de `transition_alerts` e `parent_reminders` podem ser apagadas enquanto os alarmes recorrentes continuam registrados no Android/iOS. Isso pode produzir alertas depois de “Apagar todos os dados”, com payload apontando para um alerta inexistente, além de violar a expectativa de exclusão completa. É risco de comportamento residual e de privacidade contextual.

**Correção no worktree versus `main`:** o worktree adiciona somente `await SecureBoxService.openSecureBox('parent_reminders');` em `data_wipe_service.dart:62`; no `main` (`git show HEAD:lib/core/services/data_wipe_service.dart`) essa linha não existe. O arquivo `test/data_wipe_service_test.dart` também é não rastreado. A alteração melhora a disponibilidade da box após o reset em processo, mas **não cancela notificações e não está em `main`**.

### R2 — preferência de orientação é ignorada após reinício (alta prioridade de acessibilidade)

O app pode salvar vertical/paisagem (`app_orientation_service.dart:50-64`), mas `main.dart:29-32` sempre redefine as orientações para paisagem. Em um tablet/celular montado verticalmente, o resultado após cold start diverge da escolha explícita do responsável. Isso é uma regressão funcional objetiva em acessibilidade e pode alterar tamanho/quantidade dos cartões.

### R3 — plano de comunicação salvo desaparece da UI (alta prioridade de confiança no estado local)

`CommunicationPlan` é persistido, e existe `CareCoordinationStore.loadPlans`, mas `_CommunicationPlanTabState` não carrega planos ao iniciar e tampouco renderiza os salvos (`care_coordination_screen.dart:212-276`; `care_coordination.dart:240-248`). O usuário pode receber “salvo localmente” e, ao reabrir, ver formulário vazio. É perda de visibilidade do estado, ainda que os bytes possam continuar na box.

### R4 — falhas de TTS/gravação não têm fronteira uniforme (média/alta para uso real)

O caminho infantil chama `TtsService.instance.speak(card.label)` sem `await`/tratamento (`aac_grid_screen.dart:252-255`); a barra aguarda a fala mas também não apresenta erro ao usuário (`sentence_bar_widget.dart:104-109`). `TtsService` só inicializa idioma/parâmetros, sem fallback ou estado de engine (`tts_service.dart:15-35`). Gravação/materialização no diário e no alerta também não envolve todo o fluxo em tratamento (`video_diary_screen.dart:55-64`; `transition_alert_edit_screen.dart:107-158`). Permissão recusada, engine ausente, arquivo corrompido ou armazenamento cheio podem virar erro assíncrono sem feedback previsível.

### R5 — segurança de sessão é global, mas não há enforcement declarativo nas telas

A sessão global é bloqueada por lifecycle/timeout (`main.dart:135-151`), mas `ParentalSessionService.requireSession()` só aparece no próprio serviço e nos testes; as telas parentais não o consultam. O fluxo normal depende do gate e do callback global, não de uma guarda por rota. Isso merece revisão antes de adicionar deep links, rotas externas ou novas telas parentais: a propriedade “qualquer rota parental exige sessão” não está expressa no código de navegação.

## 6. Acessibilidade — lacunas específicas

- O cartão CAA e a remoção da frase têm semântica explícita; esse padrão não é aplicado de forma sistemática às áreas parentais. Por exemplo, `settings_screen.dart:366-385` tem botões de editar/excluir sem `tooltip` explícito; `behavior_log_screen.dart:395-400`, `video_diary_screen.dart:314-325` e `transition_alert_edit_screen.dart:433-451` também têm ícones de ação sem rótulo/tooltip próprio.
- A tela nativa de mídia privada retorna somente ícone em erro/carregamento (`secure_media_image_io.dart:20-34`); não há label/hint semântico para explicar mídia ausente/corrompida. O fallback Web tem tooltip, mas não foi demonstrado em teste de leitor de tela (`secure_media_image_web.dart:17-21`).
- Há dimensões fixas relevantes: barra da frase com `height: 96` e botão mínimo `64` (`sentence_bar_widget.dart:21,127-140`), grade com `childAspectRatio: 0.85` (`aac_grid_screen.dart:225-235`) e alerta em tela cheia com indicador fixo de 180×180 (`transition_alert_full_screen.dart:112-133`). Não há teste de `MediaQuery.textScaler`, fonte grande, contraste real, orientação vertical ou overflow nos fluxos principais.
- Os controles são majoritariamente Material e têm foco/semântica padrão, mas faltam testes de teclado, TalkBack/VoiceOver, switch access, leitor de tela, alto contraste e toque assistivo em aparelho.
- A área infantil usa emojis decorativos em vários `Text` sem evidência de exclusão semântica; a repetição de emoji/tema deve ser verificada com leitor de tela, especialmente no fundo de hiperfoco (`aac_grid_screen.dart:330-357`) e nos tiles da rotina (`visual_routine_screen.dart:227-239`).

## 7. Qualidade e lacunas dos testes

### Cobertura que existe

- `test/parental_pin_service_test.dart:46-107` cobre primeiro uso, PINs fracos, bloqueio, troca e limpeza.
- `test/cards_notifier_test.dart:28-117` cobre adicionar, editar, marcar imagem personalizada, reordenar e remover, mas usa box Hive de teste simples.
- `test/grid_card_semantics_test.dart:16-52` cobre um cartão isolado; `test/sentence_bar_notifier_test.dart:21-57` cobre a máquina de estado; `test/sentence_bar_widget_test.dart` cobre remoção acessível.
- Há testes de serialização para modelos de rotina, alertas, coordenação, tarefas e tendências, e políticas de autorização/licença.
- O teste do worktree `test/data_wipe_service_test.dart:74-89` verifica que um lembrete salvo deixa de ser carregado após o wipe, usando mocks de `flutter_secure_storage`/`path_provider` (`:14-62`). Isso é uma boa regressão mínima para a box, mas é ainda não rastreado e não cobre o sistema de notificações.

### Lacunas objetivas

- A maioria dos 28 testes Dart é unitária/modelo. Os testes widget identificados são poucos e não cobrem a composição completa de `AACGridScreen`, `SettingsScreen`, `ParentalGateScreen`, `AddCardScreen`, `VideoDiaryScreen`, `DataExportScreen`, `CareCoordinationScreen`, `ParentRemindersScreen`, `TransitionAlertsListScreen` ou `TransitionAlertEditScreen`.
- Não há teste do cold start respeitando `ChildOrientation`, nem persistência/reload do `buttonScaleProvider`.
- Não há teste de integração do wipe sobre todas as boxes listadas em `data_wipe_service.dart:15-31`, mídia cifrada, chave Hive, chave de mídia, PIN, drafts de cartão, fila de sincronização e licença.
- Não há teste que prove que alarmes recorrentes são cancelados depois do wipe; nem teste do cenário em que uma notificação antiga toca quando a box/alerta foi removido.
- `media_storage_service_test.dart:8-27` verifica somente origem ausente e caminho ausente; não prova round-trip AES-GCM, rejeição de alteração, limite de tamanho, extensões, limpeza de preview ou rejeição de caminho fora da área privada.
- Não há teste do fluxo de permissão/erro do TTS, câmera, microfone, `share_plus`, impressão PDF ou notificações locais. Também não há teste real de background/lock screen.
- Não há teste de persistência da aba de planos, nem de agenda com lembrete; `care_coordination_test.dart` valida apenas serialização (`:9-71`).
- Não há teste de acessibilidade para escala de fonte, foco por teclado, semântica dos controles parentais, alertas em tela cheia ou placeholders nativos. A única asserção forte de semântica é a do cartão isolado.
- O CI verifica Web release, mas os fluxos nativos de notificações, câmera, microfone, áudio e mídia não são exercitados pelo pipeline descrito. O teste MJS em `tests/creator-console.test.mjs:11-43` valida HTML do site/preview e não aumenta a confiança no aplicativo Flutter.

## 8. Recomendações priorizadas

1. **Completar o wipe transacional:** adicionar cancelamento global/por prefixo de todas as notificações do app antes de apagar boxes; limpar previews, gravações temporárias e chaves; reabrir somente o conjunto necessário; tornar a operação idempotente; incluir teste de todas as boxes, chaves e agendamentos. Registrar a correção atualmente só no worktree separadamente de `main`.
2. **Corrigir orientação no bootstrap:** substituir o hard-code de paisagem por `AppOrientationService.applyChildOrientation()` após abrir `app_settings`; adicionar teste de cold start para vertical/paisagem. Persistir também o tamanho dos botões (ou informar claramente que é sessão) em `app_settings`.
3. **Fechar o ciclo de estado da coordenação:** carregar/renderizar `loadPlans`, permitir editar/arquivar/remover planos e decidir explicitamente se lembrete de agenda será implementado via notificações ou removido da UI até haver serviço. Fazer o mesmo para tarefas: ou conectar fila com backend autorizado, ou rotular a funcionalidade como rascunho local em toda a experiência.
4. **Criar uma camada de erro de recursos:** capturar TTS, camera/microfone, cifra, materialização, compartilhamento e PDF; mostrar mensagem acionável; manter o cartão/frase utilizável quando áudio falhar; apagar arquivo temporário/pending quando persistência falhar.
5. **Reforçar a autorização de rota:** centralizar uma guard de sessão para toda rota parental e testar expiração, retorno do background, back navigation e abertura por payload de notificação. Não depender apenas de callback global.
6. **Ampliar semântica e testes de acessibilidade:** dar labels/tooltips a todos os icon-only actions, revisar emojis decorativos, fornecer estado semântico para loading/erro de mídia e testar com text scale, teclado, leitor de tela e orientação vertical.
7. **Adicionar integração Flutter nativa:** smoke test do caminho splash → grade → frase → gate → settings; persistência/reload real de Hive cifrado; wipe; notificações; mídia; e cenários de caixa ausente/corrompida. Manter unit tests dos modelos, mas não usá-los como substituto dos fluxos.
8. **Separar claramente release local de protótipos conectados:** documentação e UI devem afirmar que convites, tarefas e coordenação remota ainda não enviam/recebem dados; qualquer futura integração precisa aplicar organização, finalidade, escopo, consentimento, expiração e auditoria no servidor, não apenas nos enums locais.

## 9. Validações futuras em dispositivo/piloto

Antes de pilotar com uma família, validar em pelo menos um Android físico de baixo/médio custo e um iPhone/iPad compatível, com dados sintéticos:

- cold start sem internet, reinício após matar processo, recuperação de boxes legadas e persistência de cartões/frase/rotina/orientação;
- grade em paisagem e vertical, fonte grande, TalkBack/VoiceOver, contraste, switch/accessibility input, toque repetido e prevenção de dupla ação;
- TTS pt-BR sem engine, volume baixo, interrupção de fala, áudio indisponível e fallback sem travar a comunicação;
- câmera/galeria/microfone com permissões negadas, Activity destruída e recuperada, armazenamento cheio, arquivos grandes/corrompidos e limpeza de arquivos temporários;
- notificação com app aberto, fechado e tela bloqueada; permissões de notificação, alarme exato e full-screen; fuso/horário de verão; cancelar/editar/remover alerta;
- sequência “agendar lembrete → apagar todos os dados → reiniciar”: nenhum alerta antigo deve aparecer e nenhuma mídia/chave/PIN/box deve permanecer utilizável;
- exportar PDF com e sem perfil, revisar o conteúdo enviado pelo share sheet e verificar que nenhuma cópia local inesperada é criada;
- expiração de sessão por tempo, background, rotação, retorno à área infantil e tentativa de abrir rotas parentais após bloqueio;
- teste piloto de compreensão: criança consegue localizar cartões e concluir frase; responsável entende o que é local, o que sai do aparelho e que convites/tarefas são apenas protótipos locais; profissional não recebe acesso sem consentimento/fluxo remoto real.

## Conclusão

O **núcleo CAA offline e a proteção local estão em estado funcional promissor**, com evidência de boas decisões de privacidade, semântica no caminho principal e uma suíte unitária relevante. O estado atual não sustenta ainda a afirmação de produto conectado nem de exclusão local completa. Os gates objetivos para avançar são: cancelar notificações no wipe (correção ainda só no worktree), respeitar orientação salva, corrigir a leitura dos planos persistidos, tratar falhas de áudio/mídia e validar os fluxos nativos em dispositivo real.
