# Fala Comigo — Comunicação Alternativa e Aumentativa (CAA)

App Flutter de Comunicação Alternativa (CAA/PECS) para autismo, com
grade de pictogramas, construtor de frases por voz (TTS pt-BR) e
painel dos pais/educadores.

- Nome comercial: **Fala Comigo**
- Nome sugerido na ficha da loja: **Fala Comigo — Comunicação Alternativa (CAA)**
- `applicationId` / namespace: `com.falacomigo.caa`

## 1. Setup do projeto

```bash
flutter pub get

# Gera o adapter do Hive (pictogram_card.g.dart)
flutter pub run build_runner build --delete-conflicting-outputs
```

Antes de rodar, crie a pasta de assets referenciada no `pubspec.yaml`:

```bash
mkdir -p assets/images/cards assets/icons
```

Adicione ali os pictogramas padrão (PNG/SVG) que quiser oferecer
prontos no app, além dos que os pais cadastrarem depois pela galeria.

## 2. Rodar em desenvolvimento

```bash
flutter run
```

## 3. Gerar a Keystore de assinatura (uma única vez)

```bash
keytool -genkey -v -keystore ~/fala-comigo-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias fala_comigo_key
```

Crie o arquivo `android/key.properties` (NÃO versionar no Git):

```
storePassword=SUA_SENHA
keyPassword=SUA_SENHA
keyAlias=fala_comigo_key
storeFile=/caminho/completo/para/fala-comigo-release-key.jks
```

## 4. Gerar o Android App Bundle (.aab)

O Google Play não aceita mais `.apk` para publicação — apenas
`.aab` (Android App Bundle):

```bash
flutter build appbundle --release
```

O arquivo gerado ficará em:
`build/app/outputs/bundle/release/app-release.aab`

## 5. Checklist antes de publicar na Google Play (2026)

- [ ] `compileSdk`/`targetSdk` = 35 (Android 15) — já configurado em
      `android/app/build.gradle`.
- [ ] Build gerado como `.aab`, assinado com a keystore de release.
- [ ] **Teste Fechado de 14 dias**: contas novas de desenvolvedor
      precisam de um teste fechado com 12–20 testadores por pelo
      menos 14 dias antes de promover para produção.
- [ ] **Política de Privacidade** publicada em uma URL pública (ver
      `privacy_policy.html` neste projeto, pronta para GitHub Pages),
      descrevendo:
  - Uso de voz/TTS (processado localmente pelo dispositivo);
  - Permissões de câmera/galeria (fotos ficam salvas localmente,
    não são enviadas a servidores);
  - Se o app é destinado ao público infantil, seguir também as
    políticas do Google Play para apps de crianças/famílias.
- [x] `namespace`/`applicationId` definidos como `com.falacomigo.caa`.
- [x] Ícone do app gerado (`android/app/src/main/res/mipmap-*`) —
      ícone legado + ícone adaptativo (Android 8+) + versão para a
      ficha da loja em `store_assets/play_store_icon_512.png`.

## 7. Contas necessárias (só na hora de publicar)

Nenhuma conta é necessária para desenvolver ou testar o app. Você só
precisa criar:

1. **Conta de desenvolvedor Google Play** (taxa única) — para
   publicar o `.aab`.
2. **Conta no GitHub** (gratuita) — para hospedar a política de
   privacidade via GitHub Pages, usando o arquivo
   `privacy_policy.html` incluído neste projeto.

## 6. Estrutura do projeto

```
lib/
  core/
    constants/    -> tamanhos de toque, categorias, PIN padrão
    services/      -> TtsService (voz pt-BR)
    theme/         -> tema visual acessível (cores pastel)
  features/
    aac_grid/
      domain/models/        -> PictogramCard (Hive)
      data/providers/       -> estado (Riverpod): cartões, frase, categoria
      presentation/screens/ -> AACGridScreen (tela principal)
      presentation/widgets/ -> GridCard, SentenceBarWidget
    parental_area/
      presentation/screens/ -> ParentalGateScreen (PIN), SettingsScreen, AddCardScreen
```
