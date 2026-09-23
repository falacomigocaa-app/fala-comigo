# Fala Comigo — Teste Android com APK debug

**Build:** `app-debug.apk`  
**Data:** 23 de setembro de 2026  
**Finalidade:** teste interno em celular ou tablet Android; não é uma versão de loja e não deve ser distribuída publicamente.

## APK gerado

O build debug foi concluído com Flutter 3.38.0, Android SDK, Android NDK e JDK 21. O arquivo local gerado foi `build/app/outputs/flutter-apk/app-debug.apk`, com aproximadamente 152 MB.

SHA-256 do APK gerado:

```text
b3baeb02271501953ee212a4bf0f05816fa557dfeb351d2fa52923b435361d70
```

O APK debug não possui assinatura de produção. Ele serve para validação controlada e não substitui um APK/AAB release assinado.

## Opção A — instalar por cabo USB e ADB

No Android:

1. Abra **Configurações → Sobre o telefone**.
2. Toque sete vezes em **Número da versão** para habilitar o modo desenvolvedor.
3. Volte para **Configurações → Sistema → Opções do desenvolvedor**.
4. Ative **Depuração USB**.
5. Conecte o aparelho ao computador e aceite a autorização RSA exibida no telefone.

No computador, execute:

```bash
adb devices
adb install -r app-debug.apk
```

O resultado de `adb devices` deve mostrar o aparelho como `device`, e não como `unauthorized` ou `offline`. Para substituir uma instalação de teste anterior sem apagar os dados locais, use `-r`. Para começar completamente limpo, desinstale o pacote primeiro:

```bash
adb uninstall com.falacomigo.fala_comigo
adb install app-debug.apk
```

O pacote Android do projeto é:

```text
com.falacomigo.fala_comigo
```

## Opção B — copiar o APK para o telefone

Se o ADB não estiver disponível, copie o arquivo para o telefone por cabo, Drive ou outro canal privado. No Android, abra o arquivo e autorize a instalação de fonte desconhecida somente para o aplicativo gerenciador de arquivos utilizado. Depois da instalação, revogue essa autorização se ela não for mais necessária.

Use somente dados sintéticos. Não coloque dados reais de crianças, prontuários, nomes completos ou vídeos identificáveis no teste.

## Checklist mínimo de execução

| ID | Verificação | Resultado | Observação |
| --- | --- | --- | --- |
| A01 | Instalação limpa abre sem falha | — | Registrar modelo e versão Android |
| A02 | Grade de pictogramas aparece offline | — | Desativar Wi-Fi e dados móveis |
| A03 | Falar, adicionar e falar + adicionar | — | Testar volume e acessibilidade |
| A04 | Montar, remover e limpar frase | — | Testar frase longa |
| A05 | Configurar e validar PIN parental | — | Não registrar o PIN real no relatório |
| A06 | Área parental bloqueia e libera corretamente | — | Testar retorno do segundo plano |
| A07 | Cartão personalizado e mídia | — | Testar permissão negada e arquivo inválido |
| A08 | Alertas e transições | — | Testar áudio e notificação |
| A09 | Rotinas, lembretes e tendências | — | Verificar estados sem dados |
| A10 | Planos não bloqueiam comunicação offline | — | Testar sem licença e sem internet |
| A11 | Exclusão local | — | Confirmar remoção de dados sintéticos |
| A12 | Acessibilidade | — | TalkBack, tamanho, foco, contraste e orientação |

Para cada item, registrar **Passou**, **Falhou** ou **Não executado**, junto com aparelho, Android, versão do APK, conectividade e descrição objetiva. Falhas devem ser reproduzidas antes de abrir uma issue.

## Limitações conhecidas

O build debug foi criado para testes. O ambiente de desenvolvimento não possui um aparelho Android conectado, então nenhum dos itens acima deve ser marcado como aprovado antes da execução em dispositivo real. Builds release continuam protegidos: exigem `android/key.properties` e uma keystore de produção.
