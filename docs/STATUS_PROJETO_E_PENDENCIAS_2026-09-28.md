# Fala Comigo — resumo do projeto e pendências

**Atualizado:** 28/09/2026

**Escopo desta atualização:** validação local e documentação no sandbox. Sem commit, push, criação/alteração de PR, merge, publicação ou acesso ao Supabase.

## Resumo executivo

**O app já compila localmente para Flutter Web release e Android debug, e as prévias locais estão acessíveis.** A suíte automatizada também passou após uma correção de privacidade no apagamento de dados. Isso significa que há uma base executável para continuar desenvolvimento — **não significa que o produto inteiro esteja pronto para produção**.

O site institucional já tem um endereço permanente no GitHub Pages. O app Flutter Web ainda está somente numa prévia temporária do sandbox. O APK produzido é de **debug**, não foi instalado em telefone ou tablet, e não é um artefato para loja. O portal institucional continua sem autenticação ou backend de produção. O usuário informou que fará os testes reais depois da finalização técnica do sistema.

## Estado do checkout

- **Repositório local:** `/home/ubuntu/fala-comigo`.
- **Branch local:** `audit/creator-privacy-alignment`.
- **HEAD local:** `cc96eaf`.
- **Árvore:** contém alterações locais ainda não commitadas. Elas não foram enviadas ao GitHub.
- **Limite respeitado:** nenhum merge, push, publicação ou operação no Supabase foi feito nesta etapa.
- Os handoffs antigos contêm registros históricos datados; esta atualização os complementa sem apagar o histórico.

## O que está pronto ou foi confirmado

### App Flutter

- O núcleo local-first de CAA, grade de cartões, montagem/fala de frases, área do responsável e recursos locais está no repositório, conforme os handoffs existentes.
- **Flutter Web release:** compilou com sucesso para `build/web`.
- **Android debug:** `flutter build apk --debug --no-pub` concluiu com sucesso.
- O APK foi verificado por `apksigner`: assinatura debug válida no esquema v2. É para teste técnico, não para publicação.
- Metadados do APK: pacote `com.falacomigo.fala_comigo`, versão `1.0.0+1`, `minSdk 24`, `compileSdk/targetSdk 36`; tamanho aproximado **153 MB**.
- **SHA-256:** `e79271b5b6a8042d675be006c24e13b9b242e77c3e3b44ec35c1d81d00211f7f`.
- O build demandou JDK 21, Android SDK 36, Build Tools 36.0.0 e dependências Android adicionais baixadas pelo Gradle. Um daemon Gradle antigo com Java incompleto foi encerrado; com JDK 21 explícito, o build concluiu.

### Correção de privacidade nesta etapa

`DataWipeService` não apagava a caixa Hive `parent_reminders`. Com isso, lembretes poderiam sobreviver à exclusão total local. A correção local agora inclui a caixa na exclusão, elimina sua chave antiga e a recria vazia com nova chave. Foi adicionado `test/data_wipe_service_test.dart`, que grava um lembrete sintético, executa o apagamento e confirma que a caixa fica vazia.

### Site e prévias

- Endereço permanente atual do site institucional: [GitHub Pages](https://falacomigocaa-app.github.io/fala-comigo/).
- A página principal, a prévia do Criador, portal/RH e privacidade já haviam respondido HTTP 200 no endereço público.
- O workflow `site-pages.yml` publica somente o diretório `site/`; ele **não** publica o build Flutter Web.
- Nesta etapa, o servidor local do site e o servidor do Flutter Web release foram reiniciados e verificados: site e prévia do Criador, Flutter Web e `main.dart.js` respondem HTTP 200.
- Os endereços do sandbox abaixo são **temporários**, não substituem o GitHub Pages e dependem da sessão do sandbox:
  - [Prévia local do site](https://4174-ijwj8rsnu6oknbsn37ldj-36a4ebfd.us4.manus.computer/)
  - [Prévia local do Espaço do Criador](https://4174-ijwj8rsnu6oknbsn37ldj-36a4ebfd.us4.manus.computer/console-preview.html)
  - [Prévia local do app Flutter Web release](https://4175-ijwj8rsnu6oknbsn37ldj-36a4ebfd.us4.manus.computer/)
- Ajustes locais em `site/index.html` e `site/console-preview.html` não foram enviados nem publicados.

## Validações executadas

| Verificação | Resultado | Observação |
|---|---|---|
| Formatação dos 2 arquivos Dart alterados | Passou; 0 arquivos alterados pela verificação | Verificou o serviço e o novo teste. |
| `flutter test --no-pub` | **93 testes passaram** | Inclui a regressão de `parent_reminders`. |
| `flutter analyze --no-pub --no-fatal-infos --no-fatal-warnings` | Código de saída 0 | Ainda aponta 37 diagnósticos não fatais: 34 `info` e 3 `warning`. Os 3 warnings são métodos/elementos não usados em `settings_screen.dart`: `_openInstitutionalSite`, `_DashboardSection` e `_DashboardActionCard`. |
| `node --test tests/creator-console.test.mjs` | **5/5 passaram** | Cobre rotulagem de preço, métricas agregadas, ausência de detalhes de lote, aviso do Pages e link legado. |
| `flutter build web --release --no-pub` | Passou | Há avisos no dry-run WebAssembly sobre dependências (`dart:html`, `dart:js`/interop); não impediram o build JavaScript. |
| `flutter build apk --debug --no-pub` | Passou | APK verificado por `apksigner`; nenhuma instalação em aparelho foi feita. |
| `git diff --check` | Passou na revisão local | Reexecutar antes de qualquer commit futuro. |
| HTTP local | Passou | Site `/`, `console-preview.html`, Flutter Web `/` e `main.dart.js`: HTTP 200. |

## Fotografia das PRs — 28/09/2026

Esta é a fotografia somente-leitura registrada durante a revisão. Não houve atualização remota das PRs nesta etapa local.

| PR | Estado observado | Pendência principal |
|---|---|---|
| [#77](https://github.com/falacomigocaa-app/fala-comigo/pull/77) | Aberta, conflito/`dirty`, check de análise e testes verde | Atualizar contra `main`, resolver conflitos documentais e obter revisão humana. |
| [#78](https://github.com/falacomigocaa-app/fala-comigo/pull/78) | Aberta, baseada na #77; sem check atual reportado | Revalidar API e migration sintéticas após atualizar a base; não é portal de produção. |
| [#79](https://github.com/falacomigocaa-app/fala-comigo/pull/79) | Aberta, `dirty`, CI falhou | O build Web falha porque `extensionHint` não está alinhado entre implementação IO e stub Web. |
| [#80](https://github.com/falacomigocaa-app/fala-comigo/pull/80) | Aberta; mergeabilidade precisava ser recalculada; CI falhou | Herda a falha Web da #79; testar alarmes em Android real depois. |
| [#81](https://github.com/falacomigocaa-app/fala-comigo/pull/81) | Aberta, `dirty`, dois checks falharam | Herda a falha Web; backend e consentimentos ainda usam identidade/dados sintéticos. |
| [#83](https://github.com/falacomigocaa-app/fala-comigo/pull/83) | Aberta, checks verdes, mas conflito com o `main` | Resolver a divergência antes de merge; não foi mesclada nem publicada. |
| #84 / #86 | Documentação #84 e prévia estática #86 aparecem como integradas no snapshot da `main`; HEAD local é `cc96eaf` | A prévia estática não equivale a login ou console conectado. |

O relatório detalhado da revisão das PRs #77–#81 está em [fala-comigo-open-pr-review-2026-09-28.md](/home/ubuntu/reports/fala-comigo-open-pr-review-2026-09-28.md).

## O que ainda falta antes de considerar o projeto finalizado

### 1. Consolidar o código e as PRs

- Resolver o contrato multiplataforma de `MediaStorageService.persistFile` (`extensionHint`) e voltar a obter CI verde para #79–#81.
- Atualizar as branches contra o `main` atual, separar deltas próprios da cadeia #77–#81, resolver conflitos e fazer revisão humana antes de qualquer merge.
- Revisar a PR #83 conflitante e decidir quais mudanças locais do site devem entrar no site permanente.
- Esta etapa não fez commit, push ou merge. Qualquer integração remota será tratada como uma etapa posterior e separada.

### 2. Definir o destino permanente do app Web

O site institucional já é permanente. O Flutter Web não está nele: o workflow atual envia apenas `site/`. Se a intenção for tornar o app Web público, ainda é preciso decidir rota/domínio (por exemplo `/app/` ou um host separado), garantir configuração correta de `base href` e assets, adaptar workflow e revisar o conteúdo que ficará público. O build e as URLs temporárias de hoje não publicam o app.

### 3. Completar o portal institucional conectado

As PRs revisadas contêm especificação/API e fluxos sintéticos locais. Ainda faltam autenticação de produção, gestão de sessão, banco persistente, organizações/roles reais, autorização server-side e políticas de acesso, consentimento versionado, revogação/auditoria operacionais, isolamento entre organizações e testes de negação em backend implantado. Nenhuma conta ou dado real deve ser usado antes dos gates de segurança e privacidade. O Supabase **não foi acessado nem alterado** neste trabalho.

### 4. Preparar a versão de lançamento do app

- O artefato atual é **debug**. Ainda falta build de release/AAB, assinatura de produção configurada fora do Git, revisão de permissões, política e ficha de distribuição.
- Os testes em dispositivos físicos e a validação humana foram deliberadamente deixados para a etapa posterior que o responsável indicou.
- Quando chegar essa etapa, cobrir celular e tablet, instalação limpa, offline, CAA, voz, câmera/mídia, alertas, permissões negadas, TalkBack, apagamento total e recuperação após interrupções.

### 5. Limpar diagnósticos e fechar critérios de lançamento

- Remover os três elementos não usados e priorizar os demais 34 `info` da análise estática.
- Tratar os avisos do build Web/Wasm e de toolchain/dependências, ou registrar conscientemente quais são apenas limitação do modo JavaScript atual.
- Completar a revisão de acessibilidade/UX com famílias e profissionais, suporte/incidentes, privacidade e documentos legais antes de lançamento público amplo.

## Próxima ordem recomendada

1. Resolver no código o bloqueio `extensionHint` e executar novamente format/analyze/test/Web.
2. Separar e atualizar em branches os deltas das PRs #77–#81; revisar conflitos e checks antes de qualquer integração remota.
3. Decidir se o app Flutter Web precisa de URL pública permanente e, em caso positivo, escolher destino e payload exato antes de publicar.
4. Terminar backend/portal com autorização e testes negativos, mantendo dados sintéticos até revisão e consentimentos apropriados.
5. Gerar APK/AAB release com assinatura segura; só depois dos critérios de produto, executar os testes reais planejados.

**Conclusão:** o sistema está pronto para **execução e validação local** nos alvos Web e Android debug. Ainda não está pronto para lançamento, portal de produção ou publicação permanente do Flutter Web.
