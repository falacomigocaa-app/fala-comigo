import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/services/tts_service.dart';
import 'core/theme/app_theme.dart';
import 'features/aac_grid/data/providers/cards_provider.dart';
import 'features/aac_grid/data/providers/seed_cards.dart';
import 'features/aac_grid/domain/models/pictogram_card.dart';
import 'features/onboarding/presentation/screens/splash_screen.dart';

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

  runApp(const ProviderScope(child: CaaApp()));
}

class CaaApp extends StatelessWidget {
  const CaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fala Comigo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
