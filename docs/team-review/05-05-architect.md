# Revisão de Arquitetura e Persistência — Fala Comigo

**ID:** 05-05  
**Papel:** Software Architect  
**Data:** 24 de setembro de 2026  
**Escopo:** inicialização Flutter/Android, persistência local, migração, exclusão de dados, observabilidade e evidências do APK.

> **Integridade da revisão:** nenhum código foi alterado. O repositório não contém logcat do aparelho físico. Portanto, este documento não atribui o fechamento a um componente específico nem inventa uma exceção, stack trace ou sinal nativo.

## Conclusão executiva

O projeto tem uma arquitetura coerente com o requisito **local-first**: o núcleo CAA é Flutter, o estado de tela usa Riverpod, o armazenamento estruturado usa Hive e as chaves ficam em `flutter_secure_storage`. Mídias Android são gravadas em diretório privado e usam AES-GCM. O aplicativo também possui uma tela Dart de falha e um serviço de diagnóstico local sanitizado [1] [7] [8] [10].

O APK compila e instala, mas o fechamento ao abrir no telefone físico continua sendo um **bloqueador P0 de execução**. A causa permanece desconhecida. Os handlers Dart só podem ajudar depois que o processo Android e o engine Flutter chegam a executar; eles não observam uma morte nativa anterior ao Flutter. O AVD utilizado no ambiente não constitui reprodução válida, pois o próprio Android do emulador perdeu serviços essenciais antes de executar o APK [3] [4] [6].

A maior exposição arquitetural está no **caminho de inicialização e na persistência**, não na existência do build. Antes de marcar o aplicativo como pronto, o bootstrap fixa orientação, inicializa Hive, cria ou recupera uma chave no Keystore, abre ou migra três caixas protegidas, inicializa o diagnóstico e semeia cartões. TTS e notificações foram adiados para depois da primeira tela, o que é uma mitigação útil, mas todos os plugins Android ainda são registrados quando o engine Flutter é criado [7] [11].

Há ainda dois defeitos de persistência verificáveis no código: a exclusão completa não inclui as caixas `visual_routine` e `parent_reminders`, e remove os arquivos de mídia sem remover a chave `fala_comigo_media_key_v1`. Assim, a promessa de apagar todos os dados locais não é demonstrada como completa. A migração Hive também trata qualquer falha de abertura cifrada como se fosse uma caixa legada e pode apagar a representação legada após uma cópia sem um protocolo explícito de versão, backup e recuperação [8] [9].

## Baseline e evidências disponíveis

O checkout observado está em `work/qa-observability-and-emulator`, no commit `c8fcab1ade6238966a2a68faaa7cb7d9c94c1ef8`. O workspace contém um APK release de aproximadamente 55 MB, um APK debug de aproximadamente 152 MB e um AAB release de aproximadamente 43 MB. O SHA-256 do APK release atualmente presente é `310b47377933f970b763d5fa9ce2de088d20b512ffdd79c49ea0effa50323503`.

Os relatórios registram análise estática, 84 testes, build Web, APK debug, APK release, AAB release e build limpa aprovados. Isso demonstra uma linha de empacotamento reproduzível, mas não demonstra que a `MainActivity` abre e permanece utilizável no aparelho afetado [3] [4]. Há divergência entre os hashes e commits documentados anteriormente e os artefatos que estão no checkout atual. O próximo teste deve registrar conjuntamente branch, commit, versão, SHA do APK, dispositivo e horário, para evitar que um resultado seja atribuído a um artefato diferente.

O relatório MobSF disponível é de outro APK release de teste, com SHA `b262679c154266f4bfb3573b13ced36c3f2b206e4d7dee77135816c01cfd1a2d`, score 46, dois achados altos e assinatura efêmera. Ele é evidência de risco de distribuição e persistência, não evidência causal do fechamento observado no telefone [14].

## Arquitetura observada

### Inicialização e caminho crítico

`main()` chama `WidgetsFlutterBinding.ensureInitialized()`, instala handlers para erros Flutter e de plataforma, chama `runApp` imediatamente e inicia `_startApp()` de forma assíncrona. Enquanto o bootstrap não termina, `StartupLoadingApp` é desenhado. Se uma exceção Dart for capturada, `StartupFailureApp` tenta exibir uma mensagem e um relatório técnico [7].

O caminho que antecede `StartupState.ready` permanece relativamente amplo:

1. `SystemChrome.setPreferredOrientations` fixa a aplicação em paisagem.
2. `Hive.initFlutter()` é executado e o adapter de `PictogramCard` é registrado.
3. A caixa `pictogram_cards` é aberta ou migrada.
4. As caixas `app_settings` e `transition_alerts` também são abertas ou migradas.
5. O serviço de diagnóstico abre sua própria caixa protegida.
6. Cartões padrão são escritos caso a caixa principal esteja vazia.
7. Só então o estado é marcado como pronto e a `CaaApp` inicia sua splash de 1,8 segundo mais transição [7].

TTS e notificações estão fora da espera do bootstrap e cada inicialização possui captura Dart independente. Isso reduz o risco de uma exceção Dart nesses serviços impedir a UI, mas não remove o registro nativo automático dos plugins. O `GeneratedPluginRegistrant` do artefato atual adiciona, entre outros, `flutter_secure_storage`, TTS, notificações, image picker, impressão, gravação, compartilhamento e URL launcher ao `FlutterEngine` [11]. Sem logcat, não é possível saber se o processo morre na Activity, no carregamento do engine, no registro de plugin, no bootstrap Dart ou depois do primeiro frame.

### Persistência estruturada

O serviço `SecureBoxService` mantém uma chave Hive de 32 bytes em `flutter_secure_storage` e usa essa mesma chave para as caixas Hive abertas pelo aplicativo. O conjunto observado inclui cartões, configurações, alertas, perfil, registros de comportamento, diário de vídeo, licença, diagnóstico, rotina visual e lembretes parentais. Algumas caixas são abertas somente quando a tela correspondente é acessada; as três primeiras e a caixa de diagnóstico participam do startup [7] [8].

Essa centralização simplifica o acesso, mas aumenta o raio de falha: perda, corrupção ou incompatibilidade da chave pode afetar várias áreas ao mesmo tempo. A disponibilidade do núcleo CAA depende da criação/leitura do segredo e da abertura da caixa de cartões antes de a grade aparecer. A comunicação não depende de servidor, conta ou licença, conforme o requisito do produto, mas ainda depende dessa cadeia local de inicialização [1] [2].

`openSecureBoxWithMigration` tenta abrir a caixa com cifra; diante de **qualquer** erro, fecha a caixa se necessário, abre o mesmo nome sem cifra, copia os valores, apaga a caixa do disco e recria a caixa cifrada. Não há, nesse método, distinção explícita entre caixa legada, chave errada, corrupção, formato incompatível ou falha temporária. Também não há protocolo de versão, cópia de segurança, checksum, marca de migração concluída ou caminho de recuperação para uma cópia parcialmente escrita [8]. Isso não prova o crash atual, mas é uma fragilidade de atualização e recuperação de dados.

O MobSF apontou CBC com padding PKCS5/PKCS7 dentro do código obfuscado associado à dependência de armazenamento Hive. Esse achado deve gerar uma decisão técnica sobre autenticidade, formato e migração, mas não autoriza concluir que o CBC é a causa do fechamento. Mídia nova segue outra arquitetura: AES-GCM-256, chave separada no Keystore e arquivos privados sob o diretório de documentos do aplicativo [10] [14].

### Exclusão e retenção local

`DataWipeService` fecha e tenta apagar oito grupos de caixas, limpa diretórios privados e temporários de mídia, remove a chave Hive, limpa credenciais do PIN e reabre algumas caixas vazias. No entanto, a lista `_boxNames` não contém `visual_routine` nem `parent_reminders`, embora os respectivos stores persistam dados em caixas Hive protegidas [9]. Uma exclusão completa pode, portanto, deixar dados dessas funcionalidades no dispositivo.

O mesmo serviço chama `MediaStorageService.clearAllMedia()`, que exclui arquivos e caches, mas o código de mídia não expõe uma operação de remoção de `fala_comigo_media_key_v1`, nem `DataWipeService` a remove diretamente. A chave pode permanecer no Keystore após os arquivos serem apagados. Isso não mantém os arquivos antigos recuperáveis por si só, mas viola a expectativa arquitetural de apagar também as credenciais e chaves do aplicativo e deixa material criptográfico órfão [9] [10].

A caixa de diagnóstico é deliberadamente opcional: falha ao abri-la não deve impedir a comunicação. O serviço limita eventos e sanitiza padrões óbvios de tokens, segredos e caminhos, mas a política de consentimento, retenção, compartilhamento e descarte dos relatórios ainda está pendente no checklist. A observabilidade local é uma mitigação; não substitui logcat para uma morte nativa [5] [7].

## Fatos, riscos e hipóteses

### Fatos confirmados ou diretamente observados

| ID | Classificação | Prioridade | Constatação |
|---|---|---:|---|
| F-01 | Fato operacional | P0 | O APK instala, mas fecha ao abrir no telefone físico, conforme o relato e os documentos de continuidade. Não há logcat do aparelho no repositório. |
| F-02 | Fato de engenharia | P0 | A matriz documentada registra análise, 84 testes, builds Web/APK/AAB e build limpa aprovados. Isso não equivale a teste de lançamento em aparelho. |
| F-03 | Fato de infraestrutura | P0 | O AVD não executou o aplicativo de modo válido: o serviço `package` e o `system_server` do emulador morreram antes da instalação/execução confiável. |
| F-04 | Fato de código | P0 | O bootstrap abre/migra persistência e semeia cartões antes de marcar o app como pronto; a tela de falha cobre apenas exceções que chegam ao Flutter. |
| F-05 | Fato de código | P1 | O `GeneratedPluginRegistrant` registra plugins nativos antes do código Dart poder decidir adiar TTS e notificações. |
| F-06 | Fato de código | P1 | `DataWipeService` não lista `visual_routine` e `parent_reminders`, e não remove a chave de mídia `fala_comigo_media_key_v1`. |
| F-07 | Fato de código | P1 | A migração Hive usa uma captura ampla de erro e um caminho destrutivo sem máquina de estados ou recuperação explicitamente testada. |
| F-08 | Fato documental | P1 | O README informa `com.falacomigo.caa`, enquanto Gradle, Manifest e o APK atual usam `com.falacomigo.fala_comigo`. Também há hashes/commits históricos diferentes entre relatórios e checkout. |

### Riscos arquiteturais e de persistência

**R-01 — Diagnóstico não observável no limite correto (P0).** Se o processo morrer antes do Flutter, `StartupFailureApp`, `DiagnosticsService` e os handlers Dart não terão oportunidade de registrar a causa. A equipe pode continuar alterando TTS, Hive ou notificações por tentativa e erro, aumentando regressão sem reduzir incerteza.

**R-02 — Disponibilidade do CAA acoplada a armazenamento e Keystore (P0).** A grade não é liberada enquanto a caixa de cartões e as caixas de suporte do bootstrap não concluem. Isso transforma um problema de persistência secundária em indisponibilidade da comunicação principal.

**R-03 — Migração potencialmente destrutiva (P1).** Uma falha que não seja “caixa legada sem cifra” entra no mesmo ramo de migração. Sem backup verificável e teste de corrupção/chave inválida, uma atualização pode travar, esconder a causa ou ameaçar a recuperação de dados.

**R-04 — Exclusão local incompleta (P1).** Rotina visual, lembretes parentais e a chave de mídia não estão cobertos pela exclusão declarada como completa. Esse risco afeta privacidade, suporte e a confiança na função de apagar dados.

**R-05 — Superfície nativa ampla (P1).** Permissões de câmera, mídia, áudio, notificações e alarmes, além de providers, receivers e inicializadores AndroidX, elevam a matriz de compatibilidade. O Manifest mesclado inclui `ProfileInstallReceiver` exportado com `android.permission.DUMP`, item já sinalizado pelo MobSF para revisão. Isso é risco de release, não diagnóstico do crash [11] [14].

**R-06 — Persistência criptografada sem decisão fechada de formato (P1).** O achado CBC do MobSF, a chave única para várias caixas e a migração sem versionamento exigem uma decisão conjunta de confidencialidade, autenticidade, perda de chave, upgrade e rollback. Trocar o algoritmo apenas para melhorar o score pode causar perda de dados.

**R-07 — Baseline operacional ambígua (P1).** Um hash de APK, commit, package name ou instrução de `pm clear` incorretos podem fazer a equipe reproduzir outro pacote e coletar evidência do alvo errado.

### Hipóteses de investigação, não diagnósticos

1. **Falha nativa anterior ao Flutter ou durante o registro de plugins.** É plausível porque o engine registra vários plugins Android e o fallback Dart não cobre morte nativa. Não há evidência para apontar qual plugin.
2. **Falha no `flutter_secure_storage`, Android Keystore, Hive ou migração.** É plausível porque essas operações são obrigatórias antes da grade. Ainda assim, uma exceção Dart capturável deveria seguir o caminho da tela de falha; somente o logcat pode separar isso de um encerramento nativo.
3. **Estado persistido antigo, chave perdida ou instalação sobre versão anterior.** É plausível porque a abertura tenta migrar dados e não há evidência manual de instalação limpa versus upgrade. Não está demonstrado no aparelho afetado.
4. **Incompatibilidade de fabricante, API ou política de segurança.** `minSdk=24`, orientação exclusiva em paisagem e permissões ampliam a matriz, mas não identificam a causa sem modelo e API do telefone.
5. **Falha após o bootstrap, na splash ou no primeiro widget.** A aplicação ainda cria uma splash adicional depois de `StartupState.ready`; um fechamento posterior poderia ocorrer em navegação, provider ou widget. Também não há evidência para priorizar essa hipótese.

O tamanho menor do APK release em relação ao debug e a assinatura temporária não são hipóteses técnicas fortes para o fechamento. A diferença de tamanho é esperada entre modos de build; a assinatura temporária limita distribuição e atualização, mas não demonstra uma falha de runtime [3] [4] [14].

## Ações recomendadas

### P0 — obter evidência e recuperar o primeiro valor

1. **Fixar o artefato antes do teste.** Registrar o commit `c8fcab1`, o SHA-256 do APK efetivamente instalado, `applicationId` `com.falacomigo.fala_comigo`, versão `1.0.0+1`, fabricante/modelo, Android/API, conectividade e horário. Não usar o hash antigo do relatório MobSF como se fosse o APK atual.
2. **Reproduzir em instalação limpa.** Desinstalar a versão anterior, reiniciar o aparelho, instalar o APK release fixado e abrir offline. Confirmar primeiro frame, entrada na grade e permanência por alguns minutos. Repetir depois em um tablet saudável; o AVD quebrado não substitui esses testes.
3. **Coletar logcat real se fechar.** Limpar o buffer imediatamente antes da tentativa e exportar o log do próprio aparelho, filtrando o package efetivo, `AndroidRuntime`, `FATAL EXCEPTION`, `flutter`, `libc`, `ActivityTaskManager`, `PackageManager` e `system_server`. Sanitizar qualquer nome, frase, foto, vídeo, token ou conteúdo de criança. Sem esse artefato, a causa deve continuar “desconhecida”.
4. **Separar estado de dados.** Executar três cenários com dados sintéticos: instalação limpa; atualização sobre uma versão anterior; e `pm clear`/remoção de dados. Comparar os resultados e os logs antes de alterar a camada de persistência.
5. **Não ampliar escopo.** Manter backend, RH, sincronização, cobrança e publicação ampla bloqueados. O incidente é do app local e deve ser resolvido no caminho CAA antes de qualquer integração futura [1] [5].

### P1 — reduzir acoplamento e fechar persistência

6. **Fatiar o bootstrap por fases.** Definir uma fase mínima para renderizar a grade com cartões padrão e uma fase posterior para migração, alertas, diagnóstico e outros módulos não essenciais, preservando a regra de que falhas opcionais não interrompem a comunicação. Toda fase deve ter marcador observável e timeout/recovery seguro.
7. **Transformar migração em protocolo versionado.** Distinguir caixa legada, chave inválida, corrupção e erro transitório. Fazer cópia verificável antes de apagar a origem, registrar versão/formato e testar rollback, atualização, corrupção, perda de chave e interrupção durante a cópia. Decidir formalmente se o formato Hive atual é aceito ou se será adotado um envelope autenticado com migração compatível.
8. **Centralizar o inventário de dados.** Manter nomes de caixas, classificação de sensibilidade, versão de schema, estratégia de migração e política de exclusão em um único registro. Incluir `visual_routine` e `parent_reminders` no fluxo de wipe ou justificar documentalmente por que não são dados do aplicativo.
9. **Completar a destruição criptográfica.** Expor uma operação segura para remover a chave de mídia e chamá-la depois da exclusão validada dos arquivos. Testar que a limpeza remove caixas, mídias, caches, chaves Hive, chave de mídia, credenciais PIN, licença e diagnóstico sem deixar dados acessíveis.
10. **Adicionar testes de integração Android.** Cobrir primeiro frame, instalação limpa, reabertura, upgrade, retorno do segundo plano, Keystore indisponível, permissão negada e wipe em dispositivo ou emulador saudável. Os testes unitários atuais não cobrem `MainActivity`, registro real de plugins ou ciclo de vida Android [5] [15].

### P2 — saneamento de release e operação

11. **Revisar Manifest e plugins.** Confirmar necessidade de cada permissão, receiver, provider e `ProfileInstallReceiver`; validar `exported`, `DUMP`, armazenamento privado, arquivos temporários e permissões em contexto. Reexecutar MobSF, análise dinâmica e revisão manual MASVS/MASTG.
12. **Alinhar a identidade documental.** Corrigir README, handoff, scripts de suporte e instruções de logcat para o `applicationId` efetivo. Separar em cada relatório o estado atual dos registros históricos.
13. **Definir governança do diagnóstico.** Aprovar consentimento, retenção, acesso, compartilhamento e descarte do relatório local. Instruir qualquer participante a enviar somente um relatório técnico sanitizado e passos de reprodução.

## Critério de saída do próximo gate

O gate de **MVP Android executável** só pode ser fechado quando o mesmo APK identificado por SHA abrir em instalação limpa em um celular e um tablet, offline, chegar à grade CAA e permanecer utilizável. Também devem passar seleção de cartões, frase, fala ou fallback, PIN, sessão, retorno do segundo plano e as permissões aplicáveis. O resultado deve incluir evidência do dispositivo e, caso ocorra novo fechamento, logcat ou relatório técnico sanitizado. Build, testes unitários e análise estática são pré-requisitos; não substituem esse gate.

O gate de persistência só pode ser fechado quando a equipe comprovar migração sem perda em atualização, recuperação definida para chave inválida/corrupção e exclusão local realmente abrangente. O APK não deve ser apresentado como publicação ou piloto com dados reais enquanto os achados MobSF, a assinatura de produção, a revisão de Manifest, a privacidade e a governança permanecerem abertos [5] [14].

## Confiança da análise

A confiança é **alta** para os fatos de que o build foi gerado, o APK instala, o AVD não constitui reprodução válida, não há logcat no repositório, o bootstrap abre persistência antes da grade, o registrador Android inclui vários plugins e o wipe não enumera duas caixas nem remove a chave de mídia. A confiança é **média** para os riscos de migração, acoplamento e compatibilidade, porque são inferidos diretamente do desenho e ainda não foram exercitados em aparelho. A confiança é **baixa** para qualquer causa específica do fechamento: sem logcat do telefone, não é possível distinguir plugin nativo, engine, Keystore/Hive, estado persistido, incompatibilidade de aparelho ou falha posterior na UI.

## Referências

[1]: ../../PROJECT_HANDOFF.md "Documento de transferência do projeto Fala Comigo"
[2]: ../../AGENTS.md "Instruções de desenvolvimento do Fala Comigo"
[3]: ../AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md "Auditoria do handoff e artefatos Android"
[4]: ../RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md "Relatório de diagnóstico de build e instalação Android"
[5]: ../CHECKLIST_EXECUCAO_E_TESTES.md "Checklist de execução, testes e prontidão"
[6]: ../team-review/03-03-tech-lead.md "Revisão Tech Lead sobre a estabilidade do APK"
[7]: ../../lib/main.dart "Inicialização Flutter e tratamento de falhas de startup"
[8]: ../../lib/core/services/secure_box_service.dart "Serviço de caixas Hive protegidas e migração"
[9]: ../../lib/core/services/data_wipe_service.dart "Serviço de exclusão completa local"
[10]: ../../lib/core/services/media_storage_service_io.dart "Armazenamento privado e cifrado de mídia"
[11]: ../../android/app/src/main/AndroidManifest.xml "Manifest Android do aplicativo"
[12]: ../../android/app/build.gradle.kts "Configuração Gradle e identidade Android"
[13]: ../../pubspec.yaml "Dependências e assets do aplicativo Flutter"
[14]: ../../security/reports/MOBSF_2026-09-24.md "Relatório MobSF do APK release de teste"
[15]: ../MATRIZ_FLUXOS_CRITICOS.md "Matriz de fluxos críticos"
[16]: ../../README.md "README e identidade documental do projeto"

**Alterações realizadas:** somente este relatório foi criado; nenhum código do aplicativo foi alterado.
