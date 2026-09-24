# Fala Comigo — Status de implementação do aplicativo e da web

**Data de referência:** 24 de setembro de 2026  
**Branch de registro:** `qa/manual-flow-execution-sheet`  
**Estado:** protótipo funcional em consolidação; ainda não é lançamento público nem operação conectada de produção

## Resumo executivo

O projeto possui dois produtos relacionados, mas não equivalentes. O **aplicativo** já contém um núcleo local-first de Comunicação Aumentativa e Alternativa (CAA), com funcionamento sem conta, sem pagamento e sem dependência de internet para a comunicação básica. A **web** já possui um site institucional publicado e um protótipo navegável do console RH com dados sintéticos, além de contratos e políticas locais que descrevem a futura autorização do backend.

O que ainda não existe é justamente a parte que transformaria a web em um serviço conectado de produção: backend, banco de dados remoto, autenticação, isolamento de organizações, autorização no servidor, consentimento versionado, auditoria operacional, suporte e ambiente controlado. Também falta validar o aplicativo em aparelhos reais e concluir os gates de acessibilidade, segurança e lançamento.

> **Regra de leitura:** uma tela, um contrato ou um teste local não deve ser apresentado como backend, integração ou serviço de produção. O portal RH continua sem acesso a frases, cartões, fotos, vídeos, áudios, registros clínicos ou métricas individuais da família.

## Legenda de status

| Status | Significado |
| --- | --- |
| **Feito** | Implementado ou publicado, com evidência no repositório ou no CI indicado. |
| **Em validação** | Existe implementação, mas ainda depende de aparelho real, revisão humana, acessibilidade ou evidência adicional. |
| **Protótipo** | Demonstra fluxo e arquitetura com dados sintéticos; não deve receber dados reais. |
| **Pendente** | Ainda precisa ser implementado ou definido. |
| **Bloqueado para produção** | Não deve avançar até cumprir autorização, privacidade, segurança, operação ou confirmação prevista. |

## Aplicativo: o que já foi feito

| Área | Situação atual | Evidência ou limite |
| --- | --- | --- |
| Núcleo CAA | **Feito** | Grade de cartões, categorias, montagem de frases e modos falar, adicionar e falar + adicionar. |
| Funcionamento offline | **Feito no núcleo** | A comunicação básica não exige conta, assinatura, internet ou Área do Responsável. |
| Voz | **Feito** | Síntese de voz usa o recurso disponível no dispositivo; falhas devem ser tratadas sem bloquear a comunicação. |
| Cartões personalizados | **Implementado; em validação** | Persistência local, seleção de mídia e fallback existem; permissões, cancelamento, arquivos inválidos e reinício ainda precisam de aparelho real. |
| Imagens, áudio e vídeo | **Implementado; em validação** | Mídias nativas novas usam armazenamento cifrado AES-GCM-256; o suporte a mídia personalizada na Web permanece limitado. |
| Área do Responsável | **Feito como módulo local** | Navegação, configurações, estados vazios e proteção parental estão implementados; a experiência ainda precisa de validação manual. |
| PIN parental | **Feito no código** | PBKDF2-HMAC-SHA256, salt aleatório, atraso progressivo e bloqueio temporário; falta validar primeira configuração e recuperação em aparelho real. |
| Sessão parental | **Feito no código** | Expiração e bloqueio ao sair do fluxo protegido; falta validar segundo plano, retorno, rotação e acesso direto em aparelhos. |
| Registros ABC | **Implementado; em validação** | Registros locais e exportação minimizada; falta testar PDF vazio, cancelamento, compartilhamento e escolha de identificadores. |
| Diário de vídeo | **Implementado; em validação** | Armazenamento e fallback existem; falta validar câmera, galeria, reprodução, arquivo corrompido, exclusão e uso offline. |
| Alertas e lembretes | **Implementado; em validação** | Alertas de transição e lembretes parentais com conteúdo genérico; falta validar permissões, tela bloqueada, fuso, cancelamento e áudio ausente. |
| Rotinas visuais | **Implementado; em validação** | Rotinas, interrupção e conclusão possuem suporte de domínio; falta observar leitura visual, tamanho, foco e recuperação. |
| Tendências e recompensas | **Implementado; em validação** | Existem telas e providers; devem ser revisados para evitar linguagem clínica, pressão, punição ou inferência sobre a criança. |
| Planos e licenças locais | **Feito como modelo local** | Catálogo, estados `invited`, `active`, `grace`, `suspended`, `expired` e `revoked`, persistência e controle de acesso local. Não há cobrança real. |
| Privacidade e exclusão | **Implementado; em validação** | Exclusão local de caixas, mídias, licença, PIN e chaves; falta executar o fluxo completo em aparelho e explicar que cópias exportadas não são apagadas. |
| Política de privacidade | **Feito como documentação pública** | Descreve armazenamento local, criptografia, mídia, voz, exportação e exclusão local. Deve ser revisada quando o comportamento mudar. |
| Testes automatizados | **Feito no CI observado** | Suíte de domínio, serviços e telas; a linha de base registrada contém 56 testes no ciclo RH e o ciclo anterior registrou 46 testes do app. O número deve ser conferido no check atual da PR antes de ser usado como evidência nova. |
| Análise de segurança | **Diagnóstico concluído; correções pendentes** | MobSF 4.5.4 registrou score 46, CBC associado ao HiveAesCipher, `minSdk=24`, `ProfileInstallReceiver` e warnings de permissões/strings. Os achados estão documentados e não foram ocultados. |

## Aplicativo: o que falta

### Validação de uso e acessibilidade

Ainda falta executar a ficha manual em um **celular Android e um tablet Android reais**, começando por F01–F07. A execução deve ocorrer com internet desligada e ligada quando aplicável, permissões concedidas e negadas, dados sintéticos e registro de versão, build, dispositivo e resultado.

Também falta a validação humana de TalkBack, VoiceOver, teclado, foco, contraste, tamanho dos alvos, escala de texto, orientação suportada, tempo de resposta, sobrecarga e recuperação após interrupções. Essa etapa precisa envolver, quando possível, pessoas usuárias de CAA, famílias e profissionais, sem transformar observações de uso em diagnóstico.

### Distribuição e operação

Ainda faltam build Android de release assinado com processo reprodutível, validação de instalação e atualização, revisão final de permissões, canal de suporte, resposta a incidentes, plano de rollback, teste fechado e decisão sobre publicação nas lojas. O APK usado no MobSF foi de teste e assinado por chave efêmera; não é build de produção.

### Segurança técnica

A migração do formato de criptografia local associado ao `HiveAesCipher` para modo autenticado continua pendente. Qualquer mudança precisa preservar dados existentes, ter migração segura, recuperação testada e estratégia de rollback. A decisão sobre elevar `minSdk` de 24 para 29 também continua pendente, pois deve considerar compatibilidade real e não apenas a pontuação do scanner.

Ainda precisam ser revisados o `ProfileInstallReceiver` com permissão `DUMP`, os warnings de armazenamento temporário, armazenamento externo, plugin de notificações e possíveis strings sensíveis. Não se deve remover funções importantes apenas para aumentar a nota do MobSF.

## Web: o que já foi feito

| Área | Situação atual | Evidência ou limite |
| --- | --- | --- |
| Site institucional | **Feito e publicado** | Site estático em `site/`, com textos de produto, privacidade, limites clínicos, planos e separação RH/família. O GitHub Pages foi habilitado e a URL pública foi validada com HTTP 200 no registro anterior. |
| Transparência de privacidade | **Feito como conteúdo público** | O site informa armazenamento local, ausência de upload automático, comunicação offline e limites do portal RH. |
| Separação RH e benefício familiar | **Feito como arquitetura e documentação** | A empresa pode contratar administração RH sem receber licença familiar; patrocínio de licença e portal administrativo são entitlements separados. |
| Console RH | **Protótipo** | Existe console navegável com dados sintéticos para demonstrar organizações, convites, licenças, indicadores agregados e limites de acesso. Não usa dados de produção. |
| Contrato de autorização RH | **Feito como contrato técnico local** | Define identidade, organização, membership, papéis, entitlements, finalidade, consentimento, licença, auditoria, retenção e acesso elevado. |
| Política RH e isolamento | **Feito como regras e testes locais** | Testes cobrem negações por organização, sessão, conta, papel, finalidade, escopo, prazo e limiar, além de estados de licença e eventos de auditoria. |
| CI/CD | **Feito no repositório** | Workflows de formatação, análise, testes, política de assinatura, build Web e publicação Pages existem; cada novo resultado deve ser verificado no check correspondente. |

## Web: o que falta

### Backend e dados conectados

Ainda falta implementar o backend real do portal. Isso inclui autenticação, usuários, organizações, memberships, convites com expiração, papéis, permissões, finalidade, consentimento versionado, retenção, revogação imediata, estados de licença e auditoria. Essas regras devem ser aplicadas no servidor, não apenas no Flutter ou no console.

Também faltam banco de dados, APIs, validação de sessão, proteção contra acesso entre organizações, ambiente separado para desenvolvimento e homologação, gestão de segredos, observabilidade mínima e processo de restauração. O primeiro ambiente deve usar dados sintéticos.

### Portal RH e benefício corporativo

Ainda falta transformar o protótipo em um console conectado de baixo risco. A primeira versão deve administrar apenas organizações, convites, licença, período, contrato e indicadores agregados autorizados. Deve impedir tecnicamente acesso a diagnóstico, nível de suporte, frases, cartões, fotos, vídeos, áudios, frequência individual, uso da criança e registros clínicos.

Ainda falta implementar a transição da família quando o vínculo corporativo termina. A revogação administrativa não pode apagar conta, mídias, configurações ou comunicação local. A família deve poder permanecer no modo offline, migrar para conta pessoal, trocar de patrocinador ou encerrar voluntariamente.

### Cuidado conectado e sincronização

Sincronização de registros clínicos, mídias, documentos ou dados de uso ainda não está implementada e permanece bloqueada para produção. Antes de considerar qualquer sincronização, será necessário definir controlador e operador, finalidade, base legal e consentimento, escopo, prazo, retenção, revogação, exportação, exclusão, URLs temporárias, auditoria e testes negativos no servidor.

### Cobrança, domínio e lançamento

Não existe cobrança real, provedor de pagamentos, assinatura automática ou integração financeira. A contratação do portal RH e o patrocínio de licenças continuam modelos de produto, não serviços comerciais ativos. Ainda faltam comparação de custos, taxas, cancelamento, portabilidade, tratamento de falhas e confirmação antes de ativar cobrança.

O site institucional está publicado em GitHub Pages, mas ainda faltam domínio final, revisão operacional do canal de suporte, monitoramento, resposta a incidentes e decisão de lançamento amplo. A publicação do site não significa que o aplicativo ou o portal estejam prontos para produção.

## Ordem recomendada a partir deste status

1. Executar F01–F07 no celular e no tablet Android com dados sintéticos.
2. Corrigir bloqueadores que possam interromper a comunicação, sem reduzir o escopo offline.
3. Executar F08–F17 e registrar privacidade, mídia, exclusão, alertas e licenças.
4. Fazer a revisão humana de acessibilidade e experiência com protocolo apropriado.
5. Reavaliar os achados MobSF e decidir a migração criptográfica e a compatibilidade de `minSdk`.
6. Consolidar build Android de teste e preparar piloto fechado sem dados reais.
7. Somente depois, implementar o backend RH em ambiente separado, começando por organizações e convites.
8. Adicionar autorização negativa no servidor, auditoria e retenção antes de qualquer dado conectado.
9. Deixar sincronização clínica, cobrança real e publicação ampla para fases posteriores, com revisão de privacidade e confirmação específica.

## Critério de pronto

O aplicativo poderá avançar para teste controlado quando o núcleo CAA funcionar offline em celular e tablet, os fluxos críticos não apresentarem bloqueadores, a acessibilidade mínima tiver sido observada e a exclusão local, a política e as permissões estiverem coerentes.

O portal RH poderá avançar para um piloto técnico somente quando existir backend separado com autorização no servidor, isolamento entre organizações, dados sintéticos, auditoria mínima, revogação testada e contrato de tratamento definido. Até lá, o console permanece um protótipo demonstrativo.

## Referências

[1]: ROADMAP_FULL_CYCLE.md "Roadmap full-cycle do Fala Comigo"
[2]: MATRIZ_FLUXOS_CRITICOS.md "Matriz de fluxos críticos"
[3]: FICHA_EXECUCAO_MANUAL_FLUXOS_CRITICOS.md "Ficha de execução manual dos fluxos críticos"
[4]: CONTINUIDADE_ASSISTENTE_IA.md "Continuidade, segurança e protocolo para novos agentes"
[5]: PLANO_SEGURANCA_OWASP_MASVS_MOBSF.md "Plano de segurança OWASP MASVS e MobSF"
[6]: ../security/reports/MOBSF_2026-09-24.md "Relatório sanitizado da linha de base MobSF"
