import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/parental_pin_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Tela para o responsável trocar o PIN de 4 dígitos do "Parental
/// Gate". Exige digitar o PIN atual antes de definir um novo.
class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final currentOk = await ParentalPinService.checkPin(_currentController.text);
    if (!currentOk) {
      setState(() => _error = 'PIN atual incorreto.');
      return;
    }
    if (_newController.text.length != 4) {
      setState(() => _error = 'O novo PIN deve ter 4 dígitos.');
      return;
    }
    if (_newController.text != _confirmController.text) {
      setState(() => _error = 'Os PINs não coincidem.');
      return;
    }

    await ParentalPinService.setPin(_newController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN atualizado com sucesso.')),
    );
    Navigator.of(context).pop();
  }

  Widget _pinField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        obscureText: true,
        maxLength: 4,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, letterSpacing: 6),
        decoration: InputDecoration(
          labelText: label,
          counterText: '',
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Trocar PIN'),
        backgroundColor: AppTheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _pinField('PIN atual', _currentController),
            _pinField('Novo PIN (4 dígitos)', _newController),
            _pinField('Confirmar novo PIN', _confirmController),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 56),
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salvar novo PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
