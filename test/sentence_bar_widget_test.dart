import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fala_comigo/features/aac_grid/data/providers/cards_provider.dart';
import 'package:fala_comigo/features/aac_grid/domain/models/pictogram_card.dart';
import 'package:fala_comigo/features/aac_grid/presentation/widgets/sentence_bar_widget.dart';

PictogramCard card(String id, String label) {
  return PictogramCard(
    id: id,
    label: label,
    imagePath: 'assets/images/cards/$id.png',
  );
}

void main() {
  testWidgets('remove um item pela ação acessível e limpa a frase',
      (tester) async {
    final notifier = SentenceBarNotifier();
    notifier.addToSentence(card('comer', 'Comer'));
    notifier.addToSentence(card('ajuda', 'Ajuda'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sentenceBarProvider.overrideWith((ref) => notifier),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SentenceBarWidget()),
        ),
      ),
    );

    expect(find.text('Comer'), findsOneWidget);
    expect(find.text('Ajuda'), findsOneWidget);
    expect(find.bySemanticsLabel('Remover Comer da frase'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Remover Comer da frase'));
    await tester.pump();

    expect(notifier.spokenText, 'Ajuda');
    expect(find.text('Comer'), findsNothing);
    expect(find.text('Ajuda'), findsOneWidget);

    await tester.tap(find.byTooltip('Limpar frase'));
    await tester.pump();

    expect(notifier.state, isEmpty);
    expect(
        find.text('Toque nos cartões para montar uma frase'), findsOneWidget);
  });
}
