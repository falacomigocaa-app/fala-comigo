import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/features/parental_area/data/shared_tasks.dart';

void main() {
  final createdAt = DateTime.utc(2026, 9, 23, 18);
  final dueAt = DateTime.utc(2026, 9, 24, 18);

  SharedTask task({SharedTaskStatus status = SharedTaskStatus.pending}) =>
      SharedTask(
        id: 'task-1',
        title: 'Praticar pedido de pausa',
        description: 'Usar o símbolo durante uma atividade natural.',
        createdBy: 'Família',
        assignedTo: 'Clínica Caminhos',
        contextLabel: 'CAA',
        dueAt: dueAt,
        reminderEnabled: true,
        status: status,
        feedback: null,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

  test('preserva os dados da tarefa ao serializar', () {
    final restored = SharedTask.fromMap(task().toMap());

    expect(restored.id, 'task-1');
    expect(restored.title, 'Praticar pedido de pausa');
    expect(restored.assignedTo, 'Clínica Caminhos');
    expect(restored.contextLabel, 'CAA');
    expect(restored.reminderEnabled, isTrue);
    expect(restored.status, SharedTaskStatus.pending);
    expect(restored.isOpen, isTrue);
  });

  test('retorno de ajuda preserva o estado sem apagar o contexto', () {
    final updated = task().copyWith(
      status: SharedTaskStatus.needsHelp,
      feedback: 'A prancha não estava disponível na escola.',
    );

    expect(updated.statusLabel, 'Precisa de ajuda');
    expect(updated.feedback, 'A prancha não estava disponível na escola.');
    expect(updated.title, task().title);
    expect(updated.isOpen, isFalse);
  });

  test('não realizada é um estado válido e explícito', () {
    final declined = task().copyWith(status: SharedTaskStatus.declined);

    expect(declined.statusLabel, 'Não realizada');
    expect(declined.isOpen, isFalse);
  });
}
