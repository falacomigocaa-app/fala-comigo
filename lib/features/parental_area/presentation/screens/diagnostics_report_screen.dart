import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/diagnostics_service.dart';
import '../../../../core/theme/app_theme.dart';

class DiagnosticsReportScreen extends StatefulWidget {
  const DiagnosticsReportScreen({super.key});

  @override
  State<DiagnosticsReportScreen> createState() =>
      _DiagnosticsReportScreenState();
}

class _DiagnosticsReportScreenState extends State<DiagnosticsReportScreen> {
  String _report = DiagnosticsService.exportReportJson();

  void _refresh() {
    setState(() => _report = DiagnosticsService.exportReportJson());
  }

  Future<void> _copyReport() async {
    await Clipboard.setData(ClipboardData(text: _report));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Relatório copiado. Envie apenas ao suporte autorizado.')),
    );
  }

  Future<void> _clearReport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar relatório técnico?'),
        content: const Text(
          'Os eventos locais de diagnóstico serão removidos deste aparelho. Isso não apaga cartões, perfil ou outros dados do aplicativo.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Apagar')),
        ],
      ),
    );
    if (confirmed != true) return;
    await DiagnosticsService.clear();
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório técnico'),
        backgroundColor: AppTheme.professionalBackground,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Este relatório contém apenas eventos técnicos minimizados. Ele não deve conter frases, nomes, diagnósticos, fotos, áudio ou vídeo. Copie e envie somente ao suporte autorizado.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _copyReport,
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copiar relatório'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clearReport,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Apagar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black12,
                child: SingleChildScrollView(
                  child: SelectableText(
                    _report,
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
