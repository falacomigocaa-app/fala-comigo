import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/parental_pin_service.dart';
import '../../../../core/theme/app_theme.dart';

/// "Parental Gate": tela de bloqueio por PIN de 4 dígitos, exigida
/// antes de entrar na Área do Responsável (configurações, perfil do
/// paciente, registros de comportamento, diário de vídeo).
///
/// O PIN é verificado pelo ParentalPinService, que guarda o valor
/// de forma segura (flutter_secure_storage) e permite que o
/// responsável o troque a qualquer momento.
class ParentalGateScreen extends StatefulWidget {
  final Widget destination;

  const ParentalGateScreen({super.key, required this.destination});

  @override
  State<ParentalGateScreen> createState() => _ParentalGateScreenState();
}

class _ParentalGateScreenState extends State<ParentalGateScreen> {
  final _pinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _checkPin() async {
    final isValid = await ParentalPinService.checkPin(_pinController.text);
    if (isValid) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => widget.destination),
      );
    } else {
      setState(() => _error = 'PIN incorreto. Tente novamente.');
      _pinController.clear();
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Digite o PIN de 4 dígitos para continuar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, letterSpacing: 8),
                decoration: const InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _checkPin(),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 20),
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
