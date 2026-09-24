import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/features/parental_area/presentation/screens/privacy_settings_screen.dart';

void main() {
  testWidgets('mostra controles de privacidade locais e política pública',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PrivacySettingsScreen()),
    );

    expect(find.text('Privacidade e dados'), findsOneWidget);
    expect(find.text('Armazenamento local'), findsOneWidget);
    expect(find.text('Transparência de segurança'), findsOneWidget);
    expect(find.textContaining('OWASP MASVS'), findsOneWidget);
    expect(find.text('Compartilhamento'), findsOneWidget);
    await tester.drag(find.byType(Scrollable), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Exclusão local'), findsOneWidget);
    expect(find.text('Ler a política de privacidade'), findsOneWidget);
    expect(
      find.textContaining('não envia dados automaticamente'),
      findsOneWidget,
    );
  });
}
