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
  }

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
    final profileBox = await SecureBoxService.openSecureBox('patient_profile');
    final profileData = profileBox.get('data') as Map?;
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
            text: 'Relatório gerado em ${_formatDate(DateTime.now().toIso8601String())}',
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
                  crossAxisAlignment: pw.CrossAx
