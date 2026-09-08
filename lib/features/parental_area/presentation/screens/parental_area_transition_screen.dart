import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

/// Tela breve exibida ao entrar na Área do Responsável/Profissional,
/// logo após o PIN ser confirmado. Usa uma identidade visual mais
/// sóbria (diferente da tela de comunicação da criança) para reforçar
/// que dali para frente é uma ferramenta de trabalho para adultos.
///
/// Também é o ponto onde a orientação de tela é liberada (retrato +
/// paisagem), já que formulários são mais confortáveis na vertical.
class ParentalAreaTransitionScreen extends StatefulWidget {
  final Widget destination;

  const ParentalAreaTransitionScreen({super.key, required this.destination});

  @override
  State<ParentalAreaTransitionScreen> createState() =>
      _ParentalAreaTransitionScreenState();
}

class _ParentalAreaTransitionScreenState
    extends State<ParentalAreaTransitionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    // Libera retrato + paisagem para a Área do Responsável.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    HapticFeedback.lightImpact();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => widget.destination),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.professionalBackground,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.professionalSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.professionalAccent,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppTheme.professionalAccent,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Painel Profissional',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Área do Responsável e Profissionais',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppTheme.professionalAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
