# Auditoria técnica — Flutter Web e integração com o navegador

**Projeto:** `/home/ubuntu/fala-comigo`\
**Área auditada:** Flutter Web, integração com o navegador, armazenamento/mídia condicional, stubs de plataforma, inicialização, notificações, privacidade e prontidão de build/hosting.\
**Data da leitura:** 29/09/2026.\
**Modo:** somente leitura; nenhum arquivo do repositório foi editado, nenhum commit/merge/deploy foi executado e nenhuma API externa, GitHub ou Supabase foi acessada.

## 1. Escopo, método e estado do checkout

Foram lidos `AGENTS.md`, `CONTINUAR_AQUI_PRIMEIRO.md`, `PROJECT_HANDOFF.md`, o código de `lib/`, `web/`, testes, workflows e histórico Git local. Foram usados `git status`, `git diff`, `git log`, busca textual e leitura numerada de arquivos.

O checkout está na branch `audit/creator-privacy-alignment`, em `cc96eaf` (`feat: preview Espaço do Criador (#86)`), e está **sujo**: há alterações não commitadas em serviços, telas, workflows, documentação, testes e arquivos gerados, além de arquivos novos. O relatório avalia o estado efetivamente presente no worktree, não apenas o `HEAD`; essa diferença precisa ser preservada ao interpretar resultados anteriores.

A toolchain local `flutter`, `dart` e `adb` não está instalada. Portanto, não foi executado um novo `flutter analyze`, `flutter test`, `flutter build web`, teste de navegador ou teste em dispositivo nesta auditoria. Existe um diretório prévio `build/web` e a documentação registra builds Web anteriores, mas eles são evidência histórica/artefato existente, não uma validação nova e limpa deste relatório.

## 2. Resumo executivo

O núcleo CAA tem uma base razoável para um alvo Web: a inicialização é assíncrona, o erro de bootstrap deixou de resultar necessariamente em tela branca, os cartões padrão usam assets e não dependem de `dart:io`, e o armazenamento de mídia foi separado por export condicional. O stub Web falha de modo explícito para mídia privada em vez de fingir que uma foto ou vídeo foi cifrado. Há testes unitários/widget para esse fallback e workflows que incluem análise, testes e build Web.

Isso **não equivale a paridade funcional nem prontidão de publicação Web**. Mídia personalizada está deliberadamente bloqueada; a interface ainda oferece fluxos de câmera/galeria, vídeo, áudio gravado e compartilhamento sem uma política Web uniforme. Alertas e notificações são implementados somente com configurações Android/iOS/macOS e não há uma implementação de Notifications API/service worker para o navegador. A tela de edição de alertas importa `dart:io` diretamente em código alcançável pela Área do Responsável, contrariando o próprio critério documentado de compatibilidade Web e exigindo nova validação/refatoração antes de afirmar portabilidade.

A persistência local usa Hive cifrado e `flutter_secure_storage`, mas a documentação do serviço descreve Keystore/Keychain nativos e não há contrato, threat model ou teste específico para a variante Web (origens, contexto seguro, armazenamento de chave, múltiplas abas, quota, limpeza e acesso por scripts da mesma origem). A política de privacidade faz declarações amplas de cifragem local que não distinguem Web de Android/iOS. Por fim, o CI gera/testa `build/web`, mas não publica esse artefato: o workflow de Pages publica somente `site/`. O destino permanente do Flutter Web, `base href`, headers e procedimento de cache/rollback continuam sem definição operacional.

## 3. O que está funcionando agora / forças implementadas

### 3.1 Inicialização e recuperação de falha

- `lib/main.dart:22-25` chama `WidgetsFlutterBinding.ensureInitialized()` e inicia o app sem bloquear o `runApp` na inicialização de serviços.
- `lib/main.dart:27-57` concentra o bootstrap: orientação, `Hive.initFlutter()`, registro do adapter `PictogramCard`, abertura das caixas e seed dos cartões padrão. A caixa `pictogram_cards` é aberta tipada como `Box<PictogramCard>` (`lib/main.dart:42-54`), coerente com o histórico local da correção da tela branca.
- `lib/main.dart:29-35` trata falha de orientação como preferência de UX, permitindo que a inicialização continue no navegador.
- `lib/main.dart:161-175` mostra loading enquanto o bootstrap está pendente e uma tela de erro com retry quando falha; `lib/main.dart:201-242` informa que nenhum dado foi apagado. Isso é uma proteção concreta contra uma tela branca silenciosa.
- `lib/main.dart:89-100` trata TTS e alertas como serviços opcionais depois do primeiro frame. Essa decisão ajuda a preservar o núcleo CAA quando um plugin não existe ou não está disponível na plataforma, embora também esconda a indisponibilidade (ver riscos abaixo).

### 3.2 Núcleo CAA sem dependência direta de mídia privada

- `lib/features/aac_grid/presentation/screens/aac_grid_screen.dart:217-265` calcula uma grade responsiva e monta os cartões; o caminho de cartões padrão (`isCustomImage == false`) usa `Image.asset` em `lib/features/aac_grid/presentation/widgets/grid_card.dart:48-55`.
- O toque, a montagem de frase e os modos de comportamento estão em código Dart/Flutter compartilhado (`aac_grid_screen.dart:243-263` e `cards_provider.dart:151-177`), sem import direto de `dart:io` nesse núcleo.
- A orientação é tratada com `try/catch` no bootstrap. No Web, a preferência nativa pode ser ignorada sem impedir a grade, desde que os outros caminhos compilem e inicializem.

### 3.3 Separação de mídia por plataforma e falha segura

- `lib/core/services/media_storage_service.dart:1-2` usa export condicional: a implementação IO não é escolhida quando `dart.library.html` está presente.
- `lib/core/widgets/secure_media_image.dart:1-2` aplica a mesma separação para o widget de imagem privada.
- `lib/core/services/media_storage_service_web.dart:16-30` aceita a assinatura atual com `extensionHint` e lança `UnsupportedError` com mensagem explícita para persistência/materialização. O alinhamento desse parâmetro também aparece como alteração local no `git diff`, resolvendo o contrato que havia sido apontado no histórico como causa de falha de compilação Web.
- `lib/core/widgets/secure_media_image_web.dart:3-23` exibe um placeholder acessível com `Tooltip`, em vez de tentar ler um caminho nativo inexistente.
- `lib/features/parental_area/presentation/screens/add_card_screen.dart:105-136` captura `UnsupportedError` e informa ao responsável que a mídia não está disponível nessa plataforma.
- `test/media_web_fallback_test.dart:8-31` verifica as exceções explícitas; `:33-47` verifica o placeholder acessível. Isso cobre o comportamento de bloqueio, não suporte real de mídia.

### 3.4 Segurança e privacidade com intenção local-first

- A implementação nativa documenta AES-GCM-256 e chave protegida por armazenamento seguro em `lib/core/services/media_storage_service_io.dart:9-13`, com limite de tamanho/extensões (`:23-34`) e validação de caminho próprio (`:176-200`). Esse código não é o caminho Web, mas mostra uma política de fail-closed no alvo nativo.
- `lib/core/services/secure_box_service.dart:28-57` centraliza caixas Hive com `HiveAesCipher` e migração legada; isso evita espalhar a abertura das caixas pelo app.
- Os textos de notificação são genéricos (`lib/core/services/transition_alert_service.dart:176-180` e `:224-233`), sem inserir contexto clínico ou conteúdo da criança na mensagem.
- O compartilhamento do diário de vídeo exige confirmação e explica que o vídeo/contexto será entregue ao destino escolhido (`lib/features/parental_area/presentation/screens/video_diary_screen.dart:103-134`).
- A UI de privacidade comunica armazenamento local, compartilhamento manual e exclusão (`lib/features/parental_area/presentation/screens/privacy_settings_screen.dart:45-80`). A política pública também declara ausência de upload automático (`privacy_policy.html:52-60`, `:88-99`). Essas são boas intenções e guardrails de produto, mas ainda precisam ser escopadas e comprovadas especificamente no navegador.

### 3.5 Gates automatizados e artefatos

- `.github/workflows/flutter.yml:20-46` fixa Flutter 3.38.0, executa `pub get`, formatação, análise, testes e `flutter build web --release`.
- `codemagic.yaml:34-50` tem um workflow Web separado que executa análise/testes e preserva `build/web/**` como artefato.
- O lockfile confirma variantes Web para parte do conjunto de plugins: `flutter_secure_storage_web` (`pubspec.lock:441-448`), `image_picker_for_web` (`:571-578`), `record_web` (`:947-954`), `audioplayers_web` (`:84-91`) e `url_launcher_web` (`:1168-1175`). Isso é um indicador de disponibilidade de pacotes, não prova de que os fluxos do produto estão integrados ou funcionando no navegador.

## 4. Incompleto, protótipo ou limitado por desenho

### 4.1 Mídia personalizada não existe no Web

O stub Web é intencionalmente um bloqueio: `persistFile` e `materializeForReading` sempre falham (`lib/core/services/media_storage_service_web.dart:16-30`), enquanto `deleteFile`, `clearAllMedia` e `deleteEncryptionKey` são no-op (`:32-36`). Não há Blob URL, IndexedDB de mídia, File System Access API, Web Crypto, política de quota ou descarte de object URLs.

A limitação chega à experiência do usuário de forma inconsistente:

- Adicionar cartão abre opções de galeria/câmera (`add_card_screen.dart:210-230`), mas a persistência falha depois que o navegador entrega o `XFile` (`:105-130`). Há mensagem, porém o fluxo continua parecendo disponível até o último passo.
- O diário chama `ImagePicker.pickVideo` e então `MediaStorageService.persistFile` sem capturar `UnsupportedError` (`video_diary_screen.dart:55-65`). Em Web, essa ação pode deixar uma exceção não tratada ou uma tela sem feedback adequado.
- Compartilhar uma entrada depende de `materializeForReading` e `Share.shareXFiles` (`video_diary_screen.dart:125-134`), ambos sem caminho Web funcional para o arquivo privado.
- A tela de alerta gravado possui gravação, caminho temporário e cópia para o storage privado, mas não tem fallback Web (`transition_alert_edit_screen.dart:98-154`).

Conclusão: o navegador pode, no máximo, oferecer o núcleo com cartões padrão e dados textuais; não deve ser descrito como paridade com o app nativo enquanto essa limitação estiver ativa.

### 4.2 Código nativo alcançável no bundle Web

`lib/features/parental_area/presentation/screens/transition_alert_edit_screen.dart:1` importa `dart:io` diretamente. O mesmo arquivo usa `getTemporaryDirectory`/`Directory` (`:98-104`) e `File.delete` (`:109-114`). Não existe export condicional para esse editor nem stub Web.

Esse arquivo é alcançável pela cadeia normal da Área do Responsável: `settings_screen.dart:24` importa `transition_alerts_list_screen.dart`, que importa o editor (`transition_alerts_list_screen.dart:6-8`), e `parental_gate_screen.dart:8-9` importa `settings_screen.dart`. O critério do próprio plano exige “ausência de import direto de `dart:io` em código compartilhado” (`docs/PLANO_SEQUENCIAL_ATE_BUILD.md:125-131`). Mesmo existindo um `build/web` prévio, o código-fonte atual não satisfaz esse contrato; deve ser corrigido ou isolado e o build limpo deve ser repetido.

### 4.3 Notificações são nativas, não Web

- `lib/core/services/transition_alert_service.dart:54-64` cria `InitializationSettings` somente para Android, iOS e macOS; não há configuração Web.
- `:66-79` chama `initialize` e consulta launch details sem uma implementação de navegador própria.
- `:98-113` só solicita permissões de Android/iOS; `:117-128` retorna a mensagem genérica de plataforma não verificável quando não encontra Android.
- Ainda assim, a UI apresenta autorização, teste em 30 segundos, disparo imediato e agendamento (`transition_alerts_list_screen.dart:60-113`, `:184-211`, `parent_reminders_screen.dart:38-78`). O editor salva o alerta e tenta agendar (`transition_alert_edit_screen.dart:205-229`). Alguns caminhos capturam falhas, mas o produto não desativa nem explica de forma sistemática que a função não existe no navegador.
- Não há código de `Notification`, `service worker` próprio, permissão de notificações Web, sincronização de alarme ou estratégia para aba fechada. O `flutter_service_worker.js` encontrado em `build/web` é um artefato gerado de cache do Flutter, não uma implementação de alertas de transição.

O texto genérico das notificações é um ponto forte de privacidade, mas não transforma o recurso em compatível com Web.

### 4.4 TTS sem contrato de capacidade do navegador

`lib/core/services/tts_service.dart:15-28` configura `flutter_tts` para `pt-BR` e o bootstrap engole falhas (`main.dart:89-94`). Porém `aac_grid_screen.dart:252-255` chama `TtsService.instance.speak` diretamente, sem indicador de suporte, mensagem de erro, fallback visual ou tratamento específico de gesto/autoplay/voz instalada.

O pacote aparece como dependência direta (`pubspec.yaml:17-18`, `pubspec.lock:462-469`), mas não há teste Web de voz, matriz de browser/voz pt-BR, nem confirmação de que a fala funciona após reload, bloqueio de autoplay ou ausência de voz. A política que diz que TTS é local (`privacy_policy.html:44-50`) é coerente como intenção, mas o comportamento real ainda precisa de validação de browser.

### 4.5 Persistência e cifragem no navegador sem modelo de segurança Web

`secure_box_service.dart:6-11` explica Keystore Android/Keychain iOS, e `:15-31` usa `FlutterSecureStorage` indistintamente para todos os alvos. O lockfile mostra que existe `flutter_secure_storage_web`, mas o repositório não define:

- quais APIs e garantias concretas a variante Web fornece;
- requisito de HTTPS/secure context e comportamento em HTTP, localhost, iframe ou navegador privado;
- onde a chave é guardada e qual é a exposição a scripts da mesma origem/XSS;
- comportamento de quota, IndexedDB indisponível/corrompido, múltiplas abas e concorrência;
- migração/recuperação de dados Web e efeito de limpar dados do site;
- teste de `DataWipeService` especificamente com backend Web.

A política diz que fotos (`privacy_policy.html:52-60`), perfil (`:63-72`) e vídeos (`:88-99`) ficam cifrados localmente de forma geral, sem separar a variante Web. Essa afirmação não deve ser usada como prova de segurança equivalente à nativa até que o modelo Web seja documentado e testado. O teste de wipe existente (`test/data_wipe_service_test.dart:14-89`) simula canais nativos de secure storage/path provider e usa filesystem; ele não valida IndexedDB/WebCrypto.

### 4.6 Shell Web e hosting ainda são defaults

- `web/index.html:17` contém base href substituível, mas o bundle existente foi gerado com `<base href="/">` (`build/web/index.html:17`). Não existe decisão operacional para hospedar em subpath, como `/fala-comigo/`, nem comando `--base-href` no CI.
- `web/index.html:21-32` ainda usa descrição e título genéricos (`A new Flutter project.`, `fala_comigo`). `web/manifest.json:2-10` repete nome, descrição e orientação `portrait-primary`, enquanto o bootstrap força paisagem (`main.dart:29-35`). Isso é inconsistência de UX/manifesto e branding, não apenas cosmética.
- Os ícones referenciados pelo manifesto existem em `web/icons/`, portanto não há ausência de asset nesse ponto.
- `.github/workflows/flutter.yml:45-46` apenas compila; não faz upload de Pages/release. `.github/workflows/site-pages.yml:1-15` reage a `site/**`, e `:51-54` envia somente `site`. Logo, o site institucional e o Flutter Web são payloads diferentes; o build Web não chega ao endereço público oficial por esse workflow.
- `codemagic.yaml:47-50` preserva `build/web/**` como artefato, mas também não define destino de hospedagem, base path, headers, CDN, rollback ou política de cache.
- O build prévio contém `flutter_service_worker.js`, mas não há validação de atualização/invalidação de cache, escopo, deep link ou comportamento offline real no navegador.

## 5. Bloqueadores objetivos e riscos críticos

Os itens abaixo são separados por causa; não são repetições do mesmo gap.

1. **Portabilidade Web comprometida por `dart:io` em código alcançável.** `transition_alert_edit_screen.dart:1,98-114` viola o critério de compatibilidade documentado. Até a tela ser isolada por export condicional ou reescrita com abstração Web, não há base para afirmar que o build Web limpo do checkout atual é reprodutível. O artefato `build/web` e o registro histórico de build não substituem essa revalidação.

2. **Mídia personalizada, diário de vídeo e áudio gravado não são funcionalidades Web.** O stub falha por desenho (`media_storage_service_web.dart:16-36`), mas vídeo e alertas continuam expostos e não têm tratamento de indisponibilidade uniforme. Se o Web for apresentado a famílias como app completo, existe risco objetivo de fluxo quebrado e perda de confiança; para lançamento Web, esses controles precisam ser desativados/rotulados ou implementados com uma arquitetura de armazenamento aprovada.

3. **Alertas/notificações não têm implementação Web.** O serviço usa apenas inicializadores nativos e os métodos podem ser invocados pela UI. Não existe garantia para permissão, aba fechada, agendamento, clique ou privacidade de notificações no browser. O recurso deve ser explicitamente “não disponível no Web” até existir desenho e validação do mecanismo.

4. **Não há evidência de cifragem e exclusão equivalentes no navegador.** As caixas são abertas por um serviço que documenta Keystore/Keychain nativos, e a política declara cifragem ampla sem escopo Web. Sem confirmar backend de chave, secure context, isolamento de origem e wipe de IndexedDB/storage, não é possível sustentar uma promessa de proteção de dados sensíveis Web.

5. **Não há rota de publicação do Flutter Web.** O CI e Codemagic produzem artefato, porém Pages só publica `site/`. A base href do artefato existente é `/`; uma publicação em subpath sem configuração pode quebrar scripts, manifesto, assets, service worker e deep links. O app Web não está pronto para hosting público permanente.

6. **Validação local atual está bloqueada pela ausência de toolchain.** `flutter`, `dart` e `adb` não estão instalados. O relatório não pode afirmar que análise, testes ou build passam no estado atual, e não há validação de navegador/dispositivo neste ciclo.

## 6. Recomendações prioritárias

### P0 — antes de qualquer promessa de Web funcional ou publicação

1. **Remover o import direto de `dart:io` do caminho Web.** Extrair gravação/caminho/arquivo para uma interface com implementação IO e stub Web, ou ocultar a tela de alertas gravados no Web. Repetir build a partir de worktree limpo e confirmar que a tela parental inteira compila.
2. **Definir explicitamente a matriz de recursos Web.** Até existir storage seguro de mídia, esconder/desabilitar adicionar foto, diário de vídeo, áudio gravado e compartilhamento de arquivo no navegador; manter mensagens acessíveis e evitar que a ação chegue a um `UnsupportedError` não tratado.
3. **Desativar alertas nativos no Web de forma declarativa.** Introduzir capability/feature gate para não exibir “Autorizar”, “Testar em 30s” ou “Novo alerta” como se fossem suportados; ou desenhar uma integração Web completa com Notifications API, service worker, permissão, agendamento e limitações de aba fechada.
4. **Especificar e testar a segurança Web antes de usar as declarações da política.** Documentar o backend de Hive Web, armazenamento/derivação da chave, secure context, modelo de ameaça same-origin/XSS, quota, recuperação e wipe. Atualizar a política para distinguir claramente Web de dispositivos nativos, se as garantias forem diferentes.

### P1 — tornar o shell e o build reproduzíveis

5. Escolher o destino permanente do Flutter Web (subpath do Pages ou host separado), fixar `--base-href`, configurar fallback de rotas, assets relativos, service worker/cache e procedimento de invalidação/rollback. Não confundir o site institucional de `site/` com `build/web`.
6. Substituir títulos/descrições genéricos em `web/index.html` e `web/manifest.json`, decidir a orientação do manifesto e alinhar esse valor com o comportamento responsivo real.
7. Adicionar um job/artefato explícito de CI para o pacote Web e, quando o destino for escolhido, um teste de smoke servido em HTTP/HTTPS com primeira carga, reload, deep link e assets sob o base path.

### P2 — cobertura funcional e de privacidade

8. Implementar testes Web reais para bootstrap, persistência/reload, migração, erro de quota, múltiplas abas e apagamento completo usando dados sintéticos; o teste nativo atual não substitui isso.
9. Adicionar testes de capacidade/falha para TTS, câmera/galeria, microfone, vídeo, compartilhamento e permissões negadas. Toda exceção de plugin deve produzir feedback de UI e não encerrar o fluxo CAA.
10. Realizar revisão de acessibilidade Web com teclado, zoom, leitor de tela, foco, toque, landscape/portrait e telas estreitas; confirmar que o placeholder de mídia e mensagens de indisponibilidade são compreensíveis.

## 7. Validações futuras obrigatórias (dispositivo, navegador e piloto)

### Toolchain e build

- Em ambiente com Flutter 3.38.0, executar `flutter pub get`, `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze --no-fatal-infos --no-fatal-warnings`, `flutter test` e `flutter build web --release` no estado exato que será publicado.
- Repetir com `--base-href` do destino escolhido, servir o payload em HTTPS e testar rota inicial, refresh de rota, link profundo, manifesto, ícones, service worker e atualização para uma nova versão.
- Registrar o commit, hash do artefato e resultado; não usar o diretório `build/web` já existente como aprovação do checkout sem rebuild.

### Persistência, privacidade e exclusão

- Em Chrome/Edge/Safari (e ao menos um navegador de referência adicional), verificar primeira execução sem rede, reload, fechamento/reabertura, modo privado, storage bloqueado, quota baixa, duas abas e atualização do app.
- Com dados sintéticos, confirmar quais bytes aparecem em IndexedDB/localStorage/Cache Storage, como a chave é protegida, se o mesmo-origin script pode acessá-los, se HTTPS é obrigatório e se o wipe remove todas as caixas, chaves, caches e mídia.
- Testar PIN, sessão parental, retorno de segundo plano/aba, limpeza do site e reinstalação; registrar diferenças entre Web e Android/iOS antes de atualizar a política.

### Mídia e navegador

- Testar selecionar imagem, captura pela câmera, cancelamento, formatos, tamanho, reload durante seleção e feedback de erro; decidir se o Web ficará somente com assets padrão ou se receberá uma implementação Web de mídia cifrada.
- Se mídia Web for implementada, testar Web Crypto/IndexedDB, object URLs, memória, quota, descarte de temporários, exportação/compartilhamento e limitações reais de exclusão segura no browser.
- Testar vídeo/microfone com permissões concedidas, negadas e revogadas, aba sem foco e dispositivo sem câmera/microfone; nunca usar fotos, vídeos, nomes ou dados clínicos reais.

### Voz, notificações e acessibilidade

- Confirmar TTS pt-BR por navegador/OS, gesto do usuário, autoplay bloqueado, voz ausente, interrupção e erro; manter um caminho visual utilizável sem voz.
- Se notificações Web forem adotadas, testar permissão concedida/negada, aba fechada, service worker atualizado, horário/fuso, clique no alerta, mensagem genérica e revogação de permissão. Caso contrário, remover o recurso da superfície Web.
- Executar checklist com teclado, leitor de tela, zoom, contraste, toque, orientation e responsividade em desktop, tablet e celular; depois validar com uma família/profissional em piloto controlado, usando somente dados sintéticos ou consentidos.

## 8. Conclusão

**Classificação:** núcleo CAA Web potencialmente utilizável com cartões padrão, bootstrap com erro visível e persistência textual a validar; mídia privada, alertas e hosting são incompletos/protótipo. O alvo Web **não está pronto para ser tratado como aplicação completa, destino público permanente ou piloto com dados sensíveis**.

O próximo gate técnico não é adicionar mais telas: é fechar a fronteira de plataforma (eliminar `dart:io` alcançável, declarar capabilities Web, bloquear fluxos sem suporte), especificar a segurança de armazenamento no navegador e definir onde o `build/web` será hospedado. Só depois de um rebuild limpo, smoke test em HTTPS, teste de wipe e validação humana de navegador se deve reclassificar a prontidão.

## Evidências principais

- `AGENTS.md:40-43` — requisitos local-first, privacidade e autorização.
- `CONTINUAR_AQUI_PRIMEIRO.md:121-129,54-66` — histórico de contrato Web, destino público e limites de validação.
- `PROJECT_HANDOFF.md:28-59,157-192` — arquitetura, mídia Web deliberadamente limitada e critérios/limites de lançamento.
- `lib/main.dart:22-57,89-100,154-175,201-242` — bootstrap, serviços opcionais e erro visível.
- `lib/core/services/media_storage_service.dart:1-2` e `lib/core/services/media_storage_service_web.dart:1-37` — export condicional e stub fail-closed.
- `lib/core/widgets/secure_media_image.dart:1-2` e `lib/core/widgets/secure_media_image_web.dart:3-23` — fallback de imagem privada.
- `lib/core/services/media_storage_service_io.dart:9-13,23-34,176-200` — referência nativa de cifragem/limites/ownership.
- `lib/core/services/secure_box_service.dart:6-31,34-63` — caixas Hive e chave via secure storage.
- `lib/features/aac_grid/presentation/screens/aac_grid_screen.dart:217-265` e `lib/features/aac_grid/presentation/widgets/grid_card.dart:48-55` — núcleo e assets padrão.
- `lib/features/parental_area/presentation/screens/add_card_screen.dart:105-136`, `video_diary_screen.dart:55-65,103-134` — fluxos de mídia Web sem suporte uniforme.
- `lib/features/parental_area/presentation/screens/transition_alert_edit_screen.dart:1-7,98-154,205-229` — `dart:io`, caminhos temporários e agendamento.
- `lib/core/services/transition_alert_service.dart:48-128,167-233` e `transition_alerts_list_screen.dart:60-113` — serviço nativo e UI exposta.
- `lib/core/services/tts_service.dart:15-35` — ausência de capability/fallback de voz.
- `test/media_web_fallback_test.dart:8-47` e `test/data_wipe_service_test.dart:14-89` — cobertura existente e limite nativo do wipe.
- `web/index.html:17-44`, `web/manifest.json:2-33` — shell/manifesto com defaults e orientação divergente.
- `.github/workflows/flutter.yml:20-46`, `.github/workflows/site-pages.yml:1-15,51-54`, `codemagic.yaml:34-50` — build/artefato sem publicação Flutter Web.
- `privacy_policy.html:44-60,63-72,88-117,150-163` e `lib/features/parental_area/presentation/screens/privacy_settings_screen.dart:45-80` — declarações de privacidade ainda não diferenciadas por plataforma.
- `docs/PLANO_SEQUENCIAL_ATE_BUILD.md:125-131` e `docs/CONTINUIDADE_ASSISTENTE_IA.md:648-658` — critério de compatibilidade e registro de build anterior.
