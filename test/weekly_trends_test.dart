import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/features/parental_area/data/weekly_trends.dart';

void main() {
  test('agrupa registros no início correto da semana', () {
    final points = buildWeeklyTrends(
      now: DateTime(2026, 9, 23),
      weeks: 2,
      behaviorTimestamps: [
        '2026-09-21T09:00:00',
        '2026-09-22T10:00:00',
        '2026-09-16T10:00:00',
      ],
      videoTimestamps: ['2026-09-23T12:00:00'],
    );

    expect(points, hasLength(2));
    expect(points.last.weekStart, DateTime(2026, 9, 21));
    expect(points.last.behaviorCount, 2);
    expect(points.last.videoCount, 1);
    expect(points.first.behaviorCount, 1);
  });

  test('ignora timestamps inválidos sem interromper o painel', () {
    final points = buildWeeklyTrends(
      now: DateTime(2026, 9, 23),
      behaviorTimestamps: ['invalido'],
      videoTimestamps: const [],
    );

    expect(points.every((point) => point.behaviorCount == 0), isTrue);
  });
}
