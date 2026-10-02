# Fala Comigo — relatório de finalização e pendências

**Data da verificação:** 29/09/2026

**Branch:** `audit/creator-privacy-alignment` (enviada ao remoto)

**PR de integração:** [#87 — Finalize privacy, caregiver plans, and Flutter Web Pages route](https://github.com/falacomigocaa-app/fala-comigo/pull/87), aberta contra `main`.

**Base remota verificada:** `origin/main` em `cc96eaf`; PR aberta sem merge. Dois checks estavam pendentes no último snapshot (04:57, horário local).

## Resumo executivo

O núcleo do aplicativo foi validado localmente em Web e Android Debug. Privacidade e persistência dos Planos de Comunicação foram corrigidas, o manual do usuário foi criado e há uma rota Flutter Web preparada em `/fala-comigo/app/` no workflow do GitHub Pages.

**Ainda não é uma publicação final:** a branch foi enviada e a PR #87 está aberta; não houve merge nem deploy desta atualização. O site institucional atual continua público, mas a rota `/app/` ainda retorna HTTP 404 no GitHub Pages. A auditoria integral do repositório e a revisão das PRs abertas estão em consolidação. Não houve teste em aparelho real, conforme a etapa posterior planejada pelo proprietário.

## Trabalho concluído localmente

- `DataWipeService` inclui `parent_reminders` na exclusão total e cancela notificações associadas; há teste de regressão.
- Preferências de orientação/escala e Planos de Comunicação foram ajustados para persistir; planos salvos podem ser consultados e editados na Área do Responsável.
- Contrato do stub Web de armazenamento de mídia agora aceita `extensionHint`, sem habilitar gravação de mídia personalizada no navegador.
- Ajustes de estabilidade, acessibilidade e análise estática no app; registradores Flutter de Linux/macOS/Windows regenerados.
- Workflow Pages preparado para publicar o site estático e compilar Flutter Web com base-href `/fala-comigo/app/`.
- Site revisado com link claro para a prévia Web, metadados do app e texto que deixa explícito o estado de validação.
- Criado o [manual do usuário](MANUAL_DO_USUARIO.md) em Markdown e versão PDF.

## Validação local

| Verificação | Resultado |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test` | Passou, sem arquivos pendentes de formatação |
| `flutter analyze --no-pub` | Passou: **No issues found** |
| `flutter test --no-pub` | Passou: **98/98 testes** |
| `node --test tests/*.test.mjs` | Passou: **10/10 testes** |
| `flutter build web --release --no-pub --base-href /fala-comigo/app/` | Passou; base-href e artefatos conferidos |
| `flutter build apk --debug --no-pub` | Passou; assinatura de debug verificada com `apksigner` |
| Workflow Pages YAML | Parser YAML local confirmou estrutura/sintaxe |
| Prévia combinada no sandbox | HTTP 200 para site, `/app/`, `main.dart.js`, bootstrap e manifesto |
| Smoke visual/funcional Web | Grade carregou; seleção do cartão “Comer” adicionou o cartão à barra de frase |
| `git diff --check` | Passou antes dos commits |

O Flutter informa limitações de dependências no dry-run para WebAssembly (`dart:html`/`dart:js`). Isso **não bloqueou** o build JavaScript Web release. A compatibilidade futura com Wasm permanece uma observação técnica, não um bloqueio do alvo JS atual.

## Artefatos verificados

| Artefato | Localização | SHA-256 / estado |
| --- | --- | --- |
| APK Android **Debug** (não release) | `build/app/outputs/flutter-apk/app-debug.apk` | `a94050ff151c65ecb21fb61982aafa8403bf45c81762121be48597f3c187dad7`; v2 válida; 153 MB |
| Pacote Flutter Web para Pages `/app/` | `/home/ubuntu/artifacts/fala-comigo-web-pages-app.zip` | `0b8885ded3a2f724d680ce1ede6572114e2761406feb750132ab4db2e7fdb320`; ZIP íntegro, 11 MB |
| Manual do usuário PDF | `/home/ubuntu/artifacts/Manual_do_Usuario_Fala_Comigo.pdf` | `807fefa9af7c80bed5e4a5eb3acc5cca6ab1cc8c8389a07be67827d60a5ca6c3`; 6 páginas A4 |

O APK é do pacote `com.falacomigo.fala_comigo`, versão `1.0.0+1`, minSdk 24/targetSdk 36. **Não foi instalado nem aberto em celular/tablet.** O ZIP contém a compilação Web com `<base href="/fala-comigo/app/">`.

Prévia combinada temporária (depende do sandbox): [site e app Web](https://4176-ijwj8rsnu6oknbsn37ldj-36a4ebfd.us4.manus.computer/fala-comigo/) — app em `/app/`.

## Estado público do site

Verificação HTTP em 29/09/2026:

- Site institucional oficial: [https://falacomigocaa-app.github.io/fala-comigo/](https://falacomigocaa-app.github.io/fala-comigo/) → **200**.
- Política pública: `/fala-comigo/privacy.html` → **200**.
- Nova rota do app: `/fala-comigo/app/` → **404**, pois o workflow e os commits locais ainda não foram publicados.

A alteração preparada mantém o site institucional e coloca o Flutter Web em `/app/`; não configura backend, login ou armazenamento de mídia no browser. A integração final alterará o conteúdo público do GitHub Pages e deve ser revisada antes do merge/deploy.

## Commits organizados na branch da PR #87

1. `9224c4c fix: harden privacy and persist caregiver workflows`
2. `fa3dc9c feat(web): prepare Flutter app route on GitHub Pages`
3. `0af73e6 docs: add user manual and refresh project handoffs`
4. `5401f4b docs: record finalization status and validation evidence`

Os commits estão na branch remota `audit/creator-privacy-alignment` e na PR #87; nenhum foi integrado à `main`.

## Auditoria de pastas, histórico e PRs

A auditoria especialista integral e a revisão atualizada das PRs abertas foram iniciadas nesta retomada. **Seus pareceres finais ainda precisam ser incorporados a este relatório** antes da decisão sobre ordem de integração. A fotografia detalhada anterior, de 28/09, está em `/home/ubuntu/reports/fala-comigo-open-pr-review-2026-09-28.md` no workspace local; os estados remotos daquela fotografia podem ter mudado.

## Pendências e gates

1. Incorporar o parecer final da auditoria de todas as pastas e do histórico Git.
2. Incorporar o parecer atualizado das PRs, reordenar dependências e revisar conflitos/CI; não mesclar PRs apenas por estarem abertas ou por parecerem relacionadas.
3. Acompanhar os checks da PR #87 e incorporar as auditorias especialistas; confirmar novamente estado e checks antes de qualquer merge.
4. **Merge/deploy do Pages:** mostrar ao responsável o payload exato (site atualizado mais nova rota `/app/`) e obter confirmação final antes de torná-lo público.
5. Preparar APK/AAB de **release** somente com a chave de produção e configuração protegida. Não criar, expor ou commitar keystore, senha ou segredo.
6. Executar testes em aparelhos reais posteriormente, conforme o proprietário informou, cobrindo abertura limpa, grade CAA, modo offline, voz, cartão/frase, orientação, notificações e Android compatível.
7. Backend e portal conectado continuam fora desta entrega: autenticação, autorização server-side, consentimento, RLS e testes negativos precisam existir antes de qualquer dado real; manter dados sintéticos.

## Conclusão

O app está **rodando e validado localmente** em Web e Android Debug, e a navegação da prévia ao novo app Web foi verificada. O site institucional existente permanece ativo. A nova rota Flutter Web está pronta para revisão e integração, mas não está publicada. Ainda não se pode afirmar lançamento de produção, build assinado de release, merge em `main` ou aprovação em dispositivo real.
