# Auditoria técnica somente de leitura — Segurança, privacidade, dados sensíveis e supply chain

**Checkout auditado:** `/home/ubuntu/fala-comigo`\
**Branch/HEAD observados:** `audit/creator-privacy-alignment` / `cc96eaf4582d1f08b7cd32684b6f12b78dbb59b4`\
**Data da leitura:** 2026-09-29\
**Escopo:** `security/`, manifestos e lockfiles, PIN/autenticação, sessão, armazenamento, mídia, exclusão, política de privacidade, portal/autorização local, CI/CD, assinatura e riscos de release.

## 1. Método e limites

- `AGENTS.md`, `CONTINUAR_AQUI_PRIMEIRO.md` e `PROJECT_HANDOFF.md` foram lidos antes da revisão.
- Foram usados somente comandos de leitura, busca e histórico Git. Não houve edição do checkout, commit, merge, deploy, acesso ao GitHub/Supabase/APIs remotas ou execução de serviços externos.
- Arquivos `.env*` e valores de credenciais/segredos não foram lidos. A presença de arquivos por nome foi apenas verificada; não há arquivo desse tipo rastreado pelo Git na listagem auditada.
- Não foram executados Flutter, Gradle, MobSF, testes, instalação em dispositivo ou análise dinâmica nesta auditoria. Resultados de builds/testes citados abaixo são **registros documentais existentes**, não nova validação.
- A árvore de trabalho não está limpa: há muitos arquivos modificados e não rastreados, inclusive em código, workflow, documentação e testes. Portanto, conclusões de release aplicam-se ao checkout efetivo observado, mas a proveniência final ainda precisa ser consolidada.

## 2. Resumo executivo

O núcleo local-first tem controles importantes já implementados: PIN parental não armazenado em claro; derivação PBKDF2-HMAC-SHA256 com salt; bloqueio progressivo; sessão em memória que expira e é bloqueada ao ir para segundo plano; caixas Hive abertas pelo serviço cifrado; mídia nativa nova com AES-GCM-256; regras Android para não incluir dados em backup/transferência; exclusão que contempla caixas locais, mídia, chaves, PIN e notificações; exportação explicitamente iniciada pelo responsável e com identificadores desmarcados por padrão; e fallback Web que deliberadamente não habilita mídia personalizada sem armazenamento cifrado equivalente.

Há, contudo, **bloqueadores objetivos antes de release ou piloto com dados reais**:

1. A migração de caixas Hive captura qualquer exceção, tenta tratar o mesmo caminho como legado não cifrado e apaga a caixa original antes de provar recuperação completa. Isso conflita diretamente com os gates documentados para chave inválida, corrupção e rollback.
2. A materialização de mídia descriptografa para arquivos temporários sem limpeza garantida em `finally`; compartilhamento e preview podem deixar cópias legíveis no diretório temporário. Há também compatibilidade explícita com arquivos legados em claro.
3. O PIN/session gate é aplicado principalmente pela navegação. Os serviços e stores que carregam dados parentais não exigem `ParentalSessionService.requireSession()`, e não há chamada de enforcement em produção além da leitura do estado de lifecycle. Isso é defesa em profundidade insuficiente.
4. O relatório MobSF versionado registra score 46, dois achados altos ainda em revisão (CBC/PKCS#5/#7 no caminho Hive e `minSdk=24`) e outros warnings de permissões, temporários, armazenamento externo e possíveis strings sensíveis. Não há evidência no checkout de que esses achados tenham sido encerrados.
5. O portal/console conectado, autenticação remota, isolamento multi-organização, RLS/autorização server-side, consentimento remoto, revogação operacional, auditoria persistente e sincronização clínica continuam protótipo/documentação. As políticas Dart locais não são uma fronteira de confiança contra um cliente adulterado.
6. CI usa ações referenciadas por tags mutáveis (`@v4`, `@v2`, etc.), imagem MobSF `:latest` e `flutter pub get` sem enforcement explícito do lockfile. Há hashes no `pubspec.lock` e checksum do Gradle Wrapper, mas não há pinagem por digest/SHA das ações/imagens nem etapa de SBOM/vulnerability audit.
7. Não há pipeline de AAB/APK de produção com assinatura real. Os workflows Android/MobSF geram artefatos de teste com chave efêmera; o build de release falha sem `android/key.properties`, o que é bom para não cair na chave debug, mas ainda deixa o release real bloqueado.

## 3. O que está funcionando agora / forças implementadas

### 3.1 Armazenamento local e chaves

- `SecureBoxService` gera uma chave Hive e a guarda via `flutter_secure_storage`, descrita como Keystore/Keychain; caixas são abertas com `HiveAesCipher` (`lib/core/services/secure_box_service.dart:6-31`).
- A exclusão remove a chave Hive, a chave de mídia e as credenciais do PIN (`lib/core/services/data_wipe_service.dart:47-51`). Perder a chave torna cópias residuais cifradas ilegíveis, embora não substitua exclusão física segura.
- Os stores atuais de perfil funcional, plano de comunicação, agenda, tarefas, grants, lembretes, licença e registros usam `SecureBoxService` em vez de `Hive.openBox` direto. A busca de acesso direto encontrou o acesso bruto principalmente como retorno de caixas já abertas pelos stores, não como novas caixas explícitas em claro.
- Os dados de acesso local incluem campos identificadores e de rede de cuidado, mas ficam na caixa protegida (`lib/features/parental_area/data/access_grants.dart:12-63,104-130`; `lib/features/parental_area/data/care_coordination.dart:7-16,90-158,220-258`).

### 3.2 PIN e sessão parental

- O PIN não é persistido em texto puro. O serviço usa salt aleatório de 16 bytes, PBKDF2-HMAC-SHA256 com 100.000 iterações e verificação em tempo constante (`lib/core/services/parental_pin_service.dart:7-25,47-71,95-107`).
- PINs fora de quatro dígitos, `1234`, `0000` e sequências de quatro dígitos repetidos são rejeitados (`parental_pin_service.dart:82-93`). Falhas têm atraso progressivo e bloqueio de 30 segundos a partir da quinta falha (`:109-123`).
- A sessão não é persistida, tem duração padrão de 10 minutos e é invalidada quando a aplicação vai para pausa (`lib/core/services/parental_session_service.dart:5-29`; `lib/main.dart:130-138`).
- A tela de gate exige criação inicial/verificação do PIN antes de abrir a área parental (`lib/features/parental_area/presentation/screens/parental_gate_screen.dart:11-18,40-103`). Há testes unitários para formato, PIN correto/incorreto, bloqueio, troca, limpeza e expiração (`test/parental_pin_service_test.dart:46-107`; `test/parental_session_service_test.dart:11-43`).

### 3.3 Mídia e permissões locais

- Novos arquivos nativos são limitados a extensões conhecidas, têm limite de 100 MiB e são gravados na área de documentos do app como `FCM1 + AES-GCM-256`, com nonce/MAC no formato da biblioteca (`lib/core/services/media_storage_service_io.dart:9-37,42-69`).
- A chave de mídia é aleatória, de 32 bytes, guardada em `flutter_secure_storage` (`media_storage_service_io.dart:160-167`). A descriptografia verifica autenticação GCM e transforma alteração/corrupção em erro (`:144-157`).
- A checagem de caminho resolve symlinks antes de aceitar exclusão/materialização e limita a área privada/áudio legado (`media_storage_service_io.dart:176-188`).
- A versão Web bloqueia persistência/materialização de mídia personalizada e mostra placeholder acessível, evitando fingir que armazenamento local de navegador é equivalente ao nativo (`media_storage_service_web.dart:1-37`; `lib/core/widgets/secure_media_image_web.dart:3-23`).
- O Android solicita câmera, áudio, notificações, alarme exato, tela cheia, boot e leitura de imagens conforme as funcionalidades declaradas (`android/app/src/main/AndroidManifest.xml:3-14`). O código de notificações usa visibilidade privada e textos genéricos, sem colocar o conteúdo da família no corpo (`lib/core/services/transition_alert_service.dart:138-173,175-210`).

### 3.4 Exclusão e exportação

- O wipe fecha/apaga as caixas conhecidas, cancela notificações, remove diretórios de mídia permanente/legada/temporária, remove chaves e PIN, e recria caixas cifradas para que o aplicativo continue utilizável (`lib/core/services/data_wipe_service.dart:16-76`). A caixa `parent_reminders` está incluída no checkout efetivo.
- A tela confirma que a ação não pode ser desfeita e sinaliza quando a exclusão não foi completada (`lib/features/parental_area/presentation/screens/settings_screen.dart:47-91`).
- Exportação de PDF é iniciada pelo responsável; perfil identificador fica opt-in, o período ABC é selecionável e a UI avisa que cópias externas permanecem fora do controle do app (`lib/features/parental_area/presentation/screens/data_export_screen.dart:35-68,86-120,122-204,309-345`).
- A política de privacidade documenta armazenamento local, ausência de upload automático, PIN derivado, exclusão local e cópias compartilhadas fora do controle (`privacy_policy.html:44-60,63-85,119-163`; `site/privacy.html:13-14`).
- As regras Android excluem `file`, `database`, `sharedpref`, `external` e `root` tanto do backup quanto da transferência de dispositivo (`android/app/src/main/res/xml/backup_rules.xml:1-8`; `data_extraction_rules.xml:1-17`).

### 3.5 Integridade de release e supply chain já existente

- O Gradle Wrapper usa distribuição com `distributionSha256Sum` (`android/gradle/wrapper/gradle-wrapper.properties:1-6`). Plugins Android/Kotlin e repositórios estão declarados explicitamente (`android/settings.gradle.kts:1-24`).
- A assinatura de release só é usada se `android/key.properties` existir e o build de release falha de propósito na ausência dela; o arquivo e keystores estão no `.gitignore` (`android/app/build.gradle.kts:13-28,52-79`; `.gitignore:42-48`). Isso impede fallback silencioso para a chave debug.
- O lockfile contém pacotes hospedados com versões e SHA-256, e os dependentes diretos estão resolvidos de forma determinística no checkout (`pubspec.lock:1-19,44-59,252-259,361-368,401-416`; `pubspec.lock` no bloco `sdks`).
- O workflow MobSF cria chave efêmera, gera APK não produtivo, registra SHA-256, coleta relatório e apaga arquivos de assinatura ao final (`.github/workflows/mobsf-security-scan.yml:27-52,100-119`). O workflow manual Android também marca o artefato como teste e usa retenção limitada (`.github/workflows/android-test-apk.yml:24-79`).

## 4. Incompleto / protótipo / limitações de escopo

1. **Backend e portal conectado:** não há autenticação remota, sessão segura, contas/organizações reais, banco conectado ao código, RLS, autorização server-side, consentimento versionado remoto, revogação operacional, auditoria persistente, isolamento multi-organização ou sincronização clínica. O próprio status do projeto classifica esses itens como pendentes (`docs/STATUS_PROJETO_E_PENDENCIAS_2026-09-28.md:87-99`) e o handoff não permite tratar documentação conceitual como implementação (`PROJECT_HANDOFF.md:175-192`).
2. **Políticas RH/portal em Dart:** `RhAuthorizationPolicy` e `RhElevatedAccessPolicy` têm boas decisões negativas para autenticação, organização, expiração, finalidade, escopo e conteúdo clínico (`lib/core/authorization/rh_authorization_policy.dart:42-80,90-171`; `rh_elevated_access.dart:33-90`), mas são funções locais alimentadas por booleanos/strings do cliente. Não constituem enforcement contra cliente modificado nem substituem RLS/API.
3. **Console Web:** as páginas em `site/` são estáticas/prévias. Não há login real, banco, sessão ou autorização no Pages; isso é coerente com a restrição documentada, mas impede chamar o console de produção (`site/console-preview.html`, `site/portal.html`, `docs/STATUS_PROJETO_E_PENDENCIAS_2026-09-28.md:91-94`).
4. **Web de mídia:** o fallback bloqueia corretamente a funcionalidade, mas `deleteFile`, `clearAllMedia` e `deleteEncryptionKey` são no-ops no Web (`media_storage_service_web.dart:26-37`). Isso é aceitável apenas enquanto nenhuma mídia personalizada é criada nessa plataforma; não é um mecanismo de apagamento Web.
5. **Proteção do PIN:** quatro dígitos têm espaço de busca pequeno. O atraso e o armazenamento seguro elevam o custo de tentativa casual, mas não protegem contra usuário com controle do dispositivo, limpeza/reinstalação do app, root/jailbreak ou extração de estado. A sessão também não é uma prova de identidade de servidor.
6. **Licença/planos:** o controlador mantém o núcleo offline disponível e deixa recursos remotos dependentes do estado local da licença (`lib/core/plans/plan_access_controller.dart:4-34`). Isso é uma boa regra de produto, mas uma licença local não é autorização confiável para recurso remoto futuro; o backend terá de reavaliar tudo.

## 5. Gaps e riscos técnicos detalhados

### G1 — Migração Hive destrutiva e captura ampla de exceções (P0 para dados existentes)

`openSecureBoxWithMigration` captura qualquer exceção ao abrir a caixa cifrada, fecha a caixa se necessário, abre o mesmo nome sem `encryptionCipher`, copia valores, apaga o box do disco e só depois cria a nova caixa cifrada (`lib/core/services/secure_box_service.dart:34-57`). Uma chave errada, corrupção, falha de autenticação, incompatibilidade de tipo ou erro transitório pode cair no caminho de legado; a origem é apagada antes de existir um checkpoint/rollback. Isso pode causar perda de dados sensíveis e pode transformar falha de integridade em tentativa de leitura não cifrada. O plano de release já identifica exatamente esse gate como obrigatório (`docs/PLANO_EXECUCAO_RELEASE_ANDROID.md:48-61`).

**Recomendação:** distinguir “caixa ausente”, “formato legado comprovado”, “chave inválida”, “corrupção” e “erro transitório”; nunca apagar a origem antes de verificar escrita, leitura e marcador de migração; usar cópia/rename atômico, backup local cifrado temporário e testes de interrupção/rollback/chave incorreta/corrupção.

### G2 — CBC/PKCS#5/#7 no Hive ainda sem decisão formal (P0 para release)

O relatório MobSF versionado registra score 46, dois achados altos e identifica CBC com padding no código obfuscado associado à dependência Hive (`security/reports/MOBSF_2026-09-24.md:11-28`). A política de release manda revisar formato/dependência e não trocar algoritmo sem migração (`:36-43`). Não há evidência de correção, falso positivo justificado ou aceitação formal do risco posterior.

**Recomendação:** reproduzir o achado no artefato candidato, decidir se o risco é aplicável ao formato Hive, documentar ameaça/compatibilidade e só então manter, atualizar ou migrar para formato autenticado com plano de recuperação.

### G3 — Arquivos temporários descriptografados não têm ciclo de vida fechado (P0 para mídia)

`materializeForReading` grava bytes em claro em `getTemporaryDirectory()/fala_comigo_media_preview` e os deixa em `_previewCache` (`lib/core/services/media_storage_service_io.dart:72-76,112-141`). O widget de imagem apenas lê o arquivo (`lib/core/widgets/secure_media_image_io.dart:7-36`); o player de áudio e o compartilhamento também materializam, mas não há `finally` para apagar após uso (`lib/features/parental_area/presentation/screens/transition_alert_edit_screen.dart:148-158`; `video_diary_screen.dart:103-135`). O cleanup geral ocorre apenas no wipe (`media_storage_service_io.dart:91-106`).

Além disso, o caminho de compatibilidade aceita arquivo sem marcador como bytes em claro (`media_storage_service_io.dart:121-130`), e `deleteFile` retorna antes de remover preview quando o arquivo fonte já não existe ou deixa de ser reconhecido como pertencente (`:78-89`). Isso cria possibilidade concreta de resíduo legível após preview, compartilhamento, crash ou encerramento.

**Recomendação:** separar materialização para imagem/player/compartilhamento; usar lease/referência e `try/finally`; apagar após conclusão/cancelamento; varrer órfãos no startup e antes de compartilhar; não aceitar legado em claro sem conversão/telemetria local de erro e migração testada; cobrir crash/interrupção e chamada repetida de delete.

### G4 — Enforcement de sessão está na navegação, não nos serviços (P1; P0 para expansão)

A busca encontrou `ParentalSessionService.requireSession()` apenas nos testes; no código de produção há apenas a leitura de `isAuthenticated` no lifecycle (`lib/main.dart:130-138`). Stores como `CareCoordinationStore` abrem e retornam dados parentais diretamente (`lib/features/parental_area/data/care_coordination.dart:220-258`), sem exigir sessão. A arquitetura atual chega a essas telas via gate, mas qualquer rota futura, callback, deep link, teste de integração ou erro de navegação pode contornar a proteção sem uma segunda barreira.

**Recomendação:** criar uma camada de caso de uso/gate que verifique sessão antes de ler ou modificar dados parentais; negar por padrão no store quando apropriado; testar acesso direto sem sessão, após expiração, após pausa e durante wipe.

### G5 — Exclusão total é abortada por falha de notificação (P1)

O wipe cancela todas as notificações antes de apagar caixas e mídia (`lib/core/services/data_wipe_service.dart:34-49`). Se `cancelAllNotifications()` lança, a função termina antes da exclusão. Isso é testado como comportamento atual (`test/data_wipe_service_test.dart:118-137`) e a UI informa que a exclusão não terminou, mas a promessa de “apagar todos os dados” fica dependente de uma API de notificação que pode estar indisponível, bloqueada ou quebrada.

**Recomendação:** registrar estado do wipe, continuar com a exclusão local mesmo se o cancelamento falhar, repetir cancelamento de forma idempotente quando possível e informar separadamente o risco de notificações residuais. Validar se payloads/IDs agendados podem permanecer após desinstalação, reboot e revogação de permissão.

### G6 — Política de privacidade tem versões e promessas que precisam ser reconciliadas (P1)

A política raiz está atualizada em 21/09/2026 e a página em `site/` em 23/09/2026 (`privacy_policy.html:32-34`; `site/privacy.html:13`). O texto diverge em extensão e detalhes. O app aponta para a URL pública configurada em `lib/core/config/public_links.dart`, não necessariamente para o HTML raiz. A política raiz afirma que dados são removidos com desinstalação (`privacy_policy.html:140-148`), mas a implementação usa Keychain/`flutter_secure_storage` no iOS (`secure_box_service.dart:8-10`) e não há regra iOS de backup/remoção equivalente no checkout; esse comportamento precisa ser confirmado em dispositivo e não deve ser prometido genericamente antes disso.

A política também oferece issues públicas do GitHub como canal de contato (`privacy_policy.html:172-177`; `site/privacy.html:13-14`). Sem instrução explícita para não enviar nomes, diagnósticos, fotos, vídeos, frases ou registros, isso pode induzir exposição de dados sensíveis em canal público.

**Recomendação:** manter uma única fonte publicada/versionada; declarar por plataforma o que uninstall, backup e Keychain fazem; adicionar aviso de “não envie dados pessoais em issue pública” e canal privado adequado; revisar linguagem sobre TTS, vídeo, compartilhamento e iOS contra o comportamento real.

### G7 — Permissões e exposição de plataforma ainda não validadas no Manifest mesclado (P1)

O Manifest declara `READ_MEDIA_IMAGES`, câmera, áudio, notificações, tela cheia, alarmes exatos, boot e vibração (`android/app/src/main/AndroidManifest.xml:3-14`). O plano exige revisar o Manifest mesclado e testar permissões concedidas/negadas (`docs/PLANO_EXECUCAO_RELEASE_ANDROID.md:71-77`). Ainda não há essa evidência no checkout. Em particular, `READ_MEDIA_IMAGES` pode ser mais amplo que o necessário dependendo do Photo Picker/versão Android; `SCHEDULE_EXACT_ALARM` e `USE_FULL_SCREEN_INTENT` são capacidades de alto impacto e devem ser justificadas por dispositivo/versão.

**Recomendação:** inspecionar o Manifest final do APK/AAB e a matriz de permissões em Android 7/13/14+; verificar negação, revogação, boot, tela bloqueada, notificações privadas e ausência de conteúdo familiar em previews/screenshots.

### G8 — Supply chain de CI/CD não é imutável (P1)

O lockfile tem hashes de pacotes hosted, mas `pubspec.yaml` usa constraints caret (`pubspec.yaml:15-51`) e os workflows executam `flutter pub get` sem `--enforce-lockfile` (`.github/workflows/flutter.yml:20-28`; `android-test-apk.yml:18-25`; `mobsf-security-scan.yml:21-29`). Isso permite resolver fora do lock em cenários de mudança/ambiente e não há relatório SBOM ou vulnerability audit no pipeline.

As actions são referenciadas por tags móveis (`actions/checkout@v4`, `subosito/flutter-action@v2`, Pages/artefact actions), e a varredura MobSF usa `opensecurity/mobile-security-framework-mobsf:latest` (`.github/workflows/mobsf-security-scan.yml:18-25,54-59`; `.github/workflows/site-pages.yml:31-66`). Tags mutáveis deixam o resultado sujeito a mudança da dependência executada sem mudança no commit do repositório. O job do site concede `pages: write` e `id-token: write` no nível do workflow, embora apenas o deploy precise dessas permissões (`site-pages.yml:18-21,27-66`).

**Recomendação:** usar `--enforce-lockfile`; pin de actions por commit SHA com processo de atualização; fixar imagem MobSF por digest e versão; gerar SBOM e scan de dependências/artefato; separar permissões por job; registrar versões de Flutter, Java, Gradle, AGP, Kotlin, plugins e imagem no artefato.

### G9 — Release de produção não está demonstrado (P0 para publicação)

O CI principal roda formatação, análise, testes e build Web, mas não gera APK/AAB de produção (`.github/workflows/flutter.yml:12-47`). Os workflows Android/MobSF são manuais e explicitamente de teste com chave efêmera (`android-test-apk.yml:9-79`; `mobsf-security-scan.yml:9-52`). O build real exige `android/key.properties` e keystore de produção (`android/app/build.gradle.kts:20-28,72-79`), que corretamente não estão no Git, mas não existe evidência local de assinatura real, AAB, Play Integrity/inspeção final do Manifest ou rollout/rollback.

O documento MobSF ainda exige tratar score/achados e não confundir APK efêmero com produção (`security/reports/MOBSF_2026-09-24.md:30-42`). O status do checkout também registra que o APK disponível é debug/teste e não foi instalado em telefone/tablet (`docs/STATUS_PROJETO_E_PENDENCIAS_2026-09-28.md:6-10,23-31,95-99`).

**Recomendação:** não publicar; criar gate de release que produza AAB/APK não-debug rastreável por commit, versão, assinatura e SHA-256, revisar Manifest mesclado, repetir MobSF nesse artefato, validar atualização/rollback e só então testar em celular e tablet.

### G10 — Conteúdo sensível é deliberadamente entregue a apps externos sem pós-compartilhamento controlável (P1)

O diário de vídeo confirma o compartilhamento e inclui o contexto digitado pelo responsável no texto entregue ao app de share (`lib/features/parental_area/presentation/screens/video_diary_screen.dart:103-135`). A confirmação existe, mas não há prévia completa do conteúdo/destinatário nem limpeza da cópia materializada após o share. Exportação ABC inclui comportamento, antecedente, consequência e notas quando o responsável escolhe (`data_export_screen.dart:166-204`). Isso é compatível com exportação explícita, mas exige avisos fortes e testes de destinos reais; depois que o SO entrega a cópia, o aplicativo não pode revogá-la.

**Recomendação:** mostrar resumo dos campos antes de compartilhar; separar “compartilhar vídeo” de “compartilhar contexto”; minimizar texto por padrão; limpar temporário em sucesso, cancelamento e erro; registrar somente resultado técnico sem conteúdo sensível.

## 6. Bloqueadores objetivos antes de release/piloto

- **B0 — Não aprovar release de dados existentes:** corrigir ou formalmente redesenhar a migração Hive para que chave errada/corrupção nunca destruam a caixa nem caiam em fallback não cifrado; adicionar testes de rollback/interrupção.
- **B1 — Não aprovar mídia:** fechar o ciclo dos temporários descriptografados, legado em claro e share/player; demonstrar cleanup em sucesso, cancelamento, crash/restart e wipe.
- **B2 — Não aprovar criptografia Hive sem decisão:** revisar os dois achados altos do MobSF, incluindo CBC/PKCS#5/#7 e `minSdk=24`, com decisão formal baseada no artefato candidato.
- **B3 — Não aprovar portal conectado:** não usar dados reais; falta backend de produção, autenticação, autorização server-side/RLS, isolamento, consentimento/revogação/auditoria e testes de negação.
- **B4 — Não aprovar publicação Android:** falta AAB/APK de produção assinado, Manifest mesclado revisado, matriz de dispositivos/permissões, atualização/rollback e validação humana em celular/tablet.
- **B5 — Não aprovar pipeline como cadeia confiável:** pin de actions/imagem MobSF e enforcement do lockfile/SBOM ainda não estão fechados.
- **B6 — Não aprovar política jurídica/operacional:** reconciliar as duas políticas e retirar/qualificar o canal público de issues para dados pessoais; confirmar uninstall/backup por plataforma.
- **B7 — Não considerar o checkout uma base de release:** a árvore está suja e contém alterações não commitadas/não rastreadas em código, workflows, documentação e testes; deve haver um commit revisado e CI correspondente.

## 7. Recomendações prioritárias ordenadas

1. **P0 — Armazenamento:** reescrever a migração Hive com classificação de erro, cópia atômica, marker de sucesso, rollback e testes sintéticos de chave inválida/corrupção/interrupção.
2. **P0 — Mídia:** introduzir API de materialização com lease/finalização explícita e cleanup garantido; eliminar compatibilidade silenciosa em claro; adicionar limpeza de órfãos no início e no wipe.
3. **P0 — MobSF/cripto:** repetir a varredura no candidato atual, classificar os dois highs e os warnings, e registrar decisão de risco/compatibilidade antes de release.
4. **P1 — Defesa em profundidade:** fazer cada caso de uso/store parental exigir sessão válida ou ser chamado apenas por um serviço autorizado; adicionar testes negativos de acesso sem sessão e após pausa/expiração.
5. **P1 — Exclusão:** tornar wipe idempotente e continuar apagamento local mesmo se notificação falhar, com estado de erro explícito e retentativa; confirmar todos os boxes/diretórios/chaves por plataforma.
6. **P1 — CI supply chain:** `flutter pub get --enforce-lockfile`; actions por SHA; MobSF por versão/digest; SBOM e auditoria de dependências; permissões mínimas por job; artefatos associados a commit/SHA.
7. **P1 — Release:** pipeline separado para AAB/APK de produção, secret manager externo, assinatura verificável, Manifest final, SHA-256, MobSF e retenção controlada sem APK público no repositório.
8. **P1 — Privacidade:** unificar política publicada, detalhar diferenças Android/iOS/Web, advertir contra dados em issues públicas e revisar cada promessa contra código e comportamento do SO.
9. **P1 — Portal futuro:** manter somente fixtures sintéticas até autenticação/sessão, RLS, autorização por recurso/organização, consentimento versionado, revogação, auditoria, retenção/exclusão e testes negativos em backend implantado.
10. **P2 — Permissões e UX de compartilhamento:** decidir necessidade de `READ_MEDIA_IMAGES`, alarmes exatos e tela cheia por matriz de aparelhos; separar contexto de mídia e oferecer minimização antes do share.

## 8. Validações futuras em dispositivo/piloto

### Dispositivo

- Instalação limpa e atualização sobre uma instalação anterior; verificar migração válida, chave errada simulada, corrupção e interrupção sem perda.
- Android 7/API 24 e aparelhos Android atuais; registrar `minSdk`, `targetSdk`, permissões concedidas/negadas/revogadas, Photo Picker, câmera, microfone, notificações, alarmes, tela cheia, boot e tela bloqueada.
- Celular e tablet reais, offline e online; abrir grade CAA, montar/falar frases, entrar/sair da área parental, pausar/retomar e confirmar expiração imediata da sessão.
- Criar cartão, vídeo e áudio; interromper captura, cancelar, trocar/editar/excluir; procurar temporários antes/depois, reinício forçado e reinstalação.
- Compartilhar vídeo/PDF para destinos descartáveis; confirmar exatamente quais campos saem, limpar arquivos temporários e verificar que não aparecem em notificações, previews, logs ou screenshots.
- Executar “Apagar todos os dados”; confirmar caixas, mídia permanente, mídia temporária, drafts, alertas, lembretes, filas, licença, chaves, PIN e notificações após reboot.
- iOS: confirmar comportamento de Keychain na desinstalação/reinstalação, backup/restore e exclusão; Web: confirmar que mídia personalizada continua bloqueada e que nenhum no-op de delete cria falsa promessa.

### Piloto controlado

- Usar somente dados sintéticos até aprovação de threat model, base legal/consentimento e canal de suporte privado.
- Demonstrar testes de negação: organização errada, conta inativa, finalidade/escopo incompatível, consentimento expirado, revogação, recurso inexistente, acesso elevado vencido e limiar agregado insuficiente.
- Verificar que empresa/patrocinador nunca recebe diagnóstico, nome, imagem, voz, frases, cartões, vídeos, ABC ou frequência individual; qualquer relatório institucional deve ser agregado com limiar anti-reidentificação.
- Exercitar retenção, exportação, apagamento, revogação, auditoria e rollback com dados descartáveis; registrar modelo do aparelho, versão do app, commit, artefato e SHA-256.
- Não chamar o piloto de produção enquanto o backend conectado, o release assinado e a validação humana não estiverem aprovados em gates separados.

## 9. Arquivos de evidência principais

- `AGENTS.md:15-21,40-43`
- `CONTINUAR_AQUI_PRIMEIRO.md:21-43,86-116`
- `PROJECT_HANDOFF.md:28-58,157-192`
- `lib/core/services/secure_box_service.dart:6-63`
- `lib/core/services/parental_pin_service.dart:7-123`
- `lib/core/services/parental_session_service.dart:5-41`
- `lib/main.dart:27-52,105-169`
- `lib/core/services/media_storage_service_io.dart:9-23,40-69,72-106,112-201`
- `lib/core/services/media_storage_service_web.dart:1-37`
- `lib/core/widgets/secure_media_image_io.dart:7-36`
- `lib/core/services/data_wipe_service.dart:12-76`
- `lib/core/services/transition_alert_service.dart:82-120,138-210`
- `lib/features/parental_area/presentation/screens/video_diary_screen.dart:55-135`
- `lib/features/parental_area/presentation/screens/transition_alert_edit_screen.dart:98-158,196-230`
- `lib/features/parental_area/presentation/screens/data_export_screen.dart:35-49,86-120,122-204,309-345`
- `lib/features/parental_area/presentation/screens/settings_screen.dart:47-91`
- `lib/features/parental_area/data/access_grants.dart:12-63,104-130`
- `lib/features/parental_area/data/care_coordination.dart:7-16,90-158,220-258`
- `lib/core/authorization/rh_authorization_policy.dart:42-80,90-171`
- `lib/core/authorization/rh_elevated_access.dart:33-90`
- `lib/core/plans/plan_license_store.dart:6-46`
- `lib/core/plans/plan_access_controller.dart:4-34`
- `privacy_policy.html:32-60,63-85,119-163,172-177`
- `site/privacy.html:7-14`
- `lib/core/config/public_links.dart:1-13`
- `android/app/src/main/AndroidManifest.xml:3-56`
- `android/app/src/main/res/xml/backup_rules.xml:1-8`
- `android/app/src/main/res/xml/data_extraction_rules.xml:1-17`
- `android/app/build.gradle.kts:13-28,44-79`
- `android/settings.gradle.kts:1-24`
- `android/gradle/wrapper/gradle-wrapper.properties:1-6`
- `.gitignore:26-48`
- `pubspec.yaml:6-58`
- `pubspec.lock:1-19,44-59,252-259,361-416` and `pubspec.lock` `sdks` block
- `.github/workflows/flutter.yml:1-47`
- `.github/workflows/android-test-apk.yml:1-79`
- `.github/workflows/mobsf-security-scan.yml:1-119`
- `.github/workflows/site-pages.yml:1-66`
- `security/reports/MOBSF_2026-09-24.md:11-43`
- `docs/PLANO_EXECUCAO_RELEASE_ANDROID.md:30-40,48-77,79-110,112-134`
- `docs/PLANO_SEGURANCA_OWASP_MASVS_MOBSF.md:1-35,37-65`
- `docs/STATUS_PROJETO_E_PENDENCIAS_2026-09-28.md:6-18,21-35,49-60,78-115`
- `test/parental_pin_service_test.dart:46-107`
- `test/parental_session_service_test.dart:11-43`
- `test/data_wipe_service_test.dart:99-137`
- `test/media_storage_service_test.dart:7-28`

**Conclusão:** há uma base local-first com boas intenções e controles parciais verificáveis, mas o checkout não deve ser classificado como pronto para release ou piloto com dados reais. Os bloqueios mais urgentes são migração Hive destrutiva, temporários de mídia em claro, fechamento do achado criptográfico MobSF, enforcement de sessão em camada de dados, pipeline/release reprodutível e ausência de backend/autorização real para qualquer recurso conectado.
