# Instruções de desenvolvimento do Fala Comigo

## Autonomia de execução

O responsável pelo projeto autorizou o programador a continuar as próximas etapas de produto e engenharia sem solicitar confirmação a cada decisão incremental.

O programador deve escolher a próxima tarefa de maior valor técnico e de menor risco, implementar em branch de trabalho, adicionar ou atualizar testes, executar as validações disponíveis, revisar o diff, criar commit e enviar a branch ao GitHub.

### Leitura obrigatória na retomada

Antes de qualquer alteração, todo agente ou assistência por IA deve ler [`CONTINUAR_AQUI_PRIMEIRO.md`](CONTINUAR_AQUI_PRIMEIRO.md), este arquivo, `PROJECT_HANDOFF.md` e o handoff específico da etapa em `docs/`. O aviso de continuidade registra a causa atual da tela branca, as branches que não devem ser mescladas diretamente e a ordem segura de validação.

Ao concluir cada etapa, o agente deve atualizar `CONTINUAR_AQUI_PRIMEIRO.md`, o handoff específico em `docs/` e `docs/CONTINUIDADE_ASSISTENTE_IA.md`, registrando branch, commit, comandos, resultado, limitações e próximo gate. Nenhuma etapa pode ser descrita como concluída sem evidência recente.

## Ordem de prioridade

1. Corrigir falhas que possam interromper a comunicação da criança.
2. Proteger privacidade, armazenamento local, exclusão e autorização.
3. Melhorar acessibilidade, previsibilidade e uso offline.
4. Aumentar cobertura de testes e reprodutibilidade do CI.
5. Evoluir o site e o portal web com arquitetura de baixo custo.
6. Preparar publicação, suporte e operação.

## Quando interromper e pedir decisão

Não interromper por escolhas técnicas reversíveis ou por detalhes de implementação. Pedir decisão somente quando houver uma ação externa de alto impacto, uma alteração irreversível, necessidade de nova credencial, mudança de cobrança, publicação ampla, compra de domínio, contratação de serviço, exclusão de dados ou uma escolha de produto que altere materialmente a intenção do responsável.

A aquisição do domínio e a contratação de plataformas pagas ficam adiadas até a etapa de lançamento e só devem ocorrer depois de comparar custos, limites, portabilidade e necessidade real.

## Padrão de entrega

Cada mudança deve manter a `main` protegida e seguir o fluxo:

```text
issue ou objetivo → branch → implementação pequena → testes → análise → revisão do diff → commit → push → Pull Request
```

Nenhuma alteração deve ser descrita como concluída sem evidência de validação. Quando uma ferramenta necessária não estiver disponível no ambiente local, registrar a limitação e usar o CI ou outra validação apropriada antes de afirmar que a entrega passou.

## Restrições do produto

O aplicativo local-first deve continuar útil sem internet. A comunicação básica não pode depender de conta, servidor ou plano pago. Dados sensíveis não devem ser vendidos, usados para publicidade ou expostos a patrocinadores. O portal conectado só pode conceder acesso quando existir organização, vínculo, finalidade, consentimento, prazo e autorização no servidor.
