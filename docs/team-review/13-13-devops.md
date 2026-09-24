# Revisão de CI e releases — DevOps

**ID:** 13-13  
**Papel:** DevOps Engineer  
**Data da revisão:** 24 de setembro de 2026  
**Escopo:** CI, empacotamento Android, assinatura, evidências de release e o relato de que o APK instala, mas fecha ao abrir.  
**Alterações de código:** nenhuma. Foi criado somente este relatório.

## Resumo executivo

O projeto **compila**: os relatórios registram sucesso para formatação, análise Flutter, 84 testes, Web release, APK debug, APK release, AAB release e uma reconstrução limpa. Há também artefatos locais presentes no workspace, incluindo `app-release.apk` de 57.279.118 bytes e `app-release.aab` de 45.023.814 bytes. Isso demonstra uma linha de empacotamento funcional, mas **não demonstra que a inicialização funciona em um aparelho Android real**.

A reclamação operacional — instalar e fechar ao abrir — deve ser tratada como falha de runtime ainda não diagnosticada. **Não existe logcat do aparelho nesta revisão** e não há evidência válida de execução do APK no AVD: o relatório registra que o `system_server` do emulador morreu antes da instalação. Portanto, não é responsável atribuir a causa a TTS, notificações, Hive, armazenamento seguro ou a uma versão específica do Android. A mudança que posterga TTS/notificações reduz uma hipótese plausível, mas não a confirma.

O CI GitHub atual valida Flutter/Web, testes e uma política textual de assinatura, mas **não constrói Android**. O workflow Android está no Codemagic, condicionado à keystore externa e sem evidência de execução nesta revisão. O branch avaliado é `work/qa-observability-and-emulator` no commit `c8fcab1`; não há execução do GitHub Actions para esse branch e não foi localizada PR aberta para ele. A `main` possui execuções anteriores verdes, mas isso não valida automaticamente o commit sob revisão.

**Decisão recomendada:** manter o APK como build de diagnóstico/teste controlado, bloquear publicação ampla e o envio do AAB até obter validação limpa em aparelho físico (celular e tablet), com logcat caso o fechamento persista, e até revisar os gates de segurança e assinatura de produção.

## Evidências e fatos verificados

| Área | Fato verificável | Fonte/evidência |
|---|---|---|
| Estado Git | HEAD é `c8fcab1` em `work/qa-observability-and-emulator`, alinhado ao remoto; o workspace tinha apenas `docs/team-review/` não rastreado antes deste relatório | `git status`, `git show`, `git branch` |
| Builds | Os relatórios registram formatação, análise não fatal, 84 testes, Web release, APK debug/release, AAB release e build limpa aprovados | [`RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md`](../RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md), [`ENTREGA_MVP_2026-09-24.md`](../ENTREGA_MVP_2026-09-24.md) |
| Artefatos locais | APK debug: 159.322.506 bytes; APK release: 57.279.118 bytes; AAB release: 45.023.814 bytes. Hashes locais: release APK `310b47377933f970b763d5fa9ce2de088d20b512ffdd79c49ea0effa50323503`; debug APK `44d6790182edd2b3a1bc80f2439d17ef95471e7d51e66e7c870e183bb5064358`; AAB `d8661182e394688f646ec188f824610815cedb67e6c0945b942b0b062b513f62` | `build/app/outputs/...`, `sha256sum` |
| Metadados reportados | `applicationId` `com.falacomigo.fala_comigo`, `versionName` `1.0.0`, `versionCode` `1`, `minSdk` 24, `targetSdk`/`compileSdk` 36 | [`RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md`](../RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md), `android/app/build.gradle.kts` |
| Assinatura | A build local de diagnóstico usa chave temporária; a release de produção depende de keystore externa do Codemagic. `android/key.properties`, `.jks` e `.keystore` estão ignorados e não aparecem como arquivos rastreados | [`AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md`](../AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md), `codemagic.yaml`, `.gitignore` |
| CI GitHub | `flutter.yml` dispara em `main`, `feat/**` e PR para `main`; executa `pub get`, `dart format`, análise, testes e Web release. Não executa APK/AAB Android | `.github/workflows/flutter.yml` |
| CI atual | Não foi encontrada execução para `work/qa-observability-and-emulator` ou para `c8fcab1`. Há execução verde histórica da `main` em [run 35961523100](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/35961523100), no commit `ee07118`, que não é o HEAD analisado | `gh run list` |
| Codemagic | `codemagic.yaml` define `android-release` com Flutter 3.38.0, análise, testes, APK e AAB assinados, além de `web-release`; exige a identidade `fala-comigo-release` | [`codemagic.yaml`](../codemagic.yaml), [`BUILDS_CODEMAGIC.md`](../BUILDS_CODEMAGIC.md) |
| MobSF | O workflow é manual (`workflow_dispatch`) e cria chave efêmera para APK de teste. Os documentos registram varredura anterior com score 46, 2 achados altos, 5 warnings, 1 informação e 1 hotspot de permissões; o relatório bruto referenciado não está presente no caminho indicado | [plano MASVS/MobSF](../PLANO_SEGURANCA_OWASP_MASVS_MOBSF.md), [`RELATORIO_CONTINUIDADE_2026-09-24.md`](../RELATORIO_CONTINUIDADE_2026-09-24.md) |
| Runtime Android | O relato de fechamento no telefone não tem logcat nesta revisão. O AVD falhou antes de executar o APK: perdeu o serviço `package` e encerrou o `system_server` | [`RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md`](../RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md), [`AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md`](../AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md) |

A diferença entre APK debug (~159 MB) e release (~57 MB) é compatível com variantes distintas e, sozinha, **não prova perda de telas, assets ou plugins**. Os builds locais foram feitos com chave temporária, não com a identidade de produção.

## Achados de CI e release

### 1. O gate GitHub não cobre Android — risco alto de regressão de release

O workflow obrigatório de GitHub termina em `flutter build web --release`. Não há `flutter build apk --release`, `flutter build appbundle --release`, instalação, smoke test Android, verificação de metadados ou validação do AAB. A política existente apenas procura uma referência textual a assinatura debug; ela não substitui a prova de que o build Android foi assinado com a identidade correta.

O Codemagic cobre o empacotamento Android, mas é um fluxo separado e depende de configuração externa. Assim, uma alteração pode passar no GitHub sem produzir uma confirmação Android para o commit. **Ação:** adicionar um gate Android não-distributivo ao CI ou tornar o Codemagic obrigatório como check de PR/release, sem expor a keystore. O gate deve verificar pelo menos build APK/AAB, versão, `applicationId`, assinatura esperada e retenção dos artefatos.

### 2. O branch de trabalho atual não recebe push CI pelo trigger declarado

O trigger de push aceita somente `main` e `feat/**`; o branch atual começa com `work/`. Como não existe execução encontrada para `c8fcab1` e não foi localizada PR aberta para esse branch, os resultados de `main` são históricos e não devem ser chamados de validação deste commit. **Ação:** abrir PR para `main` ou ajustar conscientemente os triggers para os padrões de branches de trabalho. Não declarar “CI verde” para `c8fcab1` sem uma execução que contenha esse SHA.

### 3. Formatação no CI pode mascarar alterações

`dart format lib test` modifica o workspace do runner, mas não usa `--set-exit-if-changed`. O job pode terminar verde mesmo que o branch contenha arquivos que precisariam de normalização. **Ação:** usar um check não mutante (`dart format --output=none --set-exit-if-changed lib test`) ou publicar a normalização como commit separado. Isso melhora reprodutibilidade e evita diferenças entre artefato local e CI.

### 4. Codemagic está preparado, mas a produção ainda não está comprovada

O Gradle falha de propósito quando `android/key.properties` não existe e usa a configuração de release somente quando as propriedades estão presentes. Isso é uma proteção correta contra fallback para debug. Contudo, não há nesta revisão um log de execução Codemagic, fingerprint da keystore de produção, ou confirmação do AAB assinado pela identidade `fala-comigo-release`. **Ação:** executar o workflow em branch/commit definido, conferir o fingerprint esperado fora do repositório e arquivar o log/metadata não sensível. Não confundir o APK local temporariamente assinado com a release de loja.

### 5. Versão e documentação de release estão inconsistentes

`pubspec.yaml` permanece em `1.0.0+1`; o procedimento Codemagic lembra corretamente que o `versionCode` deve ser incrementado para cada publicação. O README ainda descreve `applicationId` `com.falacomigo.caa` e `targetSdk` 35, enquanto o Gradle e os relatórios atuais usam `com.falacomigo.fala_comigo` e SDK 36. O handoff e alguns relatórios também preservam branches/commits históricos. **Ação:** atualizar README, instruções Codemagic e handoff para uma única fonte de verdade antes de distribuir; confirmar `versionCode` novo antes de qualquer upload à Play.

### 6. Segurança é um gate separado e ainda bloqueante

O checklist registra achados altos do MobSF e a política do projeto diz que achados altos bloqueiam distribuição. O scan é manual, usa `latest` do container MobSF e APK com chave efêmera; portanto, ele não é um check automático de PR nem representa assinatura de produção. Sem o relatório bruto no caminho referenciado, não foi possível revalidar os achados nesta sessão. **Ação:** preservar o JSON/PDF e SHA do scan, repetir no APK atual após cada correção, decidir formalmente CBC/Hive e `minSdk=24`, e executar análise dinâmica/revisão MASVS/MASTG antes de um piloto com dados reais.

## APK fecha ao abrir: fatos, riscos e hipóteses

### Fatos

1. O build e os testes automatizados reportados passaram; isso não equivale a teste de inicialização em aparelho.
2. A instalação no aparelho é um relato operacional recebido e o fechamento permanece sem causa identificada; **não há logcat disponível**.
3. O AVD usado na tentativa anterior não é evidência de crash do app, pois o Android interno morreu antes da instalação.
4. O código atual chama `runApp` antes de iniciar a rotina assíncrona de bootstrap e posterga TTS/notificações para depois da primeira tela. A rotina crítica ainda aguarda orientação, `Hive.initFlutter`, registro do adapter, abertura/migração de caixas protegidas e população inicial antes de marcar o app como pronto.
5. A tela de falha e os handlers Dart capturam falhas que chegam ao Flutter; eles não capturam um processo nativo morto antes da execução do engine/Dart.

### Riscos técnicos

- **Alto:** não há smoke test Android real reproduzível nem logcat do aparelho afetado; o release gate de runtime está aberto.
- **Médio/alto:** o caminho crítico depende de `flutter_secure_storage`/Android Keystore, Hive cifrado e migração de caixas antes de liberar a tela CAA; diferenças de aparelho, estado de dados ou restauração podem atingir exatamente a primeira abertura.
- **Médio:** permissões, receivers, notificações em tela cheia, alarmes exatos e orientação paisagem aumentam a superfície de compatibilidade, embora não constituam evidência de crash.
- **Médio:** instalação sobre versão anterior, dados locais antigos ou assinatura diferente podem produzir comportamento distinto de uma instalação limpa.

### Hipóteses, não causas confirmadas

As hipóteses que devem ser testadas por logcat são: (a) falha Dart/plugin durante armazenamento seguro ou migração Hive; (b) crash nativo de plugin ou do Android antes do Flutter; (c) incompatibilidade de fabricante/API; (d) dados antigos incompatíveis; (e) instalação sobre assinatura/estado anterior; ou (f) falha posterior na primeira tela. TTS e notificações eram uma hipótese plausível porque antes participavam da inicialização, mas foram postergados; **não existe evidência para afirmar que eram a causa**.

### Próximo procedimento de diagnóstico

1. Obter o APK release exato instalado e registrar SHA-256, `versionName`, `versionCode`, fabricante/modelo, versão/API do Android e horário aproximado.
2. Desinstalar completamente a versão anterior, reiniciar o aparelho e instalar a build release novamente, sem restaurar dados.
3. Abrir primeiro offline e observar se aparece a tela de diagnóstico Dart ou se o processo desaparece sem UI.
4. Se fechar, coletar o logcat imediatamente no aparelho, filtrando `AndroidRuntime`, `FATAL EXCEPTION`, `flutter`, `libc`, `system_server` e o pacote `com.falacomigo.fala_comigo`. Enviar somente o trecho técnico sanitizado; não incluir conteúdo de criança, fotos, frases ou tokens.
5. Repetir em pelo menos um celular e um tablet. Só então classificar a causa e escolher correção. **Não usar o AVD sem aceleração como substituto desta evidência.**

## Ações priorizadas

| Prioridade | Ação | Critério de saída |
|---|---|---|
| P0 | Executar teste limpo no aparelho físico afetado e coletar logcat se fechar | Causa reproduzida e classificada como Dart, plugin/nativa, dados ou compatibilidade |
| P0 | Bloquear publicação do AAB/APK até F01, F21 e F22 da matriz manual estarem evidenciados | Celular e tablet passam primeira abertura, offline e fluxos críticos |
| P0 | Produzir execução CI/Codemagic para o SHA candidato, com APK/AAB e assinatura verificáveis | Check rastreável ao commit, fingerprint confirmado e artefatos arquivados |
| P1 | Fazer o GitHub falhar por formatação não registrada e cobrir build Android não-distributivo | PR não passa sem formato limpo e build Android mínima |
| P1 | Repetir MobSF no artefato atual e fechar achados altos, `minSdk`, permissões e revisão dinâmica | Relatório revisado, decisões documentadas e sem gate alto aberto |
| P1 | Atualizar README, handoff e documentação Codemagic para branch, pacote, SDK e versão atuais | Uma única instrução operacional sem `applicationId`/branch obsoletos |
| P2 | Revisar os artefatos rastreados em `latest/` e separar SDK/artefato gerado do código | Clone e CI menores, com setup reproduzível documentado |

## Conclusão e confiança

A conclusão DevOps é **“build saudável, release ainda não validado em runtime”**. O pipeline de compilação não explica o fechamento ao abrir; tampouco o AVD fornece evidência válida. O risco principal é liberar um artefato que compila e instala, mas falha em dispositivos reais, ou declarar o commit atual coberto por CI quando ele não possui execução correspondente. A causa do crash deve permanecer **indeterminada até o logcat do aparelho**.

**Confiança:** alta para fatos de configuração, estado Git, artefatos locais e limites dos workflows; média para a leitura dos relatórios históricos (alguns registram 46 testes e branches antigas, enquanto o handoff atualizado registra 84); baixa para qualquer hipótese causal do fechamento, deliberadamente não confirmada sem logcat.

## Referências

- [`PROJECT_HANDOFF.md`](../../PROJECT_HANDOFF.md)
- [`AGENTS.md`](../../AGENTS.md)
- [`RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md`](../RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md)
- [`AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md`](../AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md)
- [`CHECKLIST_EXECUCAO_E_TESTES.md`](../CHECKLIST_EXECUCAO_E_TESTES.md)
- [`CHECKLIST_PRE_LANCAMENTO.md`](../CHECKLIST_PRE_LANCAMENTO.md)
- [`BUILDS_CODEMAGIC.md`](../BUILDS_CODEMAGIC.md)
- [`MATRIZ_FLUXOS_CRITICOS.md`](../MATRIZ_FLUXOS_CRITICOS.md)
- [`codemagic.yaml`](../../codemagic.yaml)
- [GitHub Actions — Flutter quality checks](https://github.com/falacomigocaa-app/fala-comigo/actions/workflows/flutter.yml)
- [GitHub Actions — MobSF scan](https://github.com/falacomigocaa-app/fala-comigo/actions/workflows/mobsf-security-scan.yml)
