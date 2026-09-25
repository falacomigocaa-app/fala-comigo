import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:fala_comigo/features/aac_grid/domain/models/pictogram_card.dart';
import 'package:fala_comigo/features/aac_grid/presentation/widgets/grid_card.dart';

void main() {
  setUpAll(() async {
    Hive.init('/tmp/fala_comigo_grid_card_test');
    await Hive.openBox('app_settings');
  });

  testWidgets('anuncia um cartão como um único botão acionável', (
    tester,
  ) async {
    final card = PictogramCard(
      id: 'maca',
      label: 'Maçã',
      imagePath: 'assets/images/cards/maca.png',
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 160,
              height: 180,
              child: GridCard(
                card: card,
                onTap: () {},
                semanticHint: 'Toque para falar e adicionar à frase',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final semantics = tester.getSemantics(find.bySemanticsLabel('Maçã'));
    expect(semantics.label, 'Maçã');
    expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(
      semantics.getSemanticsData().actions & SemanticsAction.tap.index,
      isNonZero,
    );
    expect(semantics.childrenCount, 0);
  });
}
