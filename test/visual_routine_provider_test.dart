import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/features/aac_grid/data/providers/visual_routine_provider.dart';

void main() {
  test('serializa e restaura um passo concluído da rotina', () {
    const item = VisualRoutineItem(
      id: 'morning',
      title: 'Escovar os dentes',
      emoji: '🪥',
      completed: true,
    );

    final restored = VisualRoutineItem.fromMap(item.toMap());

    expect(restored.id, item.id);
    expect(restored.title, item.title);
    expect(restored.emoji, item.emoji);
    expect(restored.completed, isTrue);
  });

  test('copyWith altera somente o estado de conclusão', () {
    const item = VisualRoutineItem(
      id: 'school',
      title: 'Ir para a escola',
      emoji: '🎒',
    );

    final completed = item.copyWith(completed: true);

    expect(completed.title, item.title);
    expect(completed.emoji, item.emoji);
    expect(completed.completed, isTrue);
    expect(item.completed, isFalse);
  });
}
