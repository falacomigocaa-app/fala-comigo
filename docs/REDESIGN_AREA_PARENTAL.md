# Redesign da Área do Responsável e evolução de localização

**Data:** 23 de setembro de 2026
**Branch de trabalho:** `feat/parental-dashboard-reliability`
**Escopo deste incremento:** dashboard parental, correção do fluxo Novo Cartão, orientação configurável, preparação honesta da localização e confiabilidade inicial dos alertas.

## Estrutura visual aprovada

A Área do Responsável passa a ser organizada como um dashboard de trabalho, não como uma lista vertical contínua. O cabeçalho contém o nome do painel e a ação principal **Novo cartão**, evitando que um botão flutuante cubra conteúdo ou seja perdido em telas pequenas.

A primeira seção é **Localização & Segurança**. Ela apresenta um hero card com pré-visualização visual de mapa, estado de conectividade e linguagem explícita de que nenhum local é mostrado enquanto o consentimento e a conexão segura não estiverem configurados. A prévia não simula uma posição real. O produto deve evoluir depois para um painel web autenticado com mapa, última atualização, nome do local, bateria e histórico, somente após existir o serviço do aparelho da criança e uma política de consentimento.

A segunda seção é **Acompanhamento & Relatórios**, com quatro cards de ação em composição 2x2 quando houver espaço: Tendências Semanais, Relatórios em PDF, Diário de Vídeo e Rotina Visual Diária. Cada card usa ícone em bolha, cantos arredondados, descrição curta e navegação direta.

As configurações de acessibilidade permanecem em uma seção própria, com slider de tamanho, comportamento de toque e escolha de orientação da prancha infantil. A explicação informa por que paisagem é recomendada e permite escolher vertical localmente. A orientação parental permanece livre para retrato e paisagem; a prancha infantil retorna à preferência salva ao sair do painel.

## Localização: decisão de arquitetura

A localização não deve ser inventada nem implementada como um mapa decorativo com dados falsos. A solução futura será separada em quatro camadas:

1. **Aplicativo da criança:** solicitação explícita da permissão de localização, coleta em background somente com consentimento e indicador claro de estado.
2. **Transporte seguro:** API autenticada, criptografia em trânsito, rotação de sessão, controle de acesso por família e retenção mínima.
3. **Painel web do responsável:** login, autorização por perfil, mapa, última atualização, bateria, histórico e revogação de acesso.
4. **Privacidade e governança:** consentimento versionado, auditoria, exclusão, janela de retenção e modo sem localização.

Essa camada não faz parte do núcleo offline da comunicação. O app deve continuar funcionando sem conta, internet ou plano pago.

## Alterações implementadas neste incremento

| Área | Alteração | Estado |
| --- | --- | --- |
| Dashboard | Hero de Localização & Segurança sem posição falsa | Implementado |
| Dashboard | Cards 2x2 para tendências, PDF, vídeo e rotina | Implementado |
| Novo cartão | Ação movida para o cabeçalho | Implementado |
| Novo cartão | Remoção de `Spacer` dentro de `SingleChildScrollView` | Implementado |
| Novo cartão | Salvamento aguardável, estado de carregamento e erro | Implementado |
| Cartões | Ordem usa o maior índice existente + 1 | Implementado |
| Cartões | Edição atualiza `isCustomImage` corretamente | Implementado |
| Orientação | Preferência local vertical/paisagem em `app_settings` | Implementado |
| Android | Removido bloqueio nativo permanente em paisagem | Implementado |
| Alertas | Payload de cold start fica pendente até o callback | Implementado |
| Alertas | Inicialização Darwin e detalhes iOS adicionados | Implementado |
| Alertas | Full-screen e localização web reais | Pendente de validação nativa/backend |

## Comandos executados e evidências

```bash
git switch -c feat/parental-dashboard-reliability

dart format lib/main.dart \
  lib/core/services/app_orientation_service.dart \
  lib/core/services/transition_alert_service.dart \
  lib/features/aac_grid/data/providers/cards_provider.dart \
  lib/features/parental_area/presentation/screens/add_card_screen.dart \
  lib/features/parental_area/presentation/screens/settings_screen.dart

flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build apk --debug
```

A primeira execução revelou dois erros estruturais de edição: um marcador `EOF` no serviço de orientação e uma chave fora da classe `SettingsScreen`. Ambos foram corrigidos. A segunda execução terminou com código 0: análise, testes e build APK passaram.

APK gerado:

```text
/home/ubuntu/fala-comigo-parental-dashboard.apk
SHA-256: 1cbf5282c0673e5b93094fc68998377613cab8aa2927f79ec4039cfbb97230c6
```

## Pendências para a próxima IA/equipe

A próxima etapa deve começar lendo este arquivo e `docs/CONTINUIDADE_ASSISTENTE_IA.md`, verificando a branch e executando novamente o CI. Depois deve:

- testar o APK em celular e tablet Android, especialmente abrir o painel, orientação vertical, Novo Cartão e retorno à grade;
- validar os alertas com app aberto, em background, encerrado, tela bloqueada, permissões negadas e aparelho reiniciado;
- terminar o contrato de data única versus recorrência semanal, timezone e IDs persistentes;
- aplicar tokens de tema e testes de contraste para todos os temas;
- melhorar a tela parental com escala de texto, Semantics, TalkBack/VoiceOver e reduced motion;
- somente depois especificar e construir o backend/painel web de localização com consentimento, autenticação e auditoria.

Não declarar localização em tempo real, full-screen no Android ou overlay no iOS como concluídos sem evidência em dispositivo e sem a infraestrutura correspondente.
