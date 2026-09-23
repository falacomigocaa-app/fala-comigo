import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/services/secure_box_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/weekly_trends.dart';

class WeeklyTrendsScreen extends StatefulWidget {
  const WeeklyTrendsScreen({super.key});

  @override
  State<WeeklyTrendsScreen> createState() => _WeeklyTrendsScreenState();
}

class _WeeklyTrendsScreenState extends State<WeeklyTrendsScreen> {
  List<WeeklyTrendPoint> _points = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final behaviorBox = await SecureBoxService.openSecureBox('behavior_logs');
    final videoBox = await SecureBoxService.openSecureBox('video_diary');
    final behaviorTimestamps =
        behaviorBox.values.whereType<Map>().map((entry) => entry['timestamp']);
    final videoTimestamps =
        videoBox.values.whereType<Map>().map((entry) => entry['timestamp']);
    final points = buildWeeklyTrends(
      behaviorTimestamps: behaviorTimestamps,
      videoTimestamps: videoTimestamps,
    );
    if (!mounted) return;
    setState(() {
      _points = points;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = _points.fold<int>(0, (max, point) {
      final value = point.behaviorCount > point.videoCount
          ? point.behaviorCount
          : point.videoCount;
      return value > max ? value : max;
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Tendências semanais'),
        backgroundColor: AppTheme.professionalBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.professionalBackground,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.bar_chart_outlined,
                          color: AppTheme.professionalAccent, size: 28),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Uma visão das anotações feitas nas últimas oito semanas. Os números descrevem registros; não medem a criança.',
                          style: TextStyle(
                              color: Colors.white, height: 1.35, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Legend(),
                const SizedBox(height: 12),
                _WeeklyChart(points: _points, maxValue: maxValue),
                const SizedBox(height: 18),
                _SummaryCard(points: _points),
                const SizedBox(height: 12),
                const Text(
                  'Use este painel para conversar sobre a rotina e a qualidade dos registros. Ele não identifica causas, não calcula evolução clínica e não substitui avaliação profissional.',
                  style: TextStyle(color: AppTheme.mutedText, height: 1.35),
                ),
              ],
            ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LegendItem(color: AppTheme.primary, label: 'Registros ABC'),
        const SizedBox(width: 18),
        _LegendItem(color: AppTheme.accentGreen, label: 'Vídeos locais'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<WeeklyTrendPoint> points;
  final int maxValue;

  const _WeeklyChart({required this.points, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points
                  .map((point) => Expanded(
                        child: _WeekBar(
                          point: point,
                          maxValue: maxValue,
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          const Text('Início de cada semana',
              style: TextStyle(color: AppTheme.mutedText, fontSize: 11)),
        ],
      ),
    );
  }
}

class _WeekBar extends StatelessWidget {
  final WeeklyTrendPoint point;
  final int maxValue;

  const _WeekBar({required this.point, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    final safeMax = maxValue == 0 ? 1 : maxValue;
    final behaviorHeight = point.behaviorCount / safeMax * 130;
    final videoHeight = point.videoCount / safeMax * 130;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 145,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Bar(
                  value: point.behaviorCount,
                  height: behaviorHeight,
                  color: AppTheme.primary),
              const SizedBox(width: 3),
              _Bar(
                  value: point.videoCount,
                  height: videoHeight,
                  color: AppTheme.accentGreen),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(point.label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final int value;
  final double height;
  final Color color;

  const _Bar({required this.value, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$value registro(s)',
      child: Container(
        width: 10,
        height: value == 0 ? 4 : height.clamp(8, 130),
        decoration: BoxDecoration(
          color: color.withValues(alpha: value == 0 ? 0.25 : 1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<WeeklyTrendPoint> points;

  const _SummaryCard({required this.points});

  @override
  Widget build(BuildContext context) {
    final behaviorTotal =
        points.fold<int>(0, (sum, item) => sum + item.behaviorCount);
    final videoTotal =
        points.fold<int>(0, (sum, item) => sum + item.videoCount);
    final activeWeeks = points
        .where((point) => point.behaviorCount + point.videoCount > 0)
        .length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumo do período',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          const SizedBox(height: 10),
          Text(
              '$behaviorTotal registros ABC e $videoTotal vídeos em $activeWeeks de 8 semanas.'),
          const SizedBox(height: 6),
          const Text(
              'Semanas sem registro também aparecem para ajudar a perceber lacunas de anotação.',
              style: TextStyle(color: AppTheme.mutedText, fontSize: 12)),
        ],
      ),
    );
  }
}
