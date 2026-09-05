import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/theme/app_theme.dart';

/// Tela de Registro de Comportamento (modelo ABC).
///
/// Permite que pais/educadores registrem episódios de comportamento
/// usando o modelo ABC (Antecedente - Comportamento - Consequência),
/// usado por profissionais de terapia ABA para identificar gatilhos.
///
/// Os registros ficam salvos localmente no dispositivo (Hive).
class BehaviorLogScreen extends StatefulWidget {
  const BehaviorLogScreen({super.key});

  @override
  State<BehaviorLogScreen> createState() => _BehaviorLogScreenState();
}

class _BehaviorLogScreenState extends State<BehaviorLogScreen> {
  static const String _boxName = 'behavior_logs';

  final _antecedentController = TextEditingController();
  final _behaviorController = TextEditingController();
  final _consequenceController = TextEditingController();
  final _notesController = TextEditingController();

  Box? _box;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    final box = await Hive.openBox(_boxName);
    setState(() {
      _box = box;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _antecedentController.dispose();
    _behaviorController.dispose();
    _consequenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_antecedentController.text.trim().isEmpty &&
        _behaviorController.text.trim().isEmpty &&
        _consequenceController.text.trim().isEmpty) {
      return;
    }

    final entry = {
      'timestamp': DateTime.now().toIso8601String(),
      'antecedent': _antecedentController.text.trim(),
      'behavior': _behaviorController.text.trim(),
      'consequence': _consequenceController.text.trim(),
      'notes': _notesController.text.trim(),
    };

    _box?.add(entry);

    _antecedentController.clear();
    _behaviorController.clear();
    _consequenceController.clear();
    _notesController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro salvo.')),
    );
  }

  void _deleteEntry(dynamic key) {
    _box?.delete(key);
  }

  String _formatDate(String isoString) {
    final date = DateTime.tryParse(isoString);
    if (date == null) return '';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$d/$m às $h:$min';
  Future<void> _exportPdf() async {
    if (_box == null || _box!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum registro para exportar.')),
      );
      return;
    }

    final entries = _box!.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList()
        .reversed
        .toList();

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Fala Comigo — Registro de Comportamento (ABC)'),
          ),
          pw.Paragraph(
            text: 'Relatório gerado em ${_formatDate(DateTime.now().toIso8601String())}',
          ),
          pw.SizedBox(height: 12),
          ...entries.map((entry) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    _formatDate(entry['timestamp'] ?? ''),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Antecedente: ${entry['antecedent'] ?? ''}'),
                  pw.Text('Comportamento: ${entry['behavior'] ?? ''}'),
                  pw.Text('Consequência: ${entry['consequence'] ?? ''}'),
                  if ((entry['notes'] ?? '').toString().isNotEmpty)
                    pw.Text('Notas: ${entry['notes']}'),
                ],
              ),
            );
          }),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'registro_comportamento_fala_comigo.pdf',
    );
  }}@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Registro de Comportamento'),
        backgroundColor: AppTheme.surface,
      actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar PDF',
            onPressed: _exportPdf,
          ),
        ],),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Modelo ABC',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Registre o que aconteceu antes, durante e depois de um episódio. '
                    'Isso ajuda terapeutas e educadores a identificar gatilhos.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _antecedentController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Antecedente (o que aconteceu antes)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _behaviorController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Comportamento (o que a criança fez)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _consequenceController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Consequência (o que aconteceu depois)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notas adicionais (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveEntry,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Salvar registro'),
                    ),
                  ),
                  const Divider(height: 40),
                  const Text(
                    'Registros salvos',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  if (_box != null)
                    ValueListenableBuilder(
                      valueListenable: _box!.listenable(),
                      builder: (context, Box box, _) {
                        final keys = box.keys.toList().reversed.toList();
                        if (keys.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Nenhum registro ainda.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        return Column(
                          children: keys.map((key) {
                            final entry = Map<String, dynamic>.from(
                              box.get(key) as Map,
                            );
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(_formatDate(entry['timestamp'] ?? '')),
                                subtitle: Text(
                                  'A: ${entry['antecedent']}\n'
                                  'C: ${entry['behavior']}\n'
                                  'D: ${entry['consequence']}',
                                ),
                                isThreeLine: true,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _deleteEntry(key),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
