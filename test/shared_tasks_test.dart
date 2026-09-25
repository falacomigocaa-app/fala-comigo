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
        assignedTo: 'Terapeuta responsável',
        organizationName: 'Clínica Caminhos',
        recipientRole: 'Organização convidada',
        contextLabel: 'CAA',
        dueAt: dueAt,
        reminderEnabled: true,
        status: status,
        acceptance: TaskAcceptanceStatus.pending,
        feedback: null,
        createdAt: createdAt,
        updatedAt: createdAt,
        events: [
          SharedTaskEvent(
            type: 'created',
            actor: 'Família',
            note: null,
            occurredAt: createdAt,
          ),
        ],
      );

  test('preserva vínculo, aceite e eventos ao serializar', () {
    final restored = SharedTask.fromMap(task().toMap());

    expect(restored.id, 'task-1');
    expect(restored.organizationName, 'Clínica Caminhos');
    expect(restored.recipientRole, 'Organização convidada');
    expect(restored.acceptance, TaskAcceptanceStatus.pending);
    expect(restored.events, hasLength(1));
    expect(restored.isOpen, isTrue);
  });

  test('aceite recusado permanece auditável sem alterar a tarefa', () {
    final updated = task().copyWith(
      acceptance: TaskAcceptanceStatus.declined,
      events: [
        ...task().events,
        SharedTaskEvent(
          type: 'acceptance:declined',
          actor: 'Família',
          note: 'Revisar com a clínica antes de reenviar.',
          occurredAt: dueAt,
        ),
      ],
    );

    expect(updated.acceptanceLabel, 'Recusada pelo destinatário');
    expect(updated.title, task().title);
    expect(updated.events, hasLength(2));
  });

  test('retorno de ajuda é um estado explícito e não apaga o vínculo', () {
    final updated = task().copyWith(
      status: SharedTaskStatus.needsHelp,
      feedback: 'A prancha não estava disponível na escola.',
    );

    expect(updated.statusLabel, 'Precisa de ajuda');
    expect(updated.feedback, 'A prancha não estava disponível na escola.');
    expect(updated.organizationName, 'Clínica Caminhos');
    expect(updated.isOpen, isFalse);
  });
}
