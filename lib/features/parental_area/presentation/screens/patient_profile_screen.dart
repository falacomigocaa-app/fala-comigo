import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/theme/app_theme.dart';

/// Perfil do Paciente: dados usados para identificar a criança nos
/// relatórios gerados pelo app (PDF), dando um formato mais
/// profissional para uso por terapeutas e escolas.
class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  static const String _boxName = 'patient_profile';

  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _guardianController = TextEditingController();
  final _schoolController = TextEditingController();
  String _supportLevel = 'Nível 1';

  Box? _box;
  bool _loading = true;

  static const _supportLevels = ['Nível 1', 'Nível 2', 'Nível 3'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final box = await Hive.openBox(_boxName);
    final data = box.get('data') as Map?;
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _birthDateController.text = data['birthDate'] ?? '';
      _guardianController.text = data['guardian'] ?? '';
      _schoolController.text = data['school'] ?? '';
      _supportLevel = data['supportLevel'] ?? 'Nível 1';
    }
    setState(() {
      _box = box;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _guardianController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    await _box?.put('data', {
      'name': _nameController.text.trim(),
      'birthDate': _birthDateController.text.trim(),
      'guardian': _guardianController.text.trim(),
      'school': _schoolController.text.trim(),
      'supportLevel': _supportLevel,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil salvo.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Perfil do Paciente'),
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
                    'Esses dados aparecem nos relatórios em PDF gerados pelo app.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo da criança',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _birthDateController,
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento (ex: 15/03/2018)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _supportLevel,
                    decoration: const InputDecoration(
                      labelText: 'Nível de suporte (DSM-5)',
                      border: OutlineInputBorder(),
                    ),
                    items: _supportLevels
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _supportLevel = v ?? 'Nível 1'),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _guardianController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do responsável',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _schoolController,
                    decoration: const InputDecoration(
                      labelText: 'Escola/clínica (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Salvar perfil'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
