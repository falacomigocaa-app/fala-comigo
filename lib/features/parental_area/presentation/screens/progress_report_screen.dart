import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/services/secure_box_service.dart';
import '../../../../core/theme/app_theme.dart';

class ProgressReportScreen extends StatefulWidget {
  const ProgressReportScreen({super.key});

  @override
  State<ProgressReportScreen> createState() => _ProgressReportScreenState();
}

class _ProgressReportScreenState extends State<ProgressReportScreen> {
  Box? _behaviorBox;
  Box? _videoBox;
  Map<String, dynamic>? _profile;
  bool _loading = true;

  int get _behaviorCount => _behaviorBox?.length ?? 0;
  int get _videoCount => _videoBox?.length ?? 0;

  int get _recentBehaviorCount {
    final threshold = DateTime.now().subtract(const Duration(days: 7));
    return _behaviorEntries.where((entry) {
      final date = DateTime.tryParse('${entry['timestamp'] ?? ''}');
      return date != null && date.isAfter(threshold);
    }).length;
  }

  List<Map<String, dynamic>> get _behaviorEntries {
    final values = _behaviorBox?.values ?? const [];
    return values
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList()
        .reversed
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final behaviorBox = await SecureBoxService.openSecureBox('behavior_logs');
    final videoBox = await SecureBoxService.openSecureBox('video_diary');
    final profileBox = await SecureBoxService.openSecureBox('patient_profile');
    final profile = profileBox.get('data');
    if (!mounted) return;
    setState(() {
      _behaviorBox = behaviorBox;
      _videoBox = videoBox;
      _profile = profile is Map ? Map<String, dynamic>.from(profile) : null;
      _loading = false;
    });
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse('$value');
    if (date == null) return 'Data não informada';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month às $hour:$minute';
  }

  Future<void> _exportReport() async {
    final includeProfile = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exportar resumo?'),
        content: const Text(
          'O PDF terá somente contagens e registros recentes por padrão. '
          'Os dados do perfil só entram se você escolher incluí-los. '
          'Depois de compartilhar, cópias externas ficam fora do controle do app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Somente resumo'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Incluir perfil'),
          ),
        ],
      ),
    );
    if (includeProfile == null || !mounted) return;

    final recentEntries = _behaviorEntries.take(10).toList();
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Fala Comigo — Resumo de registros'),
          ),
          pw.Text('Gerado em ${_formatDate(DateTime.now().toIso8601String())}'),
          pw.SizedBox(height: 12),
          if (includeProfile == true && _profile != null)
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Perfil informado',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  if ('${_profile?['name'] ?? ''}'.isNotEmpty)
                    pw.Text('Nome: ${_profile?['name']}'),
                  if ('${_profile?['guardian'] ?? ''}'.isNotEmpty)
                    pw.Text('Responsável: ${_profile?['guardian']}'),
                  if ('${_profile?['school'] ?? ''}'.isNotEmpty)
                    pw.Text('Escola/clínica: ${_profile?['school']}'),
                ],
              ),
            ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Indicadores descritivos',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Bullet(text: 'Registros ABC no aparelho: $_behaviorCount'),
          pw.Bullet(
            text: 'Registros ABC nos últimos 7 dias: $_recentBehaviorCount',
          ),
          pw.Bullet(text: 'Vídeos no diário local: $_videoCount'),
          pw.SizedBox(height: 12),
          pw.Text(
            'Registros recentes',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          if (recentEntries.isEmpty) pw.Text('Nenhum registro ABC disponível.'),
          ...recentEntries.map(
            (entry) => pw.Container(
              margin: const pw.EdgeInsets.only(top: 8),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              child: pw.Text(
                '${_formatDate(entry['timestamp'])}\n'
                'Antecedente: ${entry['antecedent'] ?? ''}\n'
                'Comportamento: ${entry['behavior'] ?? ''}\n'
                'Apoio/consequência: ${entry['consequence'] ?? ''}',
              ),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Este resumo descreve registros feitos pela família. Não é avaliação clínica, diagnóstico ou previsão de evolução.',
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'resumo_fala_comigo.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Relatórios de progresso'),
        backgroundColor: AppTheme.professionalBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loading ? null : _exportReport,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar resumo',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
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
                      Icon(
                        Icons.insights_outlined,
                        color: AppTheme.professionalAccent,
                        size: 28,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Um resumo do que foi registrado no aparelho, sem interpretar ou diagnosticar.',
                          style: TextStyle(
                            color: Colors.white,
                            height: 1.35,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.fact_check_outlined,
                        value: '$_behaviorCount',
                        label: 'registros ABC',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.videocam_outlined,
                        value: '$_videoCount',
                        label: 'vídeos locais',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _MetricCard(
                  icon: Icons.date_range_outlined,
                  value: '$_recentBehaviorCount',
                  label: 'registros ABC nos últimos 7 dias',
                ),
                const SizedBox(height: 18),
                const Text(
                  'Registros recentes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (_behaviorEntries.isEmpty)
                  const _EmptyReportState()
                else
                  ..._behaviorEntries
                      .take(5)
                      .map(
                        (entry) => _RecentEntryCard(
                          date: _formatDate(entry['timestamp']),
                          behavior: '${entry['behavior'] ?? ''}',
                          consequence: '${entry['consequence'] ?? ''}',
                        ),
                      ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _exportReport,
                  icon: const Icon(Icons.ios_share_outlined),
                  label: const Text('Exportar resumo para compartilhar'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.cardBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentEntryCard extends StatelessWidget {
  final String date;
  final String behavior;
  final String consequence;

  const _RecentEntryCard({
    required this.date,
    required this.behavior,
    required this.consequence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Comportamento: ${behavior.isEmpty ? 'não informado' : behavior}',
          ),
          Text(
            'Apoio/consequência: ${consequence.isEmpty ? 'não informado' : consequence}',
          ),
        ],
      ),
    );
  }
}

class _EmptyReportState extends StatelessWidget {
  const _EmptyReportState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: const Column(
        children: [
          Icon(Icons.insert_chart_outlined, color: AppTheme.primary, size: 40),
          SizedBox(height: 8),
          Text(
            'Ainda não há registros para resumir.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Os dados aparecem aqui depois que a família registrar uma rotina.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.mutedText),
          ),
        ],
      ),
    );
  }
}
