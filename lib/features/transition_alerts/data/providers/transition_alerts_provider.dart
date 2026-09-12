import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/transition_alert.dart';

const String transitionAlertsBoxName = 'transition_alerts';

final transitionAlertsBoxProvider = Provider<Box>((ref) {
  return Hive.box(transitionAlertsBoxName);
});

final transitionAlertsListProvider =
    StateNotifierProvider<TransitionAlertsNotifier, List<TransitionAlert>>(
        (ref) {
  final box = ref.watch(transitionAlertsBoxProvider);
  return TransitionAlertsNotifier(box);
});

class TransitionAlertsNotifier extends StateNotifier<List<TransitionAlert>> {
  final Box _box;

  TransitionAlertsNotifier(this._box) : super(_loadAll(_box));

  static List<TransitionAlert> _loadAll(Box box) {
    return box.values
        .map((e) =>
            TransitionAlert.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<TransitionAlert> addAlert(TransitionAlert alert) async {
    await _box.put(alert.id, alert.toMap());
    state = _loadAll(_box);
    return alert;
  }

  Future<void> updateAlert(TransitionAlert alert) async {
    await _box.put(alert.id, alert.toMap());
    state = _loadAll(_box);
  }

  Future<void> removeAlert(String id) async {
    await _box.delete(id);
    state = _loadAll(_box);
  }

  /// Gera um ID numérico único, exigido pelo flutter_local_notifications
  /// (que usa inteiros para identificar cada notificação agendada).
  int generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(1000000000);
  }

  String generateId() => const Uuid().v4();
}
