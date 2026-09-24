# Revisão Tech Lead — Android instala e fecha ao abrir

**ID:** `03-03`  
**Papel:** Tech Lead  
**Escopo:** análise de causa raiz do fechamento do APK Android após instalação  
**Branch observada:** `work/qa-observability-and-emulator`  
**HEAD observado:** `c8fcab1` (`feat: finalize MVP startup and delivery package`)

## Conclusão executiva

A causa raiz **não está confirmada**. Não há logcat do aparelho físico neste repositório, portanto não é responsável atribuir o fechamento a Hive, armazenamento seguro, TTS, notificações, Manifest, assinatura ou a um fabricante específico. O fato disponível é: o APK instala, o build compila e a abertura no aparelho físico ainda falha; a exceção ou o sinal que encerra o processo não foi capturado.

A evidência separa duas coisas. O pipeline de compilação está saudável: a documentação registra análise estática, 84 testes, APK debug, APK release, AAB release e build limpa aprovados. Isso prova geração do pacote, não inicialização correta em um telefone real [2] [3]. A execução no AVD da Manus também não diagnostica o aplicativo: o serviço Android `package` e o `system_server` do emulador morreram antes de uma execução válida do APK [3].

O domínio de falha mais importante continua sendo a **inicialização Android antes da aplicação estar pronta**, especialmente a ponte nativa de armazenamento seguro/Keystore ou outro encerramento nativo anterior ao tratamento Dart. Essa é uma hipótese priorizada, não uma causa confirmada. O caminho de TTS e notificações foi retirado do caminho crítico no commit `40d9e53`, com tratamento independente de exceções; essa mudança reduz a probabilidade de esses serviços explicarem o fechamento inicial, mas não constitui prova causal [2] [5].

## Fatos confirmados

1. **O pacote compila e instala.** A matriz documentada com Flutter 3.38.0, Android SDK 36, JDK 21 e Gradle 9.3.1 registra sucesso para análise, testes, APK debug, APK release, AAB release e build limpa. O checklist, contudo, mantém “instalação limpa abre a grade CAA” pendente [2] [3] [4].

2. **Não existe evidência de logcat do telefone.** Os relatórios explicitam que o fechamento físico permanece sem explicação e pedem fabricante, modelo, versão/API, condição de desinstalação e logcat filtrado. Este relatório não inventa nenhuma linha de log [2] [3].

3. **O AVD não é evidência de crash do aplicativo.** O erro documentado foi `Broken pipe`, acompanhado de ausência do serviço `package` e encerramento do `system_server`. A instalação não chegou a uma execução confiável do Fala Comigo nesse emulador [3].

4. **A inicialização Dart agora mostra uma tela de carregamento antes do bootstrap.** `main()` chama `runApp` com `BootstrapApp` e inicia `_startApp()` de forma assíncrona. O estado somente passa a pronto depois de orientação, Hive, caixas cifradas, diagnóstico e população inicial dos cartões concluírem [5]. Uma exceção Dart no bootstrap deve mudar o estado para `StartupFailureApp`, em vez de chamar um segundo `runApp` [5].

5. **Ainda há operações críticas antes de `StartupState.ready`.** `_bootstrapApp()` executa `SystemChrome.setPreferredOrientations`, `Hive.initFlutter`, registro do adapter Hive, leitura/criação da chave em `flutter_secure_storage`, abertura ou migração das caixas `pictogram_cards`, `app_settings` e `transition_alerts`, inicialização do diagnóstico e escrita dos cartões padrão [5] [6].

6. **TTS e notificações foram adiados.** A inicialização de `TtsService` e `TransitionAlertService` ocorre depois da primeira tela, em função separada, e cada serviço possui captura independente de exceções Dart [5]. A mudança não cobre um crash nativo anterior ao Flutter nem elimina os riscos da inicialização de armazenamento.

7. **O tratamento de erro tem limite claro.** Existem handlers para `FlutterError`, `PlatformDispatcher.onError` e exceções Dart no bootstrap. Eles registram eventos minimizados e tentam exibir diagnóstico. Um processo terminado pelo Android, por SIGABRT/SIGSEGV, por falha de uma biblioteca nativa ou antes de o Dart assumir o controle pode não alcançar esses handlers [5] [7].

8. **O Manifest de release contém componentes nativos além da Activity.** Além de `MainActivity`, o pacote mesclado contém receivers de notificações, providers de image picker, impressão e compartilhamento, uma Activity de URL e inicialização do AndroidX/Profile Installer [7]. O build ter mesclado esses componentes não prova que cada caminho de runtime esteja correto no aparelho alvo.

9. **Há riscos de segurança e compatibilidade já conhecidos, mas eles não são a causa demonstrada do fechamento.** O MobSF reportou achados altos relacionados ao CBC/PKCS5/PKCS7 e a `minSdk=24`; o checklist Android também deixa permissões, receivers, migração e análise dinâmica pendentes [2] [4]. Esses itens exigem tratamento próprio e não devem ser usados como explicação sem evidência do aparelho.

10. **Há inconsistência documental de identidade e estado.** O código Gradle e o Manifest mesclado usam `applicationId` `com.falacomigo.fala_comigo`, enquanto o README ainda menciona `com.falacomigo.caa`. Handoff e continuidade também contêm referências históricas a branches e commits anteriores. Isso pode confundir instalação limpa, atualização, comandos de suporte e coleta de logs, embora não prove um crash [1] [5] [7].

## Classificação da causa raiz

### Causa confirmada

Nenhuma. O máximo que os fatos permitem afirmar é que a falha ocorre no ciclo de abertura em aparelho físico e que a compilação não é o bloqueador. Sem o logcat correspondente ao instante da abertura, não há exceção, stack trace, sinal nativo ou componente responsável identificado.

### Hipóteses priorizadas

| Prioridade | Hipótese | Base no código e evidência disponível | Como confirmar ou refutar |
|---|---|---|---|
| Alta | Encerramento nativo durante a criação da Activity, carregamento do engine Flutter ou registro de plugin, antes de o fallback Dart conseguir renderizar. | O fechamento é descrito como silencioso no aparelho; handlers Dart não cobrem morte do processo. O Manifest mesclado declara vários componentes nativos. Não há logcat para distinguir Java, JNI, linker ou sinal nativo. | Logcat do próprio aparelho imediatamente após uma instalação limpa. Procurar `FATAL EXCEPTION`, `AndroidRuntime`, `libc`, `UnsatisfiedLinkError`, `SIGABRT` e `SIGSEGV`. |
| Média-alta | Falha específica do `flutter_secure_storage`/Android Keystore ou da abertura/migração Hive durante o bootstrap. | Essas operações são obrigatórias antes de `ready`. A função de migração captura qualquer erro da abertura cifrada e tenta abrir a caixa legada, copiar valores, apagar o arquivo e recriar a caixa cifrada [6]. O fluxo é sensível a estado antigo, chave ausente, dados incompatíveis e comportamento do Keystore. | Comparar instalação limpa (`uninstall`/`pm clear`) com instalação sobre dados existentes; coletar stack trace. Se for exceção Dart, a tela de diagnóstico deve aparecer; se o processo morrer, o log nativo deve indicar a camada. |
| Média | Estado persistido antigo ou incompatível, incluindo dados de uma versão anterior ou uma migração que não consegue ler o conteúdo. | O código possui migração genérica para as caixas principais, mas não há teste instrumentado no aparelho real para upgrade, corrupção ou perda de chave. A instalação sobre versão anterior é explicitamente um cenário pendente [4]. | Reproduzir em três estados: instalação limpa, atualização sobre dados sintéticos e dados removidos com `pm clear`. Comparar os logs e o relatório local de diagnóstico. |
| Média | Incompatibilidade de versão Android, fabricante, API ou política de segurança do aparelho. | `minSdk=24` e `targetSdk=36` ampliam a matriz de compatibilidade; a matriz real de celulares e tablets ainda não está registrada. O risco de `minSdk` foi apontado pelo MobSF, mas não há evidência de que este aparelho tenha sido afetado [2] [4]. | Registrar fabricante/modelo/API e repetir o APK release em pelo menos um aparelho de referência e no aparelho afetado, sempre com instalação limpa. |
| Baixa após a correção | TTS ou notificações causando o fechamento inicial. | Antes do commit `40d9e53`, esses serviços eram aguardados no caminho de bootstrap. No código atual, são inicializados depois da primeira tela e cada falha Dart é capturada [2] [5]. | Se o app abrir após o adiamento, isso aumenta a suspeita histórica; se continuar fechando antes da tela, essa hipótese perde força. O logcat ainda é necessário para confirmar um crash nativo de plugin. |
| Baixa como causa direta | Diferença de tamanho entre APK debug e release ou assinatura temporária. | A diferença de aproximadamente 159 MB para 57 MB é explicada pelos modos Debug e Release. O release de diagnóstico usa chave temporária, não a chave de produção; isso é um limite de distribuição, não evidência de recurso ausente [2] [3]. | Conferir `applicationId`, versão, assinatura e artefato instalado. Não usar tamanho do APK como diagnóstico de runtime. |

## Riscos que permanecem abertos

**Risco de disponibilidade:** a comunicação básica ainda não tem a evidência exigida para ser considerada funcional em instalação limpa Android. O checklist mantém primeira abertura, cartões offline, TTS/fallback e falhas de áudio pendentes [4]. O produto não deve ser apresentado como MVP validado em dispositivo apenas porque o APK compila.

**Risco de diagnóstico incompleto:** a captura local pode registrar exceções Dart e gerar relatório, mas não substitui logcat quando o processo morre antes do Flutter ou dentro de código nativo. A tela de falha é uma mitigação, não um observador universal [5] [7].

**Risco de dados locais:** a migração em `openSecureBoxWithMigration` trata qualquer falha da abertura cifrada como possível caixa legada e, em seguida, pode apagar a caixa legada depois de copiá-la. O comportamento precisa de teste de upgrade, corrupção, chave inválida e recuperação antes de ser considerado seguro para dados existentes [6]. Não se deve trocar a criptografia apenas para melhorar o score do scanner sem definir formato, autenticidade e migração [2].

**Risco de compatibilidade Android:** `minSdk=24`, `targetSdk=36`, permissões de câmera, áudio, imagens, notificações, alarmes exatos e tela cheia formam uma superfície de variação por API e fabricante. Permissões de runtime não são solicitadas no bootstrap atual, o que reduz uma causa de encerramento inicial, mas deixa os fluxos funcionais ainda não validados [4] [7].

**Risco operacional de instalação:** a discrepância entre `com.falacomigo.caa` no README e `com.falacomigo.fala_comigo` no pacote pode levar a desinstalação, `pm clear`, coleta de logcat ou atualização do pacote errado. A documentação deve usar uma identidade única antes do próximo ciclo de suporte [1] [5] [7].

**Risco de segurança independente:** o Manifest mesclado mostra `ProfileInstallReceiver` exportado com permissão `android.permission.DUMP`, e o MobSF já apontou achados altos. Isso requer revisão de release e análise dinâmica, mas não é evidência de que esse receiver tenha encerrado a Activity [2] [7].

## Ações recomendadas, sem alteração de código nesta revisão

1. **P0 — Coletar a evidência que falta no aparelho afetado.** Instalar o APK release mais recente após desinstalar a versão anterior, registrar fabricante, modelo, versão do Android, API, horário e se houve restauração de dados. Limpar o buffer imediatamente antes da tentativa e exportar o logcat do próprio aparelho. Filtrar por `AndroidRuntime`, `FATAL EXCEPTION`, `flutter`, `libc`, `ActivityTaskManager`, `PackageManager` e o pacote `com.falacomigo.fala_comigo`. Nenhum log foi coletado nesta revisão e nenhum resultado deve ser presumido.

2. **P0 — Fazer duas execuções controladas.** Primeiro, uma instalação totalmente limpa para separar falha de dados antigos. Depois, uma atualização sobre dados sintéticos para exercitar migração. Não usar dados reais de criança. A diferença entre esses resultados é necessária para classificar estado persistido versus falha de processo.

3. **P0 — Classificar o log antes de mudar o código.** `FATAL EXCEPTION` em Java/plugin aponta para componente Android; `KeyStoreException`, `BadPaddingException`, erro Hive ou stack Dart aponta para bootstrap/estado local; `SIGSEGV`, `SIGABRT`, linker ou tombstone aponta para nativo; falha de Activity/Manifest aponta para a camada Android de lançamento. Essa classificação deve vir do log real, não de inferência pelo tamanho do APK.

4. **P1 — Se o log apontar para bootstrap de armazenamento, isolar as fases.** Reproduzir em aparelho com estado limpo e estado antigo, preservando o pacote e a versão usados. Revisar a estratégia de migração, o comportamento de chave inválida e a recuperação de caixas sem apagar dados antes de existir cópia válida. A decisão de criptografia deve permanecer separada do incidente de abertura.

5. **P1 — Se o log apontar para plugin ou componente nativo, revisar o Manifest mesclado e as versões resolvidas.** Conferir Activity, receivers, providers, Profile Installer, carregamento de bibliotecas e compatibilidade do plugin no Android/API afetado. O teste deve repetir a instalação no mesmo modelo e em um aparelho de referência.

6. **P1 — Adicionar depois do diagnóstico um smoke test de lançamento Android.** O teste deve cobrir instalação limpa, primeiro frame, reabertura, atualização e retorno do segundo plano em dispositivo físico ou emulador saudável. Os testes unitários atuais cobrem domínio e serviços, mas não demonstram que a Activity real abre no dispositivo [4].

7. **P2 — Corrigir a documentação de identidade do pacote.** Alinhar README, handoff, scripts de suporte e relatórios ao `applicationId` efetivamente construído. Atualizar branch e commit somente com evidência, sem misturar registros históricos com o estado atual.

8. **P2 — Manter o gate de distribuição fechado.** Não tratar a release como pronta para publicação ou piloto real enquanto a primeira abertura em celular e tablet, offline e com permissões concedidas/negadas, continuar pendente. O APK/AAB de produção também depende da keystore oficial fora do repositório [1] [4].

## Nível de confiança

A confiança é **alta** nos fatos de compilação, instalação possível, falha do AVD e limites do tratamento Dart, porque estão documentados no repositório e no estado Git observado. A confiança é **baixa** na causa raiz do fechamento físico: sem logcat e sem fabricante/API do aparelho, não é possível distinguir processo nativo, plugin, Keystore/Hive, dados persistidos ou incompatibilidade de dispositivo. A revisão recomenda coleta de evidência e não declara uma causa que os artefatos atuais não demonstram.

## Referências

[1]: ../PROJECT_HANDOFF.md "Handoff do projeto Fala Comigo"
[2]: AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md "Auditoria do handoff e artefatos Android"
[3]: RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md "Relatório de diagnóstico de build e instalação Android"
[4]: CHECKLIST_EXECUCAO_E_TESTES.md "Checklist de execução, testes e prontidão"
[5]: ../lib/main.dart "Inicialização Flutter e tela de diagnóstico"
[6]: ../lib/core/services/secure_box_service.dart "Serviço de caixas Hive protegidas"
[7]: ../android/app/src/main/AndroidManifest.xml "Manifest Android do aplicativo"
[8]: ../android/app/build.gradle.kts "Configuração Gradle do aplicativo Android"

> **Nota de integridade:** nenhum código foi alterado durante esta revisão. Nenhuma linha de logcat foi inventada ou apresentada como evidência.

---

**Revisão preparada para a equipe:** o próximo avanço técnico depende de um logcat do aparelho afetado e de uma matriz mínima de instalação limpa versus atualização sobre dados sintéticos.
