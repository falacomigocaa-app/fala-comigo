# Plano seguro de backup e migração das caixas Hive

**Data:** 03/10/2026
**Estado:** desenho técnico; migração automática permanece desativada
**Linha de base do desenho:** `main` em `174ba5d`; a proteção inicial foi integrada pela PR #89 em `21a981f`
**Estado:** guarda de chave ausente e limpeza de sidecars no wipe explícito estão em `main`; migração e backup exportável permanecem não implementados

## Objetivo e invariantes

Definir como proteger dados locais existentes antes de qualquer conversão de formato, sem interromper a comunicação CAA nem expor dados pessoais ou de saúde. O desenho deve manter o produto local-first, offline-first e privado por padrão.

Invariantes obrigatórios:

1. A origem nunca é aberta com uma chave/cifra alternativa para “ver se funciona” antes de estar preservada.
2. Arquivo ausente, chave ausente, chave inválida, formato legado, corrupção e falha de autenticação são estados diferentes; nenhum deles pode virar silenciosamente uma caixa vazia.
3. Qualquer erro de validação aborta a migração sem descartar origem, backup ou registros não reconhecidos.
4. Não há sincronização automática, upload, telemetria de conteúdo ou uso de dados reais em testes.
5. Comunicação básica e cartões padrão permanecem disponíveis mesmo se dados parentais/opcionais precisarem de recuperação.
6. A abertura fail-closed continua sendo o padrão. Este documento **não** autoriza ativar migração automática nem distribuir uma versão de release.

## Estado atual verificado no código

- `SecureBoxService.openSecureBox<T>` abre as boxes com `HiveAesCipher` e uma chave guardada em `flutter_secure_storage`.
- No Android/iOS, o serviço copia os bytes `.hive`/`.hivec` para sidecars `.fcm-backup`, compara os bytes antes/depois da abertura e restaura a cópia se Hive tentar reescrever o arquivo. `recoverPendingHiveSnapshots()` tenta restaurar esses sidecars antes do `Hive.initFlutter()`.
- Esses sidecars são **rollback transitório de uma operação de abertura**, não backup de usuário: não têm interface de exportação/restauração, não são portáveis e não incluem o conjunto completo de mídias. São cópias brutas e podem conter dados legados sem cifra; não presumir que estão protegidas pela chave Hive.
- A migração de boxes legadas está desativada. A simples cópia de um arquivo não permite afirmar que ele está íntegro, decifrável ou compatível com o schema atual.
- Novas mídias nativas usam AES-GCM-256; há compatibilidade de leitura com arquivos legados sem marcador cifrado. Os caminhos de mídia incluem `fala_comigo_media/` e `transition_alerts_audio/`; novos cartões e registros podem referenciar esses arquivos.
- O MobSF histórico registrou CBC/PKCS5/PKCS7 associado ao `HiveAesCipher`. Backup e migração não eliminam esse achado. A substituição de formato criptográfico precisa de projeto, compatibilidade, scan e testes próprios.
- O bootstrap abre primeiro `pictogram_cards`, `app_settings` e `transition_alerts`; uma falha nessas caixas pode impedir a tela inicial. A arquitetura de recuperação futura deve isolar falhas de dados parentais e preservar um caminho CAA básico.
- A PR #89 integrou a guarda: se a chave protegida estiver ausente e houver arquivos Hive/sidecars no diretório nativo, o app não gera uma chave substituta; lança erro explícito sem abrir nem alterar a origem. A mudança não migra dados. O wipe explícito remove sidecars geridos antes da troca da chave.

## Inventário de boxes sob gestão do wipe

A lista abaixo vem de `DataWipeService`; cada entrada precisa de fixtures sintéticas, regra de compatibilidade e contagem/digest de validação antes de qualquer migração. Não inferir que uma box contém dados reais porque ela existe.

| Box | Conteúdo/forma conhecida | Observação de preservação |
| --- | --- | --- |
| `pictogram_cards` | `PictogramCard` com adapter Hive | Caixa crítica à comunicação; cartões padrão continuam disponíveis se houver recuperação. |
| `app_settings` | valores dinâmicos de preferências | Preservar modo/orientação/configurações conhecidas; não aceitar valores desconhecidos sem validação. |
| `transition_alerts` | mapas de alertas | Preservar identificadores e horários; avaliar efeitos de notificações já agendadas. |
| `parent_reminders` | mapas de lembretes | IDs/notificação associados exigem validação junto ao SO. |
| `patient_profile` | mapa de perfil familiar | Dados pessoais/sensíveis; minimizar acesso e não incluir conteúdo em logs. |
| `behavior_logs` | mapas de registros ABC | Dados sensíveis; abortar se qualquer registro não puder ser interpretado. |
| `video_diary` | mapas e referências a mídia | Incluir verificação das mídias referenciadas, não apenas a box. |
| `visual_routine` | registros de rotina | Validar chaves, ordem, cartões e referências externas. |
| `parent_access_grants` | mapas de autorizações locais | Não converter consentimento/grant em autorização server-side. |
| `shared_tasks` | mapas de tarefas e eventos | Preservar estados e histórico; não enviar itens locais para rede. |
| `shared_task_sync_queue` | mapas de operações pendentes | Preservar idempotência e não reproduzir chamadas de sync durante migração. |
| `communication_profile` | mapa do perfil de comunicação | Dados potencialmente sensíveis; manter offline. |
| `communication_plans` | mapas de planos de comunicação | Preservar datas/estado, sem interpretação clínica automática. |
| `care_appointments` | mapas de compromissos | Dados sensíveis; não disparar notificações duplicadas na restauração. |
| `plan_license` | estado local de licença | Não transformar valor local em cobrança ou autoridade remota. |

## Separar dois conceitos de backup

### A. Snapshot transacional de recuperação

Serve somente para reverter uma migração interrompida no mesmo aparelho. Deve ficar no armazenamento privado do app, ser autenticado/cifrado, usar uma chave protegida do dispositivo e ter manifesto versionado. A perda da chave do Keystore/Keychain não pode ser apresentada como recuperável por esse snapshot. O processo precisa ser idempotente e nunca apagar a origem ambígua.

### B. Backup de usuário, exportável e restaurável

É uma função de produto separada, acionada explicitamente pelo responsável. Recomendação de desenho: arquivo portátil cifrado por segredo criado pelo usuário, com derivação de chave resistente a força bruta e cifra AEAD; sem upload automático. Deve incluir dados Hive e mídias referenciadas, validar o conteúdo antes de concluir, explicar onde o arquivo foi salvo e avisar que o Fala Comigo não controla cópias compartilhadas fora do app. Chave somente no Keystore não basta para restauração em outro aparelho.

A política de backup portátil, frase-senha, tamanho máximo, inclusão de mídia e fluxo de recuperação ainda precisa de protótipo e revisão de segurança. Nenhum formato exportável está implementado nesta branch.

## Fluxo proposto de migração

1. **Inventário read-only:** enumerar somente nomes/tamanhos/versões e existência de arquivos geridos; não abrir boxes originais para classificação. Identificar chave disponível sem imprimir seu valor. Estado desconhecido permanece desconhecido.
2. **Preservação prévia:** fechar boxes; criar cópia consistente de todos os arquivos da origem e dos objetos de mídia referenciados; gerar manifesto com versão, nomes lógicos, tamanhos e hashes; cifrar/autenticar cópia; verificar leitura de volta antes de prosseguir. Verificar espaço livre antes da cópia.
3. **Leitura isolada:** copiar os arquivos preservados para diretório temporário separado e abrir **somente a cópia**, com o adapter/cifra compatível com aquela versão. Proibir fallback automático para plaintext quando a chave existe mas a autenticação falha.
4. **Conversão por schema:** transformar cada box usando migrador versionado e determinístico. Manter chaves e contagens; desconhecidos, dados inválidos ou referências de mídia quebradas abortam o lote, sem descartar linhas.
5. **Escrita em staging:** escrever o formato destino em diretório novo, com formato explicitamente versionado. O formato de destino deve usar AEAD autenticada; `HiveAesCipher` CBC não deve ser descrito como autenticado. Se Hive não permitir implementar cifra AEAD segura e testável, escolher outra camada de persistência em vez de improvisar cifra compatível.
6. **Verificação:** reabrir staging; comparar quantidade de boxes/keys/records, digest canônico dos valores, invariantes por modelo, relações entre cartões e mídias e compatibilidade do app. Não registrar valores reais em logs.
7. **Commit transacional:** registrar estados persistentes (`prepared`, `source_preserved`, `staged`, `verified`, `committing`, `committed`); fazer troca atômica quando suportada; manter origem e backup até que uma inicialização posterior seja verificada. Se o estado for ambíguo, restaurar origem e mostrar recuperação, não criar banco vazio.
8. **Retenção e rollback:** manter snapshot até que o responsável confirme que os dados estão acessíveis e que a versão atual funciona. Apagar cópias somente por ação explícita ou política documentada, com confirmação e resultado verificável.
9. **Liberação gradual:** primeiro modo dry-run/testes sintéticos; depois builds internas; migração em dispositivo de teste com dados sintéticos; só então avaliar opt-in controlado. Migração automática global continua proibida até fechar todos os gates.

## Matriz mínima de testes sintéticos

- instalação nova, sem arquivos e sem chave: cria chave e caixas vazias;
- box plaintext legada com chave ausente: não gera chave, não reescreve origem;
- box cifrada válida com chave disponível: abre e mantém contagem/valores;
- box cifrada com chave ausente/divergente/inválida: não apaga, não troca silenciosamente chave, não gera box vazia;
- arquivo truncado, `.hivec`, backup e `.tmp` interrompidos: recuperar ou abortar sem apagar a única cópia;
- interrupção de processo depois de cada estado do manifesto, com retomada idempotente;
- falta de espaço, erro de I/O, Keystore/Keychain indisponível e adapter desconhecido;
- mídias ausentes, legadas em plaintext, cifradas válidas e com tag inválida;
- operações de notificações/sync não executadas em duplicidade após rollback;
- quantidade, chaves e digest canônico iguais antes/depois; nenhum registro silenciosamente descartado;
- wipe explicitamente autorizado continua apagando os dados e deixa cartões padrão utilizáveis.
- wipe explícito remove fisicamente `.fcm-backup` e `.tmp` conhecidos antes de apagar a chave e recriar boxes; um erro de I/O aborta o fluxo em vez de deixar cópias residuais silenciosas.

Todos os testes usam fixtures sintéticas. Nenhum screenshot, log, relatório de CI ou fixture deve conter nomes, diagnósticos, imagens ou dados reais de crianças.

## Critérios que bloqueiam a ativação

- Ainda não existe exportação/restauração de backup pelo usuário.
- A estratégia de formato AEAD para persistência Hive precisa de prova de compatibilidade e revisão independente.
- Não há teste de falha de processo real em dispositivo Android para cada ponto transacional.
- A chave de banco ausente deve falhar sem sobrescrever: o guard nesta branch cobre o cenário nativo por nomes de arquivos, sujeito a CI.
- O achado MobSF de CBC permanece aberto até reexecução e revisão do artefato atual.
- Não habilitar migração automática, não remover boxes antigas e não recomendar atualização sobre instalação com dados importantes.

**Próxima validação desta branch:** CI Flutter para os testes adicionados. Como Flutter/Dart não estão instalados neste sandbox, nenhum teste local é declarado como executado. Depois, revisar resultado da CI, completar os testes de snapshot/retomada e atualizar o handoff com o commit/PR real.
