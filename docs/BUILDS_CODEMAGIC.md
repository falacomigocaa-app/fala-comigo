# Builds Android no Codemagic

## Estado do projeto

O repositório contém `codemagic.yaml` na raiz com dois workflows: `android-release`, que executa análise, testes e gera APK e AAB assinados; e `web-release`, que valida e gera o build Web. O workflow Android usa Flutter 3.38.0, a mesma versão validada no projeto.

## Configuração obrigatória no Codemagic

Adicione o repositório `falacomigocaa-app/fala-comigo` e selecione a branch de trabalho `feat/affordable-plans-model` enquanto ela não for incorporada à `main`.

Em **Team settings → codemagic.yaml settings → Code signing identities → Android keystores**, envie a keystore de produção e use exatamente esta referência:

```text
fala-comigo-release
```

Ao cadastrar a identidade, informe a senha do keystore, o alias e a senha da chave. A keystore deve ser guardada também em um local privado próprio; ela não deve ser commitada no GitHub.

O workflow recebe automaticamente do Codemagic as variáveis `CM_KEYSTORE_PATH`, `CM_KEYSTORE_PASSWORD`, `CM_KEY_ALIAS` e `CM_KEY_PASSWORD`. Durante o build, ele gera temporariamente `android/key.properties`, que está ignorado pelo Git, e o Gradle usa esses valores para assinar a release.

## Artefatos

O workflow `android-release` produz:

```text
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
```

O APK serve para instalação e testes em aparelhos Android. O AAB é o formato recomendado para envio à Google Play.

## Ordem para executar

No Codemagic, selecione o workflow `android-release`, confirme a branch e inicie o build. O pipeline instala dependências, executa `flutter analyze`, executa todos os testes, gera o APK assinado e gera o AAB assinado. Se a keystore não estiver cadastrada com a referência esperada, o build deve ser interrompido antes da distribuição.

Antes de publicar uma nova versão, atualize o campo `version` em `pubspec.yaml`, aumentando o número depois do `+`, por exemplo de `1.0.0+1` para `1.0.0+2`. O Google Play não aceita repetir o mesmo `versionCode`.

## Verificação após o download

Instale o APK em um aparelho Android real e valide primeira execução, criação e troca do PIN, retorno do segundo plano, permissões concedidas e negadas, cartões personalizados, montagem de frase, alertas de transição e funcionamento offline. O AAB deve ser enviado somente depois dessa validação em celular e tablet.

## Limitações desta sessão

O sandbox local não possui Android SDK, portanto a geração do APK não foi executada aqui. O Codemagic é o ambiente destinado a gerar os artefatos Android assinados. O build Web foi validado localmente e o workflow correspondente permanece disponível.

## Referência externa

A estrutura segue a documentação oficial do Codemagic para workflows Flutter e identidades de assinatura Android: <https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/> e <https://docs.codemagic.io/yaml-code-signing/signing-android/>.
