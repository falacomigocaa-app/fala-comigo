# Revisão QA Automation — abertura e fechamento do APK

**ID:** 12-12  
**Papel:** QA Automation Engineer  
**Data:** 24 de setembro de 2026  
**Branch auditada:** `work/qa-observability-and-emulator`  
**Commit atual do checkout:** `c8fcab1` (`feat: finalize MVP startup and delivery package`)  
**Escopo:** análise do relato de que o APK instala, mas fecha ao abrir; conferência do handoff, critérios, relatórios, artefatos e caminho de inicialização.  
**Integridade:** nenhum arquivo de código foi alterado. Este documento não contém logcat inventado.

## Conclusão executiva

O build Android está documentado como compilado e empacotado com sucesso, mas o critério de **primeira abertura funcional** continua reprovado ou não demonstrado. O relato de fechamento no aparelho é compatível com um bloqueador P0 de disponibilidade. Não existe no checkout um logcat do telefone afetado, relatório técnico sanitizado, fabricante, modelo, versão/API ou horário do incidente que permita identificar a causa.

O AVD usado no ambiente não é evidência de execução do aplicativo: o serviço Android `package` e o `system_server` morreram antes de uma instalação/executação válida. Portanto, o erro `Broken pipe` do AVD não deve ser atribuído ao Fala Comigo. Os testes automatizados e os builds demonstram qualidade de compilação, empacotamento e partes do domínio, mas não substituem um smoke test de runtime em aparelho físico ou emulador saudável.

A decisão QA é **não liberar para lançamento público nem marcar o primeiro build funcional como aprovado**. O próximo gate é reproduzir com um artefato fixado, em instalação limpa e offline, em celular e tablet, coletando logcat real se o processo fechar novamente.

## Evidência factual

### 1. Estado do artefato e da validação automatizada

O APK Release disponível neste checkout é `build/app/outputs/flutter-apk/app-release.apk`, com 57.279.118 bytes e SHA-256 `310b47377933f970b763d5fa9ce2de088d20b512ffdd79c49ea0effa50323503`. O AAB Release disponível tem 45.023.814 bytes. Os metadados documentados são `applicationId` `com.falacomigo.fala_comigo`, `versionName` `1.0.0`, `versionCode` `1`, `minSdk` 24 e `targetSdk` 36 [1] [2].

Os relatórios registram formatação, análise Flutter, 84 testes, build Web Release, APK Debug, APK Release, AAB Release e build limpa como aprovados [1] [2]. Esta é evidência documental dessas execuções; ela não demonstra, por si só, que o APK atualmente presente foi o binário instalado no telefone que fecha.

O tamanho aproximado de 159 MB no Debug e 57 MB no Release é consistente com variantes de build diferentes. A diferença não prova remoção de telas, assets ou plugins [2]. A assinatura local é de diagnóstico e não é a chave oficial de produção; isso limita distribuição e atualização, mas não prova que a assinatura cause o fechamento [1] [3].

### 2. Evidência do incidente e ausência de log causal

O handoff e os relatórios descrevem que o APK instala, mas fecha ao abrir. Não há no checkout logcat do telefone físico, exceção nativa, `FATAL EXCEPTION`, tombstone ou relatório técnico sanitizado que relacione o fechamento a um componente específico [1] [3]. Também não há os metadados mínimos do aparelho afetado.

O AVD apresentou `Failure calling service package: Broken pipe (32)`, `Can't find service: package` e encerramento do `system_server` antes de uma execução confiável. Esse evento caracteriza uma falha da infraestrutura do emulador; não é reprodução do aplicativo [1].

### 3. Caminho de inicialização relevante

Em `lib/main.dart`, `main()` instala handlers para erros Flutter e de plataforma, chama `runApp` imediatamente com `BootstrapApp` e inicia o bootstrap em uma zona protegida [4]. Uma tela de carregamento e uma tela de falha podem aparecer se o processo Dart continuar vivo e a exceção chegar aos handlers.

Antes de publicar o estado `ready`, o bootstrap ainda executa, em sequência, a trava de orientação, `Hive.initFlutter`, registro do adapter, leitura/criação de chave em `flutter_secure_storage`, abertura ou migração das caixas `pictogram_cards`, `app_settings` e `transition_alerts`, inicialização do diagnóstico e semeadura dos cartões padrão [4] [5]. Essa é a dependência obrigatória mais relevante para a disponibilidade da primeira tela funcional.

TTS e notificações foram movidos para uma tarefa não aguardada depois do bootstrap, com tratamento independente de exceções. Isso reduz a probabilidade de uma falha Dart nesses serviços bloquear a primeira interface; não elimina falhas nativas durante o registro dos plugins no engine Flutter [4] [6].

A tela `StartupFailureApp` só cobre falhas observáveis pelo Flutter/Dart. Uma morte do processo antes do Dart, falha de carregamento de biblioteca, erro JNI ou encerramento nativo da Activity não é coberto de forma confiável por essa tela [4] [7].

### 4. Configuração Android observada

O Manifest declara câmera, leitura de imagens, microfone, notificações, tela cheia, alarme exato, boot completed e vibração. A Activity launcher está exportada, usa Flutter embedding 2 e fixa paisagem tanto no Manifest quanto no código Dart [8] [9]. A declaração, isoladamente, não identifica uma causa de crash. Ela amplia, porém, a matriz que precisa ser exercitada por versão de Android, fabricante, permissões, ciclo de vida e orientação.

O registrador gerado inclui plugins de áudio, notificações, armazenamento seguro, TTS, seleção de imagem, impressão, gravação, compartilhamento, URL launcher e outros [7]. O adiamento das chamadas Dart de TTS e notificações não impede o registro nativo desses plugins quando o engine é criado.

### 5. Critérios do checklist

| Critério | Estado QA | Evidência e lacuna |
| --- | --- | --- |
| Compilação, análise e testes automatizados | **Documentado como aprovado** | 84 testes e builds registrados; não provam execução Android real [1] [2]. |
| APK instala | **Relatado como sim** | O relato não fixa hash, pacote instalado e horário; a identidade do binário no telefone não está comprovada. |
| Primeira abertura e entrada na grade CAA | **Não aprovado** | O usuário relata fechamento; o checklist mantém o item pendente [2]. |
| Comunicação offline após a abertura | **Não demonstrado** | Não há smoke test válido em aparelho físico ou AVD saudável. |
| Tela de diagnóstico para falha Dart | **Implementada; runtime não demonstrado** | Código e testes de diagnóstico existem; não há teste de abertura no aparelho afetado [4] [6]. |
| Android celular e tablet | **Pendente manual** | A matriz exige validação em ambos; o AVD quebrado não substitui esse gate [3] [10]. |
| Permissões, ciclo de vida, orientação e atualização | **Pendente manual** | O checklist requer estados concedidos/negados, offline, segundo plano, reinicialização e atualização [2] [10]. |
| Segurança e release | **Bloqueado por gates** | MobSF registrou score 46, dois achados altos e a build atual usa chave de diagnóstico; isso não é causa comprovada do fechamento [11]. |

## Achados classificados

### Fatos

1. **O problema não é demonstrado como falha de compilação.** Os relatórios registram builds Android e testes automatizados aprovados [1] [2].
2. **A abertura funcional não está provada.** O relato de fechamento contradiz o critério de primeiro build funcional, e não há evidência de primeiro frame, splash concluída, grade CAA ou permanência no aparelho afetado.
3. **Não existe logcat causal disponível.** Não é possível afirmar que o fechamento seja causado por TTS, notificações, Hive, armazenamento seguro, assinatura, Manifest, orientação, fabricante ou API.
4. **A execução do AVD não foi válida para o aplicativo.** O Android interno do emulador perdeu serviços essenciais antes da execução [1].
5. **A correção de startup adiou TTS e notificações.** Essa alteração está no código e reduz uma dependência Dart inicial, mas não é prova da causa original [4] [6].
6. **Há divergência de proveniência entre documentos.** O handoff e relatórios anteriores citam commits e hashes anteriores, enquanto o checkout atual está em `c8fcab1` e contém um APK com SHA-256 `310b473...`. O relatório de auditoria registra outro hash (`5f602b...`) e a matriz histórica registra 46 testes, enquanto os relatórios atuais registram 84 [2] [3] [10].

### Riscos

1. **P0 — indisponibilidade do núcleo de comunicação.** Até a instalação limpa chegar à grade CAA e permanecer utilizável offline, o produto não atende o gate central do handoff.
2. **P0/P1 — persistência segura acoplada ao startup.** Keystore, `flutter_secure_storage`, Hive, migração e população inicial ocorrem antes da primeira tela funcional. Uma incompatibilidade ou estado persistido inválido pode impedir a abertura, embora não haja evidência de que isso ocorreu no telefone.
3. **P1 — migração de caixas pouco discriminada.** `openSecureBoxWithMigration` trata qualquer falha na abertura cifrada como possível caixa legada, tenta abrir sem cifra, copia valores e apaga a caixa antes de uma estratégia explícita de versão, rollback ou checksum [5]. Isso é risco de disponibilidade e recuperação; não é diagnóstico causal.
4. **P1 — superfície nativa ampla.** O engine registra vários plugins Android antes que a captura Dart seja útil. Uma falha nativa nessa fase pode encerrar o processo sem `StartupFailureApp` [7].
5. **P1 — matriz de plataforma incompleta.** Permissões, orientação fixa em paisagem, alarmes, tela cheia, boot receiver, ciclo de vida, atualização e diferenças de Keystore precisam de testes em celular e tablet.
6. **P1 — segurança e release ainda não fechados.** O MobSF reportou CBC com padding PKCS5/PKCS7 e `minSdk=24` como achados altos, além de warnings de componentes/permissões. O relatório recomenda revisão e nova análise; esses itens não devem ser usados como correção especulativa do crash [11].
7. **P2 — suporte pode procurar o pacote errado.** Há documentação anterior que usa `com.falacomigo.caa`, enquanto o APK efetivo usa `com.falacomigo.fala_comigo`. Isso pode fazer comandos de instalação ou filtros de logcat coletarem o aplicativo errado [3].

### Hipóteses não confirmadas

As hipóteses a seguir servem somente para orientar a coleta. Todas têm confiança causal baixa sem logcat do aparelho.

1. **Falha nativa anterior ou durante a criação do engine.** Carregamento de biblioteca, JNI, criação da Activity ou registro de plugin pode encerrar o processo antes dos handlers Dart.
2. **Falha de Android Keystore ou `flutter_secure_storage`.** A leitura/criação da chave ocorre no caminho obrigatório; incompatibilidade de fabricante, chave inválida ou estado do Keystore são cenários plausíveis.
3. **Caixa Hive corrompida, chave incompatível ou migração acionada indevidamente.** O fluxo de fallback suporta cenários legados, mas não distingue todas as classes de erro.
4. **Incompatibilidade de fabricante, API ou política de dispositivo.** `minSdk=24`, orientação, Keystore e componentes de notificação podem variar entre aparelhos.
5. **Falha na splash ou na primeira tela após o bootstrap.** O relato “fecha ao abrir” não informa se alguma UI apareceu antes do encerramento.
6. **TTS ou notificações.** É menos provável como bloqueador Dart inicial porque as chamadas foram adiadas; continua possível uma falha nativa no registro ou no uso posterior. Não há base para atribuir o incidente a esses plugins.
7. **Assinatura temporária ou tamanho do Release.** São diferenças de distribuição e atualização que devem ser controladas no teste, mas não há evidência de que causem o fechamento.

## Plano de ação QA

### P0 — bloquear especulação e obter evidência do aparelho

1. Fixar antes do teste o commit `c8fcab1`, o APK Release com SHA-256 `310b47377933f970b763d5fa9ce2de088d20b512ffdd79c49ea0effa50323503`, o pacote `com.falacomigo.fala_comigo`, a versão `1.0.0+1` e a data/hora. Confirmar que o arquivo instalado é exatamente esse APK.
2. Fazer instalação limpa: desinstalar a versão anterior, reiniciar o celular, instalar o APK Release fixado, permanecer offline e abrir. Registrar se aparece tela de carregamento, splash, grade ou nenhuma UI. Repetir em um tablet Android.
3. Se fechar, limpar o buffer imediatamente antes da tentativa e coletar o **logcat real do próprio aparelho**, preservando horário e metadados. Filtrar o pacote efetivo, `AndroidRuntime`, `FATAL EXCEPTION`, `flutter`, `libc`, `ActivityTaskManager`, `PackageManager` e `system_server`. Remover nomes, frases, imagens, áudio, vídeo, tokens e qualquer conteúdo de criança.
4. Repetir com três estados controlados e fixtures sintéticas: instalação limpa; `pm clear`/limpeza dos dados; e atualização sobre versão anterior. Comparar o resultado sem trocar criptografia, permissões ou plugins durante a investigação.
5. Se aparecer `StartupFailureApp`, copiar apenas o relatório técnico sanitizado e correlacioná-lo com o horário. Se nenhuma UI aparecer, manter a classificação como possível morte nativa ou encerramento anterior ao Flutter.

### P1 — fechar a cobertura automatizada e de ambiente

6. Adicionar, em ciclo posterior e sem usar dados reais, testes de integração de startup para caixa ausente, caixa legada válida, chave inválida, corrupção, falha de armazenamento seguro, plugin nativo indisponível e primeira renderização. O conjunto unitário atual não substitui esses cenários.
7. Executar a matriz em celular e tablet, com internet e offline, orientação suportada, permissões concedidas e negadas, TTS indisponível, notificações bloqueadas, segundo plano, reinicialização e atualização. Confirmar que falhas de áudio/alerta não bloqueiam a comunicação visual.
8. Arquivar para cada execução o dispositivo, Android/API, versão do app, SHA-256 do APK, conectividade, permissões, resultado e evidência. Fazer o CI publicar metadados de proveniência junto com o APK para impedir atribuição de resultados ao binário errado.
9. Imprimir e revisar o Manifest mesclado do APK fixado. Confirmar Activity launcher, receivers, providers, `exported`, permissões, backup e componentes trazidos por dependências.
10. Abrir tarefas separadas para o achado criptográfico, decisão de `minSdk`, permissões e nova análise MobSF. Não mudar algoritmo ou mínimo de API como tentativa sem evidência do crash e sem plano de migração.

### P2 — reduzir ambiguidade documental

11. Reconciliar handoff, relatórios, matriz, README e instruções de suporte com branch, commit, hash do APK, versão, `applicationId` e quantidade de testes correspondentes à execução citada.
12. Manter backend, portal RH, sincronização clínica, cobrança e publicação ampla fora do incidente. O diagnóstico deve permanecer focado no runtime Android local.

## Veredito e confiança

**Veredito:** **não aprovado para lançamento** e **bloqueado no gate de primeira abertura funcional**. A build é adequada como artefato de investigação somente depois de fixar sua identidade e testar em um ambiente Android saudável. O próximo resultado decisivo é um smoke test real acompanhado de logcat caso o fechamento persista.

A confiança é **alta** para os fatos de que o build foi documentado como aprovado, o checkout contém um APK Release identificável, o AVD não executou o app de forma válida, o caminho crítico contém armazenamento seguro/Hive antes do estado `ready`, TTS/notificações foram adiados e não há logcat causal no checkout. A confiança é **média-alta** para os riscos derivados do bootstrap, migração, registro de plugins e matriz de permissões. A confiança é **baixa** para qualquer causa específica do fechamento, pois nenhum log de runtime do aparelho afetado está disponível.

## Referências

[1]: ../RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md "Diagnóstico de build e instalação Android"

[2]: ../CHECKLIST_EXECUCAO_E_TESTES.md "Checklist de execução, testes e prontidão"

[3]: ../AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md "Auditoria do handoff e artefatos Android"

[4]: ../../lib/main.dart "Inicialização Flutter e tela de diagnóstico"

[5]: ../../lib/core/services/secure_box_service.dart "Armazenamento seguro e migração Hive"

[6]: ../../lib/core/services/tts_service.dart "Serviço de síntese de voz"

[7]: ../../android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java "Registrador de plugins Android gerado"

[8]: ../../android/app/src/main/AndroidManifest.xml "Manifest principal Android"

[9]: ../../android/app/src/main/kotlin/com/falacomigo/fala_comigo/MainActivity.kt "Activity Android principal"

[10]: ../MATRIZ_FLUXOS_CRITICOS.md "Matriz de fluxos críticos"

[11]: ../../security/reports/MOBSF_2026-09-24.md "Relatório MobSF do APK Release de teste"

[12]: ../../PROJECT_HANDOFF.md "Documento de transferência do projeto Fala Comigo"
