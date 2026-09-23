class WeeklyTrendPoint {
  final DateTime weekStart;
  final int behaviorCount;
  final int videoCount;

  const WeeklyTrendPoint({
    required this.weekStart,
    required this.behaviorCount,
    required this.videoCount,
  });

  String get label =>
      '${weekStart.day.toString().padLeft(2, '0')}/${weekStart.month.toString().padLeft(2, '0')}';
}

List<WeeklyTrendPoint> buildWeeklyTrends({
  required Iterable<dynamic> behaviorTimestamps,
  required Iterable<dynamic> videoTimestamps,
  DateTime? now,
  int weeks = 8,
}) {
  final reference = now ?? DateTime.now();
  final currentMonday = DateTime(
    reference.year,
    reference.month,
    reference.day,
  ).subtract(Duration(days: reference.weekday - DateTime.monday));
  final firstMonday = currentMonday.subtract(Duration(days: (weeks - 1) * 7));
  final behaviorDates = behaviorTimestamps
      .map((value) => DateTime.tryParse('$value'))
      .whereType<DateTime>()
      .toList();
  final videoDates = videoTimestamps
      .map((value) => DateTime.tryParse('$value'))
      .whereType<DateTime>()
      .toList();

  return List.generate(weeks, (index) {
    final start = firstMonday.add(Duration(days: index * 7));
    final end = start.add(const Duration(days: 7));
    return WeeklyTrendPoint(
      weekStart: start,
      behaviorCount: behaviorDates
          .where((date) => !date.isBefore(start) && date.isBefore(end))
          .length,
      videoCount: videoDates
          .where((date) => !date.isBefore(start) && date.isBefore(end))
          .length,
    );
  });
}
