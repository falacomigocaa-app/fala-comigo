# Fala Comigo — Matriz de fluxos críticos

**Versão:** 1.0  
**Data:** 23 de setembro de 2026  
**Branch de elaboração:** `qa/critical-flow-matrix`

## Objetivo

Esta matriz transforma o checklist de pré-lançamento em uma sequência executável. Ela separa a evidência já obtida por testes automatizados da validação que ainda precisa ser realizada em aparelhos reais, com conectividade controlada e, quando possível, com famílias e profissionais de Comunicação Aumentativa e Alternativa.

A matriz não considera uma tela existente como prova suficiente de que o fluxo está pronto. Cada fluxo precisa de resultado, evidência, ambiente e observações. Nenhum teste deve utilizar dados reais de crianças.

## Evidência automatizada atual

Na branch integrada à `main`, a validação local com Flutter 3.38.0 apresentou formatação aprovada, análise estática sem falha bloqueadora, **46 testes aprovados** e build Web release concluído. O GitHub Actions também foi executado com sucesso no Pull Request de integração.

Os comandos de referência são:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build web --release
```

## Matriz de fluxos

| ID | Fluxo crítico | Evidência automatizada | Validação manual necessária | Status |
| --- | --- | --- | --- | --- |
| F01 | Primeira abertura e entrada na grade CAA | `test/splash_screen_test.dart` | Instalação limpa, sem conta, sem internet, celular e tablet | Parcial |
| F02 | Cartões padrão e categorias | `test/cards_category_filter_test.dart`, `test/cards_notifier_test.dart` | Tamanho dos alvos, contraste, foco e compreensão visual | Parcial |
| F03 | Modos falar, adicionar e falar + adicionar | `test/grid_card_semantics_test.dart`, testes da grade | Toque real, TalkBack/VoiceOver e uso por pessoa com deficiência | Parcial |
| F04 | Montagem, remoção e limpeza de frase | `test/sentence_bar_notifier_test.dart`, `test/sentence_bar_widget_test.dart` | Frase longa, orientação de tela e anúncio acessível | Parcial |
| F05 | Cartões personalizados | testes de persistência e serviços de mídia | Permissões concedidas/negadas, cancelamento, imagem inválida e reinício | Parcial |
| F06 | Criação e troca do PIN parental | `test/parental_pin_service_test.dart` | Primeira configuração, PIN fraco e recuperação em aparelho real | Parcial |
| F07 | Bloqueio e expiração da sessão parental | `test/parental_session_service_test.dart`, `test/parental_transition_screen_test.dart` | Segundo plano, retorno, rotação e tentativa de acesso direto | Parcial |
| F08 | Navegação da Área do Responsável | testes de telas parentais | Cada entrada abre e retorna; mensagens claras e estados vazios | Pendente manual |
| F09 | Registros ABC e exportação minimizada | testes de exportação existentes | PDF vazio, identificadores opcionais, compartilhamento e cancelamento | Parcial |
| F10 | Diário de vídeo e mídia nativa | `test/media_storage_service_test.dart`, testes de fallback | Câmera/galeria, arquivo corrompido, reprodução, exclusão e offline | Parcial |
| F11 | Alertas de transição | `test/transition_alert_test.dart` | Permissão negada, áudio ausente, notificação privada e agendamento | Parcial |
| F12 | Rotinas visuais | `test/visual_routine_provider_test.dart` | Leitura visual, tamanho, conclusão, interrupção e uso sem internet | Parcial |
| F13 | Lembretes parentais | `test/parent_reminders_test.dart` | Notificação no aparelho, fuso horário, cancelamento e conteúdo privado | Parcial |
| F14 | Tendências semanais | `test/weekly_trends_test.dart` | Interpretação compreensível, ausência de dados e linguagem não clínica | Parcial |
| F15 | Recompensas de comunicação | `test/communication_rewards_provider_test.dart` | Garantir que não haja punição, pressão ou bloqueio da comunicação | Parcial |
| F16 | Planos e licença local | `test/plan_access_controller_test.dart`, `test/plan_status_screen_test.dart` | Licença corrompida, expirada, revogada e comunicação offline | Parcial |
| F17 | Privacidade e exclusão local | `test/privacy_settings_screen_test.dart` e serviços de exclusão | Confirmar caixas, mídia, licença, PIN e chaves removidos | Pendente manual |
| F18 | Build Web e limitações de mídia | build Web aprovado | Abrir a URL, navegar, usar núcleo CAA e confirmar limites de mídia | Parcial |
| F19 | Atualização e persistência | testes de serviços e providers | Atualizar sobre versão anterior sem perder cartões ou configurações | Pendente manual |
| F20 | Acessibilidade geral | sem substituto completo em teste automatizado | TalkBack, VoiceOver, teclado, foco, contraste, alvos e baixa sobrecarga | Pendente manual |
| F21 | Celular Android | CI e testes unitários não substituem aparelho | Instalação, offline, permissões, voz, mídia e orientação | Pendente manual |
| F22 | Tablet Android | CI e testes unitários não substituem aparelho | Grade responsiva, paisagem/retrato, toque e acessibilidade | Pendente manual |
| F23 | iOS | sem validação local de dispositivo | VoiceOver, permissões, áudio, mídia e retorno de segundo plano | Pendente manual |
| F24 | Site institucional | workflow de Pages concluído e URL HTTP 200 | Links, responsividade, teclado, leitor de tela e textos públicos | Parcial |

## Ordem recomendada para execução manual

A validação manual deve começar pelos fluxos que podem interromper a comunicação: F01 a F07. Em seguida, devem ser executados F08 a F17, que cobrem a Área do Responsável, privacidade, mídia e planos. Por fim, devem ser validados F18 a F24 em Web, Android, tablet e iOS.

Cada execução deve registrar o dispositivo, sistema operacional, versão do aplicativo, conectividade, permissões, resultado e evidência. Screenshots só podem usar dados sintéticos ou previamente autorizados; nenhum dado identificável de criança deve entrar no repositório, em issues ou em documentos públicos.

## Critérios de aprovação

Um fluxo pode ser marcado como **Aprovado** quando a execução correspondente passa no ambiente definido, não interrompe a comunicação, não expõe dados indevidos e possui evidência registrável. Um fluxo **Parcial** possui testes automatizados, mas ainda depende de aparelho real ou observação humana. Um fluxo **Pendente manual** ainda não possui evidência suficiente fora do código.

A versão não deve ser considerada pronta para lançamento amplo enquanto F01, F02, F03, F04, F06, F07, F10, F11, F17, F20, F21 e F22 não estiverem aprovados. A publicação do site não substitui a validação do aplicativo em aparelhos reais.

## Próximo ciclo

O próximo ciclo deve executar a [ficha operacional para Android celular e tablet](FICHA_EXECUCAO_MANUAL_FLUXOS_CRITICOS.md), começando pelos fluxos F01 a F07. Depois da execução, os resultados devem ser anexados a esta matriz e ao documento `docs/CONTINUIDADE_ASSISTENTE_IA.md`, mantendo o checklist de retomada atualizado. A ficha é um roteiro e não constitui evidência de que os aparelhos já foram testados.
