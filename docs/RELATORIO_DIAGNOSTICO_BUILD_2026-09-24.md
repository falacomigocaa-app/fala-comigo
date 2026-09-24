# Diagnóstico de build e instalação Android

**Data:** 24 de setembro de 2026
**Branch:** `work/qa-observability-and-emulator`
**Commit do código:** `5741575`

## Resultado executivo

A matriz de build foi executada com o ambiente Flutter 3.38.0, Dart 3.10.0, Android SDK 36.0.0, Gradle 9.3.1 e JDK 21. O resultado foi verde em todas as etapas do código:

| Etapa | Resultado |
|---|---|
| Formatação | passou |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` | passou; há apenas informações/depreciações não bloqueadoras |
| `flutter test` | passou; 84 testes |
| `flutter build web --release` | passou |
| `flutter build apk --debug` | passou |
| `flutter build apk --release` | passou |
| `flutter build appbundle --release` | passou |
| Build limpa após `flutter clean` | APK e AAB passaram |
| `flutter doctor` após configurar SDK | Android toolchain passou |

A conclusão é que **o problema relatado não é uma falha de compilação do aplicativo**.

## Falha 1 — configuração do ambiente

Inicialmente, `flutter doctor` não encontrava o Android SDK porque `ANDROID_HOME`/`ANDROID_SDK_ROOT` não estavam configurados e o Flutter não tinha o caminho salvo. O Gradle conseguia compilar apenas quando as variáveis eram exportadas manualmente.

A correção executada foi:

```bash
flutter config --android-sdk /home/ubuntu/android-sdk
```

Depois disso, o `flutter doctor` passou a mostrar:

```text
[✓] Android toolchain - develop for Android devices
Android SDK version 36.0.0
Emulator version 37.1.11.0
Java 21.0.12.1
All Android licenses accepted.
```

Chrome e toolchain Linux continuam ausentes, mas não bloqueiam os builds Web e Android usados neste projeto.

## Falha 2 — primeiro build Android

A primeira tentativa de APK debug falhou porque o ambiente possuía apenas o runtime Java, sem `javac`. O Gradle registrou:

```text
Toolchain installation '/usr/lib/jvm/java-21-openjdk-amd64'
does not provide the required capabilities: [JAVA_COMPILER]
```

O JDK completo foi instalado e o problema foi eliminado. Os builds seguintes passaram.

## Falha 3 — instalação no AVD

O AVD chegou a aparecer como conectado, mas não estava saudável. A instalação falhou com:

```text
cmd: Failure calling service package: Broken pipe (32)
```

A confirmação veio do próprio Android:

```text
cmd: Can't find service: package
```

O log do emulador mostrou que o `system_server` foi encerrado pelo sistema:

```text
Zygote failed to write to system_server FD: Connection refused
Process 2783 exited due to signal 9 (Killed)
```

Portanto, nesse momento o APK não chegou a executar no AVD. A falha é da infraestrutura do emulador sem KVM/aceleração, não do pacote do aplicativo. O processo QEMU chegou a consumir aproximadamente 4 GB de memória mesmo com configuração mínima.

## Propriedades dos artefatos

Os APKs têm o pacote e metadados esperados:

```text
applicationId: com.falacomigo.fala_comigo
versionName: 1.0.0
versionCode: 1
minSdk: 24
targetSdk: 36
compileSdk: 36
```

O APK debug é assinado com a chave padrão Android Debug. O APK release usado para diagnóstico é assinado com uma chave temporária fora do repositório e validado com APK Signature Scheme v2. Ele não é a chave oficial de produção.

A release verdadeira para a loja ainda depende da keystore de produção configurada no Codemagic. O projeto bloqueia corretamente a release quando `android/key.properties` não existe.

## O que ainda não foi provado

A matriz prova que o código compila e que os testes de domínio passam. Ela não prova que a inicialização funciona no aparelho físico do usuário, porque não temos o logcat desse aparelho.

A captura enviada mostra o Android exibindo “o app apresenta falhas contínuas”. Isso pode ser:

1. falha de inicialização Dart/plugin;
2. falha nativa de algum plugin Android;
3. dados antigos incompatíveis no aparelho;
4. incompatibilidade específica da versão Android/aparelho;
5. instalação sobre assinatura diferente ou estado antigo do aplicativo.

A nova build contém captura global e uma tela de diagnóstico para falhas Dart. Se o processo nativo morrer antes do Flutter iniciar, somente o log do aparelho identificará a causa.

## Próximo teste correto no aparelho físico

1. Desinstalar completamente qualquer versão anterior do Fala Comigo.
2. Reiniciar o aparelho.
3. Instalar o APK release novo.
4. Abrir o aplicativo sem restaurar dados antigos.
5. Se abrir, testar primeiro a grade CAA offline.
6. Em seguida testar TTS, Área do Responsável, PIN, mídia e notificações, um recurso por vez.
7. Se fechar novamente e aparecer a tela de diagnóstico, copiar o relatório técnico.
8. Se fechar sem tela, coletar logcat do aparelho; a captura local não consegue registrar um crash nativo anterior ao Flutter.

## Conclusão

O pipeline de build está saudável. O AVD da Manus não é uma evidência válida de falha do aplicativo porque o Android interno do emulador morreu antes da instalação. O próximo gate deve ser um **teste limpo no aparelho físico**, usando o APK release, acompanhado de versão do Android, fabricante/modelo e log do crash caso o fechamento persista.
