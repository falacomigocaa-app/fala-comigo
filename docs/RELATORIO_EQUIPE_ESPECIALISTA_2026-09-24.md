# Relatório consolidado da equipe especialista

**Data:** 24 de setembro de 2026  
**Produto:** Fala Comigo  
**Responsável pela consolidação:** Tech Lead  
**Decisão:** **gate P0 de execução Android bloqueado**

## 1. Conclusão executiva

O produto tem uma proposta coerente de comunicação aumentativa e alternativa (CAA) **local-first**: a grade, a montagem de frases, a fala ou seu fallback, os cartões personalizados, o PIN e a sessão parental devem funcionar sem conta, conexão ou plano pago. Entretanto, o APK release instala e fecha ao abrir no telefone físico segundo os registros consolidados. Não existe logcat do aparelho afetado, relatório nativo, fabricante, modelo, versão do Android, API ou horário do evento. Portanto, **a causa raiz não está confirmada e não deve ser atribuída a um componente específico**.

Os builds, testes automatizados e empacotamentos documentados demonstram compilação e geração de artefatos, mas não demonstram primeiro frame, permanência da aplicação ou comunicação offline em um aparelho real. O AVD utilizado na tentativa interna não constitui reprodução válida: os serviços `package` e `system_server` morreram antes de uma execução confiável do aplicativo. [1] [2] [3]

A classificação operacional é a seguinte: o incidente é **P0 porque impede o primeiro valor do produto**; a hipótese técnica prioritária é uma falha durante a inicialização nativa ou no bootstrap obrigatório, mas isso é somente uma prioridade de investigação. O caminho anterior a `StartupState.ready` ainda envolve orientação, inicialização do Hive, armazenamento seguro/Android Keystore, abertura ou migração de caixas, diagnóstico e semeadura de cartões. Uma morte nativa anterior ao Flutter, no engine, em JNI ou no carregamento de biblioteca pode não chegar à `StartupFailureApp`. Também permanecem possíveis falhas de chave, migração, estado persistido, compatibilidade de fabricante/API ou primeira renderização. [4] [5]

A equipe não deve iniciar backend, RH, sincronização clínica, cobrança ou publicação ampla como resposta ao incidente. Essas frentes pertencem a gates posteriores e não substituem a prova de que o núcleo offline abre e permanece utilizável.

## 2. Causa provável e limite da evidência

### 2.1 Formulação correta

**Causa provável, ainda não confirmada:** encerramento durante a criação da Activity/engine/plugin ou durante o bootstrap obrigatório de armazenamento seguro e Hive/migração, antes ou durante a primeira tela. Essa hipótese recebe prioridade porque esses componentes estão no caminho crítico observado e porque a captura Dart cobre apenas falhas enquanto o processo Flutter permanece vivo. Ela não é um diagnóstico.

A ordem de investigação deve ser guiada pelo artefato real do aparelho:

1. **Falha nativa ou de Activity/engine/plugin:** linker, JNI, `SIGABRT`, `SIGSEGV`, registro de plugin, incompatibilidade de biblioteca ou morte do processo antes da UI.
2. **Armazenamento seguro/Keystore e Hive:** chave ausente ou incompatível, caixa corrompida, migração, permissões de armazenamento ou estado persistido de uma instalação anterior.
3. **Compatibilidade de aparelho/API/fabricante:** política do sistema, orientação, versão do Android ou comportamento específico do dispositivo.
4. **Falha Dart após o primeiro frame:** splash, seed, primeira renderização ou outro erro capturável pelo Flutter.

TTS e notificações foram adiados para depois da primeira tela e protegidos em partes do caminho Dart. Isso reduz sua probabilidade como bloqueador inicial, mas **não os elimina como hipótese de runtime**, pois plugins nativos são registrados durante a criação do engine. Tamanho do APK, diferença entre Debug e Release, assinatura temporária e achados do MobSF também não explicam o fechamento por si só. [6] [7] [8]

### 2.2 O que não pode ser afirmado

Não se pode afirmar que o fechamento é causado por Hive, Android Keystore, TTS, notificações, Manifest, assinatura, fabricante, API, tamanho do APK ou dados persistidos. Não se deve inventar uma exceção, stack trace ou mensagem de log. Até a coleta do aparelho, a descrição correta permanece: **“APK instala e fecha ao abrir; causa desconhecida, sem logcat disponível.”**

## 3. Fatos consolidados

### 3.1 Produto e escopo atual

O requisito funcional é local-first. O núcleo esperado não depende de conta, internet ou plano pago. Ele inclui a grade CAA, filtros e cartões, montagem e remoção de frase, falar ou usar fallback quando a voz não estiver disponível, cartões personalizados, PIN/sessão parental, persistência local, exclusão local e acessibilidade básica. [1] [4]

O caminho de inicialização compartilhado chama `runApp` antes do bootstrap, mas só libera o estado pronto depois de configurar orientação, inicializar Hive, acessar armazenamento seguro/Keystore, abrir ou migrar três caixas, inicializar diagnóstico e semear cartões. TTS e notificações foram postergados para depois da primeira tela. Essa redução é uma mitigação de acoplamento, não uma prova de que esses serviços eram a causa do fechamento. [5] [8]

A `StartupFailureApp` e os handlers Dart podem expor falhas capturáveis enquanto o engine permanece vivo. Eles não cobrem necessariamente mortes nativas anteriores ao Flutter, falhas de linker/JNI, `SIGABRT`/`SIGSEGV` ou encerramento do processo pelo sistema. [9] [10]

### 3.2 Build, artefato e execução

Os relatórios registram formatação, análise, 84 testes, build Web, APK Debug, APK Release, AAB Release e build limpa como aprovados. Essa evidência demonstra qualidade de compilação e empacotamento no contexto documentado; **não demonstra primeiro frame, abertura persistente, retorno do segundo plano ou comunicação offline em celular e tablet**. [1] [2] [11]

A ficha técnica do artefato local atualmente identificado registra:

| Campo | Valor observado | Status de proveniência |
|---|---|---|
| Branch | `work/qa-observability-and-emulator` | Registrar novamente na ficha candidata |
| Commit observado | `c8fcab1` | Fixar para o próximo teste |
| APK | `build/app/outputs/flutter-apk/app-release.apk` | Confirmar antes da instalação |
| `applicationId` efetivo | `com.falacomigo.fala_comigo` | Usar também no filtro de logcat |
| Versão | `1.0.0+1` | Incrementar antes de distribuição |
| Tamanho | 57.279.118 bytes, aproximadamente 57 MB | Não é causa confirmada |
| SHA-256 registrado | `310b47377933f970b763d5fa9ce2de088d20b512ffdd79c49ea0effa50323503` | Recalcular e arquivar no teste |
| `minSdk` / `targetSdk` | 24 / 36 | Decisão de compatibilidade pendente |
| Assinatura | Local temporária | Não é assinatura de produção |

A tabela é uma linha de base de trabalho, não substitui a verificação criptográfica do arquivo efetivamente instalado. O próximo teste deve registrar também a fingerprint da assinatura, a versão do toolchain, o fabricante, o modelo, a API, a orientação, a conectividade, as permissões e o horário.

### 3.3 Segurança, persistência e observabilidade

O MobSF registrou score 46, dois achados altos, cinco warnings, um item informativo e um hotspot. Entre os achados estão CBC/PKCS5/PKCS7 associado ao armazenamento Hive e `minSdk=24`. O relatório bruto esperado não está disponível no caminho documentado. Esses achados são gates de segurança e release independentes; **não são evidência causal do fechamento**. [11] [12]

A migração `openSecureBoxWithMigration` trata qualquer erro de abertura cifrada como possível legado, tenta abrir a caixa sem cifra e pode apagar a origem e recriá-la sem um protocolo explícito de versão, backup verificável ou rollback. Isso mistura chave incompatível, corrupção, formato inválido e erro transitório. A solução não deve ser trocar criptografia ou apagar dados como tentativa especulativa antes de observar o caso real. [5] [8]

A exclusão local não cobre completamente o inventário observado: `DataWipeService` não lista `visual_routine` nem `parent_reminders` e não remove a chave separada `fala_comigo_media_key_v1`. Esse é um defeito verificável de privacidade e de promessa de exclusão, embora não seja uma causa demonstrada do crash. [5] [6]

A observabilidade atual é local, sanitizada e limitada. Não foram encontrados backend, banco remoto, autenticação server-side, sincronização, Firebase/Crashlytics, Sentry, Datadog, OpenTelemetry ou mecanismo equivalente. Isso preserva o caráter local-first, mas deixa um ponto cego para mortes nativas e não oferece taxa de crash ou correlação remota. Qualquer futura telemetria exigirá consentimento, minimização, retenção, acesso e desligamento definidos. [13] [14]

## 4. Conflitos e riscos documentais

Os relatórios concordam sobre o bloqueio P0, a ausência de logcat e a diferença entre build e execução. Eles divergem ou misturam baselines nos seguintes pontos:

| Tema | Estado conflitante | Decisão de consolidação |
|---|---|---|
| Branch e commit | Há registros históricos, enquanto o checkout observado aponta para `work/qa-observability-and-emulator` em `c8fcab1`; outros commits aparecem em mitigação ou relatórios anteriores. | Usar somente a linha candidata explicitamente revalidada. Marcar todas as demais como históricas. |
| Hash e artefato | Hashes de artefatos anteriores aparecem junto do APK local atual. | Recalcular SHA-256 do arquivo instalado e associá-lo a branch, commit, versão e assinatura. |
| Contagem de testes | A base corrente menciona 84 testes; números menores aparecem em registros históricos. | Exibir a contagem apenas com comando, commit e data; não comparar números antigos como estado atual. |
| Identidade Android | O README usa `com.falacomigo.caa`; Gradle, Manifest e APK usam `com.falacomigo.fala_comigo`. | Considerar `com.falacomigo.fala_comigo` a identidade Android efetiva até alteração formal. |
| Identidade iOS | O bundle ID observado é `com.falacomigo.falaComigo`. | Manter separado do Android e documentá-lo explicitamente. |
| Build verde versus runtime | Builds e testes estão aprovados, mas o APK físico fecha ao abrir. | Build verde não libera o gate de runtime. |
| AVD versus aparelho | O AVD perdeu `package`/`system_server` antes da execução válida; o telefone físico é o relato do incidente. | Não usar o AVD como reprodução do crash do app. |
| MobSF | Há score e achados resumidos, mas o bruto não está disponível no caminho esperado. | Repetir no artefato candidato e arquivar JSON/PDF/SHA. |
| CI/CD | GitHub Actions cobre qualidade/Web; Codemagic prevê Android assinado, sem execução rastreável ao SHA atual. | Exigir gate Android rastreável ao SHA candidato antes da distribuição. |
| iOS | Não há macOS, Xcode, CocoaPods ou aparelho Apple neste ambiente. | Manter validação iOS como trabalho posterior e não usar sua ausência para explicar o crash Android. |

A fonte única de estado deverá conter branch, commit, APK/AAB, SHA-256, `applicationId`, versão, assinatura, toolchain, dispositivo, API, conectividade, permissões, horário, resultado e links para as evidências. Handoffs, README, checklist, matriz e suporte devem apontar para essa ficha; números antigos devem ser explicitamente rotulados como históricos.

## 5. Escopo MVP congelado

O MVP fica restrito ao **núcleo de comunicação offline**. O critério de inclusão é ser necessário para o primeiro valor e funcionar sem conta, rede ou pagamento:

- abertura confiável e permanência na grade CAA;
- filtros e cartões, incluindo cartões personalizados quando já disponíveis no núcleo;
- montagem, remoção e limpeza de frase;
- fala e fallback visível/acionável quando TTS estiver indisponível, bloqueado ou sem áudio;
- PIN e sessão parental;
- persistência local necessária ao núcleo, com migração segura e recuperação definida;
- exclusão local verificável, incluindo todas as caixas e chaves de mídia;
- layout paisagem validado em celular e tablet;
- acessibilidade essencial: semântica, foco, labels, contraste, alvo de toque e escala de texto testados;
- diagnóstico local mínimo, sem dados de criança e sem bloquear a comunicação.

Vídeo, ABC/PDF, alertas, mídia complementar, tendências, licenças, portal RH, backend, sincronização clínica, cobrança, telemetria remota e publicação ampla ficam fora do MVP e não devem ser usados para explicar ou “corrigir” o incidente. Módulos periféricos só podem entrar depois de o núcleo estar verde e de cada módulo ter validação manual, segurança, privacidade e rollback próprios. Sincronização futura deverá ser opt-in e nunca poderá bloquear o modo offline.

## 6. Plano de ação por prioridade

### P0 — obter prova de execução e desbloquear o primeiro valor

1. **Fixar o binário.** Registrar branch, commit, versão, `applicationId`, SHA-256, assinatura, toolchain, caminho do APK e horário. Confirmar que o aparelho instalou exatamente esse arquivo.

2. **Reproduzir de forma controlada.** Desinstalar completamente a versão anterior, reiniciar o celular, instalar o APK release, permanecer offline e repetir em um celular físico e em um tablet. Executar também `pm clear` e atualização sobre fixtures sintéticas, em testes separados. Não usar dados reais de crianças.

3. **Registrar a fase do encerramento.** Marcar se não há UI, se ocorre no loading, na splash, no primeiro frame ou após chegar à grade. Registrar se a grade permanece utilizável, se o retorno do segundo plano funciona e se uma segunda abertura repete o resultado.

4. **Coletar o log real se fechar.** Limpar o buffer antes da tentativa e coletar imediatamente depois no próprio aparelho, filtrando pelo pacote efetivo `com.falacomigo.fala_comigo`, `AndroidRuntime`, `FATAL EXCEPTION`, `flutter`, `libc`, `ActivityTaskManager`, `PackageManager` e `system_server`. Sanitizar conteúdo sensível e excluir qualquer dado de criança. Se a tela de diagnóstico Dart aparecer, exportar também seu relatório, sem tratá-lo como substituto do logcat.

5. **Classificar antes de alterar.** Distinguir falha Java/plugin, Keystore/Hive/migração/Dart, `SIGABRT`/`SIGSEGV`/linker, ou Activity/Manifest. Não alterar algoritmo criptográfico, plugin, orientação, permissões ou persistência com base em uma hipótese sem o artefato correspondente.

6. **Executar a matriz crítica.** Validar F01–F07, F20, F21 e F22 — ou os identificadores equivalentes vigentes na matriz — em celular e tablet. A matriz deve cobrir abertura, grade offline, cartões, frase, falar/fallback, PIN, sessão, orientação, permissões, reabertura, segundo plano e retorno. Cada resultado precisa de dispositivo, API, versão, SHA, horário e evidência.

O gate P0 permanece fechado enquanto qualquer uma destas condições ocorrer: fechamento na abertura; ausência de primeiro frame estável; impossibilidade de chegar à grade offline; evidência ausente em celular ou tablet; logcat necessário não coletado após uma nova reprodução; ou falha crítica em F01–F07, F20, F21 ou F22.

### P1 — tornar o núcleo seguro, recuperável e demonstrável

1. **Reduzir o caminho crítico.** Manter a grade independente de TTS, notificações, mídia, permissões opcionais e módulos periféricos. Adicionar marcadores de bootstrap, timeout compreensível, retry seguro e recuperação que não apague dados automaticamente.

2. **Revisar persistência.** Transformar a migração Hive em protocolo versionado, idempotente e testável. Distinguir legado, chave incompatível, corrupção, formato inválido e erro transitório. Definir cópia verificável, preservação, rollback e testes de instalação nova, upgrade, chave ausente, chave incompatível, caixa corrompida e perda de chave.

3. **Corrigir exclusão local.** Centralizar o inventário de caixas e chaves. Incluir `visual_routine`, `parent_reminders` e `fala_comigo_media_key_v1`. Provar que a remoção não deixa arquivos temporários, mídia, chaves ou dados recuperáveis fora do escopo definido.

4. **Revisar Android e segurança.** Decidir `minSdk` com base na matriz real. Revisar Manifest mesclado, componentes `exported`, receivers, providers, Profile Install Receiver, permissões contextuais, backup, arquivos temporários e assinatura de produção. Repetir MobSF no APK candidato e executar análise dinâmica alinhada a MASVS/MASTG. Cada achado alto deve ser corrigido ou aceito formalmente antes de distribuição.

5. **Validar acessibilidade e UX.** Testar TalkBack, foco e teclado, escala de texto de 1,3x e 2x, labels/frases longos, redução de movimento, brilho baixo, orientação, targets de toque e contraste em estados normal, pressionado, desabilitado e foco. Corrigir o par de contraste observado no botão Falar, calculado aproximadamente em 2,53:1 para texto branco sobre `#23B6A2`, antes de declarar conformidade.

6. **Fortalecer CI e proveniência.** Tornar o build Android um check rastreável ao SHA no GitHub ou tornar o check Codemagic obrigatório. Fazer a verificação de formatação ser não mutante. Arquivar manifesto, SBOM, hashes, toolchain, fingerprint e logs não sensíveis junto do artefato.

7. **Alinhar documentação.** Atualizar README, handoff, checklist, matriz, suporte e Codemagic para o pacote efetivo, branch, commit, hash, contagem atual de testes e critérios de runtime. Manter um registro de mudanças para separar histórico de estado atual.

### P2 — expansão somente após o núcleo verde

1. Validar iOS em macOS com Xcode e dispositivos iPhone/iPad, incluindo Keychain/Hive/migração, permissões, notificações Darwin, orientação, VoiceOver e compartilhamento com âncora de popover no iPad.

2. Considerar módulos periféricos — vídeo, ABC/PDF, alertas, mídia, tendências e licenças — apenas com testes manuais, tratamento de permissões, falhas e cancelamento, acessibilidade, privacidade e rollback.

3. Projetar backend e sincronização apenas como iniciativa separada. Antes de qualquer dado real, deverão existir autenticação, isolamento multi-organização, autorização server-side por requisição, consentimento versionado, finalidade, retenção, revogação, auditoria persistente, URLs temporárias, testes negativos e sincronização opt-in. Entitlements comerciais não podem substituir autorização de dados.

4. Avaliar telemetria remota somente com decisão explícita de privacidade, consentimento, minimização, retenção, acesso e desligamento. A ausência atual de telemetria não deve ser resolvida adicionando coleta ampla durante o incidente.

5. Liberar piloto institucional, cobrança, RH e publicação ampla somente após os gates Android, segurança, acessibilidade, privacidade, assinatura e governança estarem verdes. Nenhuma dessas frentes é critério para fechar o incidente P0.

## 7. Critérios de saída

### 7.1 Saída do incidente P0

O incidente poderá sair de P0 somente quando houver um artefato candidato único e rastreável, instalado por procedimento limpo em um celular e um tablet físicos, ambos offline, com primeiro frame e grade CAA presentes e utilizáveis. A matriz deverá mostrar verde em F01–F07, F20, F21 e F22, incluindo falar/fallback, PIN, sessão, reabertura, retorno do segundo plano, orientação e permissões aplicáveis.

Se houver novo fechamento, a saída exige logcat real do aparelho e classificação da falha. Uma correção só será considerada causalmente sustentada quando reproduzir o problema, explicar o sinal observado no log e deixar o cenário verde após nova instalação limpa e atualização sobre fixtures sintéticas. Uma abertura ocasional sem evidência ou sem permanência não satisfaz o gate.

### 7.2 Saída de P1 para distribuição controlada

Além do P0 verde, será necessário demonstrar migração versionada e recuperação sem perda indevida, exclusão local completa, decisão formal de `minSdk`, revisão do Manifest e permissões, assinatura de produção, MobSF atualizado, análise dinâmica MASVS/MASTG, acessibilidade manual e proveniência do artefato. Achados altos de segurança deverão estar fechados ou formalmente aceitos pelo responsável apropriado.

A distribuição controlada também exige checklist e matriz reconciliados, diagnóstico sem dados de criança, política de suporte, procedimento de rollback e evidência de que TTS ausente, notificações bloqueadas, permissões negadas e áudio indisponível não impedem a comunicação básica.

### 7.3 Saída de P2 e expansão

A expansão só poderá ser aprovada quando o núcleo offline permanecer estável durante o período de observação definido, a validação iOS estiver concluída para o escopo anunciado, os módulos periféricos tiverem gates próprios e qualquer backend tiver autorização server-side, auditoria, privacidade, retenção, revogação e testes negativos demonstráveis. Publicação ampla e piloto institucional não são consequência automática de um build verde.

## 8. Decisão final do Tech Lead

A equipe deve **congelar o núcleo CAA offline, manter a distribuição bloqueada e executar o P0 no aparelho físico**, começando por um APK identificado por SHA e por uma coleta de logcat sem dados de criança. A causa permanece desconhecida até essa evidência. O trabalho de segurança, persistência, acessibilidade, CI e documentação segue em P1, sem transformar hipóteses em diagnósticos. Backend, RH, sincronização clínica, cobrança, telemetria ampla e publicação ficam fora da resposta ao incidente e só retornam ao planejamento após os critérios de saída serem satisfeitos.

## Referências

[1]: file:///home/ubuntu/fala-comigo/docs/team-review/01-01-product-manager.md "Revisão do Product Manager"
[2]: file:///home/ubuntu/fala-comigo/docs/team-review/02-02-scrum-master.md "Revisão do Scrum Master"
[3]: file:///home/ubuntu/fala-comigo/docs/team-review/03-03-tech-lead.md "Revisão técnica de causa raiz Android"
[4]: file:///home/ubuntu/fala-comigo/docs/team-review/04-04-ux-ui.md "Revisão de UX e UI"
[5]: file:///home/ubuntu/fala-comigo/docs/team-review/05-05-architect.md "Revisão de arquitetura e persistência"
[6]: file:///home/ubuntu/fala-comigo/docs/team-review/06-06-senior-backend.md "Revisão de back-end e governança"
[7]: file:///home/ubuntu/fala-comigo/docs/team-review/07-07-pleno-backend.md "Revisão do desenvolvedor back-end"
[8]: file:///home/ubuntu/fala-comigo/docs/team-review/08-08-senior-frontend.md "Revisão Flutter e CAA"
[9]: file:///home/ubuntu/fala-comigo/docs/team-review/09-09-pleno-frontend.md "Revisão do desenvolvedor front-end"
[10]: file:///home/ubuntu/fala-comigo/docs/team-review/10-10-senior-ios.md "Revisão iOS e plugins"
[11]: file:///home/ubuntu/fala-comigo/docs/team-review/11-11-senior-android.md "Revisão Android e Manifest"
[12]: file:///home/ubuntu/fala-comigo/docs/team-review/12-12-qa-automation.md "Revisão de QA e automação"
[13]: file:///home/ubuntu/fala-comigo/docs/team-review/13-13-devops.md "Revisão DevOps e CI/CD"
[14]: file:///home/ubuntu/fala-comigo/docs/team-review/14-14-cloud.md "Revisão de arquitetura cloud e observabilidade"
