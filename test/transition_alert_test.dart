import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/features/transition_alerts/domain/models/transition_alert.dart';

void main() {
  test('preserva áudio, contagem, checklist e agendamento ao serializar', () {
    final alert = TransitionAlert(
      id: 'alert-1',
      title: 'Hora de guardar',
      audioType: 'gravado',
      recordedAudioPath: '/private/audio.fcm',
      ttsText: 'Vamos guardar os brinquedos',
      countdownSeconds: 45,
      checklistItems: ['Guardar blocos', 'Escolher livro'],
      isScheduled: true,
      scheduledHour: 18,
      scheduledMinute: 30,
      scheduledWeekdays: [2, 4, 6],
      notificationId: 1200,
    );

    final restored = TransitionAlert.fromMap(alert.toMap());

    expect(restored.id, 'alert-1');
    expect(restored.audioType, 'gravado');
    expect(restored.recordedAudioPath, '/private/audio.fcm');
    expect(restored.countdownSeconds, 45);
    expect(restored.checklistItems, ['Guardar blocos', 'Escolher livro']);
    expect(restored.isScheduled, isTrue);
    expect(restored.scheduledHour, 18);
    expect(restored.scheduledMinute, 30);
    expect(restored.scheduledWeekdays, [2, 4, 6]);
    expect(restored.notificationId, 1200);
  });

  test('usa defaults seguros para um mapa legado incompleto', () {
    final alert = TransitionAlert.fromMap({'id': 'legacy-alert'});

    expect(alert.title, isEmpty);
    expect(alert.audioType, 'tts');
    expect(alert.countdownSeconds, 60);
    expect(alert.checklistItems, isEmpty);
    expect(alert.isScheduled, isFalse);
    expect(alert.scheduledWeekdays, isEmpty);
    expect(alert.notificationId, 0);
  });
}
