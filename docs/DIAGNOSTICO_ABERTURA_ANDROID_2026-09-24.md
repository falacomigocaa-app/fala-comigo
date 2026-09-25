# Diagnóstico da falha de abertura Android

**Data:** 24 de setembro de 2026  
**Base investigada:** `299cb9ea1b14b80e47ebf01913244358ba0c61e4`  
**Branch da correção:** `fix/android-startup-bootstrap`

## Causa confirmada no código

O baseline executava operações potencialmente falíveis antes de chamar `runApp()`:

1. bloqueio de orientação;
2. inicialização do Hive;
3. registro e abertura de caixas protegidas;
4. carga dos cartões iniciais;
5. inicialização do TTS;
6. inicialização das notificações;
7. somente depois, desenho da primeira tela Flutter.

Se um plugin nativo, uma migração Hive, uma permissão ou uma configuração Android falhasse, o processo terminava antes que o usuário visse qualquer tela. Isso explica o comportamento de instalar, tentar abrir e fechar imediatamente.

## Correção aplicada

A correção mantém o produto e o baseline anteriores à integração, mas altera o bootstrap para:

- chamar `runApp()` imediatamente;
- executar inicialização pesada em segundo plano;
- tratar armazenamento, TTS e notificações como etapas recuperáveis;
- impedir que falhas opcionais encerrem o processo antes da primeira tela;
- manter o callback de alertas após a inicialização.

## APK candidata

```text
Arquivo: build/app/outputs/flutter-apk/app-debug.apk
Tamanho: 178 MB
SHA-256: 824ad486de779f35da531c8e07726ec419ba3f8713343ccff3690491ad9bfcad
```

## Validação local

`flutter pub get`, análise estática, testes Flutter e build APK Debug concluíram com sucesso. A abertura em aparelho físico ainda é o teste decisivo; não foi inventada evidência de execução em dispositivo, pois não há ADB conectado nesta sessão.
