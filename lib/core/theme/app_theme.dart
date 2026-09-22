import 'package:flutter/material.dart';

/// Tema visual do app: futurismo calmo, com contraste, previsibilidade e
/// pouca estimulação visual para preservar a comunicação como prioridade.
class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFFF4F7FB);
  static const Color primary = Color(0xFF315BFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color accentGreen = Color(0xFF23B6A2);
  static const Color textDark = Color(0xFF14213D);
  static const Color cardBorder = Color(0xFFD8E1F0);

  // Paleta sóbria usada na Área do Responsável/Profissional — mais
  // discreta que as cores lúdicas da tela de comunicação da criança,
  // para reforçar a sensação de "ferramenta de trabalho".
  static const Color professionalBackground = Color(0xFF0B1325);
  static const Color professionalSurface = Color(0xFF141F38);
  static const Color professionalAccent = Color(0xFF7DE2D1);

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
