import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/services/transition_alert_service.dart';
import 'core/services/tts_service.dart';
import 'core/theme/app_theme.dart';
import 'features/aac_grid/data/providers/cards_provider.dart';
import 'features/aac_grid/data/providers/seed_cards.dart';
import 'features/aac_grid/domain/models/pictogram_card.dart';
import 'features/onboarding/presentation/screens/splash_screen.dart';
import 'features/transition_alerts/data/providers/transition_alerts_provider.dart';
import 'features/transition_alerts/domain/models/transition_alert.dart';
import 'features/transition_alerts/presentation/screens/transition_alert_full_screen.dart';

/// Chave global de navegação: permite abrir uma tela (como o alerta
/// de transição em tela cheia) a partir de fora da árvore de widgets,
/// por exemplo quando uma notificação é tocada.
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Trava a orientação em Paisagem (Landscape), recomendado para
  // tablets e celulares usados como pranchas de comunicação.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Persistência local dos cartões.
  await Hive.initFlutter();
  Hive.registerAdapter(PictogramCardAdapter());
  final box = await Hive.openBox<PictogramCard>(cardsBoxName);

  // Caixa simples de configurações do app (ex: tema de hiperfoco
  // escolhido pelos pais).
  await Hive.openBox('app_settings');

  // Caixa dos Alertas de Transição de Atividade (configurações dos
  // alertas: áudio, horário, checklist).
  await Hive.openBox(transitionAlertsBoxName);

  // Primeiro uso: popula os pictogramas básicos que acompanham o app,
  // para que a criança já tenha cartões disponíveis antes mesmo dos
  // pais cadastrarem fotos personalizadas.
  if (box.isEmpty) {
    for (final card in SeedCards.defaultCards()) {
      await box.put(card.id, card);
    }
  }

  // Pré-inicializa o TTS para reduzir latência na primeira fala.
  await TtsService.instance.init();

  // Inicializa o serviço de notificações do Alerta de Transição.
  await TransitionAlertService.instance.init();

  // Quando uma notificação de Alerta de Transição é tocada, abre a
  // tela em tela cheia correspondente, buscando o alerta salvo pelo
  // ID recebido no payload da notificação.
  TransitionAlertService.instance.onAlertTriggered = (alertId) {
    final ctx = navigatorKey.currentContext;
    try {
      final alertsBox = Hive.box(transitionAlertsBoxName);
      final rawMap = alertsBox.get(alertId);
      if (rawMap != null) {
        final alert =
            TransitionAlert.fromMap(Map<String, dynamic>.from(rawMap as Map));
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => TransitionAlertFullScreen(alert: alert)),
        );
      } else if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
              content: Text(
                  'DIAGNÓSTICO: callback chamado, mas alerta não encontrado (id: $alertId)')),
        );
      }
    } catch (e) {
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('DIAGNÓSTICO: erro ao abrir alerta: $e')),
        );
      }
    }
  };

  runApp(const ProviderScope(child: CaaApp()));
}

class CaaApp extends StatelessWidget {
  const CaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Fala Comigo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
