import 'dart:async';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/services/transition_alert_service.dart';
import 'core/services/secure_box_service.dart';
import 'core/services/parental_session_service.dart';
import 'core/services/tts_service.dart';
import 'core/services/diagnostics_service.dart';
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
bool _startupFailureShown = false;
final ValueNotifier<StartupState> _startupState =
    ValueNotifier<StartupState>(const StartupState.loading());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    DiagnosticsService.captureFlutterError(details);
  };
  ui.PlatformDispatcher.instance.onError =
      DiagnosticsService.capturePlatformError;

  runApp(const ProviderScope(child: BootstrapApp()));
  unawaited(runZonedGuarded(_startApp, (error, stackTrace) {
    DiagnosticsService.capture(
      kind: 'uncaught_error',
      error: error,
      stackTrace: stackTrace,
    );
    _showStartupFailure(error, stackTrace);
  }));
}

Future<void> _startApp() async {
  try {
    await _bootstrapApp();
    _startupState.value = const StartupState.ready();
  } catch (error, stackTrace) {
    DiagnosticsService.capture(
      kind: 'startup_error',
      error: error,
      stackTrace: stackTrace,
      context: 'bootstrap',
    );
    _startupState.value = StartupState.failure(error, stackTrace);
    _showStartupFailure(error, stackTrace);
  }
}

void _showStartupFailure(Object error, StackTrace stackTrace) {
  if (_startupFailureShown) return;
  _startupFailureShown = true;
  _startupState.value = StartupState.failure(error, stackTrace);
}

Future<void> _bootstrapApp() async {
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
  final box = await SecureBoxService.openSecureBoxWithMigration<PictogramCard>(
    cardsBoxName,
  );

  // Caixa simples de configurações do app (ex: tema de hiperfoco
  // escolhido pelos pais).
  await SecureBoxService.openSecureBoxWithMigration('app_settings');

  // Caixa dos Alertas de Transição de Atividade (configurações dos
  // alertas: áudio, horário, checklist).
  await SecureBoxService.openSecureBoxWithMigration(transitionAlertsBoxName);
  await DiagnosticsService.init();

  // Primeiro uso: popula os pictogramas básicos que acompanham o app,
  // para que a criança já tenha cartões disponíveis antes mesmo dos
  // pais cadastrarem fotos personalizadas.
  if (box.isEmpty) {
    for (final card in SeedCards.defaultCards()) {
      await box.put(card.id, card);
    }
  }

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
          MaterialPageRoute(
              builder: (_) => TransitionAlertFullScreen(alert: alert)),
        );
      } else if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir este alerta.')),
        );
      }
    } catch (error, stackTrace) {
      DiagnosticsService.capture(
        kind: 'notification_navigation_error',
        error: error,
        stackTrace: stackTrace,
        context: 'transition_alert_notification',
      );
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir este alerta.')),
        );
      }
    }
  };

  // Recursos opcionais nativos são inicializados depois da primeira tela.
  // Uma falha de TTS/notificações nunca pode impedir a comunicação visual.
  unawaited(_initializeOptionalServices());
}

Future<void> _initializeOptionalServices() async {
  try {
    await TtsService.instance.init();
  } catch (error, stackTrace) {
    DiagnosticsService.capture(
      kind: 'tts_initialization_error',
      error: error,
      stackTrace: stackTrace,
    );
  }

  try {
    await TransitionAlertService.instance.init();
  } catch (error, stackTrace) {
    DiagnosticsService.capture(
      kind: 'notifications_initialization_error',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

class StartupState {
  final bool ready;
  final Object? error;
  final StackTrace? stackTrace;

  const StartupState.loading()
      : ready = false,
        error = null,
        stackTrace = null;

  const StartupState.ready()
      : ready = true,
        error = null,
        stackTrace = null;

  const StartupState.failure(this.error, this.stackTrace) : ready = false;
}

class BootstrapApp extends StatelessWidget {
  const BootstrapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StartupState>(
      valueListenable: _startupState,
      builder: (context, state, child) {
        if (state.ready) return const CaaApp();
        if (state.error != null) {
          return StartupFailureApp(
            message: state.error.toString(),
            stackTrace: state.stackTrace.toString(),
          );
        }
        return const StartupLoadingApp();
      },
    );
  }
}

class StartupLoadingApp extends StatelessWidget {
  const StartupLoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FlutterLogo(size: 64),
              const SizedBox(height: 20),
              Text(
                'Preparando o Fala Comigo…',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
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

class StartupFailureApp extends StatelessWidget {
  final String message;
  final String stackTrace;

  const StartupFailureApp({
    required this.message,
    required this.stackTrace,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final report = DiagnosticsService.exportReportJson();
    return MaterialApp(
      title: 'Fala Comigo — diagnóstico',
      home: Scaffold(
        appBar: AppBar(title: const Text('Falha ao iniciar')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 64),
              const SizedBox(height: 16),
              const Text(
                'O aplicativo não conseguiu concluir a inicialização. Nenhum dado deve ser perdido por esta tela.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                'Envie o relatório técnico ao suporte autorizado. Não inclua dados da criança na mensagem.',
              ),
              const SizedBox(height: 16),
              SelectableText('Mensagem técnica: $message'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Clipboard.setData(
                  ClipboardData(text: report),
                ),
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copiar relatório técnico'),
              ),
              const SizedBox(height: 12),
              ExpansionTile(
                title: const Text('Detalhes técnicos'),
                children: [SelectableText(stackTrace)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
