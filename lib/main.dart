import 'dart:async';

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

/// Chave global de navegação: permite abrir uma tela (como o alerta
/// de transição em tela cheia) a partir de fora da árvore de widgets,
/// por exemplo quando uma notificação é tocada.
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A orientação é uma preferência de plataforma e não deve impedir o
  // Flutter de renderizar a primeira tela se o Android demorar ou falhar.
  unawaited(
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]),
  );

  // Renderiza o aplicativo imediatamente. Hive, armazenamento seguro e
  // migrações são executados pela BootstrapScreen após o primeiro frame.
  runApp(const ProviderScope(child: CaaApp()));
}

Future<void> _initializeOptionalServices() async {
  try {
    await TtsService.instance.init();
  } catch (_) {
    // O serviço tenta inicializar novamente quando for usado.
  }
  try {
    await TransitionAlertService.instance.init();
  } catch (_) {
    // Alertas permanecem indisponíveis nesta plataforma/configuração.
  }
}

void _configureTransitionAlertNavigation() {
  TransitionAlertService.instance.onAlertTriggered = (alertId) {
    final ctx = navigatorKey.currentContext;
    try {
      final alertsBox = Hive.box(transitionAlertsBoxName);
      final rawMap = alertsBox.get(alertId);
      if (rawMap != null) {
        final alert = TransitionAlert.fromMap(
          Map<String, dynamic>.from(rawMap as Map),
        );
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => TransitionAlertFullScreen(alert: alert),
          ),
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
      home: const BootstrapScreen(),
    );
  }
}

class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  Object? _error;
  StackTrace? _stackTrace;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(PictogramCardAdapter());
      }

      final box =
          await SecureBoxService.openSecureBoxWithMigration<PictogramCard>(
            cardsBoxName,
          );
      await SecureBoxService.openSecureBoxWithMigration('app_settings');
      await SecureBoxService.openSecureBoxWithMigration(
        transitionAlertsBoxName,
      );

      if (box.isEmpty) {
        for (final card in SeedCards.defaultCards()) {
          await box.put(card.id, card);
        }
      }

      _configureTransitionAlertNavigation();
      if (mounted) {
        setState(() => _ready = true);
      }

      // Recursos auxiliares não podem bloquear a primeira tela.
      unawaited(_initializeOptionalServices());
    } catch (error, stackTrace) {
      if (mounted) {
        setState(() {
          _error = error;
          _stackTrace = stackTrace;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return StartupFailureView(error: _error!, stackTrace: _stackTrace);
    }
    if (_ready) return const SplashScreen();
    return const StartupLoadingView();
  }
}

class StartupLoadingView extends StatelessWidget {
  const StartupLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Preparando o Fala Comigo…',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class StartupFailureView extends StatelessWidget {
  const StartupFailureView({
    required this.error,
    required this.stackTrace,
    super.key,
  });

  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Falha de inicialização')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: SelectableText(
          'O aplicativo não conseguiu preparar os dados locais.\n\n'
          'Erro:\n$error\n\n'
          'Stack trace:\n${stackTrace ?? 'não disponível'}',
        ),
      ),
    );
  }
}
