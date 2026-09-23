import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/features/onboarding/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('navega da abertura para o destino inicial', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          destination: const Scaffold(body: Text('Grade inicial')),
        ),
      ),
    );

    expect(find.text('Fala Comigo'), findsOneWidget);
    expect(find.text('Comunicação Alternativa'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Grade inicial'), findsOneWidget);
  });
}
