import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/pictogram_card.dart';

const String cardsBoxName = 'pictogram_cards';

/// Expõe a box do Hive já aberta (deve ser inicializada em main()
/// antes de rodar o app).
final cardsBoxProvider = Provider<Box<PictogramCard>>((ref) {
  return Hive.box<PictogramCard>(cardsBoxName);
});

/// Lista reativa de todos os cartões cadastrados, ordenada.
final cardsListProvider = StateNotifierProvider<CardsNotifier, List<PictogramCard>>((ref) {
  final box = ref.watch(cardsBoxProvider);
  return CardsNotifier(box);
});

class CardsNotifier extends StateNotifier<List<PictogramCard>> {
  final Box<PictogramCard> _box;

  CardsNotifier(this._box) : super(_box.values.toList()..sort((a, b) => a.order.compareTo(b.order)));

  Future<void> addCard({
    required String label,
    required String imagePath,
    bool isCustomImage = false,
    String category = 'personalizado',
  }) async {
    final card = PictogramCard(
      id: const Uuid().v4(),
      label: label,
      imagePath: imagePath,
      isCustomImage: isCustomImage,
      category: category,
      order: state.length,
    );
    await _box.put(card.id, card);
    state = _box.values.toList()..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<void> removeCard(String id) async {
    await _box.delete(id);
    state = _box.values.toList()..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Atualiza um cartão existente (usado ao editar pela Área do
  /// Responsável). Só altera os campos informados.
  Future<void> updateCard({
    required String id,
    String? label,
    String? imagePath,
    String? category,
  }) async {
    final card = _box.get(id);
    if (card == null) return;
    if (label != null) card.label = label;
    if (imagePath != null) card.imagePath = imagePath;
    if (category != null) card.category = category;
    await card.save();
    state = _box.values.toList()..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Reordena os cartões (drag-and-drop na lista de Configurações),
  /// persistindo a nova ordem no Hive.
  Future<void> reorderCards(int oldIndex, int newIndex) async {
    final list = [...state];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    for (var i = 0; i < list.length; i++) {
      list[i].order = i;
      await list[i].save();
    }
    state = list;
  }

  /// Usado pelo painel dos pais para ajustar tamanho/config sem
  /// duplicar cartões.
  void refresh() {
    state = _box.values.toList()..sort((a, b) => a.order.compareTo(b.order));
  }
}

/// Categoria atualmente selecionada na grade.
final selectedCategoryProvider = StateProvider<String>((ref) => 'todas');

/// A "barra de frase": lista ordenada de cartões que o usuário
/// selecionou para montar uma frase (ex: "Eu Quero" + "Comer" + "Maçã").
final sentenceBarProvider = StateNotifierProvider<SentenceBarNotifier, List<PictogramCard>>((ref) {
  return SentenceBarNotifier();
});

class SentenceBarNotifier extends StateNotifier<List<PictogramCard>> {
  SentenceBarNotifier() : super([]);

  void addToSentence(PictogramCard card) {
    state = [...state, card];
  }

  void removeAt(int index) {
    final updated = [...state]..removeAt(index);
    state = updated;
  }

  void clear() {
    state = [];
  }

  String get spokenText => state.map((c) => c.label).join(' ');
}

/// Tamanho ajustável dos botões, controlado no Painel dos Pais.
final buttonScaleProvider = StateProvider<double>((ref) => 1.0);

/// Configurações bloqueadas (Modo Infantil Sensorial ativo).
final settingsLockedProvider = StateProvider<bool>((ref) => true);
