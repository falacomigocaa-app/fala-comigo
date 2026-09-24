# Revisão Senior Back-End — Backend e autorização

**ID:** 06-06  
**Papel:** Senior Back-End Developer  
**Data:** 24 de setembro de 2026  
**Escopo:** handoff, `AGENTS.md`, checklists, relatórios de build e segurança, revisões anteriores, código de inicialização, persistência, planos, autorização RH, testes e protótipo do portal.

> **Integridade da revisão:** nenhum código foi alterado. Não há logcat do aparelho físico no repositório. Nenhuma exceção, stack trace, sinal nativo ou causa do fechamento foi inventada.

## Decisão executiva

O projeto continua coerente com um aplicativo **local-first**: a comunicação CAA básica deve funcionar sem conta, servidor, internet ou plano pago [1] [2]. O checkout observado é `work/qa-observability-and-emulator`, no commit `c8fcab1` (`feat: finalize MVP startup and delivery package`). Há divergências históricas entre esse estado e alguns documentos, que citam outros commits, hashes e contagens de testes; por isso, a equipe deve tratar o artefato efetivamente instalado como a única fonte de verdade para o próximo teste [3] [4] [5].

O APK instala, o build compila e os relatórios registram análise, testes e builds Android aprovados. Isso **não prova que a Activity abre e permanece utilizável em um telefone**. O fechamento ao abrir continua sendo um bloqueador P0. Não há logcat do aparelho físico, fabricante, modelo, versão/API ou horário do crash. A causa permanece desconhecida. O AVD usado no ambiente não constitui reprodução válida do aplicativo, pois serviços internos do Android do emulador morreram antes de uma execução confiável [3] [4].

Quanto ao backend, **não existe backend conectado nem autorização server-side implementada neste checkout**. O repositório contém políticas Dart de domínio, testes unitários, modelos de licença local, documentação contratual e um console RH HTML estático com dados sintéticos. Esses artefatos são uma preparação útil para um backend futuro, mas não protegem endpoints, bancos de dados, downloads, convites ou organizações reais. O piloto institucional e qualquer sincronização clínica permanecem bloqueados [6] [7].

A recomendação é resolver primeiro a evidência do Android e manter o núcleo offline independente. Em paralelo, o backend pode ser especificado, mas não deve ser apresentado como implementado nem usado para explicar o fechamento do APK.

## 1. Fatos confirmados

### 1.1 Build verde não equivale a execução Android

Os relatórios registram Flutter 3.38.0, Dart 3.10.0, Android SDK 36, JDK 21, análise estática sem falha bloqueadora, 84 testes, build Web, APK debug, APK release, AAB release e build limpa aprovados [3] [4]. O APK release de diagnóstico usa uma chave temporária; não é a assinatura oficial de produção [4].

Esses resultados comprovam uma linha de compilação e empacotamento. Eles não comprovam instalação limpa, primeiro frame, persistência, ciclo de vida, compatibilidade de fabricante, uso offline ou permanência na grade CAA em aparelho real. O checklist ainda mantém esses critérios pendentes [8].

### 1.2 O fechamento físico não tem causa confirmada

O fato operacional disponível é: o APK instala, tenta abrir e fecha no telefone, conforme o handoff e os relatórios. Não foi localizado logcat do telefone físico. O registro do AVD indica que o serviço `package` e o `system_server` do próprio emulador foram encerrados antes da instalação/execução confiável; isso é uma falha do ambiente, não uma reprodução do Fala Comigo [3] [4].

No código atual, `main()` chama `runApp` cedo e instala handlers para erros Flutter e de plataforma. Porém, antes de marcar o aplicativo como pronto, `_bootstrapApp()` fixa a orientação, inicializa Hive, cria ou lê a chave do armazenamento seguro, abre ou migra caixas cifradas, inicializa o diagnóstico e semeia cartões padrão [9] [10]. TTS e notificações foram adiados para depois da primeira tela e têm captura independente de exceções Dart. Essa mitigação reduz o caminho crítico, mas não prova que TTS ou notificações tenham sido a causa original.

Uma tela Dart de falha só pode aparecer se o processo Android, o engine Flutter e o código Dart permanecerem ativos tempo suficiente para renderizá-la. Ela não captura necessariamente morte nativa anterior ao Flutter, falha de carregamento de biblioteca, encerramento por sinal, falha da Activity ou erro de plugin durante o registro do engine.

### 1.3 Não há serviço de backend no checkout

A inspeção do repositório não encontrou diretório de servidor, funções de API, esquema de banco, migrações, middleware de autenticação, provedor de identidade, dependência de backend ou rota remota para organizações, convites, consentimentos, licenças, conteúdo ou auditoria. As únicas superfícies relacionadas são:

- políticas e modelos Dart em `lib/core/authorization/`;
- catálogo e licença administrativa local em `lib/core/plans/`;
- testes Flutter de política, estados e isolamento;
- `site/rh/index.html`, um console estático com referências sintéticas;
- contratos e modelos em `docs/`, explicitamente descritos como protótipo ou backend futuro [6] [7] [11].

O console RH informa no próprio HTML que não é um sistema de RH, não processa dados reais e ainda requer backend, retenção, encarregado e revisão LGPD [11]. Portanto, não existe atualmente uma superfície remota que possa ser chamada de “autorizada no servidor”.

### 1.4 A autorização atual é uma política local de decisão, não enforcement remoto

`RhAuthorizationPolicy.decide()` recebe valores booleanos e campos fornecidos pelo chamador, como `authenticated`, `accountActive`, `sameOrganization`, `consentValid`, `aggregateMeetsThreshold` e `auditReady`. Ela verifica sessão lógica, estado da conta, organização, expiração, papel, entitlements, finalidade, escopo, consentimento e limiar. Também nega, para esse conjunto de operações RH, conteúdo familiar, exportação familiar e criação de autorização de cuidado [12].

Essa função é útil como **contrato de domínio e especificação de negações**, mas não verifica identidade, consulta membership, confirma a organização do recurso, carrega consentimento versionado, calcula retenção, grava auditoria ou controla uma transação. `sameOrganization`, `consentValid`, `auditReady`, `requiredPurpose` e `requiredScope` não são obtidos de uma autoridade remota nesta implementação; são argumentos já preparados pelo chamador. Um cliente modificado poderia ignorar a política, pois não há servidor para repetir a decisão.

A política também não modela, por si só, uma relação concreta entre usuário e criança, um `childSubjectId`, a classificação do registro, uma permissão por recurso ou uma URL temporária de mídia. A ausência desses campos não é um defeito de uma função que se declara local, mas é uma lacuna objetiva para qualquer futura autorização remota.

### 1.5 Acesso elevado, licenças e auditoria também são apenas lógica local

`RhElevatedAccessPolicy` valida que o solicitante esteja ativo, tenha um aprovador autorizado, permaneça na organização, apresente finalidade, use escopo permitido, tenha expiração de até duas horas e não esteja revogado [13]. A regra proíbe escopos de conteúdo familiar e clínico, o que é coerente com o princípio de menor privilégio.

Entretanto, `approverAuthorized`, `sameOrganization` e `revokedAt` também chegam como argumentos. A política não identifica o aprovador, não persiste uma concessão, não vincula a decisão a uma sessão, não força uma segunda pessoa, não registra o evento e não consulta uma revogação em tempo real. Ela valida uma entrada; não concede nem revoga acesso em uma infraestrutura.

`RhLicenseStateMachine` valida transições administrativas e exige motivo para suspensão, expiração ou revogação [14]. Não há persistência, controle de concorrência, idempotência de eventos, vínculo obrigatório com organização ou gravação transacional de auditoria. `PlanAccessController` decide recursos com base em uma licença armazenada localmente e preserva o núcleo offline [15]. Essa licença local é uma decisão comercial do cliente e **não pode ser usada como prova de autorização para um endpoint remoto**.

`RhAuditEvent` apenas valida campos e serializa um JSON mínimo. O contrato de retenção informa explicitamente que o protótipo não persiste eventos [16]. Não existe trilha append-only, retenção aplicada, alerta de abuso, integridade do evento ou consulta de auditoria implementada.

### 1.6 Os testes provam branches da política, não isolamento server-side

Os testes de autorização cobrem sessão ausente, conta inativa, organização divergente, entitlement insuficiente, limiar agregado, operações RH proibidas, finalidade, escopo, expiração e auditoria pronta [17]. O teste de organização cruza valores de `sameOrganization` e verifica a precedência da negação [18]. Os testes de acesso elevado cobrem aprovação, organização, finalidade, escopos proibidos, prazo e revogação lógica [19].

Esses testes são úteis e devem ser preservados. Porém, são testes Flutter unitários de funções puras. Eles não iniciam API, não autenticam tokens, não consultam banco, não exercitam row-level security, não verificam concorrência, não tentam acesso com um cliente adulterado e não demonstram que uma organização A não consegue ler o recurso da organização B no servidor. A documentação do piloto distingue corretamente o backend multi-organização real como pendente e bloqueador [6].

## 2. Riscos confirmados ou diretamente evidenciados

### R-01 — Disponibilidade P0: o APK ainda não passa pelo primeiro valor

Enquanto o aplicativo fecha ao abrir no telefone e não há logcat causal, a comunicação offline não pode ser considerada operacional em Android. A ausência de backend não causa, por si só, esse fechamento. Iniciar endpoints ou portal agora aumentaria a superfície de mudança sem resolver o incidente local.

### R-02 — Diagnóstico P0: a causa pode estar antes do limite observado pelo Dart

O bootstrap ainda acopla a disponibilidade da grade a orientação, Keystore, Hive, migração, diagnóstico e semeadura de cartões. A migração trata qualquer erro de abertura cifrada como possível caixa legada e então abre a caixa sem cifra, copia valores, apaga a caixa do disco e recria a caixa cifrada [10]. Sem teste de aparelho e sem logcat, não é possível saber se esse caminho participa do fechamento. Também existe risco de perda ou comportamento inesperado em estado corrompido, chave incorreta ou formato incompatível.

### R-03 — Autorização P0 para qualquer portal: não há fronteira de confiança server-side

A política local pode orientar a interface e os testes de domínio, mas não resiste a cliente modificado. Sem um backend que derive a identidade da sessão, consulte memberships e ownership, compare organização do recurso, valide consentimento e retenção e registre sucesso ou negação, qualquer portal conectado seria apenas uma aparência de controle.

### R-04 — Multi-organização P0: isolamento ainda não é uma propriedade demonstrada

Os modelos documentais exigem negação por padrão e isolamento por organização [20]. O código atual aceita `sameOrganization` como booleano. Não há recurso persistido com `organizationId` protegido por uma camada de acesso, nem teste de integração que tente ler, alterar, exportar ou baixar dados de outra organização. O piloto deve permanecer bloqueado até esse isolamento ser implementado e testado no servidor.

### R-05 — Consentimento e finalidade P1: campos lógicos não são registros jurídicos ou operacionais

A política aceita `consentValid` e compara strings de finalidade e escopo, mas não há consentimento versionado com texto, organização, destinatário, campos envolvidos, data de emissão, revogação e prazo. Não há garantia de que uma revogação interrompa imediatamente leituras e downloads. Essa lacuna impede sincronização clínica ou compartilhamento com escola, clínica e profissionais.

### R-06 — Auditoria P1: “auditReady” não é auditoria

A decisão exige que o chamador informe `auditReady`, mas isso não garante que um evento de sucesso ou negação tenha sido gravado. O contrato exige eventos mínimos para acesso permitido e negado, inclusive tentativas de cruzar organizações, exportar conteúdo e consultar grupos abaixo do limiar [16]. O protótipo não persiste esses eventos e não aplica retenção.

### R-07 — Privacidade local P1: exclusão declarada como completa tem lacunas no código

`DataWipeService` lista caixas de cartões, configurações, alertas, perfil, registros, vídeo, licença e diagnóstico, mas não inclui `visual_routine` nem `parent_reminders` [21]. O serviço também remove a chave Hive, mas não remove a chave de mídia `fala_comigo_media_key_v1`, segundo a revisão arquitetural e a implementação de mídia [22]. Isso não prova o fechamento do APK, mas enfraquece a promessa de apagar todos os dados e chaves locais. A lacuna deve ser tratada separadamente do incidente de startup, com teste de exclusão em aparelho.

### R-08 — Segurança de release P1: achados MobSF continuam abertos

O APK de teste recebeu score MobSF 46, com achados altos para CBC com PKCS5/PKCS7 e `minSdk=24`, além de warnings em receiver, arquivos temporários, armazenamento externo, possíveis strings sensíveis e permissões [23]. Esses achados bloqueiam uma decisão de distribuição ampla e exigem revisão própria. Não são evidência causal do fechamento sem logcat.

### R-09 — Operação P1: identidade de pacote está inconsistente na documentação

O README declara `com.falacomigo.caa`, enquanto os relatórios de build e o pacote atual usam `com.falacomigo.fala_comigo` [4] [24]. Essa divergência pode fazer a equipe desinstalar, limpar dados ou filtrar logcat do pacote errado. Deve ser corrigida antes do próximo ciclo de suporte, mas não é diagnóstico do crash.

## 3. Hipóteses sobre o fechamento do APK

As hipóteses abaixo são caminhos de investigação. **Nenhuma é causa confirmada.** A confiança causal é baixa porque não há logcat do telefone físico.

1. **Falha nativa anterior ao Flutter ou durante o registro de plugins.** O processo pode morrer na criação da Activity, carregamento do engine, JNI, linker ou registro de algum plugin. Os handlers Dart não seriam suficientes nesse caso. O Manifest mesclado e o conjunto de plugins ampliam a superfície, mas não identificam um componente responsável [25].

2. **Falha no Android Keystore, `flutter_secure_storage`, Hive ou migração.** Essas operações são obrigatórias antes de a grade ficar pronta. Estado antigo, chave ausente, chave inválida, corrupção ou incompatibilidade de formato são possibilidades sustentadas pelo caminho de bootstrap. Uma exceção Dart capturável deveria direcionar para a tela de diagnóstico; uma morte nativa ainda exigiria logcat.

3. **Estado persistido ou atualização sobre instalação anterior.** Dados de versão antiga, assinatura diferente ou resíduos no dispositivo podem alterar o resultado. É necessário comparar instalação limpa, `pm clear` e atualização sobre dados sintéticos.

4. **Incompatibilidade de fabricante, API ou política do aparelho.** `minSdk=24`, `targetSdk=36`, orientação fixa, armazenamento seguro e permissões podem interagir de forma diferente em versões e fabricantes. Sem modelo e API, não há base para priorizar essa hipótese.

5. **Falha posterior ao bootstrap.** O app pode chegar ao primeiro frame e encerrar na splash, navegação, provider, widget ou serviço acionado imediatamente depois. O relato “fecha ao abrir” não distingue esse momento.

6. **TTS ou notificações como causa histórica.** Antes do ajuste de startup, esses serviços participavam do caminho crítico; no código atual foram adiados e têm captura própria. A mudança reduz a plausibilidade de uma exceção Dart desses serviços bloquear a primeira tela, mas não confirma nem elimina um erro nativo específico de plugin.

7. **Tamanho do APK release ou assinatura temporária.** A diferença entre Debug e Release é esperada. A assinatura temporária limita distribuição e atualização, mas não é evidência de que faltam recursos ou de que ela tenha causado o fechamento. Essa hipótese deve ser mantida como baixa e não orientar correções sem log.

## 4. Ações recomendadas

### P0 — evidência do Android e preservação do núcleo offline

1. **Fixar o artefato antes de testar.** Registrar branch, commit, versão, `applicationId`, SHA-256 calculado no APK efetivamente instalado, dispositivo, API, conectividade, permissões e horário. Não misturar os hashes históricos do handoff ou do MobSF com o APK atual.

2. **Reproduzir em aparelho físico saudável com instalação limpa.** Desinstalar a versão anterior, reiniciar o aparelho, instalar o APK release fixado e abrir offline. Confirmar primeiro frame, chegada à grade CAA e permanência utilizável. Repetir em pelo menos um tablet. O AVD quebrado não substitui esse teste.

3. **Se fechar novamente, coletar o logcat real do próprio aparelho.** Limpar o buffer imediatamente antes da tentativa e salvar a saída filtrada por pacote efetivo, `AndroidRuntime`, `FATAL EXCEPTION`, `flutter`, `libc`, `ActivityTaskManager`, `PackageManager` e `system_server`. Registrar somente metadados técnicos; não incluir nomes, frases, fotos, vídeos, áudios, tokens ou dados de criança. Sem esse artefato, o diagnóstico deve continuar “causa desconhecida”.

4. **Separar os estados de dados.** Executar instalação limpa, `pm clear` e atualização sobre dados sintéticos. Comparar logs e resultado antes de alterar a camada de persistência ou criptografia. Não trocar CBC, Hive ou Keystore apenas para testar uma explicação não confirmada.

5. **Manter backend, RH, sincronização, cobrança e publicação ampla fora do gate do incidente.** O fechamento é um problema de disponibilidade do app local até que evidência demonstre o contrário. Backend não deve ser usado como correção especulativa.

### P1 — contrato mínimo antes de qualquer backend real

6. **Escolher e documentar a infraestrutura de identidade e API antes de criar telas conectadas.** A solução deve usar contas individuais, sessão expirada e revogável, autenticação forte para perfis sensíveis e contexto de organização derivado no servidor. Não aceitar `organizationId`, papel, membership, consentimento ou autorização como fatos confiáveis enviados pelo cliente.

7. **Implementar o modelo de dados multi-organização.** As entidades mínimas são `User`, `Organization`, `Membership`, `ChildSubject`, `Relationship`, `Role`, `Permission`, `Purpose`, `Consent`, `Retention` e `AuditEvent`. Todo recurso compartilhado deve carregar a organização proprietária e uma classificação de sensibilidade. O identificador pseudonimizado da criança nunca deve autorizar acesso sozinho [20].

8. **Centralizar a decisão de autorização no servidor e negar por padrão.** Cada leitura, gravação, exportação, convite, download de mídia e mudança de consentimento deve validar sessão, conta, organização do recurso, membership vigente, relação com a criança, permissão específica, finalidade, escopo, consentimento, revogação e retenção. A resposta a quem não tem autorização deve ser genérica e não revelar se existe uma criança, mídia ou relatório em outra organização.

9. **Persistir auditoria mínima para sucesso e negação.** O servidor deve gravar ator, organização, operação, tipo e identificador técnico do recurso, finalidade ou motivo, resultado e timestamp UTC. O evento não deve conter frases, diagnósticos, cartões, fotos, áudios, vídeos, registros clínicos ou texto livre sensível. Retenção, descarte, integridade e acesso aos próprios eventos precisam ser definidos antes do piloto [16].

10. **Implementar testes de integração negativos antes de dados reais.** Os testes devem cobrir duas organizações, sessão ausente, conta inativa, membership cruzado, papel insuficiente, entitlement incompatível, convite expirado ou reutilizado, finalidade divergente, escopo ausente, consentimento revogado, prazo vencido, suporte sem aprovação/prazo/motivo, exportação RH proibida, URL temporária expirada e relatório abaixo do limiar. O teste deve chamar o servidor, não apenas esconder botões no navegador [6] [7].

11. **Separar entitlements comerciais de autorização de dados.** `organizationPortal`, `benefitAdministration`, `aggregateReporting` e `sponsoredLicense` não devem conceder acesso entre si. Licença patrocinada não autoriza conteúdo familiar, e portal RH não autoriza conteúdo clínico. O plano Essencial e a comunicação local devem continuar disponíveis quando a licença remota expirar, for suspensa ou revogada [11] [15].

12. **Tornar sincronização opt-in e não bloqueante.** O app local deve funcionar sem conta ou internet. Registros sincronizados devem carregar organização, sujeito, finalidade, consentimento, retenção e classificação. Mídia, quando autorizada, deve usar URLs temporárias e revogáveis; não deve haver caminho permanente ou exportação ampla por padrão [20].

### P1 — privacidade e segurança local, em trilha separada

13. **Corrigir a especificação e o teste de exclusão local antes de declarar apagamento completo.** Cobrir todas as caixas, inclusive rotina visual e lembretes parentais, todos os arquivos, a chave de mídia, licença, PIN, credenciais e diagnóstico. Verificar o resultado com dados sintéticos após reinicialização do app.

14. **Fechar os gates de release independentemente do crash.** Revisar migração e autenticidade do armazenamento Hive, decidir `minSdk` com matriz de dispositivos, revisar Manifest/receivers/permissões, executar nova varredura MobSF e concluir análise dinâmica/manual MASVS/MASTG. Não tratar score de scanner como diagnóstico do fechamento.

## 5. Critério de saída

O gate Android só pode avançar para teste técnico controlado quando uma instalação limpa chegar à grade CAA e permanecer utilizável offline em um celular e um tablet, com o artefato, dispositivo e evidência registrados. Os fluxos de seleção, frase, falar ou fallback, PIN, sessão e retorno do segundo plano devem ter sido observados. Se houver fechamento, o logcat do aparelho ou um relatório técnico sanitizado deve acompanhar a classificação; sem logcat, a causa permanece desconhecida.

O gate de backend só pode avançar para piloto quando houver uma API real com autenticação individual, isolamento multi-organização, autorização server-side, consentimento e retenção versionados, auditoria de sucesso e negação, testes negativos automatizados e sincronização opt-in. O console RH atual continua sendo protótipo. Nenhum dado real de criança deve ser usado para preencher essas lacunas.

## Confiança e limites

A confiança é **alta** para afirmar que o build foi documentado como aprovado, que o fechamento físico permanece sem causa confirmada, que o AVD não é reprodução válida, que não existe backend conectado neste checkout e que a autorização atual é lógica de domínio local. A confiança é **alta** para afirmar que o piloto RH está bloqueado sem endpoints reais, isolamento e enforcement no servidor, pois isso é declarado tanto nos checklists quanto no contrato do portal.

A confiança é **média-alta** para os riscos de persistência, exclusão local e limites da política, porque são observáveis nos arquivos e modelos consultados. A confiança é **baixa** para qualquer hipótese específica sobre o fechamento do APK. Nenhuma linha de log foi inventada e nenhum componente foi declarado como causa.

## Referências

[1]: ../../PROJECT_HANDOFF.md "Documento de transferência do projeto Fala Comigo"
[2]: ../../AGENTS.md "Instruções de desenvolvimento do Fala Comigo"
[3]: ../AUDITORIA_HANDOFF_E_ARTEFATOS_2026-09-24.md "Auditoria do handoff e artefatos Android"
[4]: ../RELATORIO_DIAGNOSTICO_BUILD_2026-09-24.md "Diagnóstico de build e instalação Android"
[5]: ../CONTINUIDADE_ASSISTENTE_IA.md "Continuidade para assistência por IA"
[6]: ../CHECKLIST_PILOTO_RH_CONTROLADO.md "Checklist do piloto RH controlado"
[7]: ../CONTRATO_PORTAL_RH_AUTORIZACAO.md "Contrato técnico do portal RH e autorizações"
[8]: ../CHECKLIST_EXECUCAO_E_TESTES.md "Checklist de execução, testes e prontidão"
[9]: ../../lib/main.dart "Inicialização Flutter e tela de diagnóstico"
[10]: ../../lib/core/services/secure_box_service.dart "Serviço de caixas Hive protegidas"
[11]: ../MODELO_PORTAL_RH_E_BENEFICIO.md "Modelo separado: portal RH e benefício familiar"
[12]: ../../lib/core/authorization/rh_authorization_policy.dart "Política local de autorização RH"
[13]: ../../lib/core/authorization/rh_elevated_access.dart "Política de acesso elevado RH"
[14]: ../../lib/core/authorization/rh_license_state_machine.dart "Máquina de estados de licença RH"
[15]: ../../lib/core/plans/plan_access_controller.dart "Controlador local de acesso por plano"
[16]: ../RH_AUDITORIA_E_RETENCAO.md "Auditoria e retenção do portal RH"
[17]: ../../test/rh_authorization_policy_test.dart "Testes unitários da política de autorização RH"
[18]: ../../test/rh_organization_isolation_test.dart "Testes unitários de isolamento organizacional"
[19]: ../../test/rh_elevated_access_test.dart "Testes unitários de acesso elevado RH"
[20]: ../MODELO_AUTORIZACAO_CLINICAS_ESCOLAS.md "Modelo de autorização para clínicas e escolas"
[21]: ../../lib/core/services/data_wipe_service.dart "Serviço de exclusão completa local"
[22]: ../team-review/05-05-architect.md "Revisão de arquitetura e persistência"
[23]: ../../security/reports/MOBSF_2026-09-24.md "Relatório MobSF do APK release de teste"
[24]: ../../README.md "README do projeto e identidade declarada do pacote"
[25]: ../../android/app/src/main/AndroidManifest.xml "Manifest Android do aplicativo"

**Resultado da revisão:** nenhum arquivo de código foi alterado; somente este relatório foi criado.
