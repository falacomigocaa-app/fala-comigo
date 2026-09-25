import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fala_comigo/features/parental_area/presentation/screens/plan_status_screen.dart';

void main() {
  testWidgets('mostra o plano Essencial e preserva a comunicação offline', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: PlanStatusScreen())),
    );

    expect(find.text('Essencial'), findsOneWidget);
    expect(find.text('Uso local'), findsOneWidget);
    expect(find.text('Comunicação offline'), findsOneWidget);
    expect(find.textContaining('não depende de assinatura'), findsOneWidget);
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Planos disponíveis'),
      400,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Planos disponíveis'), findsOneWidget);
    expect(find.text('Essencial'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Gratuito'),
      300,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Gratuito'), findsOneWidget);
    for (final name in ['Família', 'Cuidado Conectado', 'Patrocinado']) {
      await tester.scrollUntilVisible(
        find.text(name),
        300,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();
      expect(find.text(name), findsOneWidget);
    }
    expect(find.text('Organização'), findsNothing);
  });
}
