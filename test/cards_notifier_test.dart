import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:fala_comigo/features/aac_grid/data/providers/cards_provider.dart';
import 'package:fala_comigo/features/aac_grid/domain/models/pictogram_card.dart';

const _boxName = 'cards_notifier_test';

void main() {
  late Box<PictogramCard> box;

  setUpAll(() async {
    Hive.init('/tmp/fala_comigo_cards_notifier_test');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PictogramCardAdapter());
    }
    box = await Hive.openBox<PictogramCard>(_boxName);
  });

  setUp(() async {
    await box.clear();
  });

  tearDownAll(() async {
    await box.close();
  });

  test('adiciona cartão persistido com ordem ao final', () async {
    final notifier = CardsNotifier(box);

    await notifier.addCard(
      label: 'Comer',
      imagePath: 'assets/images/cards/comer.png',
      category: 'acoes',
    );

    expect(notifier.state, hasLength(1));
    expect(notifier.state.single.label, 'Comer');
    expect(notifier.state.single.order, 0);
    expect(box.get(notifier.state.single.id)?.label, 'Comer');
  });

  test('edita dados do cartão e preserva o identificador', () async {
    final card = PictogramCard(
      id: 'card-1',
      label: 'Comer',
      imagePath: 'assets/images/cards/comer.png',
      category: 'acoes',
    );
    await box.put(card.id, card);
    final notifier = CardsNotifier(box);

    await notifier.updateCard(id: card.id, label: 'Beber', category: 'comidas');

    expect(notifier.state.single.id, 'card-1');
    expect(notifier.state.single.label, 'Beber');
    expect(notifier.state.single.category, 'comidas');
  });

  test('marca imagem personalizada ao substituir a imagem do cartão', () async {
    final card = PictogramCard(
      id: 'card-with-image',
      label: 'Comer',
      imagePath: 'assets/images/cards/comer.png',
      category: 'acoes',
    );
    await box.put(card.id, card);
    final notifier = CardsNotifier(box);

    await notifier.updateCard(
      id: card.id,
      imagePath: '/private/card-image.fcm',
      isCustomImage: true,
    );

    expect(notifier.state.single.isCustomImage, isTrue);
    expect(box.get(card.id)?.isCustomImage, isTrue);
  });

  test('reordena cartões e persiste a nova ordem', () async {
    final first = PictogramCard(
      id: 'first',
      label: 'Comer',
      imagePath: 'assets/images/cards/comer.png',
      order: 0,
    );
    final second = PictogramCard(
      id: 'second',
      label: 'Ajuda',
      imagePath: 'assets/images/cards/ajuda.png',
      order: 1,
    );
    await box.put(first.id, first);
    await box.put(second.id, second);
    final notifier = CardsNotifier(box);

    await notifier.reorderCards(1, 0);

    expect(notifier.state.map((item) => item.id), ['second', 'first']);
    expect(box.get('second')?.order, 0);
    expect(box.get('first')?.order, 1);
  });

  test('remove cartão e atualiza a lista reativa', () async {
    final card = PictogramCard(
      id: 'card-1',
      label: 'Comer',
      imagePath: 'assets/images/cards/comer.png',
    );
    await box.put(card.id, card);
    final notifier = CardsNotifier(box);

    await notifier.removeCard(card.id);

    expect(notifier.state, isEmpty);
    expect(box.get(card.id), isNull);
  });
}
