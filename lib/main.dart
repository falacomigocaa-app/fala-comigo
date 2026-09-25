import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/services/transition_alert_service.dart';
import 'core/services/secure_box_service.dart';
import 'core/services/parental_session_service.dart';
import 'core/services/tts_service.dart';
import 'core/theme/app_theme.dart';
import 'features/aac_grid/data/providers/cards_provider.dart';
import 'features/aac_grid/data/providers/seed_cards.dart';
import 'features/aac_grid/domain/models/pictogram_card.dart';
import 'features/onboarding/presentation/screens/splash_screen.dart';
import 'features/parental_area/presentation/screens/parental_gate_screen.dart';
import 'features/transition_alerts/data/providers/transition_alerts_provider.dart';
import 'features/transition_alerts/domain/models/transition_alert.dart';
import 'features/transition_alerts/presentation/screens/transition_alert_full_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CaaApp()));
  // A primeira tela não pode depender de plugins, armazenamento ou serviços
  // opcionais. O bootstrap continua depois que o Flutter já desenhou a UI.
  _bootstrap();
}

Future<void> _bootstrap() async {
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(PictogramCardAdapter().typeId)) {
      Hive.registerAdapter(PictogramCardAdapter());
    }
    final box = await SecureBoxService.openSecureBoxWithMigration(cardsBoxName);
    await SecureBoxService.openSecureBoxWithMigration('app_settings');
    await SecureBoxService.openSecureBoxWithMigration(transitionAlertsBoxName);

    if (box.isEmpty) {
      for (final card in SeedCards.defaultCards()) {
        await box.put(card.id, card);
      }
    }
  } catch (_) {
    // O app continua disponível mesmo se a migração/armazenamento precisar
    // de recuperação posterior. A falha não pode encerrar o processo nativo.
  }

  try {
    await TtsService.instance.init();
  } catch (_) {
    // TTS é opcional para a primeira abertura.
  }

  try {
    await TransitionAlertService.instance.init();
  } catch (_) {
    // Notificações são opcionais para a primeira abertura.
  }

  TransitionAlertService.instance.onAlertTriggered = (alertId) {
    final ctx = navigatorKey.currentContext;
    try {
      final alertsBox = Hive.box(transitionAlertsBoxName);
      final rawMap = alertsBox.get(alertId);
      if (rawMap != null) {
        final alert =
            TransitionAlert.fromMap(Map<String, dynamic>.from(rawMap as Map));
        navigatorKey.currentState?.push(
          MaterialPageRoute(
              builder: (_) => TransitionAlertFullScreen(alert: alert)),
        );
      } else if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir este alerta.')),
        );
      }
    } catch (_) {
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir este alerta.')),
        );
      }
    }
  };
}

class CaaApp extends StatefulWidget {
  const CaaApp({super.key});

  @override
  State<CaaApp> createState() => _CaaAppState();
}

class _CaaAppState extends State<CaaApp> with WidgetsBindingObserver {
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ParentalSessionService.onExpired = _showParentalGate;
  }

  @override
  void dispose() {
    if (ParentalSessionService.onExpired == _showParentalGate) {
      ParentalSessionService.onExpired = null;
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasInBackground = ParentalSessionService.isAuthenticated;
      ParentalSessionService.lock();
    } else if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      _showParentalGate();
    }
  }

  void _showParentalGate() {
    final navigator = navigatorKey.currentState;
    if (navigator == null || !mounted) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ParentalGateScreen()),
      (route) => route.isFirst,
    );
  }

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
