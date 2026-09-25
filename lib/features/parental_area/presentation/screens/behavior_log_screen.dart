import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/services/secure_box_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Tela de Registro de Comportamento (modelo ABC).
///
/// Permite que pais/educadores registrem episódios de comportamento
/// usando o modelo ABC (Antecedente - Comportamento - Consequência),
/// usado por profissionais de terapia ABA para identificar gatilhos.
///
/// Os registros ficam salvos localmente no dispositivo, em uma Hive
/// Box criptografada com AES-256 (ver SecureBoxService).
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
    final box = await SecureBoxService.openSecureBox(_boxName);
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

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Registro salvo.')));
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
  }

  Future<void> _exportPdf() async {
    if (_box == null || _box!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum registro para exportar.')),
      );
      return;
    }

    final includeProfileData = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        var includeData = false;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Exportar relatório?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Por padrão, o PDF contém somente os registros ABC. '
                  'Depois do compartilhamento, o aplicativo não controla as cópias enviadas a outros serviços.',
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: includeData,
                  onChanged: (value) =>
                      setDialogState(() => includeData = value ?? false),
                  title: const Text('Incluir dados identificadores'),
                  subtitle: const Text(
                    'Nome, responsável, escola e nível de suporte',
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(includeData),
                child: const Text('Exportar'),
              ),
            ],
          ),
        );
      },
    );
    if (includeProfileData == null || !mounted) return;

    final entries = _box!.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList()
        .reversed
        .toList();
    final profileData = includeProfileData
        ? (await SecureBoxService.openSecureBox('patient_profile')).get('data')
              as Map?
        : null;
    final patientName = profileData?['name'] ?? '';
    final birthDate = profileData?['birthDate'] ?? '';
    final supportLevel = profileData?['supportLevel'] ?? '';
    final guardian = profileData?['guardian'] ?? '';
    final school = profileData?['school'] ?? '';

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Fala Comigo — Registro de Comportamento (ABC)'),
          ),
          pw.Paragraph(
            text:
                'Relatório gerado em ${_formatDate(DateTime.now().toIso8601String())}',
          ),
          if (patientName.toString().isNotEmpty)
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 8, bottom: 8),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Paciente: $patientName',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  if (birthDate.toString().isNotEmpty)
                    pw.Text('Data de nascimento: $birthDate'),
                  if (supportLevel.toString().isNotEmpty)
                    pw.Text('Nível de suporte (DSM-5): $supportLevel'),
                  if (guardian.toString().isNotEmpty)
                    pw.Text('Responsável: $guardian'),
                  if (school.toString().isNotEmpty)
                    pw.Text('Escola/clínica: $school'),
                ],
              ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Registro de Comportamento'),
        backgroundColor: AppTheme.professionalBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar PDF',
            onPressed: _exportPdf,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          Icons.fact_check_outlined,
                          color: AppTheme.professionalAccent,
                          size: 28,
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modelo ABC',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Descreva o contexto, o que foi observado e o apoio oferecido. Prefira fatos concretos.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                      labelText: 'Comportamento observado (sem interpretações)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _consequenceController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Depois e apoio oferecido',
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
                                title: Text(
                                  _formatDate(entry['timestamp'] ?? ''),
                                ),
                                subtitle: Text(
                                  'A: ${entry['antecedent']}\n'
                                  'B: ${entry['behavior']}\n'
                                  'C: ${entry['consequence']}',
                                ),
                                isThreeLine: true,
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
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
