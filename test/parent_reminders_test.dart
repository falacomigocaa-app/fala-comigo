import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/features/parental_area/data/parent_reminders.dart';

void main() {
  test('serializa e restaura um lembrete semanal', () {
    const reminder = ParentReminder(
      id: 'morning',
      label: 'Consultar a rotina',
      hour: 8,
      minute: 30,
      weekdays: [2, 3, 4, 5, 6],
      notificationId: 123,
    );

    final restored = ParentReminder.fromMap(reminder.toMap());

    expect(restored.id, reminder.id);
    expect(restored.label, reminder.label);
    expect(restored.hour, 8);
    expect(restored.minute, 30);
    expect(restored.weekdays, [2, 3, 4, 5, 6]);
    expect(restored.notificationId, 123);
  });
}
