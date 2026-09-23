import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/services/secure_box_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Perfil do Paciente: dados usados para identificar a criança nos
/// relatórios gerados pelo app (PDF), dando um formato mais
/// profissional para uso por terapeutas e escolas.
///
/// Esses dados são sensíveis (nome, data de nascimento, diagnóstico
/// de um menor) e ficam salvos em uma Hive Box criptografada com
/// AES-256 (ver SecureBoxService).
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
  bool _consentAccepted = false;

  static const _supportLevels = ['Nível 1', 'Nível 2', 'Nível 3'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final box = await SecureBoxService.openSecureBox(_boxName);
    final data = box.get('data') as Map?;
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _birthDateController.text = data['birthDate'] ?? '';
      _guardianController.text = data['guardian'] ?? '';
      _schoolController.text = data['school'] ?? '';
      _supportLevel = data['supportLevel'] ?? 'Nível 1';
      _consentAccepted = data['consentAccepted'] == true;
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
    if (!_consentAccepted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Proteção de dados da criança'),
          content: const Text(
            'Estes dados podem identificar uma criança e aparecer em relatórios. Preencha somente o que for necessário. Ao continuar, confirme que você é o responsável legal ou está autorizado a cuidar desses dados. O conteúdo fica no aparelho e não é enviado automaticamente pelo Fala Comigo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sou responsável/autorizado'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      _consentAccepted = true;
    }

    await _box?.put('data', {
      'name': _nameController.text.trim(),
      'birthDate': _birthDateController.text.trim(),
      'guardian': _guardianController.text.trim(),
      'school': _schoolController.text.trim(),
      'supportLevel': _supportLevel,
      'consentAccepted': true,
      'consentAt': DateTime.now().toIso8601String(),
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
        backgroundColor: AppTheme.professionalBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.professionalBackground,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.shield_outlined,
                            color: AppTheme.professionalAccent, size: 26),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tudo é opcional. Preencha somente o necessário; os dados aparecem nos relatórios em PDF gerados pelo app.',
                            style: TextStyle(
                                fontSize: 13, color: Colors.white, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Column(
                      children: [
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
                            labelText: 'Data de nascimento (opcional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _supportLevel,
                          decoration: const InputDecoration(
                            labelText: 'Nível de suporte (opcional)',
                            border: OutlineInputBorder(),
                          ),
                          items: _supportLevels
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _supportLevel = v ?? 'Nível 1'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _guardianController,
                          decoration: const InputDecoration(
                            labelText: 'Nome do responsável (opcional)',
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
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Salvar perfil'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
