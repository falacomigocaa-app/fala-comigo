import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/parental_pin_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'parental_area_transition_screen.dart';
import 'settings_screen.dart';

/// Gate da Área do Responsável. No primeiro uso exige que o responsável crie
/// um PIN próprio; depois aplica verificação e bloqueio progressivo.
class ParentalGateScreen extends StatefulWidget {
  final Widget destination;

  const ParentalGateScreen({super.key, this.destination = const SettingsScreen()});

  @override
  State<ParentalGateScreen> createState() => _ParentalGateScreenState();
}

class _ParentalGateScreenState extends State<ParentalGateScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = true;
  bool _setupMode = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final hasPin = await ParentalPinService.hasPin();
    if (!mounted) return;
    setState(() {
      _setupMode = !hasPin;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (_setupMode) {
      if (_pinController.text != _confirmController.text) {
        setState(() => _error = 'Os PINs não coincidem.');
        return;
      }
      try {
        await ParentalPinService.setPin(_pinController.text);
      } on FormatException catch (error) {
        setState(() => _error = error.message);
        return;
      }
      if (!mounted) return;
      _openDestination();
      return;
    }

    final locked = await ParentalPinService.remainingLockout();
    if (locked != null) {
      setState(() => _error = 'Acesso temporariamente bloqueado. Tente mais tarde.');
      return;
    }
    final isValid = await ParentalPinService.checkPin(_pinController.text);
    if (!mounted) return;
    if (isValid) {
      _openDestination();
    } else {
      setState(() => _error = 'PIN incorreto. Tente novamente.');
      _pinController.clear();
    }
  }

  void _openDestination() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ParentalAreaTransitionScreen(destination: widget.destination),
      ),
    );
  }

  Widget _pinField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      obscureText: true,
      maxLength: 4,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 28, letterSpacing: 8),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        border: const OutlineInputBorder(),
      ),
      onSubmitted: (_) => _submit(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_setupMode ? 'Criar acesso do responsável' : 'Área do Responsável'),
        backgroundColor: AppTheme.surface,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _setupMode
                    ? 'Crie um PIN pessoal de 4 dígitos. Não use 1234 ou números repetidos.'
                    : 'Digite o PIN de 4 dígitos para continuar',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              _pinField(_setupMode ? 'Novo PIN' : 'PIN do responsável', _pinController),
              if (_setupMode) ...[
                const SizedBox(height: 16),
                _pinField('Confirmar PIN', _confirmController),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_setupMode ? 'Criar PIN e continuar' : 'Entrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
