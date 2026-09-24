# Revisão Cloud e Observabilidade — Cloud Architect

**ID:** 14-14  
**Papel:** Cloud Architect  
**Data da revisão:** 24 de setembro de 2026  
**Escopo:** arquitetura cloud existente e futura, CI/CD, proveniência de artefatos, observabilidade do aplicativo e análise do relato de que o APK instala, mas fecha ao abrir.  
**Alterações de código:** nenhuma. Foi criado somente este relatório.

> **Regra de evidência:** o build compila, mas não existe logcat do aparelho físico no checkout. Portanto, este relatório não atribui o fechamento a TTS, notificações, Hive, armazenamento seguro, assinatura, fabricante ou versão Android. Hipóteses causais são explicitamente tratadas como não confirmadas.

## Resumo executivo

O projeto é, no estado observado, um aplicativo Flutter **local-first**, não uma plataforma cloud conectada. A comunicação CAA básica não depende de conta, servidor, internet ou plano pago. Não foram encontrados backend, API, banco remoto, autenticação remota, sincronização, telemetria remota ou serviço de crash reporting no checkout. Essa separação é coerente com o requisito de privacidade e disponibilidade offline, mas significa que não existe uma camada cloud capaz de receber automaticamente evidência do fechamento no aparelho.

As superfícies cloud existentes são de engenharia e publicação: GitHub Actions para qualidade e Web, Codemagic para APK/AAB Android assinado com identidade externa, GitHub Pages para o site institucional e um workflow manual de MobSF para análise estática com chave efêmera. Elas não constituem observabilidade de runtime do aplicativo. O GitHub Actions atual também não executa APK/AAB Android; o Codemagic está descrito, mas não há nesta revisão uma execução rastreável ao commit atual com assinatura de produção confirmada.

A observabilidade implementada é **local, minimizada e manual**. `DiagnosticsService` captura eventos Dart/Flutter, limita a 200 eventos, sanitiza mensagens, caminhos e padrões óbvios de segredo e permite exportar JSON pela área protegida. Isso é uma boa barreira de privacidade e um mecanismo útil de suporte, mas não captura morte nativa anterior ao Flutter, falha de linker/JNI, encerramento da Activity ou processo terminado antes de o diagnóstico ser inicializado. A inicialização do diagnóstico ocorre depois de Hive, armazenamento seguro e três caixas principais; falhas anteriores ficam apenas em memória e podem desaparecer com o processo.

O incidente deve permanecer classificado como **P0 de disponibilidade e causa indeterminada**. A prioridade é fixar o APK efetivamente testado, executar instalação limpa offline em aparelho físico saudável e coletar logcat técnico sanitizado se o fechamento persistir. A publicação do AAB deve continuar bloqueada até que o runtime Android, a proveniência do artefato, os gates de segurança e o procedimento de suporte tenham evidência correspondente.

## Baseline verificado

O checkout observado está na branch `work/qa-observability-and-emulator`, commit `c8fcab1ade6238966a2a68faaa7cb7d9c94c1ef8`, com working tree contendo apenas `docs/team-review/` não rastreado antes deste relatório. Há divergência documental: o handoff atualizado menciona `40d9e53`, relatórios de build mencionam `5741575` e revisões anteriores mencionam `c8fcab1`; os hashes de APK também variam entre documentos. Essa divergência não é, por si só, causa de crash, mas impede atribuir um resultado ao binário correto sem registrar SHA-256, pacote, versão, commit, dispositivo e horário juntos.

Os relatórios disponíveis registram sucesso para formatação, análise Flutter, 84 testes, build Web release, APK debug, APK release, AAB release e reconstrução limpa. Esses resultados demonstram compilação e empacotamento, não primeiro frame, permanência no processo, entrada na grade CAA ou uso offline em aparelho físico. O AVD da Manus não é uma reprodução válida do aplicativo: o serviço `package` e o `system_server` do próprio Android do emulador morreram antes de uma execução confiável.

## Inventário de arquitetura cloud e operação

| Superfície | Estado factual | Limite operacional |
|---|---|---|
| Aplicativo Android/Web | Flutter local-first; armazenamento Hive e chaves locais; comunicação básica sem servidor | Não há coleta automática de crash, métricas de disponibilidade ou diagnóstico nativo remoto |
| Backend/portal conectado | Não implementado no checkout; há contratos, modelos e políticas Dart/documentais | Não existe API, banco, autenticação, autorização server-side, sincronização ou isolamento multi-organização real |
| GitHub Actions | Workflow de qualidade executa `pub get`, formatação, análise, testes e build Web; dispara em `main`, `feat/**` e PR para `main` | Não constrói APK/AAB, não instala Android, não executa smoke test e não cobre push em `work/**` |
| Codemagic | Workflow `android-release` usa Flutter 3.38.0, identidade externa `fala-comigo-release` e gera APK/AAB; `web-release` gera Web | Não há nesta revisão log de execução para o SHA atual, fingerprint da keystore ou check obrigatório de PR/release |
| GitHub Pages | Publica `site/` em push na `main` quando há alteração relevante ou por disparo manual | É publicação do site, não backend do app nem canal de suporte/telemetria |
| MobSF | Workflow manual constrói APK release de teste com chave efêmera, executa MobSF isolado e publica JSON/PDF/SHA como artefatos | É análise estática de segurança; não substitui runtime, análise dinâmica, crash reporting ou aprovação de produção |
| Diagnóstico local | JSON local sanitizado, até 200 eventos, exportação manual pelo responsável | Sem ingestão remota, sem alertas, sem correlação de versões/dispositivos e sem cobertura de morte nativa pré-Flutter |

## Fatos confirmados

### F-01 — Não há plano de dados cloud do aplicativo

A busca no código, dependências e configuração não encontrou cliente de API, servidor, banco remoto, Firebase/Crashlytics, Sentry, Datadog, OpenTelemetry, Supabase ou mecanismo equivalente de telemetria. O Manifest principal sequer declara `INTERNET`, coerente com o núcleo offline. Os modelos de planos citam recursos remotos futuros, mas não são implementação de backend. O console RH estático e os contratos documentais não formam uma fronteira de confiança server-side.

**Implicação:** o app deve continuar funcionando sem cloud, mas a equipe não pode esperar que o incidente físico apareça em um painel remoto. Qualquer captura automática futura precisará de decisão explícita de privacidade, consentimento, minimização, retenção e desligamento, especialmente porque o produto lida com dados de crianças.

### F-02 — CI/CD cobre compilação parcialmente, não operação Android

`.github/workflows/flutter.yml` executa qualidade, testes e Web release, mas não executa `flutter build apk --release`, `flutter build appbundle --release`, verificação de assinatura efetiva, instalação, primeiro frame ou smoke test Android. O comando de formatação modifica o workspace e não usa `--set-exit-if-changed`, portanto a verificação não é um gate não mutante de árvore limpa.

`codemagic.yaml` está preparado para assinatura externa e produção de APK/AAB, mas a presença da configuração não comprova execução. Não foi encontrado nesta revisão um artefato Codemagic rastreado ao SHA atual com fingerprint de produção confirmada. A release local de diagnóstico usa chave temporária, e o Gradle bloqueia release sem `android/key.properties`, o que é uma proteção correta contra fallback para debug.

### F-03 — O fechamento ao abrir não tem evidência cloud ou log causal

O relato disponível é que o APK instala e fecha ao abrir. Não há logcat, tombstone, relatório técnico sanitizado do aparelho, fabricante, modelo, API Android ou horário do incidente no checkout. Os relatórios registram o AVD inválido, não uma execução do app: o próprio sistema Android do emulador perdeu serviços essenciais antes da instalação/execução confiável.

Logo, os fatos permitidos são: **build aprovado segundo os relatórios; instalação/fechamento relatados; runtime físico não diagnosticado; causa desconhecida**. Não é permitido transformar o erro do AVD em crash do app nem inventar stack trace.

### F-04 — O diagnóstico local cobre apenas parte do espaço de falhas

`main.dart` instala `FlutterError.onError`, `PlatformDispatcher.onError` e uma zona protegida; chama `runApp` cedo e mostra uma tela de carregamento/falha quando o Flutter permanece vivo. O bootstrap ainda executa orientação, `Hive.initFlutter`, registro de adapter, leitura/criação de chave em `flutter_secure_storage`, abertura/migração de três caixas, inicialização de diagnóstico e semeadura de cartões antes do estado `ready`.

`DiagnosticsService.init()` ocorre somente depois das três caixas principais. Eventos anteriores permanecem em memória. A captura é limitada e sanitizada, mas um processo nativo morto antes do Dart, uma falha de linker/JNI, falha de criação da Activity, erro de registro nativo de plugin ou encerramento por sinal não chega necessariamente à tela nem ao JSON local. TTS e notificações foram adiados para depois da primeira tela; isso reduz uma hipótese de falha Dart inicial, mas não prova a causa original e não remove o registro nativo dos plugins no engine.

### F-05 — Os testes de diagnóstico verificam sanitização, não coleta em Android real

`test/diagnostics_service_test.dart` verifica remoção de token/caminho, metadados sensíveis e limite de 200 eventos. Não há evidência de teste de integração Android que valide primeiro frame, captura de morte nativa, comportamento com Keystore indisponível, caixa corrompida, migração em aparelho, geração de relatório após interrupção ou fluxo de suporte do aparelho afetado.

### F-06 — Segurança e proveniência ainda são gates separados

O relatório MobSF do APK de teste (`b262679c...`) registra score 46, dois achados altos, cinco warnings, uma informação e um hotspot de permissões. Entre os achados estão CBC com padding PKCS5/PKCS7 associado à dependência usada pelo Hive e `minSdk=24`. Isso é risco de segurança, compatibilidade e release; **não é evidência de que qualquer um desses itens causou o fechamento**.

Há ainda inconsistência documental do pacote: README cita `com.falacomigo.caa`, enquanto Gradle, Manifest e relatórios atuais usam `com.falacomigo.fala_comigo`. A divergência pode fazer a equipe desinstalar, limpar dados ou filtrar logs do pacote errado.

### F-07 — O backend futuro está corretamente bloqueado, mas ainda não existe

As políticas locais verificam flags e valores recebidos pelo chamador, como organização, consentimento e auditoria. Elas servem como contrato de domínio e testes de negação, mas não autenticam sessão, consultam membership, protegem banco, impõem isolamento, persistem auditoria ou controlam URLs de mídia. Portal RH, sincronização clínica, cobrança e licenças remotas não devem ser tratados como recursos implementados nem usados para explicar o crash Android.

## Riscos classificados

### R-CLOUD-01 — P0: ausência de gate de runtime e de rollback verificável

Um APK pode passar por compilação e empacotamento e ainda fechar no primeiro uso. O pipeline atual não produz evidência automática de primeiro frame, estabilidade mínima, comunicação offline ou compatibilidade em celular/tablet. Também não há nesta revisão um procedimento comprovado de promoção, rollback e identificação de versão no canal Android. Liberar o AAB antes do smoke test físico e da assinatura/proveniência verificadas transfere uma falha P0 para famílias.

### R-OBS-01 — P0: ponto cego entre Dart e o processo Android

A observabilidade local é útil somente enquanto o processo Flutter continua vivo. O caso relatado pode ocorrer antes da tela e antes da inicialização persistente do diagnóstico. Sem logcat nativo, a equipe fica sujeita a alterações por tentativa e erro em TTS, notificações, Hive ou Keystore, sem redução responsável da incerteza.

### R-OPS-01 — P1: ausência de telemetria remota é uma escolha de privacidade, mas não de operação completa

Não enviar dados automaticamente reduz exposição de conteúdo sensível e está alinhado ao local-first. Porém, sem uma alternativa operacional aprovada, não há taxa de crash, distribuição por API/fabricante, alertas, tendência de regressão ou correlação entre versão e incidente. A solução não deve ser adicionar coleta irrestrita: deve-se escolher entre suporte manual sanitizado e telemetria técnica opt-in/minimizada, com política de consentimento, retenção, acesso e descarte antes de qualquer implantação.

### R-CLOUD-02 — P1: o CI não valida o artefato Android do commit candidato

O trigger não inclui `work/**`, e a configuração do GitHub não constrói Android. Um resultado verde histórico de `main` não valida automaticamente `c8fcab1`. Codemagic é uma linha separada e depende de segredo/identidade externa. Isso cria risco de produzir, testar ou instalar um APK diferente daquele revisado.

### R-CLOUD-03 — P1: proveniência de artefatos está ambígua

Branches, commits, hashes, contagens de testes e tamanho de artefatos variam entre handoff e relatórios. Sem um manifesto de build que registre SHA do commit, SHA-256 do APK/AAB, `applicationId`, `versionName`, `versionCode`, assinatura/fingerprint, toolchain e horário, uma captura de log ou resultado manual pode ser atribuído ao binário errado.

### R-CLOUD-04 — P1: release e segurança não têm evidência de fechamento

A keystore de produção fica fora do Git, o que é correto, mas não há confirmação nesta sessão de fingerprint esperada, execução Codemagic ou AAB assinado por essa identidade. A análise MobSF é manual e o relatório tem achados altos em revisão. Publicar antes de decidir os achados, repetir o scan no artefato candidato e executar análise dinâmica mantém um gate de segurança aberto.

### R-OBS-02 — P1: governança do diagnóstico local está incompleta

O checklist mantém pendentes aprovação de consentimento/retenção, instrução aos pilotos para não enviar conteúdo de crianças, classificação de severidade, triagem e descarte após análise. A sanitização cobre padrões óbvios, mas não deve ser tratada como garantia universal contra conteúdo sensível em qualquer exceção. O relatório técnico deve ser explicitamente limitado a metadados e analisado em canal autorizado.

### R-CLOUD-05 — P1: superfície cloud futura sem fronteira de confiança implementada

Qualquer portal ou sincronização futura exigirá autenticação, autorização por requisição, isolamento multi-organização, consentimento versionado, retenção, auditoria mínima e URLs temporárias para mídia. Hoje esses itens são contratos e políticas, não controles executados. Ativar backend ou cloud storage antes desses testes negativos criaria risco de exposição e não ajudaria a diagnosticar o fechamento local.

### R-OPS-02 — P2: controles de supply chain e documentação operacional podem divergir

Workflows usam referências de actions por tags (`@v4`, `@v5`) e o MobSF usa imagem `latest`; isso reduz a reprodutibilidade histórica em comparação com referências imutáveis e versões registradas. Além disso, README, handoff e documentos de build não têm uma única fonte de verdade para pacote, SDK, branch e estado. O impacto principal é de rastreabilidade, auditoria e resposta a incidente, não evidência de crash.

## Hipóteses sobre o fechamento — não diagnósticos

Todas as hipóteses abaixo têm **confiança causal baixa** sem logcat do aparelho físico.

1. **Morte nativa antes ou durante a criação do engine Flutter.** Carregamento de biblioteca, JNI, Activity ou registro de plugin pode terminar o processo antes dos handlers Dart. É compatível com a ausência de relatório local, mas não identifica componente.
2. **Falha de Android Keystore ou `flutter_secure_storage`.** A chave é lida/criada antes da abertura das caixas. Fabricante, estado do Keystore ou chave inválida podem alterar o resultado; não há evidência no aparelho para confirmar.
3. **Caixa Hive corrompida, chave incompatível ou migração acionada indevidamente.** O fallback trata erro amplo de abertura cifrada como possível legado e executa recuperação. Isso é risco sustentado pelo código, não causa comprovada.
4. **Dados persistidos ou atualização sobre uma instalação anterior.** Estado antigo, assinatura diferente ou formato incompatível podem produzir comportamento distinto da instalação limpa. É necessário separar os cenários com fixtures sintéticas.
5. **Incompatibilidade de fabricante, API ou política do dispositivo.** `minSdk=24`, orientação paisagem, Keystore, permissões e componentes de notificação ampliam a matriz, mas o dispositivo afetado não está identificado.
6. **Falha após o bootstrap, na splash ou na primeira renderização.** Providers, caixas, assets e widgets só são exercitados em etapas posteriores; o relato não informa em qual tela o processo desaparece.
7. **TTS ou notificações.** Como chamadas Dart foram adiadas e protegidas individualmente, são menos prováveis como bloqueador inicial nesse nível. Ainda pode existir falha nativa de plugin ou falha ao usar o recurso. Não há base para atribuir o incidente a eles.
8. **Tamanho do APK, redução Debug/Release ou chave temporária.** A diferença de tamanho é esperada entre variantes. A chave temporária limita atualização/distribuição, mas não prova perda de recursos nem causalidade do fechamento.

## Ações recomendadas e critérios de saída

| Prioridade | Ação | Critério de saída |
|---|---|---|
| P0 | Fixar o artefato do teste: commit, SHA-256 do APK, pacote `com.falacomigo.fala_comigo`, `versionName`/`versionCode`, assinatura, toolchain, dispositivo e horário | Uma ficha única permite reproduzir exatamente o binário e o incidente |
| P0 | Fazer instalação limpa em celular físico saudável, offline, com a versão anterior desinstalada e reinicialização; repetir em tablet | Primeiro frame, grade CAA e permanência observados; F01/F21/F22 deixam de estar pendentes |
| P0 | Se fechar, limpar o buffer e coletar logcat real do aparelho imediatamente; filtrar pacote efetivo, `AndroidRuntime`, `FATAL EXCEPTION`, `flutter`, `libc`, `ActivityTaskManager`, `PackageManager` e `system_server` | Causa classificada como Dart, plugin/nativa, dados ou compatibilidade; nenhum conteúdo de criança incluído |
| P0 | Repetir instalação limpa, `pm clear`/dados limpos e atualização sobre dados sintéticos | Diferença entre estado persistido e instalação nova demonstrada sem destruir dados reais |
| P0 | Bloquear AAB/APK público até smoke test Android, assinatura de produção e gates MobSF/MASVS terem evidência | Decisão de release assinada, rastreável ao SHA candidato e com rollback documentado |
| P1 | Fazer Android build não-distributivo ser check rastreável ao commit no GitHub ou tornar Codemagic check obrigatório de PR/release | APK/AAB, metadados, fingerprint e logs são associados ao mesmo SHA; branch `work/**` não fica sem cobertura por acidente |
| P1 | Corrigir a verificação de formatação para modo não mutante e registrar o estado limpo do workspace | CI falha quando o código exige formatação, em vez de alterá-lo silenciosamente |
| P1 | Definir política de observabilidade: suporte manual sanitizado versus telemetria técnica opt-in; retenção, acesso, consentimento, classificação e descarte | Checklist de diagnóstico aprovado; nenhum upload automático de conteúdo familiar; procedimento de incidente testado |
| P1 | Criar, em ciclo próprio, cobertura de startup/instrumentação nativa e teste Android de primeira renderização, sem alterar o código nesta revisão | Falhas de Keystore, Hive, plugin indisponível e morte pré-Flutter têm caminhos de evidência separados |
| P1 | Reexecutar MobSF no APK candidato e executar análise dinâmica/revisão MASVS/MASTG | Achados altos corrigidos ou aceitos formalmente com mitigação; SHA do scan preservado |
| P1 | Reconciliar README, handoff, checklist, matriz e Codemagic com uma única linha de base | Pacote, branch, SDK, versão, testes e hashes deixam de divergir |
| P2 | Fixar versões/SHAs de actions e imagem MobSF, e preservar manifesto/SBOM de build | Reexecução futura usa dependências de CI identificáveis e auditáveis |
| P2 | Manter backend, storage remoto, RH, sincronização e cobrança bloqueados até implementar autorização server-side e testes negativos | Nenhum recurso remoto é apresentado como existente; o núcleo offline permanece independente |

## Arquitetura cloud recomendada para a fase futura

A fase atual deve permanecer com dois planos claramente separados:

1. **Plano local de comunicação:** cartões, frase, TTS, acessibilidade, dados locais e controles parentais. Deve abrir e operar sem internet, conta ou licença. Falha de rede ou indisponibilidade cloud jamais pode bloquear esse plano.
2. **Plano conectado opt-in:** somente depois de contrato de dados, governança e testes. Uma API deve derivar identidade da sessão, validar organização, vínculo, finalidade, escopo, consentimento, retenção e revogação a cada operação. Banco e storage devem aplicar isolamento por organização; mídia deve permanecer privada, com URLs temporárias, limites de tipo/tamanho e auditoria minimizada.
3. **Plano de operação:** CI/CD deve produzir artefatos rastreáveis, release deve ter aprovação e rollback, e observabilidade deve coletar somente o mínimo técnico necessário. Logs e eventos não devem conter nomes, frases, cartões, fotos, áudio, vídeo, diagnóstico ou tokens. Métricas agregadas de saúde devem ser separadas do conteúdo de uso e submetidas a política de retenção.

Nenhum desses controles cloud futuros está implementado no checkout atual. A recomendação é tratá-los como arquitetura-alvo, não como capacidade já disponível.

## Conclusão e confiança

**Veredito:** build e empacotamento estão documentados como saudáveis, mas o runtime Android permanece não validado e o incidente de fechamento permanece sem causa. A arquitetura cloud atual é deliberadamente mínima e local-first, porém a operação ainda não possui um gate Android reproduzível nem observabilidade nativa suficiente para diagnosticar uma morte pré-Flutter. O release público deve permanecer bloqueado.

**Confiança:** alta para o inventário de superfícies cloud, configuração dos workflows, ausência de backend/telemetria no checkout, existência e limites do diagnóstico local, caminho de startup e ausência de logcat. Média-alta para os riscos de proveniência, CI/CD, governança e release, pois decorrem diretamente dos arquivos e checklists. Baixa para qualquer hipótese causal do fechamento, deliberadamente não confirmada sem logcat do aparelho físico.

## Referências

- [`PROJECT_HANDOFF.md`](../../PROJECT_HANDOFF.md)
- [`AGENTS.md`](../../AGENTS.md)
- [`RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md`](../RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md)
- [`AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md`](../AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md)
- [`CHECKLIST_EXECUCAO_E_TESTES.md`](../CHECKLIST_EXECUCAO_E_TESTES.md)
- [`CHECKLIST_PRE_LANCAMENTO.md`](../CHECKLIST_PRE_LANCAMENTO.md)
- [`MATRIZ_FLUXOS_CRITICOS.md`](../MATRIZ_FLUXOS_CRITICOS.md)
- [`BUILDS_CODEMAGIC.md`](../BUILDS_CODEMAGIC.md)
- [`PLANO_SEGURANCA_OWASP_MASVS_MOBSF.md`](../PLANO_SEGURANCA_OWASP_MASVS_MOBSF.md)
- [`RELATORIO_CONTINUIDADE_2026-09-24.md`](../RELATORIO_CONTINUIDADE_2026-09-24.md)
- [`codemagic.yaml`](../../codemagic.yaml)
- [GitHub Actions — Flutter quality checks](https://github.com/falacomigocaa-app/fala-comigo/actions/workflows/flutter.yml)
- [GitHub Actions — MobSF mobile security scan](https://github.com/falacomigocaa-app/fala-comigo/actions/workflows/mobsf-security-scan.yml)
- [GitHub Actions — GitHub Pages](https://github.com/falacomigocaa-app/fala-comigo/actions/workflows/site-pages.yml)
- [`lib/main.dart`](../../lib/main.dart)
- [`lib/core/services/diagnostics_service.dart`](../../lib/core/services/diagnostics_service.dart)
- [`test/diagnostics_service_test.dart`](../../test/diagnostics_service_test.dart)
- [`android/app/src/main/AndroidManifest.xml`](../../android/app/src/main/AndroidManifest.xml)
- [`android/app/build.gradle.kts`](../../android/app/build.gradle.kts)
- [`pubspec.yaml`](../../pubspec.yaml)
- [`security/reports/MOBSF_2026-09-24.md`](../../security/reports/MOBSF_2026-09-24.md)

_Nota: nenhuma linha de código foi alterada como parte desta revisão._
