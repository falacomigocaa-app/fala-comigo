# Fala Comigo — Modelo de custos e planos

## Objetivo

O Fala Comigo será construído para ajudar famílias e pessoas que utilizam Comunicação Aumentativa e Alternativa. O preço deve ser compatível com essa finalidade. A sustentabilidade financeira será necessária para manter segurança, acessibilidade, suporte e continuidade do serviço, mas não deverá depender da venda de dados, de publicidade direcionada ou da exposição de informações de crianças.

A decisão principal é **reduzir o custo estrutural antes de definir preços**. O domínio será adquirido somente quando o produto estiver pronto para uma presença pública estável. Até lá, o projeto poderá usar os endereços temporários fornecidos pelo ambiente de desenvolvimento, hospedagem estática gratuita ou subdomínios técnicos adequados para testes.

## Princípios financeiros e de produto

1. **O modo local continua sendo o núcleo:** comunicação básica, cartões, frase, voz e configurações essenciais não devem exigir mensalidade nem servidor.
2. **O plano gratuito precisa ser útil:** ele não será apenas uma demonstração limitada. A família deve conseguir experimentar a comunicação com dignidade.
3. **Planos pagos financiam serviços adicionais:** sincronização opcional, suporte ampliado, armazenamento remoto e recursos de cuidado conectado não devem ser necessários para a comunicação básica.
4. **Privacidade não é um item premium:** criptografia, controle familiar e ausência de publicidade devem existir em todos os planos.
5. **Sem monetização de dados:** nenhum plano autoriza venda de dados, publicidade baseada em diagnóstico, perfilização clínica ou acesso corporativo ao conteúdo familiar.
6. **Subsídio é parte do produto:** empresas, instituições e doadores poderão financiar licenças sem receber o conteúdo das famílias.
7. **Custos variáveis precisam ser visíveis:** armazenamento, tráfego, mensagens, processamento e suporte serão acompanhados por unidade de uso.

## Arquitetura de menor custo

### Etapa inicial: aplicativo e site informativo

O aplicativo deve continuar distribuível sem backend obrigatório. O site institucional pode ser estático, com páginas de apresentação, política de privacidade, documentação, suporte e informações dos planos. Essa configuração reduz hospedagem, manutenção e superfície de ataque.

O domínio não é uma dependência inicial. A aquisição deve ocorrer somente depois de definidos o nome público, a política de privacidade publicada, o canal de suporte e o processo de lançamento. Antes disso, um endereço temporário é suficiente para validar conteúdo e navegação.

### Etapa seguinte: serviços conectados sob demanda

Quando houver necessidade real de conta, sincronização ou portal, será preferível usar serviços gerenciados com cobrança por uso e limites explícitos. O sistema não deverá manter servidores ociosos ou infraestrutura complexa antes de existir demanda.

A primeira versão conectada deve armazenar apenas o necessário para autenticação, licenças e autorizações. Mídias e registros sensíveis continuarão fora do servidor até que existam modelo de consentimento, retenção, exclusão, auditoria e autorização por recurso.

### Controle operacional

Cada serviço deverá ter limite de orçamento, alertas de consumo, retenção mínima e procedimento de desligamento. O produto deverá conseguir funcionar localmente mesmo se um serviço remoto estiver indisponível. Nenhuma falha de cobrança ou de rede pode interromper a comunicação da criança no modo offline.

## Proposta inicial de planos

Os nomes e preços abaixo são uma estrutura para validação. Não são preços finais. A tabela de custo real deverá ser calculada antes de publicar qualquer oferta.

| Plano | Público | Inclui | Não inclui por padrão |
| --- | --- | --- | --- |
| **Essencial** | Famílias que precisam começar sem custo | Uso local offline, cartões, frase, voz disponível no dispositivo, modos de toque, configurações parentais e recursos básicos de acessibilidade | Sincronização remota, armazenamento remoto e suporte prioritário |
| **Família** | Famílias que desejam conveniência adicional | Tudo do Essencial, mais recursos remotos opcionais com limites claros, histórico sincronizado selecionado, restauração e suporte padrão | Compartilhamento automático com clínicas, escolas ou empregadores |
| **Cuidado conectado** | Famílias que autorizaram uma rede de apoio | Tudo do Família, mais vínculos com profissionais ou escola, tarefas e registros com escopo, finalidade, prazo e revogação | Acesso global por papel, mídia aberta ou prontuário corporativo |
| **Patrocinado** | Famílias beneficiadas por empresa, instituto ou convênio | Acesso financiado total ou parcialmente, com os mesmos controles de privacidade da família | Acesso do patrocinador a diagnóstico, conteúdo, uso individual ou mídias |
| **Organização** | Clínicas, escolas e parceiros | Ferramentas administrativas, convites e acompanhamento somente dentro dos vínculos autorizados | Acesso automático a crianças ou conteúdo não autorizado |

O plano Essencial deve permanecer disponível mesmo quando uma licença patrocinada termina. O encerramento de um benefício não deve bloquear o modo local, apagar dados ou retirar da família o controle sobre a conta.

## Regras para o plano gratuito

O plano gratuito deve ser desenhado para não gerar um custo variável alto por usuário. Por isso, sua base deve ser local-first. Recursos que geram custos contínuos, como armazenamento de vídeos, serão limitados ou oferecidos como opcionais transparentes, sem retirar o acesso à comunicação.

Os limites devem ser compreensíveis. A família deverá saber o que permanece no dispositivo, o que é enviado, por quanto tempo fica armazenado, quanto espaço está sendo usado e como excluir ou exportar seus dados.

Não serão usados anúncios, venda de dados, bloqueios de acessibilidade ou notificações comerciais para pressionar uma família a pagar.

## Regras para planos pagos

Um plano pago deverá comprar conveniência, suporte e serviços operacionais. Ele não deverá comprar dignidade, privacidade ou a capacidade básica de se comunicar.

A cobrança deve ser simples e previsível. Não serão assumidos pagamentos anuais, reajustes, taxas de cancelamento ou consumo ilimitado antes de validar a capacidade de pagamento das famílias e os custos de infraestrutura.

Antes de lançar qualquer plano, a equipe deverá informar:

- o preço total e a periodicidade;
- os limites de armazenamento, tráfego e contas;
- os recursos que permanecem offline;
- os dados que podem sair do dispositivo;
- a forma de cancelamento;
- o que acontece com os dados e com o modo offline após o cancelamento;
- o canal de suporte;
- os impostos e eventuais custos de terceiros, quando aplicáveis.

## Subsídios e parcerias

O programa patrocinado será uma ferramenta de inclusão, não um mecanismo de vigilância. A organização patrocinadora poderá saber somente o necessário para administrar licenças, validade e custos agregados. Ela não deverá saber se uma determinada criança possui diagnóstico, quais cartões utiliza ou com que frequência se comunica.

Instituições sociais, universidades, empresas e doadores poderão financiar códigos de acesso ou lotes de licenças. A família deverá poder aceitar ou recusar o benefício sem revelar informação clínica ao patrocinador.

## Modelo de custos a validar

Antes de escolher fornecedores, será criada uma planilha de custo mensal com estas unidades:

| Unidade | Pergunta de controle |
| --- | --- |
| Usuário ativo | Quantos usuários realmente geram custo remoto? |
| Armazenamento | Quantos megabytes são criados, mantidos e excluídos por usuário? |
| Tráfego | Quantos downloads e uploads ocorrem por mês? |
| Autenticação | Qual é o custo por usuário ou por operação? |
| Notificações | Quais mensagens são necessárias e quais podem ser locais? |
| Suporte | Quanto tempo de atendimento cada plano exige? |
| Observabilidade | Quais logs são necessários sem armazenar conteúdo sensível? |
| Publicação | Quais taxas das lojas e serviços de distribuição existem? |

A margem de segurança deverá considerar crescimento inesperado, abuso, restauração, incidentes e variação cambial. Um preço só será aprovado depois de cobrir o custo esperado e uma reserva operacional sem tornar o acesso inviável para as famílias.

## Ordem recomendada de implantação

1. Manter o aplicativo local-first e validar os fluxos de comunicação.
2. Criar o site institucional estático sem comprar o domínio definitivo.
3. Publicar política de privacidade, suporte e descrição dos planos em ambiente de teste.
4. Medir custos com dados sintéticos e limites de uso.
5. Implementar conta e licenças somente quando houver necessidade comprovada.
6. Lançar o plano Essencial antes dos planos conectados.
7. Validar o plano Patrocinado com um parceiro pequeno e dados administrativos mínimos.
8. Comprar o domínio definitivo no momento do lançamento público, após a revisão de marca e operação.
9. Ativar o portal de cuidado conectado apenas depois dos testes de autorização negativa.

## Critério para escolher uma plataforma

A plataforma escolhida deverá ser comparada por custo total, não apenas pelo preço inicial. A avaliação deverá considerar custo variável, limites gratuitos, portabilidade dos dados, exportação, segurança, disponibilidade regional, suporte, facilidade de desligamento e risco de dependência do fornecedor.

A opção mais barata será a que mantém o núcleo local, reduz dados remotos, usa serviços simples e permite migrar sem reescrever o produto inteiro. Uma plataforma aparentemente gratuita que bloqueie os dados ou cobre caro quando o uso crescer não será considerada de baixo custo.

## Referências

[1]: ../README.md "README do aplicativo Fala Comigo"
[2]: CHECKLIST_PRE_LANCAMENTO.md "Checklist de pré-lançamento do Fala Comigo"
[3]: MODELO_AUTORIZACAO_CLINICAS_ESCOLAS.md "Modelo de autorização para clínicas e escolas"
[4]: MODELO_BENEFICIO_CORPORATIVO_PCD.md "Modelo de benefício corporativo para pessoas com deficiência"
