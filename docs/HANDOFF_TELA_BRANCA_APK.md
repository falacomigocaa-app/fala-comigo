# Fala Comigo — Handoff da tela branca e do APK Android

> **Nota de atualização — 30/09/2026:** o conteúdo abaixo preserva o histórico da retomada de 25/09. A instrução de `openSecureBoxWithMigration` está obsoleta: essa API foi removida. O código atual usa `SecureBoxService.openSecureBox<T>`, snapshot/rollback do arquivo Hive em plataformas nativas e falha fechada; migração automática de boxes legadas está desativada. Consulte `docs/STATUS_PROJETO_E_PENDENCIAS_2026-09-30.md` para os resultados e gates atuais. A recuperação no Web continua sem validação.

**Data da retomada:** 25 de setembro de 2026
**Repositório:** `falacomigocaa-app/fala-comigo`
**Branch de correção:** `fix/main-startup-and-android-build`
**Base da correção:** `origin/main` no commit `0d0b685`

## Conclusão atual

A `main` não foi apagada nem reescrita. A PR 29 continua aberta e a PR 60 continua aberta como rascunho. A tentativa de mesclar a PR 60 foi recusada pelo GitHub porque ela está marcada como draft; portanto, nenhuma dessas operações alterou a `main`.

A causa mais provável da tela branca foi localizada no caminho de inicialização do Hive. A `main` abria a caixa `pictogram_cards` sem tipo explícito, produzindo `Box<dynamic>`. O provider da grade exige `Hive.box<PictogramCard>(cardsBoxName)`. Em um aparelho Android, essa combinação já produziu o erro conhecido:

> `HiveError: The box "pictogram_cards" is already open and of type Box<dynamic>`

Quando a exceção ocorre antes de `runApp`, o aplicativo pode abrir apenas uma tela branca, dependendo do build e da forma como o erro é tratado. A PR 29 contém a correção tipada, mas foi criada contra uma versão antiga da `main` e hoje aparece como `DIRTY`; ela não deve ser mesclada inteira sem reaplicação seletiva.

## O que foi verificado

| Item | Estado confirmado |
| --- | --- |
| `origin/main` | `0d0b685`, linha de segurança e CI preservada |
| PR 29 | Aberta, não é draft, `DIRTY`; contém correção Hive e Gradle |
| PR 60 | Aberta, draft, checks verdes; adiciona tela visível de falha de inicialização |
| Codemagic | Não foi executado nesta retomada; o workflow Codemagic exige keystore configurada |
| APK diagnosticado | Gerado pelo GitHub Actions na branch `diagnostics/show-startup-failure`, não pela `main` via Codemagic |
| APK diagnosticado | SHA-256 `86ba70c8868d4919fe7b00ccf262a25b774ad06b6a698b4e21ce6db77df0da06` |
| Run do APK diagnosticado | <https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36096527894> |
| Run de análise/testes diagnosticado | <https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36096510331> |

O APK acima é útil para diagnóstico, mas não prova que a `main` esteja corrigida. Ele foi produzido a partir de `edcea00` na branch de diagnóstico.

## Correção reaplicada sem perder funcionalidades

Na branch `fix/main-startup-and-android-build`, baseada na `origin/main`, foram reaplicadas apenas estas mudanças:

1. `SecureBoxService.openSecureBox<T>` agora retorna `Box<T>` e chama `Hive.openBox<T>`.
2. Naquela correção, `SecureBoxService.openSecureBoxWithMigration<T>` preservava o tipo durante abertura, migração e recriação. **Esse método foi removido em 30/09; não usar a migração automática descrita no histórico.**
3. `lib/main.dart` abre `pictogram_cards` como `Box<PictogramCard>`.
4. `android/app/build.gradle.kts` aplica `org.jetbrains.kotlin.android`.
5. A exigência de `android/key.properties` continua obrigatória para tarefas release; o APK debug não deve falhar durante a configuração por ausência da keystore de produção.

Não foram removidos dados, telas, planos, entitlements RH, testes de negação, política de privacidade, controles offline ou a linha de base MobSF.

## O que um agente futuro deve fazer

O agente deve começar por atualizar as referências e nunca usar a PR 29 diretamente como base sem comparar com a `main` atual:

```bash
git fetch origin --prune
git status --short --branch
git log origin/main -12 --oneline --decorate
gh pr view 29 --repo falacomigocaa-app/fala-comigo
gh pr view 60 --repo falacomigocaa-app/fala-comigo
```

Depois deve verificar a correção do Hive:

```bash
git show origin/main:lib/main.dart | sed -n '35,45p'
git show origin/main:lib/core/services/secure_box_service.dart | sed -n '25,60p'
```

A chamada tipada atualmente suportada é:

```dart
SecureBoxService.openSecureBox<PictogramCard>(cardsBoxName)
```

O serviço usa `Hive.openBox<T>` e, no nativo, mantém snapshot para restaurar o arquivo se a abertura tentar reescrevê-lo. A migração de dados legados segue desativada até existir um fluxo validado.

A validação remota deve ser feita em branch ou PR, nunca com alteração direta não revisada na `main`:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build web --release
flutter build apk --debug
```

Se o ambiente local não tiver Flutter ou Android SDK, usar o workflow `Android test APK artifact` do GitHub Actions. Esse workflow gera um APK de teste assinado com chave efêmera e verifica o APK com `apksigner`. Ele não é um APK de produção.

Para o Codemagic, a execução correta é outra: selecionar a branch/commit que contém a correção, confirmar a keystore `fala-comigo-release`, e então executar o workflow `android-release`. O Codemagic deve gerar o APK e o AAB release somente com a keystore cadastrada. Não declarar que o Codemagic passou sem uma execução visível e um artefato com hash.

## Procedimento no aparelho Android

1. Instalar o APK de teste em uma instalação limpa para validar a primeira abertura. **Não atualizar por cima de uma instalação com dados reais**: a migração de caixas antigas está desativada e deve ser planejada separadamente com backup/recuperação.
2. Abrir o aplicativo com Wi-Fi e dados móveis desligados.
3. Confirmar que a grade de cartões aparece após a abertura.
4. Testar falar, adicionar, falar + adicionar e limpar a frase.
5. Se aparecer a tela `Falha de inicialização`, copiar somente a mensagem e o tipo da exceção, sem dados de criança, fotos, vídeos, PIN ou tokens.
6. Registrar modelo, versão Android, versão do APK, conectividade e resultado.
7. Não marcar o fluxo como aprovado apenas porque o APK instalou; instalação, abertura e navegação são verificações diferentes.

## Limites e segurança

A correção não altera a decisão de manter o núcleo CAA offline e gratuito. Também não resolve ainda a dívida técnica MobSF do `HiveAesCipher` em CBC nem a decisão de `minSdk`; esses itens continuam monitorados conforme `security/reports/MOBSF_2026-09-24.md`. A migração para AES-GCM deve ser tratada em uma etapa separada, com migração compatível e teste de recuperação.

O portal RH continua sintético e isolado. Nenhuma correção de build Android autoriza sincronização clínica, métricas individuais, acesso a frases, mídia, diagnóstico ou cobrança.

## Resultado esperado desta etapa

O resultado mínimo é um PR baseado na `main` atual que passe análise, testes e build Android debug. Após a instalação em aparelho real, o resultado deve ser classificado como **abriu**, **falhou com erro visível** ou **não executado**. O termo “build válido” significa apenas que o artefato foi produzido e verificado; não significa que a experiência no aparelho foi aprovada.

A próxima correção de produto só deve ser feita depois de observar o resultado desse APK corrigido em aparelho Android. Se ele ainda apresentar falha, usar a tela diagnóstica da PR 60 ou os logs do aparelho para corrigir a exceção específica, sem remover a proteção nem voltar a abrir caixas Hive como `dynamic`.

## Referências

- `PROJECT_HANDOFF.md`
- `docs/CONTINUIDADE_ASSISTENTE_IA.md`
- `docs/ANDROID_TESTE_DEBUG.md` na PR 29
- `docs/PLANO_SEGURANCA_OWASP_MASVS_MOBSF.md`
- `security/reports/MOBSF_2026-09-24.md`
- `.github/workflows/android-test-apk.yml`
- `codemagic.yaml`

Este documento não contém credenciais, chaves, dados clínicos ou dados reais de crianças.

## References

[1]: https://github.com/falacomigocaa-app/fala-comigo "Fala Comigo — repositório oficial"
[2]: https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36096527894 "GitHub Actions — APK diagnóstico"
[3]: https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36096510331 "GitHub Actions — análise e testes diagnósticos"
[4]: https://mas.owasp.org/MASVS/ "OWASP MASVS — Mobile Application Security Verification Standard"


## Evidência do APK corrigido da PR 66

Em 25 de setembro de 2026, o workflow `Android test APK artifact` foi executado no commit `abe8633` da branch `fix/main-startup-and-android-build`.

- **Run:** [36109508895](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36109508895)
- **Resultado:** sucesso
- **Etapas:** Flutter configurado, dependências instaladas, build release de teste concluído, APK verificado com `apksigner` e artefato publicado.
- **APK:** `fala-comigo-test.apk`
- **SHA-256:** `63f3d897f07995baff7262b4f43d691733f0e7c80e25f97988a9bc818b373646`
- **Tipo:** APK de teste não produtivo, assinado com chave efêmera do GitHub Actions.

Esse resultado comprova a geração e a integridade estrutural do APK da correção. Ainda não comprova a abertura da grade em celular ou tablet real. A próxima ação é instalar o APK em aparelho Android, preferencialmente após desinstalação limpa, e registrar o resultado de abertura, grade CAA, modo offline e acessibilidade.


## Atualização — 27/09/2026 — falha de compilação Web em PRs com a correção de câmera

A revisão dos checks remotos das PRs #79, #80 e #81 identificou uma incompatibilidade entre plataformas: a implementação nativa `media_storage_service_io.dart` recebe `extensionHint`, mas o stub Web não aceitava o parâmetro nomeado usado por `add_card_screen.dart`. O compilador Web interrompeu as checks com `No named parameter with the name 'extensionHint'`.

Foi aplicada em branch separada `fix/web-media-api-parity`, baseada na `origin/main` atual (`b43e18b`), uma alteração somente de contrato em `media_storage_service_web.dart`: aceitar o parâmetro `String? extensionHint`. O método continua lançando `UnsupportedError`, de modo que nenhuma persistência de mídia personalizada foi habilitada na Web.

O commit `0aae627` foi publicado na branch e a [PR #82](https://github.com/falacomigocaa-app/fala-comigo/pull/82) foi aberta contra `main`.

**Estado:** pendente de CI. A revisão do diff e `git diff --check` passaram. Esta sessão não tem Flutter/Dart nem adb disponíveis. Não há validação de APK nem em aparelho nesta etapa; os resultados previamente registrados para o Realme C71 permanecem limitados aos fluxos e à versão já testados pelo proprietário. A `main` não foi alterada. Próximo passo: confirmar checks verdes antes de gerar um novo APK de teste para a repetição dos fluxos no Realme C71.


## Atualização — 28/09/2026 — build Android debug local

O ambiente sandbox recebeu Flutter 3.38.0, JDK 21 e Android SDK 36. Após encerrar um daemon Gradle que estava associado a Java incompleto, o build local concluiu:

- Comando final: `flutter build apk --debug --no-pub`.
- Artefato: `build/app/outputs/flutter-apk/app-debug.apk` (aprox. 153 MB).
- Pacote `com.falacomigo.fala_comigo`, versão `1.0.0+1`, minSdk 24, targetSdk 36.
- `apksigner verify --verbose`: assinatura v2 válida.
- SHA-256: `e79271b5b6a8042d675be006c24e13b9b242e77c3e3b44ec35c1d81d00211f7f`.
- Build Web release e 93 testes Flutter também passaram nesta atualização.
- Correção local adicional: `DataWipeService` agora apaga `parent_reminders`; a regressão está em `test/data_wipe_service_test.dart` e passou.

**Limite:** o APK é de debug e não foi instalado nem aberto em dispositivo real. Não comprova tela inicial, grade CAA, uso offline ou comportamento em celular/tablet. A validação de aparelho foi deixada para a etapa posterior indicada pelo proprietário. Build de release/AAB e assinatura de produção continuam pendentes. Resumo completo: `docs/STATUS_PROJETO_E_PENDENCIAS_2026-09-28.md`.


## Atualização — 29/09/2026 — APK debug reconstruído e validação automatizada

Depois de concluir correções locais em privacidade, preferências e persistência dos Planos de Comunicação, o build foi repetido com Flutter 3.38.0, JDK 21 e Android SDK 36:

- APK: `build/app/outputs/flutter-apk/app-debug.apk`, 153 MB, pacote `com.falacomigo.fala_comigo`, versão `1.0.0+1`, minSdk 24, targetSdk 36.
- `apksigner verify --verbose --print-certs`: assinatura de debug válida; SHA-256 do APK `a94050ff151c65ecb21fb61982aafa8403bf45c81762121be48597f3c187dad7`.
- Validações locais: `flutter analyze --no-pub` sem problemas; **98 testes Flutter**; build Web release concluído. Não foi feita instalação/abertura em aparelho real.
- O Web release foi também empacotado para a subrota planejada `/fala-comigo/app/`; o smoke visual confirmou grade e seleção local de cartão. Isso não substitui teste em telefone/tablet nem valida armazenamento/permissões nativas.
- **Ainda pendente:** AAB/APK release assinado com chave de produção; não criar nem registrar a chave no Git. Testes físicos continuam para a etapa posterior indicada pelo proprietário.
