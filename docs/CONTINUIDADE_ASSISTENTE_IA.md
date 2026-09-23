# Fala Comigo — Continuidade para assistência por IA

**Última atualização:** 23 de setembro de 2026
**Estado:** avaliação inicial concluída; transferência para `main` ainda não iniciada.

## 1. Objetivo deste documento

Este arquivo permite que outra pessoa ou assistência por IA retome o projeto rapidamente, entendendo o que foi analisado, quais decisões foram tomadas, quais comandos foram executados, o que já está pronto e o que ainda falta realizar.

Cada etapa relevante deve registrar:

- data e objetivo;
- comando executado;
- resultado resumido;
- arquivos ou branches afetados;
- riscos ou conflitos encontrados;
- próximo passo recomendado.

Nenhuma credencial, token, senha, chave privada ou dado real de criança deve ser registrado neste documento.

## 2. Identificação do projeto

- **Produto:** Fala Comigo — Comunicação Aumentativa e Alternativa (CAA/PECS).
- **Repositório:** `falacomigocaa-app/fala-comigo`.
- **Branch principal:** `main`.
- **Branch de trabalho avaliada:** `feat/affordable-plans-model`.
- **Conta GitHub conectada:** `falacomigocaa-app`.
- **Permissões confirmadas:** leitura, push, maintain e admin.
- **Regra central do produto:** a comunicação básica deve funcionar localmente, sem internet, sem conta e sem plano pago.

## 3. Documentos lidos

Foram lidos ou avaliados os documentos centrais e de continuidade da branch de trabalho:

- `README.md`;
- `PROJECT_HANDOFF.md`;
- `docs/PLANO_SEQUENCIAL_ATE_BUILD.md`;
- `docs/CHECKLIST_PRE_LANCAMENTO.md`;
- `docs/ROADMAP_FULL_CYCLE.md`;
- `docs/SEQUENCIA_FULL_STACK_ATE_PILOTO.md`;
- `docs/MODELO_CUSTOS_E_PLANOS.md`;
- `docs/MODELO_AUTORIZACAO_CLINICAS_ESCOLAS.md`;
- `docs/MODELO_BENEFICIO_CORPORATIVO_PCD.md`;
- `docs/RELATORIO_FUNCOES_INSTITUCIONAIS.md`;
- `privacy_policy.html`;
- `store_listing.md`.

## 4. Estado atual conhecido

### Já implementado ou documentado

- grade de pictogramas e categorias;
- montagem e reprodução de frases;
- modos de toque falar, adicionar e falar + adicionar;
- cartões padrão e personalizados;
- área protegida do responsável;
- PIN parental com PBKDF2-HMAC-SHA256;
- sessão parental temporária;
- caixas Hive protegidas;
- mídia nativa cifrada;
- exclusão local de dados, credenciais e chaves;
- registros ABC e exportação minimizada;
- diário de vídeo;
- alertas de transição;
- acessibilidade semântica;
- tratamento de mídia ausente ou corrompida;
- catálogo de planos e estados de licença;
- controle local de recursos sem bloquear o modo offline;
- tela de status de planos;
- rotinas, lembretes, relatórios e tendências na branch affordable;
- site institucional em desenvolvimento;
- workflows de CI e validações de qualidade;
- documentação de pré-lançamento e privacidade.

### Ainda não pronto para produção

- Flutter/Dart instalado neste ambiente local;
- validação local completa com `flutter analyze` e `flutter test`;
- build Web local validado;
- build Android validado em celular e tablet reais;
- validação humana com famílias e profissionais;
- backend do portal conectado;
- contas e organizações remotas;
- autorização clínica no servidor;
- consentimento versionado remoto;
- auditoria de acesso remoto;
- sincronização clínica;
- cobrança real;
- painel corporativo em produção;
- domínio final;
- publicação ampla.

## 5. Situação das branches

### `main`

- Branch principal atual.
- Commit observado: `299cb9e` — `Add corporate PCD benefit model`.
- Working tree local da `main` está limpa após o clone.

### `feat/affordable-plans-model`

- Commit observado: `d0af6e2` — `feat: add local parent routine reminders`.
- Está significativamente à frente da `main`.
- Possui aproximadamente 78 arquivos alterados em relação à `main`, com cerca de 7.533 adições e 851 remoções.
- Workflows recentes do GitHub Actions foram concluídos com sucesso.
- O trabalho inclui planos locais, área parental, rotinas, relatórios, tendências, site institucional, testes e documentação.

### Observação sobre a documentação

`PROJECT_HANDOFF.md` registra um commit mais antigo (`8b0d7d7`) como último commit do handoff. Esse registro precisa ser atualizado quando a branch e o estado do projeto forem consolidados.

## 6. Validações já realizadas

- GitHub conectado e autenticado.
- Repositório localizado e clonado.
- Permissão de `push` confirmada pela API do GitHub.
- Branches e histórico recente avaliados.
- CI da `feat/affordable-plans-model` consultado: resultados recentes com sucesso.
- Tentativa de testes locais registrada: não executada porque `flutter` não está instalado nesta sessão.
- Nenhuma alteração, commit, push ou merge foi feito no GitHub durante a avaliação.

## 7. Ordem planejada para a integração com `main`

A integração deve ser feita sem alterar a `main` remota inicialmente:

1. confirmar estado limpo e referências atualizadas;
2. registrar o ponto de partida;
3. comparar `main` e `feat/affordable-plans-model`;
4. simular o merge em worktree ou branch temporária;
5. listar conflitos automáticos;
6. classificar conflitos de código, documentação, produto e cronograma;
7. revisar alterações sensíveis de CAA, privacidade, planos e acessibilidade;
8. instalar ou disponibilizar Flutter para validação local, se possível;
9. executar formatação, análise, testes e build Web;
10. revisar o diff final;
11. somente após decisão explícita, criar commit, push ou Pull Request.

## 8. Regras de segurança da integração

- Não fazer merge direto na `main` sem revisar o diff.
- Não fazer push ou publicar alterações sem registrar o resultado nesta documentação.
- Não apagar branches ou commits.
- Não registrar segredos no Git.
- Não usar dados reais de crianças em testes, logs, issues ou screenshots.
- Não bloquear comunicação, acessibilidade ou modo offline por plano.
- Não afirmar que um teste passou sem evidência recente.
- Não ativar cobrança real, domínio, portal clínico ou sincronização sem as validações e confirmações previstas.
- Documentação conceitual não deve ser tratada como implementação pronta.

## 9. Checklist rápido de retomada

- [x] GitHub conectado.
- [x] Repositório identificado.
- [x] Permissões de escrita confirmadas.
- [x] `main` identificada.
- [x] `feat/affordable-plans-model` identificada.
- [x] Documentos centrais lidos.
- [x] CI remoto consultado.
- [ ] Flutter instalado localmente.
- [ ] Testes locais executados.
- [ ] Build Web local executado.
- [ ] Simulação de integração realizada.
- [ ] Conflitos classificados.
- [ ] Diff de integração revisado.
- [ ] Decisão sobre merge tomada.
- [ ] Commit de integração criado.
- [ ] Push ou Pull Request realizado.

## 10. Registro de comandos e etapas

### 23/09/2026 — Avaliação inicial

**Objetivo:** confirmar conexão, localizar o repositório e entender o estado do projeto.

**Ações realizadas:**

- verificação da conexão GitHub;
- verificação da autenticação da conta `falacomigocaa-app`;
- listagem de repositórios acessíveis;
- clone local do repositório;
- inspeção de branches, histórico e documentação;
- consulta das permissões do repositório;
- consulta dos resultados recentes do GitHub Actions;
- criação de worktree isolado da `feat/affordable-plans-model`.

**Resultado:** acesso confirmado; nenhum commit, push ou merge realizado.

**Limitação:** Flutter não está instalado no ambiente local.

## 11. Próximo passo

Aguardar os comandos ou a autorização operacional para iniciar a simulação de transferência da `feat/affordable-plans-model` para a `main`. A primeira ação deve ser somente de comparação/simulação, sem alteração na `main` remota.

## 13. Primeira etapa de integração — linha de base e simulação

**Data:** 23 de setembro de 2026.

Foi feita uma atualização das referências remotas com `git fetch origin --prune`, sem alteração no GitHub. A linha de base registrada foi:

| Referência | Commit | Situação |
| --- | --- | --- |
| `origin/main` | `299cb9e` | branch principal |
| `origin/feat/affordable-plans-model` | `d0af6e2` | branch de trabalho |
| ancestral comum | `299cb9e` | a affordable parte exatamente da main |

Foi executada uma simulação de merge usando `git merge-tree`. O resultado não apresentou conflitos textuais, marcadores de conflito, arquivos deletados ou necessidade de resolução manual. Como a ancestral comum é exatamente o commit atual da `main`, a integração é tecnicamente um avanço linear/fast-forward, desde que a decisão de publicação seja tomada depois da revisão.

A diferença contém 78 arquivos: 42 de aplicação em `lib/`, 8 de documentação, 18 testes, 2 arquivos de CI, 3 itens de site/assets e 5 arquivos de outras categorias. A checagem de diff não apresentou erro estrutural, mas apontou espaços à direita em três linhas de documentação de `RELATORIO_FUNCOES_INSTITUCIONAIS.md` e `SEQUENCIA_FULL_STACK_ATE_PILOTO.md`. Isso é uma pendência de qualidade documental, não um conflito de merge.

Não foram encontrados marcadores de conflito ou nomes de arquivos que indiquem segredos evidentes. Essa verificação não substitui a análise completa de conteúdo sensível.

**Conclusão da etapa:** não há conflito técnico de Git entre a `main` atual e a `feat/affordable-plans-model`. Ainda não foi feito merge, commit, push ou alteração na `main` remota. O próximo gate é a revisão multidisciplinar do diff e a validação disponível antes de qualquer fast-forward.

## 14. Revisão multidisciplinar inicial do diff

O módulo de planos preserva explicitamente o núcleo offline: `PlanAccessController` libera comunicação, controles parentais, acessibilidade e armazenamento local independentemente de licença; recursos remotos dependem de licença e estado compatíveis. Os testes adicionados cobrem plano Essencial, licença ativa, período de transição, suspensão, expiração, revogação, status desconhecido e ausência de dados clínicos na serialização.

O CI da branch adiciona build Web e um workflow de GitHub Pages para o diretório `site/`. O workflow está tecnicamente separado e exige arquivos mínimos, mas um avanço da branch para `main` poderá disparar publicação pública do site se o GitHub Pages estiver configurado para essa fonte. Essa publicação será tratada como gate separado e não será acionada automaticamente durante a simulação.

A branch adiciona 18 arquivos de teste, 42 arquivos de aplicação, documentação e site. Não foram encontrados marcadores de conflito, arquivos deletados ou segredos evidentes na inspeção inicial. A análise local de Flutter continua bloqueada porque a toolchain não está instalada.

**Pendências de validação:** revisar visualmente os fluxos; corrigir os três espaços à direita documentados; revisar o workflow de Pages antes de qualquer publicação; e revisar o diff final em relação ao cronograma.

## 15. Validação local da affordable

**Data:** 23 de setembro de 2026.

Foi instalada a versão Flutter `3.38.0`, com Dart `3.10.0`, correspondente à versão declarada no CI. Na cópia isolada da branch foram executados `flutter pub get`, verificação de formatação, `flutter analyze --no-fatal-infos --no-fatal-warnings`, `flutter test` e `flutter build web --release`.

O resultado foi:

| Verificação | Resultado |
| --- | --- |
| Dependências | concluído; 84 pacotes possuem versões mais novas incompatíveis com as restrições atuais, sem falha de instalação |
| Formatação | a verificação retornou status 1 porque 12 arquivos foram formatados pelo comando; a branch precisa registrar essa normalização ou aceitar o comportamento atual do CI |
| Análise estática | concluída sem falha bloqueadora; foram reportados 33 issues informativos/avisos, incluindo um import não utilizado em `weekly_trends_screen.dart` e APIs depreciadas |
| Testes Flutter | **46 testes passaram** |
| Build Web release | concluído com sucesso; `build/web` foi gerado |

O build Web também apresentou avisos de compatibilidade com o dry-run WebAssembly em dependências (`flutter_secure_storage_web`, `package:js` e `flutter_tts`). Isso não impediu o build JavaScript atual, mas deve ser registrado como limitação técnica da compatibilidade futura com Wasm.

O comando de dependências regenerou arquivos de plugin em Linux, macOS e Windows apenas na cópia local. Essas alterações geradas não representam alteração da branch remota e devem ser descartadas ou tratadas separadamente antes de qualquer diff de integração.

**Conclusão da etapa:** a affordable compila para Web e passa os 46 testes locais, mas não está totalmente limpa do ponto de vista de qualidade: a formatação ainda altera 12 arquivos e existem 33 avisos informativos/diagnósticos. Não há bloqueio de compilação ou teste neste ambiente.

## 16. Segunda validação após ajustes mecânicos

Foi criada a branch local `integration/affordable-to-main-preview`, baseada em `d0af6e2`, para preparar a integração sem tocar na branch remota. Nessa branch foram aplicadas somente alterações mecânicas: formatação dos 12 arquivos apontados e remoção do import Hive não utilizado em `weekly_trends_screen.dart`.

Após os ajustes, foram executados novamente `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze --no-fatal-infos --no-fatal-warnings`, `flutter test` e `flutter build web --release`.

| Verificação | Resultado final |
| --- | --- |
| Formatação | passou; 74 arquivos verificados, 0 alterados |
| Análise estática | passou no modo não fatal; 32 issues informativos/deprecados permanecem, sem falha bloqueadora |
| Testes Flutter | **46 testes passaram** |
| Build Web release | concluído com sucesso |

Os arquivos gerados automaticamente pelos comandos de dependência foram restaurados e não fazem parte das alterações intencionais. A branch local contém apenas as normalizações de código, a remoção do import não utilizado e este documento de continuidade. Ainda não existe commit ou push dessas correções.

**Conclusão da etapa:** a cópia de integração está formatada, analisada, testada e compilada para Web. O próximo passo técnico é revisar o diff dessas correções e decidir como incorporá-las ao fluxo da branch affordable antes do fast-forward da `main`.

## 17. Pré-integração publicada para revisão

Foi criada a branch local `integration/affordable-to-main-preview` e registrado o commit `22628ad` (`chore: prepare affordable branch for main integration`). O commit contém as normalizações de formatação, a remoção do import não utilizado e este documento de continuidade.

A branch foi enviada ao GitHub sem alterar a `main`. Foi aberto o Pull Request [#27](https://github.com/falacomigocaa-app/fala-comigo/pull/27), com destino `main`, para manter a integração revisável e rastreável. O PR registra os resultados de formatação, análise, 46 testes e build Web.

**Estado:** aguardando a revisão final do diff e dos checks do PR. O merge não foi executado. A publicação do site via GitHub Pages continua sendo um efeito separado a revisar antes de qualquer merge na `main`.

Na consulta seguinte, o PR estava `OPEN`, com `mergeStateStatus: CLEAN`, sem conflitos e sem checks remotos listados ainda. A branch local está limpa e o commit local coincide com `origin/integration/affordable-to-main-preview` em `a500f38`.

## 18. Integração concluída na `main`

Em 23 de setembro de 2026, o Pull Request #27 foi mesclado com sucesso na `main`. O merge gerou o commit `5a0d12517557c218b98074347ee578ed1a710a95`. A branch `main` local foi atualizada para esse commit e está limpa, alinhada com `origin/main`.

Após o merge, foram disparados dois workflows no GitHub Actions para o novo commit: `Flutter quality checks` e `Publicar site institucional`. No momento deste registro, ambos estavam `in_progress`; os resultados finais ainda precisam ser verificados quando concluírem.

O endpoint de GitHub Pages retornou `404 Not Found` antes do merge, indicando que Pages ainda não estava configurado no repositório. Portanto, o workflow do site foi disparado, mas a publicação pública definitiva depende da configuração do Pages e de sua conclusão com sucesso.

**Estado da integração:** código da affordable incorporado à `main`; merge concluído; nenhum dado clínico, cobrança ou portal conectado foi ativado. Pendência imediata: confirmar os resultados dos workflows pós-merge e, se necessário, corrigir somente problemas de CI ou de configuração do site.

## 19. Pós-merge — falha de configuração do GitHub Pages

O workflow `Publicar site institucional` do commit `5a0d125` foi executado e falhou na etapa `actions/configure-pages@v5`. O log informa `Get Pages site failed` e confirma que o repositório ainda não tem GitHub Pages habilitado para publicação por GitHub Actions. A API de Pages também retornou `404 Not Found`.

Isso não representa falha do aplicativo Flutter nem do código integrado. O workflow está preparado para publicar o diretório `site/`, mas a ativação do Pages é uma mudança de publicação externa e deve ser feita separadamente, com confirmação explícita antes de tornar o site público. Não foi ativado automaticamente.

O workflow `Flutter quality checks` do commit `41956c3` estava em andamento no momento deste registro. O resultado deve ser verificado antes de declarar a validação pós-merge completamente encerrada.

## 20. GitHub Pages habilitado

O proprietário confirmou manualmente a configuração correta em **Settings → Pages**. A fonte está definida como `GitHub Actions`, com branch `main` e caminho `/`. A API passou a confirmar a configuração e forneceu a URL pública:

<https://falacomigocaa-app.github.io/fala-comigo/>

O workflow `Publicar site institucional` foi solicitado novamente após a ativação do Pages e concluiu com sucesso. A URL pública respondeu HTTP 200 e exibiu o título `Fala Comigo — Comunicação que respeita o seu tempo`:

<https://falacomigocaa-app.github.io/fala-comigo/>

**Conclusão:** o GitHub Pages está habilitado e o site institucional está publicado com sucesso. A publicação não ativa cobrança, portal clínico ou sincronização de dados; ela publica somente os arquivos estáticos versionados em `site/`.

## 21. Próxima fase — matriz de fluxos críticos

Foi criada a matriz executável `docs/MATRIZ_FLUXOS_CRITICOS.md` na branch `qa/critical-flow-matrix`. Ela organiza 24 fluxos, relaciona cada um aos testes automatizados existentes e separa as validações que ainda exigem celular, tablet, iOS, leitor de tela ou observação humana.

A matriz registra a evidência atual de 46 testes Flutter e build Web aprovado. Os fluxos mais importantes ainda classificados como parciais ou pendentes manuais incluem primeira execução, grade CAA, modos de toque, frases, PIN, sessão parental, mídia, alertas, exclusão, acessibilidade e testes em Android real.

O próximo ciclo deve começar por um celular Android e um tablet Android, usando dados sintéticos e sem internet, antes de qualquer nova construção de portal, sincronização clínica ou cobrança.

## 12. Atuação multidisciplinar da assistência

Para a continuação deste projeto, a assistência atuará de forma integrada nas seguintes responsabilidades:

| Área | Responsabilidades aplicadas |
| --- | --- |
| Arquitetura e backend | Solutions Architect, Software Architect, Principal Backend Engineer e Staff API Specialist: arquitetura, contratos, segurança, autorização, persistência, integração futura e limites do backend. |
| Web e mobile | Senior Web Engineer, Staff Mobile Engineer — iOS e Staff Mobile Engineer — Android: Flutter, Web, Android, iOS, builds, compatibilidade, permissões, armazenamento e uso offline. |
| Design | Head of Design, Product Design Lead, Design System Architect e Senior UX/UI Designer: acessibilidade, hierarquia visual, consistência, design system, fluxos e experiência da criança e do responsável. |
| Produto | Technical Product Manager e Product Owner: escopo, prioridades, cronograma, critérios de aceite, decisões de produto e preservação da sequência planejada. |
| Qualidade | QA Automation Engineer: estratégia de testes, testes de regressão, testes de negação, CI, revisão de risco e critérios de pronto. |

Essa atuação significa que cada alteração será analisada por mais de uma perspectiva antes de ser considerada pronta. A documentação, o diff, os testes, a acessibilidade, a privacidade e o impacto no cronograma serão avaliados conjuntamente.

As validações que não podem ser inventadas ou substituídas por análise de código continuarão explícitas: teste em celular e tablet reais, observação com famílias e profissionais, revisão jurídica ou regulatória, confirmação de decisões comerciais e aprovação para publicação ou cobrança.

## 22. Validação técnica pós-merge da `main`

Após a integração da matriz, a `main` foi validada novamente com Flutter `3.38.0`. A formatação verificou 74 arquivos sem alterações, a análise estática terminou sem falha bloqueadora com 32 issues informativos/deprecados, **46 testes passaram** e `flutter build web --release` concluiu com sucesso.

Os arquivos gerados automaticamente durante `flutter pub get` foram restaurados, deixando a cópia local da `main` limpa. A sessão possui somente um dispositivo Linux desktop; não há celular ou tablet Android conectado, `adb devices` não encontrou dispositivos e não existem ferramentas iOS disponíveis. Portanto, F21, F22 e F23 da matriz continuam pendentes de execução física.

**Próximo gate:** executar F01–F17 em um celular Android e um tablet Android, começando offline e usando dados sintéticos. O resultado deve ser registrado na `MATRIZ_FLUXOS_CRITICOS.md` antes de iniciar portal conectado, sincronização clínica ou cobrança.

## 23. APK debug para teste Android

Foi instalado o Android SDK Command-line Tools oficial, platform-tools, plataforma Android, build-tools, NDK e JDK 21. O primeiro build revelou dois problemas no projeto Android: o plugin `org.jetbrains.kotlin.android` não estava aplicado no módulo e a regra de assinatura executava `error()` durante a configuração mesmo em builds debug.

Na branch `fix/android-kotlin-plugin`, foram aplicadas correções mínimas em `android/app/build.gradle.kts`: aplicação explícita do plugin Kotlin e exigência de `key.properties` somente quando uma tarefa de release é solicitada. O build `flutter build apk --debug` foi concluído com sucesso.

O APK resultante tem aproximadamente 152 MB e SHA-256 `e3e3592ecf36f1118b2e15e34ed13d6aa044d7e04c04c36f48afdc52e0a0b3bb`. O roteiro de instalação por USB/ADB e a ficha de testes estão em `docs/ANDROID_TESTE_DEBUG.md`. Nenhum aparelho Android estava conectado nesta sessão; a instalação e os fluxos ainda precisam ser executados pelo teste físico.

**Próximo passo:** revisar o PR da correção Android, integrar somente após o CI, e instalar o APK debug em um celular e um tablet Android usando dados sintéticos e conectividade controlada.

## 24. Correção Hive validada no APK

O primeiro APK debug apresentou em aparelho Android o erro `HiveError: The box "pictogram_cards" is already open and of type Box<dynamic>`. A correção abriu a caixa como `Box<PictogramCard>` e tornou genérico o serviço de abertura/migração de caixas seguras.

A validação automática da correção passou: análise estática, testes Flutter e `flutter build apk --debug`. O novo APK tem aproximadamente 152 MB e SHA-256 `b3baeb02271501953ee212a4bf0f05816fa557dfeb351d2fa52923b435361d70`.

O APK corrigido está fora do Git e deve ser instalado como uma nova versão de teste. A execução humana no Android — tocar, navegar, conceder permissões, testar voz, mídia, offline e acessibilidade — depende do aparelho do responsável e não pode ser simulada ou declarada como concluída pelo ambiente de desenvolvimento.

## 25. Redesign da Área do Responsável e confiabilidade P0

**Data:** 23 de setembro de 2026.
**Branch:** `feat/parental-dashboard-reliability`, baseada na branch com a correção Hive/Android.

A equipe auditou cinco áreas: temas, alertas/lembretes, Novo Cartão, dashboard parental e orientação. A auditoria concluiu que a tela branca do Novo Cartão vinha do `Spacer` dentro de `SingleChildScrollView`; alertas não tinham contrato de data única, permissões/estado visível, inicialização iOS ou fila de cold start; a Activity Android estava fixada nativamente em paisagem; e a Área do Responsável era uma lista longa apesar de já possuir recursos suficientes para um dashboard.

Alterações implementadas nesta branch:

- criado `lib/core/services/app_orientation_service.dart` com preferência local vertical/paisagem em `app_settings`;
- `main.dart` aplica a preferência salva e processa payload de alerta depois da primeira frame;
- removido `android:screenOrientation="landscape"` do Manifest para não impedir a escolha vertical;
- `SettingsScreen` recebeu hero de **Localização & Segurança**, prévia visual sem posição falsa, cards 2x2 de Tendências, PDF, Diário de Vídeo e Rotina Visual, e ação **Novo cartão** no cabeçalho;
- localização foi documentada como módulo futuro web autenticado, dependente de consentimento, permissão no aparelho da criança, transporte seguro e auditoria;
- `AddCardScreen` não usa mais `Spacer` no scroll, aguarda o salvamento, impede toque duplo, trata erro e só fecha após sucesso;
- `CardsNotifier` usa o maior `order` + 1 e `updateCard` atualiza `isCustomImage`;
- `TransitionAlertService` passou a preservar payload de cold start até o callback existir e recebeu inicialização/detalhes Darwin básicos;
- criado `docs/REDESIGN_AREA_PARENTAL.md` com arquitetura, decisões, comandos e checklist para continuidade.

Comandos executados:

```bash
git switch -c feat/parental-dashboard-reliability
dart format lib/main.dart lib/core/services/app_orientation_service.dart lib/core/services/transition_alert_service.dart lib/features/aac_grid/data/providers/cards_provider.dart lib/features/parental_area/presentation/screens/add_card_screen.dart lib/features/parental_area/presentation/screens/settings_screen.dart
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build apk --debug
```

A primeira validação encontrou e corrigiu dois erros estruturais de edição: marcador `EOF` no serviço de orientação e chave fora da classe `SettingsScreen`. A segunda validação terminou com código 0: análise, testes e build APK passaram.

Artefato local da validação:

```text
/home/ubuntu/fala-comigo-parental-dashboard.apk
SHA-256: 1cbf5282c0673e5b93094fc68998377613cab8aa2927f79ec4039cfbb97230c6
```

Pendências que permanecem abertas e não devem ser declaradas prontas:

- instalar e testar o APK em celular e tablet reais;
- validar alertas com app aberto, background, encerrado, tela bloqueada, permissões negadas, reboot e diferentes fabricantes;
- finalizar data única, recorrência, timezone e IDs persistentes de alertas;
- testar contraste, font scale, TalkBack/VoiceOver e reduced motion;
- integrar localização real somente depois de definir backend web autenticado, consentimento e auditoria;
- revisar o PR/CI antes de qualquer merge na `main`.

**Ponto de retomada:** ler `docs/REDESIGN_AREA_PARENTAL.md`, este capítulo e `docs/ANDROID_TESTE_DEBUG.md`; confirmar `git status`, executar o CI da branch e continuar pelo teste físico. Não usar mapa com localização inventada e não prometer full-screen no iOS ou no Android sem permissões e evidência do sistema.

## 26. Correção do Novo Cartão com câmera após retorno ao PIN

**Data:** 23 de setembro de 2026.
**Branch:** `feat/parental-dashboard-reliability`.

Foi relatado que escolher imagem da galeria funciona, mas ao escolher **Tirar Foto**, confirmar a foto e retornar, o app entrava novamente na tela do PIN e o cartão era perdido. A causa provável é o comportamento conhecido do Android: enquanto a câmera externa está aberta, o sistema pode destruir/recriar a Activity do Flutter. O `image_picker` entrega esse resultado perdido por `retrieveLostData()`; antes desta correção o app não recuperava esse resultado.

Correção implementada em `lib/features/parental_area/presentation/screens/add_card_screen.dart`:

- chamada de `_picker.retrieveLostData()` no início da tela;
- persistência da imagem recuperada no armazenamento privado cifrado já existente;
- rascunho em `Hive.box('app_settings')` para imagem, nome e categoria;
- recuperação do rascunho mesmo que o responsável precise passar novamente pela tela do PIN;
- limpeza do rascunho somente depois que o cartão foi salvo com sucesso;
- tratamento tolerante de erro: se a recuperação falhar, o rascunho anterior permanece disponível.

Validação executada:

```bash
dart format lib/features/parental_area/presentation/screens/add_card_screen.dart
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build apk --debug
```

Todos terminaram com código 0. Novo APK:

```text
/home/ubuntu/fala-comigo-camera-fix.apk
SHA-256: 675df3e39955d5a576a9aa3b9f8d06c75e522b2aaf1041904750a2c9b135cd15
```

Teste humano obrigatório no Android:

1. instalar o APK novo;
2. entrar na Área do Responsável pelo PIN;
3. tocar em **Novo cartão**;
4. preencher o nome antes de abrir a câmera;
5. escolher **Tirar Foto**;
6. tirar e confirmar a foto;
7. se o PIN aparecer, informar o PIN e voltar a **Novo cartão**;
8. confirmar que a foto e o nome continuam preenchidos;
9. salvar o cartão;
10. sair do painel e verificar o cartão na grade infantil;
11. repetir cancelando a câmera e repetindo com galeria.

O ambiente não possui um celular Android conectado, portanto a correção automática foi validada por análise/testes/build, mas o comportamento final de câmera precisa ser confirmado no aparelho real.

## 27. Protótipo comparativo da Área do Responsável em HTML/Tailwind

**Data:** 23 de setembro de 2026.
**Arquivo:** `docs/prototypes/area-responsavel-3-opcoes.html`.

Foi criado um protótipo navegável, responsivo e autocontido em HTML com Tailwind CSS via CDN para comparar três direções de design antes da implementação final em Flutter:

- **Opção A — Dashboard Moderno:** cards bem definidos, fundo suave, hero de localização, mapa demonstrativo, status de bateria/atualização, progresso visual e cards 2x2;
- **Opção B — Minimalista/Clean:** tipografia com bastante espaço em branco, linhas sutis, ícones discretos e menor densidade visual;
- **Opção C — Visual com Abas:** abas superiores `Segurança`, `Rotina` e `Configurações`, com cada contexto concentrando seus próprios controles.

Todas as opções contêm Localização em Tempo Real demonstrativa, botão de histórico de trajeto, bateria, última atualização, Relatórios em PDF, Tendências Semanais, Diário de Vídeo, Rotina Visual Diária, ajustes de tamanho dos botões, comportamento de voz/texto e ação `Novo Cartão` no cabeçalho.

O protótipo usa dados fictícios e deixa explícito que localização real depende de consentimento, aparelho conectado e backend seguro. Não deve ser interpretado como implementação de rastreamento.

Comportamentos interativos implementados:

- troca entre modelos A, B e C;
- abas internas da Opção C;
- sliders de tamanho dos botões;
- radio buttons de comportamento de toque;
- estados de foco acessíveis e layout responsivo.

**Ponto de decisão:** escolher uma direção visual antes de transformar os componentes em widgets Flutter reutilizáveis. A recomendação inicial da equipe é usar a hierarquia da Opção A, o respiro tipográfico da Opção B e as separações contextuais da Opção C.
