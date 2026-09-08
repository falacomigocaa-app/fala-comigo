import 'package:flutter/material.dart';

/// Tema visual do app, seguindo boas práticas de UI/UX para autismo:
/// cores suaves (tons pastel), contraste adequado para leitura,
/// sem gradientes ou elementos visuais agressivos.
class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFFF7F8FC);
  static const Color primary = Color(0xFF5B5FEF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color accentGreen = Color(0xFF34B37A);
  static const Color textDark = Color(0xFF23243A);
  static const Color cardBorder = Color(0xFFE2E4F0);

  // Paleta sóbria usada na Área do Responsável/Profissional — mais
  // discreta que as cores lúdicas da tela de comunicação da criança,
  // para reforçar a sensação de "ferramenta de trabalho".
  static const Color professionalBackground = Color(0xFF161B2E);
  static const Color professionalSurface = Color(0xFF232A45);
  static const Color professionalAccent = Color(0xFF3AAFA9);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        bodyMedium: TextStyle(fontSize: 16, color: textDark),
      ),
    );
  }
}
