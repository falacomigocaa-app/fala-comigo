import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Registro de Comportamento'),
        backgroundColor: AppTheme.surface,
      ),
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
                      la
