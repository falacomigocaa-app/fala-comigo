# LEIA PRIMEIRO — Continuidade obrigatória do Fala Comigo

O manual completo para iniciar outro agente está em [`MANUAL_CONTINUIDADE_MESTRE.md`](MANUAL_CONTINUIDADE_MESTRE.md). Ele pode ser copiado integralmente para uma nova conversa. O prompt histórico [`PROMPT_RETORNO_NOVO_AGENTE.md`](PROMPT_RETORNO_NOVO_AGENTE.md) continua preservado para consulta.

> **Não alterar a `main` diretamente.** Antes de executar qualquer correção, leia este arquivo, `AGENTS.md`, `PROJECT_HANDOFF.md` e `docs/HANDOFF_TELA_BRANCA_APK.md`.

## Estado imediato em 25/09/2026 — integração concluída

A integração foi mesclada na `main` pela PR 67, com commit `7aa12f5`. O CI pós-merge e o deploy do GitHub Pages terminaram com sucesso. Foram aprovados 92 testes Flutter locais, o build Web release e o APK debug local. A branch `integration/finalize-project` foi preservada para auditoria.

Para uma nova demanda, o agente deve analisar primeiro e pedir confirmação somente antes de merge, publicação, release, cobrança, alteração de acesso ou outra ação irreversível. Decisões técnicas locais e reversíveis podem ser executadas dentro do escopo autorizado.

Após cada demanda, o agente deve comparar o resultado com os agentes anteriores, classificar o estado como resolvido, parcial, pendente, falha conhecida ou novo trabalho, e atualizar este arquivo, `PROJECT_HANDOFF.md` e `docs/CONTINUIDADE_ASSISTENTE_IA.md`. Nenhuma etapa deve ser declarada concluída sem evidência.

### Verificação de layouts — 25/09/2026

As PRs 30, 32, 33 e 66 foram confirmadas como ancestrais da `main` atual em `7aa12f5`; não mesclar novamente. O dashboard parental atual contém as rotas de rotina, diário, alertas, tendências, relatórios, perfil, privacidade, acesso familiar, tarefas compartilhadas e continuidade do cuidado. Um APK foi gerado diretamente da `main` para teste visual; SHA-256 `e5f626b361c16add29a8bf5993df57acbc141b9ef079b4313bb079cdf32b964c`. Ainda falta a comparação em aparelho/emulador real.

O estado histórico abaixo explica a investigação original da tela branca; não deve ser interpretado como se a `main` ainda estivesse sem a correção.

## Estado histórico da tela branca — preservado para contexto

O projeto está em uma branch de correção chamada `fix/main-startup-and-android-build`, baseada na `origin/main` no commit `0d0b685`. A `main` remota não foi alterada nesta retomada.

O problema relatado é: **o APK instala e abre, mas mostra uma tela totalmente branca**. A causa mais provável foi localizada e não é uma mudança de produto: `pictogram_cards` era aberta no bootstrap como `Box<dynamic>`, enquanto a grade exige `Box<PictogramCard>`. O erro Android já observado foi:

```text
HiveError: The box "pictogram_cards" is already open and of type Box<dynamic>
```

A PR 29 contém a correção, mas está `OPEN` e `DIRTY` porque foi criada sobre uma `main` antiga. **Não mesclar a PR 29 inteira.** A correção foi reaplicada seletivamente na branch atual.

A PR 60 adiciona uma tela que mostra a exceção de inicialização em vez de deixar branco, mas está `OPEN` e `DRAFT`. Não foi mesclada. A tentativa de merge foi recusada pelo GitHub por ela ser draft. **Não apagar nem fechar a PR 60 antes de obter o erro real, se a correção Hive não resolver.**

## Correções já preparadas nesta branch

- `lib/main.dart`: `pictogram_cards` abre como `Box<PictogramCard>`.
- `lib/core/services/secure_box_service.dart`: as funções de abertura e migração são genéricas e usam `Hive.openBox<T>`.
- `android/app/build.gradle.kts`: plugin `org.jetbrains.kotlin.android` aplicado.
- Build release continua exigindo `android/key.properties`; não adicionar keystore ou segredo ao Git.
- `docs/HANDOFF_TELA_BRANCA_APK.md`: explicação completa, comandos, evidências e limites.
- `docs/CONTINUIDADE_ASSISTENTE_IA.md`: registro histórico atualizado.

## Próxima ordem obrigatória

1. Não fazer reset, rebase destrutivo, force-push ou exclusão de branch.
2. Executar `git diff --check` e revisar o diff.
3. Confirmar que a branch contém somente a correção seletiva e a documentação.
4. Fazer commit e push da branch.
5. Abrir ou atualizar uma PR contra `main`.
6. Aguardar e revisar CI: formatação, análise, testes e build Web.
7. Executar o workflow `Android test APK artifact` no commit da branch/PR.
8. Baixar o APK, registrar SHA-256 e instalar em aparelho Android real.
9. Classificar o resultado como `abriu`, `falhou com erro visível` ou `não executado`.
10. Só depois decidir se a correção deve entrar na `main`.

Se o ambiente não tiver Flutter/Android SDK, não declarar build local aprovado. Usar CI e informar a limitação. O Codemagic ainda não foi executado nesta retomada; um APK do GitHub Actions não prova que o Codemagic ou a `main` via Codemagic passaram.

## Regra de atualização obrigatória

Ao concluir **cada etapa**, o agente deve atualizar:

1. este arquivo, na seção “Histórico curto”;
2. `docs/HANDOFF_TELA_BRANCA_APK.md`, quando a etapa tratar de APK, Android ou tela branca;
3. `docs/CONTINUIDADE_ASSISTENTE_IA.md`, para manter a sequência histórica;
4. o corpo da PR com comandos, resultados, commit, branch e próximo gate.

Não registrar neste repositório credenciais, tokens, chaves privadas, PINs, fotos, vídeos, nomes completos ou dados clínicos reais.

## Histórico curto

- **25/09/2026:** `origin/main` confirmado em `0d0b685`; PR 29 continua aberta e `DIRTY`; PR 60 continua draft e verde; nenhuma alteração foi perdida.
- **25/09/2026:** causa provável da tela branca identificada na tipagem da caixa Hive; correção seletiva preparada em `fix/main-startup-and-android-build`.
- **25/09/2026:** APK diagnóstico anterior preservado fora do Git; ele foi gerado pelo GitHub Actions na branch de diagnóstico, não pelo Codemagic e não pela `main` atual.
- **25/09/2026:** prompt mestre criado em `PROMPT_RETORNO_NOVO_AGENTE.md`, com leitura obrigatória, regras de preservação, comandos de diagnóstico, validação do APK e formato de atualização passo a passo.

## Comandos de retomada

```bash
git fetch origin --prune
git status --short --branch
git log origin/main -12 --oneline --decorate
git diff --check
gh pr list --repo falacomigocaa-app/fala-comigo --state open
```

## Resultado que ainda não pode ser afirmado

Ainda não se pode afirmar que o APK corrigido abre em aparelho real, que o Codemagic passou, que a `main` foi corrigida ou que o aplicativo está pronto para publicação. Essas afirmações exigem evidência posterior e devem ser registradas neste arquivo.


## Evidência mais recente do build

O workflow `Android test APK artifact` da PR 66 terminou com sucesso no run [36109508895](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/36109508895), usando o commit `abe8633` da branch de correção. O APK foi gerado, verificado pelo `apksigner` e publicado como artefato de teste. SHA-256: `63f3d897f07995baff7262b4f43d691733f0e7c80e25f97988a9bc818b373646`.

Esse resultado confirma somente o build e a integridade estrutural do APK. Ainda falta instalar e abrir o aplicativo em aparelho Android real para confirmar que a grade CAA não permanece branca.
