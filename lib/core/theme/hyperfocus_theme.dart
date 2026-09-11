import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Temas de "hiperfoco": deixam a identidade visual da tela de
/// comunicação da criança mais parecida com o interesse dela,
/// gerando conexão imediata com o app. Escolhido pelos pais na
/// Área do Responsável.
enum HyperfocusTheme {
  padrao,
  dinossauros,
  espaco,
  carros,
  bolhasDeSabao,
  animais,
  trens;

  String get displayName {
    switch (this) {
      case HyperfocusTheme.padrao:
        return 'Padrão';
      case HyperfocusTheme.dinossauros:
        return 'Dinossauros';
      case HyperfocusTheme.espaco:
        return 'Espaço';
      case HyperfocusTheme.carros:
        return 'Carros';
      case HyperfocusTheme.bolhasDeSabao:
        return 'Bolhas de Sabão';
      case HyperfocusTheme.animais:
        return 'Animais';
      case HyperfocusTheme.trens:
        return 'Trens';
    }
  }

  String get emoji {
    switch (this) {
      case HyperfocusTheme.padrao:
        return '⭐';
      case HyperfocusTheme.dinossauros:
        return '🦕';
      case HyperfocusTheme.espaco:
        return '🚀';
      case HyperfocusTheme.carros:
        return '🚗';
      case HyperfocusTheme.bolhasDeSabao:
        return '🫧';
      case HyperfocusTheme.animais:
        return '🐾';
      case HyperfocusTheme.trens:
        return '🚂';
    }
  }

  Color get primaryColor {
    switch (this) {
      case HyperfocusTheme.padrao:
        return const Color(0xFF5B5FEF);
      case HyperfocusTheme.dinossauros:
        return const Color(0xFF4C8C4A);
      case HyperfocusTheme.espaco:
        return const Color(0xFF3B4A8C);
      case HyperfocusTheme.carros:
        return const Color(0xFFD1495B);
      case HyperfocusTheme.bolhasDeSabao:
        return const Color(0xFF4FB6C4);
      case HyperfocusTheme.animais:
        return const Color(0xFFC97A3D);
      case HyperfocusTheme.trens:
        return const Color(0xFF7A5FC7);
    }
  }

  /// Cor de fundo da tela da criança para este tema: um tom bem
  /// suave (pastel) misturado com branco, mantendo o contraste alto
  /// para leitura e evitando estímulo visual excessivo. O tema
  /// Padrão mantém exatamente o fundo original do app.
  Color get backgroundColor {
    if (this == HyperfocusTheme.padrao) {
      return const Color(0xFFF7F8FC);
    }
    return Color.alphaBlend(primaryColor.withValues(alpha: 0.07), Colors.white);
  }
}

const String _hiveBoxName = 'app_settings';
const String _hiveKey = 'hyperfocus_theme';

class HyperfocusThemeNotifier extends StateNotifier<HyperfocusTheme> {
  HyperfocusThemeNotifier() : super(_loadInitial());

  static HyperfocusTheme _loadInitial() {
    final box = Hive.box(_hiveBoxName);
    final saved = box.get(_hiveKey) as String?;
    return HyperfocusTheme.values.firstWhere(
      (t) => t.name == saved,
      orElse: () => HyperfocusTheme.padrao,
    );
  }

  Future<void> setTheme(HyperfocusTheme theme) async {
    state = theme;
    final box = Hive.box(_hiveBoxName);
    await box.put(_hiveKey, theme.name);
  }
}

final hyperfocusThemeProvider =
    StateNotifierProvider<HyperfocusThemeNotifier, HyperfocusTheme>(
  (ref) => HyperfocusThemeNotifier(),
);
