# Rollback para o estado anterior à integração

**Data:** 24 de setembro de 2026  
**Branch:** `rollback/pre-affordable-integration`  
**Commit funcional restaurado:** `299cb9ea1b14b80e47ebf01913244358ba0c61e4`

## O que foi restaurado

A branch foi criada no commit imediatamente anterior ao merge da integração `affordable` (`5a0d125`). Assim, ela não contém a integração de rotinas, relatórios, tendências, alterações posteriores de dashboard, diagnóstico global, bootstrap controlado, correções Hive posteriores ou alterações de wipe feitas depois desse ponto.

A branch atual de desenvolvimento não foi apagada nem alterada. O rollback existe como linha separada para comparação e teste.

## Validação

Na cópia restaurada:

- `flutter pub get`: concluído;
- `flutter analyze --no-fatal-infos --no-fatal-warnings`: concluído com avisos informativos/deprecações;
- `flutter test`: concluído com sucesso;
- `flutter build web --release`: concluído;
- `flutter build apk --debug`: concluído.

O APK foi gerado com:

```text
Arquivo: build/app/outputs/flutter-apk/app-debug.apk
Tamanho: 152 MB
SHA-256: 233feb2a5956721c27fc700c989b096ba56faae7206f97c4163d9344d5e1395e
```

## Observação sobre o build

O commit histórico usava uma configuração Kotlin/Gradle que o toolchain atual não aceita. Foi aplicada somente uma adaptação de script Android para permitir a compilação com o toolchain instalado: importação de `KotlinCompile`, configuração de `JvmTarget.JVM_17` e remoção do erro de assinatura executado durante a configuração de uma build Debug. O código Dart e o fluxo de inicialização são os do commit histórico.

## Limite

O APK restaurado foi compilado e testado automaticamente, mas ainda precisa ser aberto no aparelho que apresentava o problema. O teste no AVD da Manus não é considerado evidência suficiente porque o ambiente perdeu o serviço Android durante o boot.
