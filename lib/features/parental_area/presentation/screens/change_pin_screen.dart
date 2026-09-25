import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/parental_pin_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/parental_ui.dart';

/// Tela para o responsável trocar o PIN de 4 dígitos do "Parental Gate".
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
    setState(() => _error = null);
    final currentOk = await ParentalPinService.checkPin(
      _currentController.text,
    );
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

    try {
      await ParentalPinService.setPin(_newController.text);
    } on FormatException catch (error) {
      setState(() => _error = error.message);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN atualizado com sucesso.')),
    );
    Navigator.of(context).pop();
  }

  Widget _pinField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        obscureText: true,
        maxLength: 4,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 23,
          fontWeight: FontWeight.w700,
          letterSpacing: 8,
        ),
        decoration: parentalInputDecoration(
          labelText: label,
          icon: Icons.lock_outline,
        ).copyWith(counterText: ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Trocar PIN'),
        backgroundColor: AppTheme.professionalBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ParentalSectionHeading(
                    eyebrow: 'SEGURANÇA LOCAL',
                    title: 'Atualizar acesso',
                    description: 'Altere o código usado para abrir a Área Parental neste aparelho.',
                  ),
                  const SizedBox(height: 18),
                  const ParentalInfoBanner(
                    icon: Icons.lock_outline,
                    eyebrow: 'PROTEÇÃO DO APARELHO',
                    message: 'O PIN permanece local. Escolha um código que o responsável consiga guardar com segurança.',
                  ),
                  const SizedBox(height: 16),
                  ParentalSurface(
                    child: Column(
                      children: [
                        _pinField('PIN atual', _currentController),
                        _pinField('Novo PIN (4 dígitos)', _newController),
                        _pinField('Confirmar novo PIN', _confirmController),
                        if (_error != null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F1),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: const Color(0xFFF4C7C7),
                              ),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Color(0xFFB42318),
                                height: 1.3,
                              ),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Salvar novo PIN'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              backgroundColor: AppTheme.professionalBackground,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
