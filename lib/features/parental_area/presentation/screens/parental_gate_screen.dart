import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import 'settings_screen.dart';

/// "Parental Gate": tela de bloqueio simples que impede que a
/// criança acesse acidentalmente as configurações. Exige que um
/// adulto digite um PIN de 4 dígitos.
///
/// Não é um mecanismo de segurança forte — é uma barreira cognitiva
/// básica adequada para o público infantil do app, como exigido
/// pelas políticas de apps para crianças da Google Play.
class ParentalGateScreen extends StatefulWidget {
  const ParentalGateScreen({super.key});

  @override
  State<ParentalGateScreen> createState() => _ParentalGateScreenState();
}

class _ParentalGateScreenState extends State<ParentalGateScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _error;

  void _checkPin() {
    if (_pinController.text == AppConstants.defaultParentalPin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    } else {
      setState(() => _error = 'PIN incorreto. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Área do Responsável'),
        backgroundColor: AppTheme.surface,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 56, color: AppTheme.primary),
              const SizedBox(height: 16),
              const Text(
                'Digite o PIN para continuar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  decoration: InputDecoration(
                    counterText: '',
                    errorText: _error,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checkPin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Entrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
