import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fala_comigo/features/parental_area/presentation/screens/plan_status_screen.dart';

void main() {
  testWidgets('mostra o plano Essencial e preserva a comunicação offline',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PlanStatusScreen()),
      ),
    );

    expect(find.text('Essencial'), findsNWidgets(2));
    expect(find.text('Uso local'), findsOneWidget);
    expect(find.text('Comunicação offline'), findsOneWidget);
    expect(find.text('Gratuito'), findsOneWidget);
    expect(find.text('Preço a definir'), findsNWidgets(3));
    expect(
      find.textContaining('não depende de assinatura'),
      findsOneWidget,
    );
  });
}
