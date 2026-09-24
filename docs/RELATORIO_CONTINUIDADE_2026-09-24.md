# Relatório de continuidade do projeto Fala Comigo

**Data da avaliação:** 24 de setembro de 2026  
**Branch avaliada:** `main`  
**Commit avaliado:** `ee07118` — `Merge: atualizar estado de segurança`  
**Repositório:** `falacomigocaa-app/fala-comigo`

## 1. Conclusão executiva

O repositório está em uma fase avançada de **MVP offline-first/protótipo funcional**, com uma base Flutter multiplataforma organizada, núcleo de comunicação aumentativa, área parental, alertas de transição, armazenamento local, controles de plano/licença e contratos de autorização para um futuro portal RH. A documentação de continuidade, segurança e piloto está bem desenvolvida, e os últimos checks remotos do GitHub estão verdes.

O projeto, porém, **ainda não está pronto para produção, piloto com dados reais ou sincronização clínica/RH**. As principais razões são: inexistência de backend real no repositório; contratos RH ainda não equivalem a autorização executada no servidor; pendências de segurança apontadas pelo MobSF; ausência de validação manual em dispositivo; decisões abertas sobre criptografia local e `minSdk`; e falta de confirmação local nesta avaliação porque o ambiente atual não possui Flutter/Dart instalados.

A recomendação é continuar em três trilhas ordenadas: **(1) estabilizar e validar o aplicativo local/offline; (2) fechar segurança, privacidade e release Android; (3) somente depois construir backend/portal RH com autorização server-side e testes negativos multi-organização**.

> **Decisão de continuidade:** continuar o projeto, mas manter o produto explicitamente como MVP/protótipo controlado. Não liberar dados clínicos, sincronização RH, cobrança ou distribuição de produção antes dos gates descritos neste documento.

## 2. Evidências da avaliação

| Item | Resultado |
|---|---|
| Árvore de trabalho | Limpa; `main` alinhada com `origin/main` |
| Arquivos rastreados | 380 |
| Código em `lib/` | 59 arquivos |
| Testes em `test/` | 24 arquivos |
| Documentação em `docs/` | 17 arquivos |
| Workflows GitHub | 3 |
| Checks remotos recentes | Sucesso nos workflows de qualidade e publicação do site |
| MobSF | Executado em APK release de teste; score 46, com 2 achados altos, 5 warnings, 1 informação e 1 hotspot de permissões |
| Validação local nesta avaliação | Bloqueada: `flutter` e `dart` não estão instalados no ambiente atual |
| Artefatos grandes rastreados | 104 arquivos sob `latest/`, aproximadamente 147 MB; requer decisão de manutenção |

Os checks remotos verdes comprovam que o pipeline executado no GitHub passou para os commits avaliados. Eles não substituem teste manual em dispositivo, análise dinâmica, revisão jurídica/LGPD, threat model nem validação de backend.

## 3. O que já está pronto ou suficientemente implementado

### 3.1 Aplicativo Flutter e núcleo offline

A estrutura do aplicativo está funcionalmente organizada por camadas de `core`, domínio, dados e apresentação. O núcleo inclui:

- grade de cartões CAA e filtros por categoria;
- barra de frases e síntese de voz;
- rotina visual;
- recompensas de comunicação;
- área parental protegida por PIN e sessão;
- lembretes parentais e tendências semanais;
- alertas e checklist de transição;
- perfil do paciente, configurações e privacidade;
- exportação de dados e serviço de limpeza;
- armazenamento de mídia com caminhos específicos para plataforma e fallback Web;
- controle de acesso por plano/licença, preservando os recursos essenciais offline.

Os testes existentes cobrem boa parte da lógica de domínio e vários fluxos críticos: cartões, semântica da grade, frase, mídia, PIN, sessão parental, alertas, tendências, planos, privacidade e políticas RH.

### 3.2 Controles parentais e privacidade local

Há uma base concreta para o controle parental: PIN, sessão, expiração, bloqueio e limpeza de credenciais. Também existem serviços para apagar dados e exportar informações. Esses componentes têm testes automatizados e são uma boa fundação para o MVP.

Ainda assim, a prontidão não deve ser confundida com conformidade concluída: backup, restauração, troca/perda de dispositivo, retenção, consentimento operacional e resposta a incidentes ainda precisam ser exercitados em procedimento real.

### 3.3 Planos e licença

O `PlanAccessController`, catálogo, armazenamento de licença e máquina de estados foram implementados com testes para estados ativos, transição, suspensão, expiração, revogação e estado desconhecido. A regra central de manter a comunicação e os controles essenciais independentes de licença está alinhada ao posicionamento offline-first.

O que existe é principalmente a **regra local de decisão**. Ainda não existe o serviço remoto que emita, valide, revogue e audite licenças em produção.

### 3.4 Contratos e políticas RH

O repositório já registra políticas importantes para:

- separação entre família, organização e funções RH;
- isolamento por organização;
- acesso elevado com aprovação, finalidade, escopo permitido, expiração e revogação;
- máquina de estados de licença;
- eventos de auditoria minimizados;
- proibição de acesso RH a conteúdo familiar/clínico;
- limiares para dados agregados;
- retenção e redução de dados.

Os testes negativos de autorização e isolamento organizacional são uma base relevante para a futura implementação. A documentação também afirma corretamente que esses contratos não são backend implementado nem parecer jurídico.

### 3.5 CI, build e publicação institucional

O CI cobre dependências, formatação, análise, política de assinatura, testes e build Web. O Codemagic está preparado para build Android assinado via credenciais externas, produzindo APK e AAB. O workflow de GitHub Pages valida e publica o diretório `site/` quando há alteração relevante.

A separação entre chave de produção e chave efêmera usada no scan MobSF foi uma decisão correta. O site institucional e a política de privacidade estão presentes, mas a publicação do site não significa que o aplicativo esteja pronto para distribuição comercial.

### 3.6 Documentação de continuidade

O conjunto de documentos já cobre visão de produto, sequência até build, roadmap full-cycle, matriz de fluxos críticos, checklist pré-lançamento, checklist de piloto RH, contrato de autorização e plano OWASP/MASVS/MobSF. O histórico recente também registra decisões e gates, reduzindo o risco de perder contexto entre agentes ou colaboradores.

## 4. O que ainda falta antes de chamar de MVP validado

### 4.1 Validação técnica reprodutível

Nesta avaliação, a validação local não foi executada porque o ambiente não possui `flutter` nem `dart`. Portanto, não foi possível confirmar localmente `flutter pub get`, `dart format`, `flutter analyze`, `flutter test` ou `flutter build web --release`.

Os checks remotos recentes estão verdes, mas a continuidade deve instalar/reproduzir o ambiente Flutter 3.38.0 e registrar:

1. `flutter pub get`;
2. `dart format --output=none --set-exit-if-changed lib test`;
3. `flutter analyze --no-fatal-infos --no-fatal-warnings`;
4. `flutter test`;
5. `flutter build web --release`;
6. build Android debug e release de teste;
7. teste em pelo menos um dispositivo Android real ou emulador.

Também é necessário decidir se o CI deve apenas formatar o workspace, como hoje, ou falhar quando houver arquivos não formatados. O comportamento atual pode mascarar alterações de formatação não registradas.

### 4.2 Segurança criptográfica do armazenamento local

O relatório MobSF de 24/09/2026 encontrou como achado alto o uso de CBC com padding PKCS5/PKCS7 no código obfuscado relacionado à dependência de armazenamento Hive. Esse achado precisa de decisão técnica explícita.

A correção não deve ser uma troca cega de algoritmo: é necessário definir formato autenticado, gerenciamento de chave, migração dos dados existentes, comportamento quando a migração falhar e teste de recuperação. Depois, deve-se gerar novo APK e repetir MobSF.

### 4.3 Decisão de `minSdk`

O MobSF classificou `minSdk=24` como achado alto. A equipe precisa decidir com base na matriz real de aparelhos do piloto se o mínimo será elevado, provavelmente para uma API mais recente, ou se o suporte antigo será mantido com justificativa de produto e mitigação.

Essa decisão afeta cobertura de usuários e não deve ser feita apenas para melhorar o score do scanner.

### 4.4 Permissões, receivers e armazenamento de arquivos

Ainda precisam ser revisados no APK e no Manifest final:

- `ProfileInstallReceiver` e sua permissão/exportação;
- permissões de câmera, áudio, notificações e mídia;
- escrita/leitura em armazenamento externo;
- arquivos temporários de gravação, impressão ou PDF;
- limpeza e retenção de mídias privadas;
- falsos positivos de strings sensíveis encontrados pelo MobSF.

A regra deve ser solicitar permissões no contexto, usar armazenamento privado por padrão e compartilhar arquivos somente por mecanismo controlado, como `FileProvider` quando aplicável.

### 4.5 Teste manual dos fluxos críticos

A documentação já possui matriz e folha de execução manual, mas o repositório não demonstra nesta avaliação que todos os cenários foram executados em dispositivo. Antes do piloto, registrar evidências para:

- primeira abertura e onboarding;
- comunicação sem internet;
- bloqueio e desbloqueio parental;
- expiração de sessão;
- criação, edição e exclusão de alertas;
- mídia e permissões negadas;
- exportação e limpeza;
- mudança de plano/licença;
- atualização do aplicativo preservando dados;
- perda/troca de dispositivo, se esse fluxo fizer parte do piloto;
- acessibilidade básica, contraste, semântica, foco e tamanho de toque.

### 4.6 Backend e portal RH ainda não existem como produto conectado

O código atual não apresenta cliente de API, autenticação remota, banco de dados de servidor, sincronização, OAuth, portal RH funcional ou enforcement server-side. Existem contratos, modelos e políticas de referência.

Essa distinção é crítica: regras locais no Flutter não protegem dados se um backend futuro aceitar operações sem repetir autorização. O backend só deve ser iniciado após fechar o contrato de dados e os testes de negação.

### 4.7 LGPD, governança e piloto com dados reais

Ainda faltam, fora do código:

- definição formal do controlador/operador e responsabilidades;
- base legal, consentimento quando aplicável e registro de decisões;
- política de retenção e descarte operacional;
- procedimento de incidente e suporte;
- backup/restauração testados;
- aprovação de responsável técnico e revisão jurídica;
- threat model e revisão manual MASVS/MASTG;
- critérios de inclusão, exclusão e encerramento do piloto;
- dados sintéticos e processo para impedir fixtures reais no ambiente de teste.

## 5. Riscos prioritários

| Prioridade | Risco | Impacto | Próxima ação |
|---|---|---|---|
| P0 | Liberar backend/RH sem autorização server-side e isolamento multi-organização | Exposição de dados familiares/clínicos | Não iniciar sincronização real; implementar testes negativos antes dos endpoints |
| P0 | Considerar o APK MobSF como aprovado apesar do score 46 e achados altos | Falsa sensação de segurança | Corrigir ou aceitar formalmente cada achado, repetir scan e executar análise dinâmica |
| P0 | Usar dados reais no piloto sem LGPD, suporte, retenção e incidente definidos | Risco jurídico e operacional | Manter piloto controlado com dados sintéticos até aprovação formal |
| P1 | Criptografia local sem decisão de migração/autenticidade | Perda ou exposição de dados locais | Escolher formato autenticado, implementar migração e testar upgrade |
| P1 | `minSdk=24` sem decisão de produto | Exposição a base Android vulnerável ou perda de usuários | Levantar matriz de dispositivos e registrar decisão |
| P1 | Falta de teste manual em dispositivo | Falhas em permissões, mídia e ciclo de vida | Executar matriz manual e anexar evidências |
| P1 | 147 MB de artefatos sob `latest/` rastreados | Repositório pesado e manutenção confusa | Confirmar se é SDK necessário; retirar do Git se for artefato gerado e documentar setup |
| P2 | CI formata arquivos sem exigir árvore limpa | Mudanças de estilo podem passar sem serem registradas | Trocar por check de formatação ou gerar commit explícito de normalização |
| P2 | Avisos/depreciações do Android/Gradle/Kotlin | Custo de atualização e possível quebra futura | Planejar migração para o modelo de Kotlin/AGP recomendado pela versão usada |

## 6. Plano recomendado para continuar

### Fase A — Fechar a linha de base do app

1. Preparar ambiente reproduzível com Flutter/Dart 3.38.0.
2. Executar e registrar os cinco checks Flutter e os builds Web/Android.
3. Corrigir formatação, imports não usados e avisos de baixo risco sem alterar comportamento.
4. Executar a matriz manual em Web e Android.
5. Registrar limitações conhecidas do MVP e congelar o escopo local/offline.

**Saída da fase:** aplicativo local validado, com evidências de testes automatizados e manuais.

### Fase B — Fechar segurança e release Android

1. Abrir tarefa para o achado CBC/Hive.
2. Definir criptografia autenticada e migração compatível.
3. Decidir `minSdk` com dados do piloto.
4. Revisar Manifest, receivers, permissões e arquivos temporários.
5. Fazer busca de segredos e revisar os falsos positivos.
6. Executar novo MobSF, análise dinâmica e checklist manual MASVS/MASTG.
7. Validar assinatura real, ProGuard/R8, AAB e procedimento de rollback.

**Saída da fase:** build candidata ao piloto técnico, ainda sem dados clínicos reais até aprovação de governança.

### Fase C — Preparar piloto controlado

1. Finalizar checklist LGPD, suporte, retenção e incidentes.
2. Definir dados sintéticos, organizações de teste e perfis de acesso.
3. Executar os cenários de autorização negativa e isolamento.
4. Obter aprovação do responsável técnico e revisão jurídica aplicável.
5. Definir métricas agregadas mínimas, sem conteúdo clínico indevido.
6. Executar piloto pequeno, monitorado e reversível.

**Saída da fase:** evidência de uso controlado, sem transformar o protótipo RH em produto clínico ou administrativo não validado.

### Fase D — Backend e portal RH

Somente depois das fases A–C:

1. especificar modelo de dados e classificação de cada campo;
2. implementar autenticação e autorização no servidor;
3. implementar isolamento por organização no banco e na API;
4. repetir todas as negações dos testes locais no backend;
5. implementar auditoria mínima, retenção e revogação;
6. integrar o app por sincronização opt-in, mantendo o núcleo offline;
7. realizar teste de carga, threat model, análise de dependências e revisão de privacidade.

**Saída da fase:** backend/portal RH em ambiente de homologação, nunca diretamente em produção.

## 7. Critério de pronto para o próximo gate

O próximo gate recomendado é a **validação do MVP offline em dispositivo**, não a construção imediata do portal RH. Esse gate só deve ser marcado como concluído quando:

- todos os testes automatizados passarem em CI;
- o ambiente local reproduzir a mesma versão de Flutter/Dart;
- a matriz manual crítica tiver evidências;
- a comunicação offline continuar funcional;
- exportação, limpeza, PIN e sessão estiverem testados;
- o APK de teste tiver permissões revisadas;
- o achado criptográfico tiver decisão documentada;
- `minSdk` tiver decisão registrada;
- nenhum dado real de família/criança estiver sendo usado sem aprovação de governança.

## 8. Primeira sequência de trabalho sugerida

Para a próxima sessão de desenvolvimento, a ordem mais eficiente é:

1. instalar/preparar Flutter 3.38.0;
2. reproduzir `pub get`, format, analyze, test e build;
3. revisar e, se necessário, remover ou justificar `latest/` rastreado;
4. transformar o relatório MobSF em tarefas técnicas P0/P1;
5. executar a folha manual de fluxos críticos em Android;
6. fechar decisão de Hive/CBC e `minSdk`;
7. atualizar o checklist de piloto somente com evidências reais;
8. manter backend/RH conectado fora do escopo até que os gates de segurança estejam verdes.

## 9. Referências do próprio repositório

- [Projeto e handoff](../PROJECT_HANDOFF.md)
- [Continuidade do assistente](CONTINUIDADE_ASSISTENTE_IA.md)
- [Roadmap full-cycle](ROADMAP_FULL_CYCLE.md)
- [Plano sequencial até build](PLANO_SEQUENCIAL_ATE_BUILD.md)
- [Matriz de fluxos críticos](MATRIZ_FLUXOS_CRITICOS.md)
- [Checklist pré-lançamento](CHECKLIST_PRE_LANCAMENTO.md)
- [Checklist do piloto RH controlado](CHECKLIST_PILOTO_RH_CONTROLADO.md)
- [Contrato de autorização do portal RH](CONTRATO_PORTAL_RH_AUTORIZACAO.md)
- [Plano OWASP/MASVS/MobSF](PLANO_SEGURANCA_OWASP_MASVS_MOBSF.md)
- [Relatório MobSF de 24/09/2026](../security/reports/MOBSF_2026-09-24.md)

**Status final desta avaliação:** continuidade recomendada; produção e backend conectado bloqueados até o fechamento dos gates de validação, segurança e governança acima.
