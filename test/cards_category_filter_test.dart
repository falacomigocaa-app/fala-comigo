import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/features/aac_grid/data/providers/cards_provider.dart';
import 'package:fala_comigo/features/aac_grid/domain/models/pictogram_card.dart';

PictogramCard card(String id, String category) {
  return PictogramCard(
    id: id,
    label: id,
    imagePath: 'assets/images/cards/$id.png',
    category: category,
  );
}

void main() {
  test('retorna todos os cartões na ordem original para a categoria todas', () {
    final cards = [card('comer', 'acoes'), card('feliz', 'sentimentos')];

    final visible = filterCardsByCategory(cards, 'todas');

    expect(visible.map((item) => item.id), ['comer', 'feliz']);
    expect(identical(visible, cards), isFalse);
  });

  test('filtra somente os cartões da categoria escolhida', () {
    final cards = [
      card('comer', 'acoes'),
      card('feliz', 'sentimentos'),
      card('triste', 'sentimentos'),
    ];

    final visible = filterCardsByCategory(cards, 'sentimentos');

    expect(visible.map((item) => item.id), ['feliz', 'triste']);
  });

  test('categoria sem cartões retorna lista vazia sem lançar exceção', () {
    final visible = filterCardsByCategory([card('comer', 'acoes')], 'lugares');

    expect(visible, isEmpty);
  });
}
