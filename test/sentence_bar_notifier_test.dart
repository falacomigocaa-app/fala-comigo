import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/features/aac_grid/data/providers/cards_provider.dart';
import 'package:fala_comigo/features/aac_grid/domain/models/pictogram_card.dart';

PictogramCard card(String id, String label) {
  return PictogramCard(
    id: id,
    label: label,
    imagePath: 'assets/images/cards/$id.png',
  );
}

void main() {
  late SentenceBarNotifier notifier;

  setUp(() {
    notifier = SentenceBarNotifier();
  });

  test('monta o texto na mesma ordem dos cartões selecionados', () {
    notifier.addToSentence(card('eu', 'Eu'));
    notifier.addToSentence(card('quero', 'Quero'));
    notifier.addToSentence(card('agua', 'Água'));

    expect(notifier.spokenText, 'Eu Quero Água');
    expect(notifier.state.map((item) => item.id), ['eu', 'quero', 'agua']);
  });

  test('remove somente o cartão solicitado', () {
    notifier.addToSentence(card('eu', 'Eu'));
    notifier.addToSentence(card('quero', 'Quero'));
    notifier.addToSentence(card('agua', 'Água'));

    notifier.removeAt(1);

    expect(notifier.spokenText, 'Eu Água');
  });

  test('ignora remoção com índice inválido sem lançar exceção', () {
    notifier.addToSentence(card('eu', 'Eu'));

    notifier.removeAt(-1);
    notifier.removeAt(1);

    expect(notifier.spokenText, 'Eu');
  });

  test('limpa todos os cartões e o texto falado', () {
    notifier.addToSentence(card('eu', 'Eu'));
    notifier.addToSentence(card('quero', 'Quero'));

    notifier.clear();

    expect(notifier.state, isEmpty);
    expect(notifier.spokenText, isEmpty);
  });
}
