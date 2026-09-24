# Auditoria do handoff, instruções e artefatos Android

**Data:** 24 de setembro de 2026  
**Branch auditada:** `work/qa-observability-and-emulator`  
**Commit atual:** `40d9e53` (`fix: defer optional native services until app launch`)

## 1. Conclusão executiva

A reclamação sobre o APK de aproximadamente 57 MB está correta como observação, mas o tamanho menor não é, por si só, uma falha. O arquivo de aproximadamente 159 MB era uma build **Debug**; o arquivo de aproximadamente 57 MB é uma build **Release**. São modos de distribuição diferentes.

A diferença de tamanho é esperada porque a build Debug contém bibliotecas nativas não otimizadas, símbolos e dados de depuração. A Release usa código AOT otimizado e remove dados de depuração. Portanto, a redução de 159 MB para aproximadamente 57 MB não prova que faltaram recursos do aplicativo.

O ponto não comprovado continua sendo o fechamento no aparelho físico. O build compila, os testes passam e a instalação foi possível, mas ainda não existe logcat do telefone confirmando qual componente derruba o processo.

## 2. O que foi verificado novamente

A documentação central foi relida: `PROJECT_HANDOFF.md`, `AGENTS.md`, `docs/PLANO_SEQUENCIAL_ATE_BUILD.md` e `docs/CONTINUIDADE_ASSISTENTE_IA.md`.

A branch real e a documentação não estavam sincronizadas. O handoff ainda apontava `feat/affordable-plans-model` e commits antigos, enquanto o trabalho atual estava em `work/qa-observability-and-emulator`, no commit `40d9e53`.

A continuidade também continha afirmações históricas que agora estão incorretas como estado atual, incluindo:

- Flutter/Dart não instalados localmente;
- testes locais ainda não executados;
- build Web local ainda não validado;
- apenas 46 testes passando;
- branch e commits anteriores como referência atual;
- validação Android real descrita somente como pendência sem registrar a falha de runtime atual.

Essas afirmações devem ser interpretadas como histórico das etapas anteriores, não como diagnóstico atual.

## 3. Evidência atual de build

A matriz executada com Flutter 3.38.0, Dart 3.10.0, JDK 21 e Android SDK 36 passou nas seguintes etapas:

| Etapa | Resultado |
|---|---|
| Formatação | passou |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` | passou |
| `flutter test` | 84 testes passaram |
| `flutter build web --release` | passou |
| `flutter build apk --debug` | passou em execução anterior da matriz |
| `flutter build apk --release` | passou |
| `flutter build appbundle --release` | passou |
| build limpa depois de `flutter clean` | APK e AAB passaram |
| Android SDK reconhecido pelo Flutter | corrigido com `flutter config --android-sdk` |

A última APK Release da correção de inicialização foi gerada depois de `flutter clean` e possui o hash:

```text
5f602b0a3ff807a8004344bb4c38f539dc423339588a71ad384500bd9161a8b9
```

## 4. Por que Debug tem aproximadamente 159 MB e Release aproximadamente 57 MB

A build Debug foi gerada como:

```bash
flutter build apk --debug
```

A build Release foi gerada como:

```bash
flutter build apk --release
```

O APK Debug é destinado a desenvolvimento e inclui conteúdo necessário para depuração. O APK Release é destinado à instalação de teste de distribuição e usa AOT, otimizações e remoção de dados de depuração. A diferença de tamanho é esperada em Flutter e não indica automaticamente que telas, assets ou plugins foram removidos.

A confirmação deve ser feita comparando `aapt dump badging`, o `applicationId`, `versionName`, `versionCode`, `targetSdkVersion` e os assets. Esses metadados permanecem os esperados:

```text
applicationId: com.falacomigo.fala_comigo
versionName: 1.0.0
versionCode: 1
minSdk: 24
targetSdk: 36
compileSdk: 36
```

## 5. O que foi alterado no caminho de inicialização

A implementação anterior aguardava TTS e notificações antes de chamar `runApp`. Isso era uma hipótese plausível de bloqueio: uma falha nativa poderia fechar o processo antes de qualquer tela aparecer.

A alteração `40d9e53` moveu esses dois serviços para depois de `runApp`, com captura independente de exceções. A grade CAA deve aparecer antes da inicialização opcional de TTS e notificações.

Essa alteração foi validada por análise, 84 testes e build Release, mas ainda não foi validada por logcat no telefone físico. Portanto, ela é uma correção estrutural importante, não uma prova de que o defeito original era exatamente TTS ou notificações.

## 6. O que ainda pode causar o fechamento

O caminho crítico ainda contém Hive, armazenamento seguro, migração de caixas, orientação de tela e população inicial de cartões antes de `runApp`. Se o processo nativo morrer durante armazenamento seguro ou se houver incompatibilidade específica do aparelho, a tela de fallback Dart não será suficiente.

Também existe uma diferença entre o AVD e o aparelho físico: o AVD utilizado na Manus perdeu o próprio serviço Android `package` e encerrou o `system_server` antes de instalar o APK. O erro `Broken pipe` observado no AVD não é um teste de execução do Fala Comigo.

Sem o logcat do aparelho físico, não é possível distinguir de forma responsável entre:

1. crash em armazenamento seguro;
2. crash de plugin Android;
3. crash nativo anterior ao Flutter;
4. dados antigos incompatíveis;
5. incompatibilidade de versão Android ou fabricante;
6. falha posterior dentro da primeira tela.

## 7. Próximo teste técnico correto

A próxima instalação deve usar a APK Release mais recente, depois de desinstalar a versão anterior. Se ela fechar novamente, deve ser coletado o logcat do próprio aparelho imediatamente após a tentativa de abertura.

O dado mínimo necessário é:

- fabricante e modelo;
- versão do Android e nível API;
- se o aplicativo foi desinstalado antes da instalação;
- horário aproximado do crash;
- logcat filtrado por `Fala Comigo`, `AndroidRuntime`, `FATAL EXCEPTION`, `flutter`, `libc` e `system_server`.

Não devem ser enviados nomes, frases, fotos, vídeos, dados de criança ou tokens.

## 8. Estado correto para continuidade

O projeto está em branch de trabalho e não deve ser tratado como publicação final. O pipeline de build está saudável, mas os critérios de primeiro build funcional do handoff ainda exigem validação humana em celular e tablet, offline, com acessibilidade e permissões negadas.

A chave usada na APK local de diagnóstico é temporária. A keystore oficial de produção deve continuar fora do Git e ser configurada somente no fluxo de distribuição autorizado.

A próxima IA ou pessoa deve usar este documento junto com o handoff, distinguindo sempre:

- implementação existente;
- build reproduzida;
- teste automatizado;
- teste em emulador;
- teste em aparelho real;
- hipótese de causa;
- causa confirmada por log.
