# Baseline Android funcional — PR29

**Estado:** ponto oficial de continuidade para os próximos testes em aparelho.
**Branch:** `recovery/baseline-pr29-working`
**Base:** `fix/android-kotlin-plugin`
**Commit da base:** `3c107f3`
**PR de origem:** #29
**APK reconstruído:** `fala-comigo-pr29-baseline-debug.apk`
**SHA-256 do APK reconstruído:** `9aeda7ab61a98c45c4cf2124eb2dcee8d7a01f1d3bf3116e3a6d990d2f31ebfd`

## Decisão

Esta é a base funcional oficial para continuar a validação Android no aparelho. O APK reconstruído a partir desta linha abriu no dispositivo do usuário. Os testes funcionais realizados anteriormente pelo usuário no APK antigo também pertencem a esta linha Debug/Profile e devem ser considerados a evidência funcional existente.

A `main` atual não deve ser usada como substituta silenciosa desta baseline. Ela contém mudanças posteriores e a build Release AOT de 57 MB apresentou crash de inicialização no aparelho. A investigação dessa linha fica separada até que uma mudança seja incorporada e validada individualmente.

## O que está preservado

A base contém a correção do build Android Debug da PR #29 e a correção para evitar abertura duplicada de caixas Hive tipadas. A estrutura do APK reconstruído coincide com a estrutura do APK antigo enviado, incluindo os snapshots e bibliotecas características da build Debug/Profile.

## O que pode ter ficado fora

Funcionalidades e documentos adicionados depois do commit `3c107f3` não são automaticamente considerados parte desta baseline. Isso inclui mudanças posteriores na área parental, rotinas, planos, segurança, site e correções aplicadas à `main`. A ausência dessas mudanças é conhecida e aceitável nesta etapa; elas só devem voltar por cherry-pick ou implementação isolada, com novo APK e teste de abertura.

## Regras para a próxima etapa

1. Não misturar a baseline PR29 com a `main` em um único merge amplo.
2. Escolher uma única correção por branch.
3. Gerar APK Debug da branch antes de qualquer alteração seguinte.
4. Instalar sobre uma cópia controlada, preservando o APK baseline.
5. Testar primeiro somente abertura, primeira tela, cartões e fala.
6. Se abrir, executar o fluxo específico da mudança.
7. Se fechar, descartar a branch e retornar imediatamente a esta baseline.
8. Registrar commit, APK, SHA-256, aparelho e resultado.
9. Não gerar Release AOT até que a causa do crash da linha atual seja entendida.
10. Não integrar a baseline inteira na `main` sem uma decisão explícita sobre as funcionalidades posteriores que foram deixadas de fora.

## Sequência de recuperação

A próxima mudança recomendada é pequena e de baixo risco: reproduzir na baseline somente uma melhoria que seja necessária para o funcionamento atual, gerar um APK Debug e validar a abertura. Depois disso, as mudanças posteriores devem ser reincorporadas uma a uma, sempre com PR independente.

O APK antigo enviado pelo usuário permanece a referência histórica. O APK reconstruído pela CI é a referência reproduzível. Os hashes podem ser diferentes entre builds Debug sem indicar corrupção, pois o empacotamento e os metadados podem variar.


## Base unificada Android + Web

A branch `recovery/pr29-with-current-web` mantém o código Android da baseline PR29 e incorpora os arquivos `site/` atuais da `main`. Ela inclui a página institucional reformulada, privacidade, favicon e o protótipo RH publicados no GitHub Pages. A publicação oficial continua ocorrendo pela `main`; esta branch é a linha segura para futuras alterações coordenadas entre Android e Web.
