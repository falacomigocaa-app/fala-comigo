# Fala Comigo — Ficha de execução manual dos fluxos críticos

**Versão:** 1.0  
**Data de preparação:** 24 de setembro de 2026  
**Uso:** validação controlada com dados sintéticos  
**Status:** pronta para execução em aparelho real

## Objetivo e limite

Esta ficha transforma a matriz de fluxos críticos em um roteiro de execução observável. Ela deve ser preenchida em um celular Android e em um tablet Android antes de qualquer decisão de lançamento amplo. O roteiro verifica continuidade da comunicação, acessibilidade básica, recuperação após falhas e proteção dos dados locais.

A ficha não substitui avaliação de acessibilidade com pessoas que usam Comunicação Aumentativa e Alternativa (CAA), revisão por profissionais ou testes de segurança. Nenhum dado real de criança deve ser usado. Os registros devem conter apenas o identificador do dispositivo, a versão do aplicativo e observações técnicas não identificáveis.

## Regras de execução

Antes de começar, instalar uma versão limpa do aplicativo, registrar a versão e criar um conjunto sintético de cartões. Executar cada cenário primeiro com internet desativada. Quando o cenário exigir permissão, repetir com a permissão concedida e negada. Não inserir nomes reais, fotografias reais, vídeos reais, diagnósticos ou qualquer texto que identifique uma criança.

O resultado **Aprovado** exige que o fluxo conclua sem interromper a comunicação, sem expor dados indevidos e sem apagar dados após uma falha esperada. O resultado **Falhou** deve ser acompanhado de passos de reprodução, condição do dispositivo e evidência sintética. O resultado **Bloqueado** deve ser usado quando o aparelho, a versão ou a permissão necessária não estiver disponível.

## Identificação da execução

| Campo | Android celular | Android tablet |
| --- | --- | --- |
| Identificador sintético do aparelho |  |  |
| Fabricante e modelo |  |  |
| Versão do Android |  |  |
| Versão do aplicativo |  |  |
| Build ou commit |  |  |
| Orientação testada |  |  |
| Internet inicialmente desativada |  |  |
| Data e hora |  |  |
| Executor |  |  |

## Dados sintéticos permitidos

Use cartões como `Água`, `Pausa`, `Sim`, `Não`, `Dor`, `Banheiro` e `Ajuda`. Use a frase sintética `Quero água`. Para mídia, use arquivos sem informação pessoal, como uma imagem de teste criada para o roteiro e um áudio curto contendo apenas a palavra `teste`. Para o PIN, use um valor temporário que não seja reutilizado em nenhuma conta.

## Cenários prioritários F01–F07

| ID | Execução | Resultado esperado | Celular | Tablet | Observações e evidência |
| --- | --- | --- | --- | --- | --- |
| F01 | Abrir após instalação limpa, sem conta, sem internet, e entrar na grade CAA. | A grade abre sem login, cobrança ou internet. |  |  |  |
| F02 | Abrir cartões padrão, trocar categoria e retornar à categoria anterior. | Cartões e categorias aparecem de forma previsível; a troca não fecha o app. |  |  |  |
| F03 | Usar os modos falar, adicionar e falar + adicionar com `Água`. | Cada modo executa somente sua ação configurada e mantém a comunicação disponível. |  |  |  |
| F04 | Adicionar `Quero água`, remover um item, limpar a frase e montar uma frase longa sintética. | Adicionar, remover, limpar e falar funcionam; a frase não fica presa após repetição. |  |  |  |
| F05 | Criar cartão sintético com imagem de teste; negar permissão, cancelar seleção e reiniciar o app. | A negação ou cancelamento mostra recuperação clara; cartões existentes e configurações permanecem. |  |  |  |
| F06 | Criar PIN temporário, sair e tentar entrar com PIN inválido e depois válido. | Não existe PIN padrão; tentativa inválida não revela o PIN; PIN válido permite entrar no fluxo protegido. |  |  |  |
| F07 | Entrar na Área do Responsável, enviar o app ao segundo plano e retornar após a expiração configurada. | A sessão expira e exige nova autenticação; a grade CAA continua acessível sem a sessão parental. |  |  |  |

## Cenários de proteção e recuperação F08–F17

| ID | Execução | Resultado esperado | Celular | Tablet | Observações e evidência |
| --- | --- | --- | --- | --- | --- |
| F08 | Abrir cada entrada da Área do Responsável, voltar e verificar estados vazios. | Cada tela retorna corretamente e não apresenta conteúdo clínico inexistente como se fosse dado real. |  |  |  |
| F09 | Criar um registro ABC sintético, exportar sem identificadores, repetir com identificadores opcionais e cancelar. | A exportação informa o escopo; cancelamento não cria arquivo inesperado. |  |  |  |
| F10 | Adicionar mídia sintética, reproduzir, tentar arquivo inválido e excluir. | Falha de mídia não encerra o app; exclusão remove o item local conforme informado. |  |  |  |
| F11 | Criar alerta com conteúdo genérico, negar notificação e cancelar o alerta. | Notificação não revela conteúdo sensível; a negação não apaga configurações. |  |  |  |
| F12 | Criar rotina visual curta, concluir uma etapa, interromper e retomar. | O estado é compreensível e a interrupção não bloqueia a comunicação. |  |  |  |
| F13 | Criar lembrete parental sintético, verificar conteúdo privado e cancelar. | O lembrete não expõe dados na tela bloqueada além do texto genérico previsto. |  |  |  |
| F14 | Abrir tendências sem dados e com poucos dados sintéticos. | A tela explica ausência ou insuficiência de dados sem linguagem clínica ou promessa de resultado. |  |  |  |
| F15 | Usar recompensas de comunicação e tentar concluir sem responder. | A função não pune, não bloqueia cartões e não transforma comunicação em obrigação. |  |  |  |
| F16 | Alternar licença local sintética entre estados válidos e expirada. | A comunicação offline permanece disponível em todos os estados; somente recursos autorizados mudam. |  |  |  |
| F17 | Executar exclusão local completa e reabrir o app. | Caixas locais, mídia, licença, PIN e chaves são removidos conforme o escopo informado. |  |  |  |

## Acessibilidade e continuidade

Repetir F01–F04 com TalkBack ativado no Android. Verificar nome, ação e estado anunciados para cada cartão, controle de categoria, item da frase e botão de remoção. Repetir com tamanho de fonte aumentado e em orientação suportada. Observar se os alvos permanecem utilizáveis, se o foco é previsível e se nenhuma animação obrigatória impede uma ação.

Registrar separadamente qualquer sobrecarga, ambiguidade, atraso, foco perdido ou anúncio incorreto. Não interpretar uma observação de uso como diagnóstico ou conclusão clínica. A avaliação com pessoas usuárias de CAA deve ser organizada como atividade própria, com consentimento e protocolo adequado.

## Encerramento da execução

| Critério | Celular | Tablet |
| --- | --- | --- |
| F01, F02, F03, F04, F06 e F07 sem bloqueador |  |  |
| Falhas de permissão e mídia recuperáveis |  |  |
| Dados sintéticos somente |  |  |
| Comunicação offline preservada |  |  |
| TalkBack e escala de texto verificados |  |  |
| Evidências armazenadas fora do repositório quando sensíveis |  |  |
| Decisão da execução |  |  |

A decisão final deve ser uma destas: **apto para próxima rodada**, **requer correção**, ou **bloqueado por ambiente**. Uma execução manual não autoriza publicação ampla, sincronização clínica, cobrança ou ativação de portal em produção.

## Referências

[1]: MATRIZ_FLUXOS_CRITICOS.md "Matriz de fluxos críticos do Fala Comigo"
[2]: CHECKLIST_PRE_LANCAMENTO.md "Checklist de pré-lançamento do Fala Comigo"
[3]: CONTINUIDADE_ASSISTENTE_IA.md "Continuidade, segurança e protocolo para novos agentes"
