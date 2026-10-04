# MobSF — análise estática do APK de teste da main

**Data do scan:** 03/10/2026; **commit analisado:** `21a981f6068a39e5658fd3f53f8a13bb5bbda037`; **workflow:** [run 37142972414](https://github.com/falacomigocaa-app/fala-comigo/actions/runs/37142972414); **scanner:** MobSF 4.5.4.
**Artefato:** APK de teste `com.falacomigo.fala_comigo`, versão 1.0.0; SHA-256 `0a070cda62635613c4bf3f12fb949b31071aa1b3a32503fcbd6ccb88ae9b1792`. O APK foi assinado no runner com uma chave efêmera de teste, não com assinatura de produção.

## Conclusão executiva

O workflow concluiu com sucesso porque conseguiu compilar e escanear o APK; isso **não** significa que o aplicativo passou no gate de segurança. O MobSF atribuiu score estático 46/100 e registrou achados altos, inclusive AES-CBC com padding PKCS5/PKCS7 e `minSdk=24`. Este resultado é uma fotografia do APK de `21a981f`, não um scan da branch atual nem uma aprovação de lançamento.

A origem do finding CBC merece uma distinção importante. A versão travada `flutter_secure_storage 9.2.4` usa `AES/CBC/PKCS7Padding` como cifra Android padrão, e o app usa a instância padrão do plugin ao guardar a chave Hive. Separadamente, `Hive 2.2.3` declara que `HiveAesCipher` usa AES-256-CBC com PKCS7. O relatório MobSF aponta uma classe Java ofuscada (`defpackage/s3.java:1277`); sem mapping de símbolos do APK não foi possível atribuir essa ocorrência a uma classe-fonte exata. Portanto, o achado MobSF não deve ser dado como corrigido apenas atualizando um dos dois componentes: **as duas camadas CBC precisam de plano e validação próprios**.

## Achados e triagem

As contagens abaixo vêm de seções distintas do MobSF e se sobrepõem; não devem ser somadas como se fossem vulnerabilidades independentes. A seção `appsec` reportou 2 high, 5 warning e 2 info; `code_analysis`, 1 high, 3 warning e 2 info; a análise de manifesto, 1 high e 1 warning. O scanner não identificou trackers.

| Severidade | Achado | Avaliação / ação necessária |
| --- | --- | --- |
| High | AES-CBC com padding PKCS5/PKCS7; CVSS 7.4, CWE-649; classe Java ofuscada `defpackage/s3.java`, linha 1277 | Finding real no APK. As versões das dependências travadas contêm CBC em dois caminhos: o armazenamento Android do plugin `flutter_secure_storage` e `HiveAesCipher`. O scanner não permite provar qual classe exata gerou esta referência. Planejar retirada/migração de ambas sem perder a chave Hive nem boxes existentes; não fazer upgrade direto nem reabrir dados antigos com chave substituta. Reexecutar MobSF no artefato corrigido. |
| High | `minSdk=24` (Android 7.0); scanner recomenda API 29 | Confirmado em `android/app/build.gradle.kts`/APK. Elevar para 29 excluiria aparelhos Android 7–9; não foi alterado automaticamente. A decisão deve ponderar segurança, alcance em famílias/escolas e política de suporte a dispositivos antes do AAB de produção. |
| Warning | `androidx.profileinstaller.ProfileInstallReceiver` exportado e protegido por `android.permission.DUMP` | Originado no manifesto/dependência Android. Inspecionar manifesto mesclado e versão/configuração do componente; confirmar proteção efetiva e se é possível desativar ou restringir sem quebrar profile installation. |
| Warning | Heurística de possíveis dados sensíveis/segredos em arquivos e strings | O relatório inclui candidatos que podem ser padrões/test vectors; nenhum valor foi copiado para este documento. Não há segredo confirmado por esse finding. Rastrear origem e remover valores reais se encontrados; manter saída bruta fora de documentação pública. |
| Warning | Criação de arquivos temporários | Achado em classes Android ofuscadas/de dependências. Identificar conteúdo, diretório, permissões e se dados do usuário passam por esses caminhos; não concluir exposição de conteúdo sem essa verificação. |
| Warning | Leitura/escrita em armazenamento externo | Encontrado em classes ofuscadas. Mapear a origem e os caminhos acessíveis; confirmar que conteúdo pessoal/CAA não é gravado em armazenamento público. |
| Info | Logging em várias classes, incluindo dependências e código gerado | Revisar se logs em builds de release podem carregar conteúdo, tokens ou dados identificáveis. O finding estático não prova que esses dados sejam registrados no fluxo do app. |
| Info | Cópia para clipboard | Identificar quem aciona o clipboard e garantir que frases/dados sensíveis não sejam copiados inadvertidamente. |

## Confirmação de algoritmos nas dependências

A API oficial de `flutter_secure_storage 9.2.4` define `AES_CBC_PKCS7Padding` como `storageCipherAlgorithm` padrão no Android e `resetOnError=false`. A distribuição oficial dessa versão contém `Cipher.getInstance("AES/CBC/PKCS7Padding")` em sua implementação Android. O app usa `const FlutterSecureStorage()` sem passar opções de cifra. Fonte: [AndroidOptions 9.2.4](https://pub.dev/documentation/flutter_secure_storage/9.2.4/flutter_secure_storage/AndroidOptions-class.html).

O código distribuído de `Hive 2.2.3` identifica `HiveAesCipher` como AES-256-CBC com PKCS7, IV aleatório de 16 bytes e verificação CRC associada à chave; isso não é uma tag AEAD de integridade por registro. Fonte da versão: [Hive 2.2.3](https://pub.dev/packages/hive/versions/2.2.3). A cifra CBC é usada para os arquivos Hive cifrados já tratados pelo app.

O changelog do plugin informa que 10.x migra os valores do armazenamento Android para defaults AES-GCM/RSA-OAEP, mas mantém compatibilidade/código legado CBC; 11.x remove a cifra antiga e requer que a migração intermediária tenha sido executada antes. Em 10.3.4, `resetOnError=true` e `migrateWithBackup=false` são defaults, portanto os defaults não são aceitáveis para a migração da chave que desbloqueia as boxes. Ver [changelog 10.3.4](https://pub.dev/packages/flutter_secure_storage/versions/10.3.4/changelog), [AndroidOptions 10.3.4](https://pub.dev/documentation/flutter_secure_storage/10.3.4/flutter_secure_storage/AndroidOptions-class.html) e [changelog 11.2.0](https://pub.dev/packages/flutter_secure_storage/versions/11.2.0/changelog). O método Android `checkUpgradeStatus()` de 11.2.0 é somente leitura: não recupera, migra nem apaga os dados; deve ser chamado antes de read/write para detectar certos upgrades diretos não decifráveis ([API](https://pub.dev/documentation/flutter_secure_storage/11.2.0/flutter_secure_storage/FlutterSecureStorage/checkUpgradeStatus.html)).

A investigação upstream inclui [issue #694](https://github.com/juliansteenbakker/flutter_secure_storage/issues/694) e [issue #1025](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1025), que documentam o alerta CBC e a compatibilidade temporária em v10. Há também um caso de regressão no Keychain Apple durante update 10.0→10.1 ([issue #1158](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1158)), com correção upstream no [PR #1183](https://github.com/juliansteenbakker/flutter_secure_storage/pull/1183); isso reforça a necessidade de validar todas as plataformas, não apenas Android.

## Plano de remediação seguro

1. Não atualizar diretamente `9.2.4 → 11.x` nem ativar uma migração global. Primeiro construir upgrade sintético de `9.2.4 → 10.3.4`, configurando explicitamente backup recuperável e `resetOnError=false`; provar leitura do mesmo valor da chave Hive, preservar o armazenamento original e testar cada estado de falha. Essa fase ainda deixa código CBC no plugin.
2. Somente depois de a migração intermediária ser comprovada, testar a transição para uma versão 11.x que remove CBC, incluindo detecção read-only de incompatibilidade antes da primeira leitura/escrita. Nunca tratar `checkUpgradeStatus()` como mecanismo de recuperação.
3. Em trilha separada, substituir ou encapsular o formato Hive CBC por formato autenticado AEAD, versionado, com staging, cópia/restauração validada, comparação de contagens/digests e rollback. O backup `.fcm-backup` existente é sidecar transacional e não backup do usuário. A implementação e os requisitos ainda estão descritos em [`HIVE_MIGRATION_BACKUP_PLAN.md`](../../HIVE_MIGRATION_BACKUP_PLAN.md).
4. Fazer testes de falha, upgrade e rollback apenas com fixtures sintéticas. A atualização não deve sobrescrever, zerar nem descartar caixas; não recomendar instalação sobre dados importantes enquanto o processo não estiver validado. Teste físico real continua sendo gate posterior do proprietário.
5. Revisar os warnings de manifesto, arquivos temporários, armazenamento externo, logging, clipboard e strings candidatas; fechar cada um com evidência ou registrar formalmente falso positivo/risco residual.
6. Reexecutar Flutter quality, gerar APK de teste com chave efêmera e MobSF; comparar artefatos pelo commit e SHA-256. Manter `minSdk` como decisão de produto documentada, não como ajuste automático ditado pelo scanner.

## Limitações e estado

O MobSF é análise estática do APK de teste. Não demonstra explorabilidade em runtime, não cobre todos os caminhos de dados e não substitui revisão do código, testes de migração, inspeção dinâmica, validação em dispositivo ou auditoria independente. A versão `21a981f` não recebe neste documento aprovação para distribuição Android. A migração Hive permanece desativada; assinatura produtiva/AAB, validação física e os demais gates de release continuam pendentes.

Nenhuma string detectada como possível segredo, dado de usuário ou linha de conteúdo do relatório bruto foi reproduzida aqui. A evidência bruta permanece fora do Git; este relatório registra somente hashes, títulos e resultados sanitizados.
