# Fala Comigo — Plano de execução para release Android

**Versão:** 1.0
**Data:** 24 de setembro de 2026
**Estado da main:** `4399a79`
**Objetivo:** conduzir a validação do APK/AAB de produção com gates verificáveis, sem misturar correções de produto, segurança, assinatura e publicação na mesma etapa.

## Decisão operacional

A `main` está limpa e os workflows de qualidade Flutter e GitHub Pages estão aprovados. Isso significa que a linha de base de código e Web está consistente. Ainda não significa que o Android esteja pronto para distribuição.

Nenhum APK/AAB de produção deve ser considerado aprovado antes de passar por este plano. Cada fase deve produzir evidência identificável por commit, ambiente, versão e SHA-256. Quando uma fase falhar, o fluxo retorna à fase responsável; não se contorna um gate para avançar.

> **Regra de segurança:** a comunicação básica, a acessibilidade, os controles parentais e o funcionamento offline nunca podem ser removidos ou bloqueados apenas para melhorar uma métrica de segurança ou facilitar o release.

## Estado e critérios de decisão

Os estados possíveis de uma fase são:

- **Não iniciada:** ainda não há execução registrada.
- **Em execução:** existe uma branch ou run identificado, mas a evidência ainda não foi revisada.
- **Aprovada:** todos os critérios de saída estão atendidos e a evidência foi registrada.
- **Bloqueada:** existe uma falha, uma decisão pendente ou uma dependência externa ausente.
- **Reprovada:** a execução apresentou um defeito que exige correção antes de repetir a fase.

Somente fases **Aprovadas** liberam a fase seguinte. “Documentado”, “compila no Web” ou “parece funcionar” não substituem uma aprovação com evidência.

## Fases do próximo ciclo

| Fase | Objetivo | Evidência obrigatória | Saída que libera a próxima fase |
| --- | --- | --- | --- |
| 0. Linha de base | Fixar commit, versão e estado limpo | SHA do commit, `git status`, lista de mudanças e versão do Flutter | Branch de trabalho criada a partir da main limpa |
| 1. Armazenamento e migração | Fechar riscos de Hive, CBC e recuperação | Testes de caixa legada, chave inválida, corrupção, rollback e interrupção | Nenhuma perda destrutiva sem recuperação definida |
| 2. Mídia e privacidade local | Fechar temporários e arquivos legados | Testes de reprodução, corrupção, exclusão, wipe e compartilhamento | Mídia ausente ou inválida não interrompe a comunicação |
| 3. Android e Manifest | Confirmar compatibilidade e permissões | Manifest mesclado, `minSdk`, `targetSdk`, componentes, permissões e backup | Decisão registrada sobre cada permissão e API mínima |
| 4. Pipeline de release | Gerar artefato rastreável | APK/AAB, assinatura, `applicationId`, versão, SHA-256 e logs sem dados reais | Artefato de teste reproduzível e não-debug |
| 5. Dispositivos reais | Validar fluxos críticos em celular e tablet | Ficha F01–F24 com dispositivo, sistema, conectividade, permissões e resultado | F01, F02, F03, F04, F06, F07, F10, F11, F17, F20, F21 e F22 aprovados |
| 6. Segurança do artefato | Revisar o APK/AAB com MASVS/MobSF | Relatório sanitizado, SHA-256, achados classificados e decisões | Nenhum achado alto sem decisão e plano aprovado |
| 7. Gate de release | Consolidar todas as evidências | Checklist assinado no PR de release e revisão técnica | Candidato de distribuição controlada |
| 8. Publicação controlada | Distribuir somente após autorização | Canal, versão, changelog, suporte e plano de rollback | Publicação limitada e monitorada |

## Fase 0 — Linha de base

A execução começa sempre com `main` atualizada e limpa. O agente deve registrar o commit de origem, a versão do Flutter usada pelo CI, a versão do aplicativo e a branch de trabalho. Nenhuma correção deve ser feita diretamente na `main`.

A branch deve conter uma alteração pequena e um objetivo único. Correções de armazenamento, mudanças de permissões, alterações de UI e configuração de assinatura devem usar branches separadas quando puderem ser revisadas de forma independente.

## Fase 1 — Armazenamento, criptografia e recuperação

Antes de gerar o artefato final, deve ser revisado o comportamento de `SecureBoxService`. O código não pode apagar uma caixa cifrada antes de distinguir chave ausente, corrupção, formato legado e falha de autenticação.

A implementação deve ter caminho de recuperação ou rollback. A migração deve ser compatível com dados existentes e deve ser testada sem dados reais. A troca do algoritmo ou do formato de armazenamento fica bloqueada até que exista um plano de migração, recuperação e compatibilidade.

Os testes mínimos são:

1. abrir uma caixa nova;
2. abrir uma caixa legada válida;
3. rejeitar uma chave incorreta sem apagar a origem;
4. detectar corrupção sem transformar silenciosamente a caixa em armazenamento não cifrado;
5. interromper uma migração e recuperar o estado anterior;
6. executar o wipe e confirmar que cartões padrão continuam disponíveis.

## Fase 2 — Mídia e privacidade local

A mídia descriptografada para reprodução ou compartilhamento deve permanecer em diretório privado e ter limpeza em `finally`. O aplicativo deve remover temporários órfãos em pontos seguros, sem apagar uma mídia que ainda esteja em uso.

Arquivos legados sem marcador de formato devem ser reconhecidos como legado. A conversão não deve ocorrer automaticamente sem teste de recuperação e compatibilidade. O sistema deve distinguir ausência, corrupção e formato não suportado.

A evidência deve cobrir mídia válida, ausente, corrompida, excluída, interrompida, compartilhada, cancelada e removida pelo wipe. Cópias entregues a aplicativos externos devem ser descritas como fora do controle do Fala Comigo.

## Fase 3 — Android, Manifest e compatibilidade

A validação deve usar o Manifest mesclado produzido pelo build, porque plugins podem adicionar permissões e componentes. Devem ser registrados `minSdk`, `targetSdk`, `applicationId`, atividades, receivers, serviços, componentes exportados e regras de backup.

Cada permissão deve ter uma função correspondente e um teste de permissão concedida e negada. A decisão sobre `READ_MEDIA_IMAGES`, câmera, áudio, notificações, alarmes exatos, tela cheia e inicialização após reboot deve considerar o comportamento real do aplicativo e a compatibilidade do aparelho.

A decisão sobre `minSdk=24` deve ser registrada antes do release. Elevar o mínimo sem a matriz de aparelhos não é permitido, porque pode excluir famílias que dependem do aplicativo.

## Fase 4 — Pipeline e artefato de release

O pipeline deve gerar APK e AAB com configuração de produção, sem chave debug. A chave de produção deve permanecer em secret manager autorizado e não pode aparecer no repositório, nos logs ou nos relatórios públicos.

Cada artefato deve ser acompanhado por:

- commit de origem;
- nome e versão do aplicativo;
- `versionCode`;
- tipo de artefato;
- assinatura verificada;
- SHA-256;
- data e run do workflow;
- resultado da inspeção do Manifest.

O artefato de produção não deve ser enviado ao repositório. Quando for usado em MobSF, o upload deve ocorrer em ambiente controlado e sem dados reais.

## Fase 5 — Validação em dispositivos reais

A validação começa com dados sintéticos, conectividade controlada e uma instalação limpa. Depois deve ser repetida como atualização sobre uma versão anterior de teste. O celular e o tablet devem ser registrados com modelo, versão do Android, tamanho de tela e permissões.

Os fluxos prioritários são a abertura inicial, cartões, modos de toque, frases, PIN, sessão parental, mídia, alertas, exclusão, acessibilidade e uso offline. Devem ser testados retorno do segundo plano, rotação quando aplicável, permissões negadas, áudio indisponível, notificações bloqueadas e arquivos corrompidos.

Nenhum fluxo pode ser marcado como aprovado apenas porque existe uma tela ou um teste unitário. A matriz `docs/MATRIZ_FLUXOS_CRITICOS.md` deve receber resultado, ambiente, evidência e observações para cada execução.

## Fase 6 — MobSF e MASVS

A análise deve ser executada no artefato correspondente ao candidato de release. O relatório deve registrar versão do MobSF, SHA-256, tipo de assinatura e escopo da análise. APK efêmero de teste e artefato de produção não devem ser tratados como equivalentes.

Cada achado deve ser classificado como aplicável, falso positivo justificado, dívida técnica aceita ou bloqueador. Achados altos bloqueiam a distribuição até que exista correção ou decisão formal com risco, impacto, compatibilidade e prazo.

O status público permitido permanece **“varredura concluída; achados em revisão”** enquanto a análise não for encerrada por evidência suficiente. A varredura não é certificação MASVS, auditoria independente ou aprovação da OWASP.

## Fase 7 — Gate único de release

O PR de release só pode ser aprovado quando todos os itens abaixo estiverem presentes:

- main limpa e CI verde;
- análise e testes Flutter aprovados;
- build Web aprovado;
- APK/AAB não-debug rastreável;
- assinatura e SHA-256 verificados;
- Manifest mesclado revisado;
- armazenamento e mídia testados;
- celular e tablet aprovados nos fluxos bloqueadores;
- acessibilidade observada;
- MobSF revisado;
- política de privacidade coerente com o comportamento real;
- rollback e suporte definidos;
- nenhuma credencial ou dado real no repositório, artefato público ou log.

A aprovação deve ocorrer no PR, não por mensagem informal ou por alteração direta na `main`.

## O que permanece bloqueado

Até o fechamento do gate de release, não devem ser iniciados cobrança real, sincronização clínica, backend RH de produção, integração com sistemas de RH, publicação ampla ou uso de dados reais de crianças. Essas etapas exigem gates próprios de segurança, privacidade, contrato, operação e validação humana.

## Registro obrigatório por agente

Cada agente que atuar no projeto deve ler este documento, o handoff, o `PROJECT_HANDOFF.md`, a matriz de fluxos e o plano MASVS/MobSF. Ao terminar, deve registrar branch, commit, mudanças, comandos, resultados, limitações e próximo gate. Nunca deve afirmar que um teste passou sem saída recente ou substituir validação de aparelho por inferência de código.

## Referências

[1]: https://mas.owasp.org/MASVS/ "OWASP MASVS"
[2]: https://mas.owasp.org/MASTG/ "OWASP MASTG"
[3]: https://github.com/MobSF/Mobile-Security-Framework-MobSF "MobSF — Mobile Security Framework"
[4]: https://github.com/falacomigocaa-app/fala-comigo/blob/main/docs/MATRIZ_FLUXOS_CRITICOS.md "Fala Comigo — Matriz de fluxos críticos"
[5]: https://github.com/falacomigocaa-app/fala-comigo/blob/main/docs/PLANO_SEGURANCA_OWASP_MASVS_MOBSF.md "Fala Comigo — Plano de segurança OWASP MASVS e MobSF"
