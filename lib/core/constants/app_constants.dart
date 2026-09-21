class AppConstants {
  AppConstants._();

  /// Tamanho mínimo de toque recomendado para acessibilidade motora
  /// (crianças com dificuldades de coordenação fina).
  static const double minTouchTarget = 64.0;

  /// Espaçamento entre cartões na grade.
  static const double gridSpacing = 12.0;

  /// Duração da animação de destaque ao tocar um cartão.
  /// Mantida curta e suave para evitar sobrecarga sensorial.
  static const Duration cardTapAnimationDuration = Duration(milliseconds: 120);

  static const Map<String, String> categoryLabels = {
    'acoes': 'Ações',
    'pessoas': 'Pessoas',
    'comidas': 'Comidas',
    'sentimentos': 'Sentimentos',
    'lugares': 'Lugares',
    'objetos': 'Objetos',
    'personalizado': 'Meus Cartões',
  };
}
