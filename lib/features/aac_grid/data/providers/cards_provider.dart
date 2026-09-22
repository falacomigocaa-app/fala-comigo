import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/media_storage_service.dart';
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
    final card = _box.get(id);
    await _box.delete(id);
    if (card != null && card.isCustomImage) {
      await MediaStorageService.deleteFile(card.imagePath);
    }
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
    final previousImagePath = card.imagePath;
    final previousWasCustom = card.isCustomImage;
    if (label != null) card.label = label;
    if (imagePath != null) card.imagePath = imagePath;
    if (category != null) card.category = category;
    await card.save();
    if (imagePath != null &&
        imagePath != previousImagePath &&
        previousWasCustom) {
      await MediaStorageService.deleteFile(previousImagePath);
    }
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
    // A árvore de acessibilidade pode manter uma ação pendente quando a
    // frase muda rapidamente. Uma ação obsoleta não deve encerrar o app.
    if (index < 0 || index >= state.length) return;
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

/// Define se tocar em um cartão fala, adiciona à frase, ou faz as duas coisas.
///
/// O modo padrão preserva o comportamento anterior. Famílias podem escolher
/// um modo silencioso para montar mensagens sem produzir áudio a cada toque.
enum CardTapBehavior { speakAndAdd, addOnly, speakOnly }

class CardTapBehaviorNotifier extends StateNotifier<CardTapBehavior> {
  CardTapBehaviorNotifier() : super(_loadInitial());

  static CardTapBehavior _loadInitial() {
    final saved = Hive.box('app_settings').get('card_tap_behavior') as String?;
    return CardTapBehavior.values.firstWhere(
      (behavior) => behavior.name == saved,
      orElse: () => CardTapBehavior.speakAndAdd,
    );
  }

  Future<void> setBehavior(CardTapBehavior behavior) async {
    state = behavior;
    await Hive.box('app_settings').put('card_tap_behavior', behavior.name);
  }
}

final cardTapBehaviorProvider = StateNotifierProvider<CardTapBehaviorNotifier,
    CardTapBehavior>((ref) => CardTapBehaviorNotifier());

/// Configurações bloqueadas (Modo Infantil Sensorial ativo).
final settingsLockedProvider = StateProvider<bool>((ref) => true);
