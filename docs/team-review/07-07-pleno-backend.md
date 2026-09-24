# Revisão Pleno Back-End — APIs futuras e fechamento no Android

**ID:** 07-07  
**Papel:** Pleno Back-End Developer  
**Data:** 24 de setembro de 2026  
**Escopo:** handoff, `AGENTS.md`, relatórios de build e segurança, checklists, documentação de portal/RH, inicialização Flutter/Android, persistência local, planos, autorização e testes.

> **Integridade da revisão:** nenhum arquivo de código foi alterado. O APK instala e fecha ao abrir segundo o handoff e os relatórios, mas não há logcat do aparelho físico neste checkout. Nenhuma linha de log, exceção nativa ou causa foi inventada.

## Resumo executivo

O build está saudável como processo de compilação e empacotamento: os relatórios registram formatação, análise, 84 testes, build Web, APK debug, APK release, AAB release e build limpa aprovados. Isso **não prova** que o aplicativo Android chega ao primeiro frame ou permanece utilizável no aparelho físico. O fechamento ao abrir continua um bloqueador de disponibilidade, com causa desconhecida até existir evidência do próprio aparelho [1] [2].

O checkout efetivamente revisado é `work/qa-observability-and-emulator`, no commit `c8fcab1`. Alguns documentos ainda citam branches, commits e contagens históricas diferentes; a equipe deve fixar o APK realmente instalado, seu SHA-256 e seus metadados antes do próximo teste. A assinatura local é temporária e não representa a chave de produção [3] [4].

Não existe backend conectado neste checkout. Não foram encontrados servidor, rotas, esquema/migrações de banco, autenticação remota, middleware, cliente de API ou persistência remota. Existem modelos e políticas Dart, testes unitários, catálogo de planos local e contratos documentais. Esses artefatos são uma **especificação inicial**, não enforcement server-side. Portanto, não há API futura disponível que possa explicar o fechamento do APK, e iniciar portal, sincronização ou cobrança agora aumentaria o risco sem resolver o incidente local [5] [6] [7].

A prioridade recomendada é dupla, com gates separados: **P0**, reproduzir o APK release em aparelho físico saudável e coletar logcat se ele fechar; **P1**, transformar os contratos de identidade, organização, autorização, consentimento, auditoria e sincronização em uma API testada antes de qualquer dado real. O núcleo CAA deve continuar local-first e independente de conta, internet e plano pago.

## Fatos confirmados

| Fato | Evidência e limite |
|---|---|
| O pipeline compila | `RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md` registra análise sem falha bloqueadora, 84 testes e builds Web/APK/AAB, inclusive após `flutter clean`. Isso é evidência de build, não de execução física. |
| O fechamento físico permanece sem causa | O handoff registra que o APK instala e fecha ao abrir. Não há fabricante, modelo, API Android, horário ou logcat do telefone no repositório. |
| O AVD da Manus não é reprodução válida | O relatório registra que o serviço `package` e o `system_server` do AVD morreram antes de uma instalação/execução confiável. Essa evidência é da infraestrutura do emulador, não do processo do Fala Comigo. |
| O caminho crítico foi parcialmente reduzido | `main.dart` chama `runApp` antes do bootstrap. Depois, o bootstrap ainda executa orientação, Hive, `flutter_secure_storage`, migração de caixas, diagnóstico e semeadura dos cartões antes de marcar o app como pronto. TTS e notificações foram adiados e têm captura independente de erros Dart [8] [9]. |
| A tela de falha não captura toda morte possível | A tela `StartupFailureApp` depende de o engine Flutter e o Dart continuarem vivos. Ela não é evidência contra crash nativo anterior ao Flutter, falha de linker/JNI, morte da Activity ou encerramento do processo. |
| Não há backend implementado | O repositório tem `lib/core/authorization/`, `lib/core/plans/`, testes e documentação, mas não tem rotas, handlers, banco, migrações, autenticação remota ou serviço de sincronização. O MVP declara explicitamente esses itens fora do escopo [4] [5]. |
| A autorização atual é local | `RhAuthorizationPolicy.decide()` recebe booleans e valores já preparados pelo chamador, como `sameOrganization`, `consentValid` e `auditReady`. Ela ajuda a fixar o domínio e as negações, mas não identifica a sessão, consulta membership, verifica ownership, persiste auditoria ou protege um endpoint [10]. |
| Licença local não equivale a autorização remota | `PlanAccessController` mantém o núcleo offline e libera recursos conectados conforme uma licença em Hive. Essa decisão do cliente não pode autorizar acesso a dados em servidor [11]. |
| O contrato RH nega conteúdo familiar por padrão | Os documentos separam `organizationPortal`, `benefitAdministration`, `aggregateReporting`, `sponsoredLicense` e `careNetwork`, e exigem negação no servidor para organização, papel, finalidade, escopo, consentimento e prazo [6] [7]. Ainda não há serviço que aplique essas regras. |
| A auditoria ainda não é persistida | `RhAuditEvent` valida e serializa um evento mínimo. O contrato de retenção declara que o protótipo não persiste eventos; não há trilha append-only, retenção aplicada ou consulta de auditoria [12] [13]. |
| A rede não é parte do app atual | A permissão `INTERNET` aparece no Manifest de debug; o Manifest principal não a declara. Isso não é defeito do MVP offline, mas uma futura API precisará decidir e testar a permissão no artefato release, além de TLS, endpoints e política de falha [14]. |

## Riscos de engenharia

### R-01 — Disponibilidade P0: o primeiro valor ainda não foi provado

Enquanto o APK fecha no telefone e a grade CAA não foi observada permanecendo aberta offline, a comunicação Android não pode ser considerada operacional. O resultado verde do build não substitui instalação limpa, primeiro frame, permanência, ciclo de vida e compatibilidade de dispositivo.

### R-02 — Caminho de inicialização ainda concentra persistência sensível

Antes da interface principal ficar pronta, o app abre ou migra caixas cifradas. `openSecureBoxWithMigration()` trata qualquer erro na abertura cifrada como possível caixa legada, abre a caixa sem cifra, copia os valores, remove a caixa do disco e recria a caixa cifrada [9]. Estado corrompido, chave incompatível ou formato inesperado podem produzir comportamento diferente no aparelho. Isso é um risco observável do caminho, não uma causa confirmada do fechamento.

### R-03 — P0 para o portal: não existe fronteira de confiança no servidor

Um cliente modificado pode ignorar uma política Dart local. Sem API que derive a identidade da sessão, consulte memberships e ownership, valide o escopo e registre a decisão, esconder uma tela não protege dados. O portal, convites, downloads e sincronização devem permanecer bloqueados como produção até esse enforcement existir.

### R-04 — Multi-organização não é propriedade demonstrada

Os modelos documentais exigem que clínica, escola, família, patrocinador e RH sejam isolados. O código atual trabalha com flags e IDs fornecidos em memória. Não há banco ou teste de integração que tente ler, editar, exportar ou baixar um recurso da organização B usando a organização A.

### R-05 — Consentimento, finalidade e retenção são apenas campos lógicos

Comparar strings de finalidade ou aceitar `consentValid = true` não cria consentimento versionado. A API futura precisa armazenar texto/versão apresentada, destinatário, organização, escopo, finalidade, emissão, revogação e prazo. Revogar deve bloquear novas leituras e downloads imediatamente, sem apagar o recibo mínimo exigido para auditoria.

### R-06 — Auditoria e operações administrativas precisam de consistência

A API deve auditar sucessos e negações, inclusive tentativas de cruzar organizações, exportar conteúdo, baixar mídia e consultar agregados abaixo do limiar. Alterações de licença e convites precisam ser idempotentes e concorrentes de forma segura; eventos repetidos de webhook ou retry não podem emitir duas licenças nem produzir estados conflitantes. O código atual não implementa essa persistência nem idempotência.

### R-07 — Entitlement comercial pode ser confundido com autorização de dados

O plano `organization` não deve liberar `sponsoredLicense`, e uma licença patrocinada não deve liberar portal RH ou conteúdo familiar. A política local sugere essa separação, mas o backend terá de repeti-la por recurso e operação. Expiração, suspensão ou revogação remota jamais podem retirar comunicação, acessibilidade, controle parental ou dados locais.

### R-08 — Mídia e exportação ampliam o risco da API

A mídia local é cifrada e pode ser materializada em arquivo temporário para widgets, players ou compartilhamento. No portal futuro, mídia não deve ser enviada por padrão. Quando autorizada, deve usar artefato de escopo explícito e URL temporária, curta e revogável, com limite de tamanho/tipo e auditoria. Caminho local, URL permanente, exportação ampla e logs com conteúdo são proibidos por padrão [6] [7].

### R-09 — Exclusão local e remoção remota são problemas distintos

O serviço local de wipe não é uma API de titular nem revoga cópias já exportadas. Antes de sincronizar, o contrato deve separar exclusão no dispositivo, remoção no servidor, expiração por retenção, revogação de acesso e cópias baixadas por terceiros. A promessa de “exclusão completa” precisa continuar explicitando seu limite local.

### R-10 — Segurança do release ainda tem gates abertos

O checklist mantém pendentes revisão do Manifest, permissões, `minSdk`, achados MobSF, migração criptográfica, análise dinâmica e revisão manual MASVS/MASTG. Esses pontos podem bloquear distribuição, mas não são evidência causal do fechamento sem logcat [2] [15].

## Hipóteses sobre o fechamento do APK

As hipóteses abaixo orientam investigação e **não são diagnósticos**. A confiança causal em todas é baixa porque não existe logcat do aparelho físico.

1. **Morte nativa antes ou durante o Flutter.** Carregamento de biblioteca, JNI, registro de plugin, criação da Activity ou outro erro nativo pode encerrar o processo antes dos handlers Dart e da tela de diagnóstico.
2. **Falha em Keystore, `flutter_secure_storage`, Hive ou migração.** O caminho é obrigatório antes da grade. Estado antigo, chave inválida, corrupção ou incompatibilidade de formato são possibilidades sustentadas pelo código, mas não foram confirmadas.
3. **Dados persistidos ou atualização sobre instalação anterior.** Assinatura diferente, resíduos da versão anterior ou dados incompatíveis podem mudar o resultado. É necessário comparar instalação limpa, `pm clear` e atualização sobre fixtures sintéticas.
4. **Incompatibilidade de fabricante, versão/API ou política do aparelho.** `minSdk`, `targetSdk`, orientação fixa, armazenamento seguro, permissões e componentes de tela cheia podem interagir de modo específico. Sem modelo e API não é responsável priorizar uma causa.
5. **Falha depois do bootstrap.** Splash, provider, primeira tela ou serviço acionado após a abertura podem fechar o processo; o relato “fecha ao abrir” não informa em qual instante isso ocorre.
6. **TTS ou notificações.** Erros Dart desses serviços ficaram menos plausíveis como bloqueadores do primeiro frame porque foram adiados para depois da tela e protegidos por `try/catch`. Ainda não é possível eliminar falha nativa de plugin sem logcat.
7. **Tamanho do APK release ou chave temporária.** A diferença entre Debug e Release é esperada. A assinatura temporária limita distribuição/atualização, mas não prova que faltam recursos nem que causou o fechamento.

## Contrato recomendado para APIs futuras

A recomendação é especificar primeiro um contrato versionado e independente do provedor. Os nomes abaixo são famílias de recursos, não endpoints já existentes.

### 1. Identidade e sessão

Cada pessoa deve ter identidade individual. A API deve emitir sessão curta e revogável, rejeitar conta inativa e não aceitar do cliente papel, organização, consentimento ou autorização como fatos confiáveis. Operações sensíveis devem exigir autenticação forte conforme o risco. A resposta de sessão inválida deve ser genérica e não revelar a existência de recursos.

### 2. Organização e relacionamento

O modelo mínimo deve conter `User`, `Organization`, `Membership`, `ChildSubject`, `Relationship`, `Role`, `Permission`, `Purpose`, `Consent`, `Retention` e `AuditEvent`. Todo recurso remoto deve possuir `organizationId`, classificação de sensibilidade e ownership verificável no servidor. `childSubjectId` deve ser pseudonimizado e nunca pode autorizar acesso sozinho.

### 3. Autorização por requisição

Toda leitura, criação, edição, exclusão, convite, exportação, download de mídia e alteração de consentimento deve executar, no servidor, a sequência: sessão válida; conta ativa; organização da sessão; ownership do recurso; membership vigente; relação com o sujeito; permissão e entitlement específicos; finalidade compatível; escopo; consentimento vigente; prazo de retenção; revogação; operação permitida; auditoria pronta. Qualquer requisito ausente produz negação segura. O cliente pode antecipar uma decisão para UX, mas não pode ser a autoridade.

### 4. Convites e consentimentos

Convites devem ser individuais, de uso único, expiráveis e revogáveis. O consentimento deve identificar versão do texto, finalidade, destinatário, campos/mídias, organização, emissão, prazo e revogação. A API deve impedir reuso de convite, registrar recusa sem expor inferências ao patrocinador e bloquear imediatamente novas leituras e downloads após revogação.

### 5. Auditoria e retenção

Eventos permitidos e negados devem conter apenas `id`, `actorId`, `organizationId`, operação, tipo e ID técnico do recurso, resultado, motivo e timestamp UTC. Não devem conter nome de criança, diagnóstico, frases, cartões, fotos, áudio, vídeo, frequência individual ou texto clínico. A implementação deve definir retenção por finalidade, acesso restrito aos eventos, descarte/anonimização e correlação técnica sem registrar conteúdo sensível.

### 6. Sincronização opt-in e offline

O aplicativo deve abrir e comunicar sem login, internet ou licença. A sincronização, quando explicitamente ativada, deve enviar registros versionados com organização, sujeito, criador, finalidade, `consentId`, expiração de retenção e classificação. O contrato deve definir `idempotencyKey`, versão do registro, conflitos, retries, ordenação e comportamento offline. Falha de rede, expiração de sessão ou indisponibilidade do backend deve deixar o dado local e a comunicação utilizáveis.

### 7. Mídia e exportação

Mídia deve ser separada de metadados administrativos e excluída por padrão de exportações. Um download autorizado deve usar URL curta, temporária e revogável, com escopo, finalidade, destinatário, expiração, tamanho e tipo controlados. A API não deve expor caminho do filesystem, bucket público ou token permanente. Exportações devem mostrar o escopo ao responsável e gerar auditoria.

### 8. Licenças e pagamentos posteriores

Catálogo, assinatura comercial e licença de produto devem ser recursos distintos. A emissão de licença deve depender de webhook assinado e validado, não do redirecionamento de checkout. Eventos externos devem ter ID único, verificação de assinatura, deduplicação, transação idempotente e reconciliação. O fluxo deve começar em sandbox; cobrança real exige escolha de provedor, política de reembolso, revisão legal/fiscal e confirmação explícita [5].

### 9. Observabilidade e proteção operacional

A API futura deve devolver códigos estáveis de erro sem enumerar recursos, usar correlação técnica, limites de requisição, timeouts e métricas sem conteúdo familiar. Logs de aplicação, auditoria administrativa e conteúdo familiar devem permanecer separados. O suporte elevado deve exigir motivo, aprovador, organização, escopo mínimo, expiração curta e auditoria; o acesso a conteúdo familiar deve permanecer negado por padrão.

## Plano de ação

### P0 — fechar o incidente Android sem alterar a hipótese por conveniência

1. Fixar branch, commit, `applicationId`, `versionName`, `versionCode`, SHA-256 do APK instalado, dispositivo, API, conectividade, permissões e horário.
2. Desinstalar a versão anterior, reiniciar o aparelho, instalar o APK release fixado e testar offline. Confirmar primeiro frame, chegada à grade CAA e permanência em celular e tablet.
3. Se fechar, limpar o buffer e coletar o logcat do próprio aparelho imediatamente antes e depois da tentativa, filtrando pelo pacote efetivo, `AndroidRuntime`, `FATAL EXCEPTION`, `flutter`, `libc`, `ActivityTaskManager`, `PackageManager` e `system_server`. Enviar somente metadados técnicos; nunca conteúdo de criança.
4. Repetir em três estados com fixtures sintéticas: instalação limpa, `pm clear` e atualização sobre dados existentes. Registrar o resultado separadamente.
5. Não iniciar API, cobrança, sincronização clínica ou alteração criptográfica como correção especulativa do fechamento.

### P1 — preparar API sem dados reais

6. Congelar um contrato OpenAPI versionado para identidade, organização, convites, consentimentos, licenças, auditoria, recursos e mídia; definir códigos de negação e modelo de erro sem enumeração.
7. Implementar primeiro duas organizações sintéticas, memberships, relacionamentos e autorização server-side. A decisão deve derivar a organização do recurso e não confiar no `organizationId` enviado pelo cliente.
8. Criar testes de integração negativos contra a API: sessão ausente, conta inativa, organização cruzada, papel/entitlement insuficiente, convite expirado/reutilizado, finalidade divergente, escopo ausente, consentimento revogado, prazo vencido, exportação RH, mídia sem autorização, URL expirada, suporte sem aprovação e relatório abaixo do limiar.
9. Persistir auditoria de sucesso e negação com retenção configurável. Testar concorrência e idempotência de convite, licença, revogação e webhook antes de qualquer piloto.
10. Validar que licença patrocinada, portal RH e cuidado conectado continuam separados e que expiração remota não bloqueia a comunicação local.
11. Definir sync opt-in, versionamento, retries, conflitos, limites e URLs temporárias; adicionar permissão de rede somente ao artefato release quando houver implementação real e testar falha offline.
12. Manter o piloto com dados sintéticos até concluir revisão de privacidade/LGPD, threat model, MobSF, MASVS/MASTG, suporte, incidentes, retenção e aprovação documental.

## Critério de saída

O gate Android só pode avançar quando uma instalação limpa chegar à grade CAA e permanecer utilizável offline em um celular e um tablet, com evidência registrada. Se houver novo fechamento, a causa deve permanecer classificada como **desconhecida** até o logcat ou relatório técnico sanitizado do aparelho indicar um componente.

O gate de backend só pode avançar para piloto quando a API real possuir autenticação individual, isolamento multi-organização, autorização server-side, consentimento e retenção versionados, auditoria de sucessos e negações, idempotência e testes de integração negativos. Até lá, contratos, telas estáticas e políticas Dart não devem ser descritos como backend pronto.

## Confiança

**Alta** para os fatos de que o build foi documentado como aprovado, o fechamento físico não tem causa confirmada, o AVD não é reprodução válida, o checkout não contém backend conectado e as políticas de autorização são locais. **Média-alta** para os riscos derivados diretamente do caminho de inicialização, da migração de caixas, da ausência de persistência de auditoria e da falta de isolamento server-side. **Baixa** para qualquer hipótese específica sobre a causa do fechamento, pois não há logcat do telefone.

## Referências

[1]: ../RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md "Diagnóstico de build e instalação Android"
[2]: ../CHECKLIST_EXECUCAO_E_TESTES.md "Checklist de execução, testes e prontidão"
[3]: ../AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md "Auditoria do handoff e artefatos Android"
[4]: ../ENTREGA_MVP_2026-09-24.md "Entrega do MVP Fala Comigo"
[5]: ../SEQUENCIA_FULL_STACK_ATE_PILOTO.md "Sequência full-stack até o piloto institucional"
[6]: ../CONTRATO_PORTAL_RH_AUTORIZACAO.md "Contrato técnico do portal RH e autorizações"
[7]: ../MODELO_AUTORIZACAO_CLINICAS_ESCOLAS.md "Modelo de autorização para clínicas e escolas"
[8]: ../CONTINUIDADE_ASSISTENTE_IA.md "Continuidade para assistência por IA"
[9]: ../../lib/main.dart "Inicialização Flutter e tela de diagnóstico"
[10]: ../../lib/core/authorization/rh_authorization_policy.dart "Política local de autorização RH"
[11]: ../../lib/core/plans/plan_access_controller.dart "Controlador local de acesso por plano"
[12]: ../../lib/core/authorization/rh_audit_event.dart "Modelo local de evento de auditoria RH"
[13]: ../RH_AUDITORIA_E_RETENCAO.md "Auditoria e retenção do portal RH"
[14]: ../../android/app/src/main/AndroidManifest.xml "Manifest principal Android"
[15]: ../PLANO_SEGURANCA_OWASP_MASVS_MOBSF.md "Plano de segurança móvel OWASP MASVS e MobSF"
[16]: ../../PROJECT_HANDOFF.md "Documento de transferência do projeto Fala Comigo"
[17]: ../../AGENTS.md "Instruções de desenvolvimento do Fala Comigo"

**Resultado da revisão:** relatório criado sem alteração de código.
