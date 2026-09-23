import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/services/secure_box_service.dart';

const _boxName = 'shared_tasks';

enum SharedTaskStatus {
  pending,
  inProgress,
  completed,
  partiallyCompleted,
  needsHelp,
  declined,
  cancelled,
}

@immutable
class SharedTask {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final String assignedTo;
  final String contextLabel;
  final DateTime dueAt;
  final bool reminderEnabled;
  final SharedTaskStatus status;
  final String? feedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SharedTask({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.assignedTo,
    required this.contextLabel,
    required this.dueAt,
    required this.reminderEnabled,
    required this.status,
    required this.feedback,
    required this.createdAt,
    required this.updatedAt,
  });

  SharedTask copyWith({
    SharedTaskStatus? status,
    String? feedback,
    DateTime? updatedAt,
  }) => SharedTask(
        id: id,
        title: title,
        description: description,
        createdBy: createdBy,
        assignedTo: assignedTo,
        contextLabel: contextLabel,
        dueAt: dueAt,
        reminderEnabled: reminderEnabled,
        status: status ?? this.status,
        feedback: feedback ?? this.feedback,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'createdBy': createdBy,
        'assignedTo': assignedTo,
        'contextLabel': contextLabel,
        'dueAt': dueAt.toIso8601String(),
        'reminderEnabled': reminderEnabled,
        'status': status.name,
        'feedback': feedback,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SharedTask.fromMap(Map<dynamic, dynamic> map) => SharedTask(
        id: '${map['id'] ?? ''}',
        title: '${map['title'] ?? 'Tarefa compartilhada'}',
        description: '${map['description'] ?? ''}',
        createdBy: '${map['createdBy'] ?? 'Família'}',
        assignedTo: '${map['assignedTo'] ?? 'Família'}',
        contextLabel: '${map['contextLabel'] ?? 'Rotina'}',
        dueAt: DateTime.tryParse('${map['dueAt']}') ?? DateTime.now(),
        reminderEnabled: map['reminderEnabled'] == true,
        status: SharedTaskStatus.values.firstWhere(
          (value) => value.name == map['status'],
          orElse: () => SharedTaskStatus.pending,
        ),
        feedback: map['feedback'] == null ? null : '${map['feedback']}',
        createdAt: DateTime.tryParse('${map['createdAt']}') ?? DateTime.now(),
        updatedAt: DateTime.tryParse('${map['updatedAt']}') ?? DateTime.now(),
      );

  String get statusLabel => switch (status) {
        SharedTaskStatus.pending => 'Pendente',
        SharedTaskStatus.inProgress => 'Em andamento',
        SharedTaskStatus.completed => 'Concluída',
        SharedTaskStatus.partiallyCompleted => 'Parcial',
        SharedTaskStatus.needsHelp => 'Precisa de ajuda',
        SharedTaskStatus.declined => 'Não realizada',
        SharedTaskStatus.cancelled => 'Cancelada',
      };

  bool get isOpen => status == SharedTaskStatus.pending ||
      status == SharedTaskStatus.inProgress;
}

class SharedTaskStore {
  SharedTaskStore._();

  static Future<Box> _box() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return SecureBoxService.openSecureBox(_boxName);
  }

  static Future<List<SharedTask>> load() async {
    final box = await _box();
    return box.values
        .whereType<Map>()
        .map(SharedTask.fromMap)
        .where((task) => task.id.isNotEmpty)
        .toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
  }

  static Future<void> save(SharedTask task) async {
    final box = await _box();
    await box.put(task.id, task.toMap());
  }
}
