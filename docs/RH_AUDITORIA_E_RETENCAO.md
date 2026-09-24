# Auditoria e retenção do portal RH

**Status:** contrato para protótipo e backend futuro
**Escopo:** eventos administrativos do portal RH; não inclui registros clínicos.

## Evento mínimo

Cada operação administrativa deve gerar um evento com `id`, `actorId`, `organizationId`, operação, tipo e id técnico do recurso, resultado, motivo e timestamp UTC. O evento não pode conter nome de criança, diagnóstico, frases, cartões, fotos, áudio, vídeo, registros ABC, frequência individual ou texto clínico livre.

Eventos de sucesso e de negação são importantes. Uma tentativa de exportar conteúdo, acessar outra organização ou consultar relatório abaixo do limiar deve deixar uma negação auditável, sem revelar o conteúdo ou a existência de uma conta familiar.

## Retenção inicial do protótipo

O protótipo não persiste eventos. Em backend futuro, a retenção deve ser definida por finalidade e contrato antes de produção. A proposta inicial é:

| Classe de evento | Finalidade | Retenção de referência | Regra de descarte |
| --- | --- | --- | --- |
| Segurança e autorização | investigar acesso indevido e incidentes | 180 dias após o evento | apagar ou anonimizar ao fim do prazo |
| Contrato e licença | provar estado administrativo do benefício | vigência do contrato + 90 dias | eliminar identificadores desnecessários |
| Atendimento administrativo | resolver solicitação do operador | 90 dias após encerramento | manter somente metadados necessários |
| Relatório agregado | governança do programa | 180 dias | suprimir grupos pequenos e apagar derivação individual |

Os prazos são uma hipótese técnica para revisão. Não devem ser tratados como política jurídica final. A definição de controlador, operador, base legal, encarregado, retenção e descarte exige revisão LGPD e contratual antes de produção.

## Controles obrigatórios

- limitar leitura por organização e papel;
- criptografar dados em trânsito e em repouso;
- restringir suporte elevado por tempo, motivo e aprovação;
- separar logs de aplicação e conteúdo familiar;
- impedir texto livre em campos de auditoria;
- monitorar exportações, tentativas negadas e alterações de papel;
- testar apagamento e expiração de retenção;
- manter relógio UTC e identificador técnico não interpretável;
- não usar eventos para inferir diagnóstico, adesão ou uso da criança.

## Resposta a titulares e incidentes

O futuro backend deve oferecer procedimento para localizar, corrigir, exportar e apagar dados administrativos dentro da finalidade aplicável. Um incidente deve preservar evidências técnicas sem copiar conteúdo familiar para o log. A triagem deve registrar organização afetada, operação, intervalo temporal, escopo técnico e medidas tomadas.
