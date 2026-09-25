import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/secure_box_service.dart';

const visualRoutineBoxName = 'visual_routine';

@immutable
class VisualRoutineItem {
  final String id;
  final String title;
  final String emoji;
  final bool completed;

  const VisualRoutineItem({
    required this.id,
    required this.title,
    required this.emoji,
    this.completed = false,
  });

  VisualRoutineItem copyWith({bool? completed}) => VisualRoutineItem(
        id: id,
        title: title,
        emoji: emoji,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'emoji': emoji,
        'completed': completed,
      };

  factory VisualRoutineItem.fromMap(Map<dynamic, dynamic> map) {
    return VisualRoutineItem(
      id: '${map['id'] ?? const Uuid().v4()}',
      title: '${map['title'] ?? ''}',
      emoji: '${map['emoji'] ?? '⭐'}',
      completed: map['completed'] == true,
    );
  }
}

class VisualRoutineStore {
  VisualRoutineStore._();

  static Future<Box> _box() async {
    if (Hive.isBoxOpen(visualRoutineBoxName)) {
      return Hive.box(visualRoutineBoxName);
    }
    return SecureBoxService.openSecureBox(visualRoutineBoxName);
  }

  static Future<List<VisualRoutineItem>> load() async {
    final box = await _box();
    return box.values
        .whereType<Map>()
        .map(VisualRoutineItem.fromMap)
        .where((item) => item.title.trim().isNotEmpty)
        .toList();
  }

  static Future<void> save(List<VisualRoutineItem> items) async {
    final box = await _box();
    await box.clear();
    for (var index = 0; index < items.length; index++) {
      await box.put(index, items[index].toMap());
    }
  }

  static String newId() => const Uuid().v4();
}
