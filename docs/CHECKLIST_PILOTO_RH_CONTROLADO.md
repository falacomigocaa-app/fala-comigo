# Checklist do piloto RH controlado

**Status:** preparação; não autoriza produção
**Escopo:** console administrativo sintético e benefício patrocinado opcional.

Este checklist complementa o `docs/CHECKLIST_PRE_LANCAMENTO.md`. O piloto só pode usar dados sintéticos ou dados administrativos minimizados com aprovação formal. Não deve usar diagnóstico, conteúdo de comunicação, mídia, registros clínicos ou frequência individual.

## Critérios de bloqueio

O piloto não começa se qualquer item abaixo estiver pendente:

- backend real sem isolamento por organização e autorização no servidor;
- conta de suporte sem aprovação, motivo, escopo e prazo;
- possibilidade de RH acessar conteúdo familiar ou clínico;
- ausência de trilha de auditoria para sucesso e negação;
- retenção e descarte não definidos para a finalidade;
- consentimento ou contrato sem controlador, operador, finalidade e canal de titulares;
- cobrança, renovação automática ou cancelamento real não revisados;
- dados de produção misturados com fixtures, screenshots ou testes;
- indicador agregado capaz de reidentificar uma família;
- comunicação offline bloqueada por convite, licença ou indisponibilidade de servidor.

## Preparação técnica

| Item | Evidência esperada | Estado atual |
| --- | --- | --- |
| Console navegável | `site/rh/index.html` com aviso de protótipo | Concluído |
| Dados sintéticos | referências `A-014`, `B-027`, `C-031` e organização de demonstração | Concluído |
| Entitlements separados | `organizationPortal`, `benefitAdministration`, `aggregateReporting` e `sponsoredLicense` | Concluído |
| Política de autorização | negação por sessão, conta, organização, papel, finalidade, escopo, prazo e limiar | Concluído |
| Isolamento | testes de organização cruzada e papéis não administrativos | Concluído |
| Estados de licença | convite, ativo, transição, suspenso, expirado e revogado | Concluído |
| Auditoria mínima | evento sem conteúdo clínico, motivo e timestamp UTC | Concluído |
| Acesso elevado | aprovação, mesma organização, prazo máximo de duas horas e revogação | Concluído |
| Backend multi-organização | endpoints reais com enforcement no servidor | Pendente — bloqueador |
| Revisão LGPD e segurança | parecer, threat model, retenção final e resposta a incidentes | Pendente — bloqueador |

## Cenários obrigatórios

1. Uma empresa contrata somente o portal RH e não cria licença familiar.
2. Uma empresa patrocina licenças, mas o administrador vê apenas estado, validade e referências técnicas.
3. A família aceita ou recusa o benefício sem revelar diagnóstico ou uso individual ao empregador.
4. Um operador tenta acessar outra organização e recebe negação genérica.
5. Um operador tenta abrir frase, cartão, foto, áudio, vídeo, registro ou exportação familiar e recebe negação.
6. Um relatório abaixo do limiar mínimo é suprimido.
7. Um convite expirado não pode ser reativado; uma licença revogada é terminal.
8. Um suporte aprovado recebe somente escopo administrativo, por prazo curto e com evento auditável.
9. O servidor fica indisponível e a comunicação básica local continua funcionando.
10. A exclusão de uma licença patrocinada não apaga cartões, PIN, mídia ou dados locais da família.

## Dados e participantes

O piloto deve usar organizações fictícias, operadores com contas descartáveis, referências técnicas não interpretáveis e dados administrativos mínimos. Participantes devem receber instruções para não inserir nomes reais, diagnósticos, imagens, áudios, vídeos ou observações clínicas. Screenshots e relatórios do piloto devem passar por revisão antes de sair do ambiente controlado.

## Aprovação e encerramento

Antes de iniciar, registrar responsável pelo piloto, finalidade, período, organizações envolvidas, papéis, escopos, contatos de incidente e critério de interrupção. Ao encerrar, revogar acessos elevados, expirar convites, exportar somente métricas agregadas aprovadas, apagar fixtures e revisar eventos de auditoria.

O piloto pode avançar para a próxima fase somente se todos os cenários passarem, nenhuma tentativa de acesso indevido for bem-sucedida, a comunicação offline permanecer independente e a revisão LGPD/security remover os bloqueadores. Até lá, o console permanece um protótipo demonstrativo.
