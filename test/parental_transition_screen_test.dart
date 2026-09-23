import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/features/parental_area/presentation/screens/parental_area_transition_screen.dart';

void main() {
  testWidgets('abre o destino parental após a transição', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ParentalAreaTransitionScreen(
          destination: const Scaffold(body: Text('Painel parental')),
        ),
      ),
    );

    expect(find.text('Painel Profissional'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump();

    expect(find.text('Painel parental'), findsOneWidget);
  });
}
