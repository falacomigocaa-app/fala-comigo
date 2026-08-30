import '../../domain/models/pictogram_card.dart';

/// Conjunto inicial de pictogramas que acompanha o app, para que a
/// criança já tenha cartões básicos disponíveis no primeiro uso —
/// antes mesmo dos pais cadastrarem fotos personalizadas.
///
/// As imagens ficam em `assets/images/cards/` (ver pubspec.yaml).
class SeedCards {
  SeedCards._();

  static List<PictogramCard> defaultCards() {
    final data = <Map<String, String>>[
      {'label': 'Comer', 'file': 'comer', 'category': 'acoes'},
      {'label': 'Beber', 'file': 'beber', 'category': 'acoes'},
      {'label': 'Dormir', 'file': 'dormir', 'category': 'acoes'},
      {'label': 'Brincar', 'file': 'brincar', 'category': 'acoes'},
      {'label': 'Ajuda', 'file': 'ajuda', 'category': 'acoes'},
      {'label': 'Feliz', 'file': 'feliz', 'category': 'sentimentos'},
      {'label': 'Triste', 'file': 'triste', 'category': 'sentimentos'},
      {'label': 'Bravo', 'file': 'bravo', 'category': 'sentimentos'},
      {'label': 'Água', 'file': 'agua', 'category': 'comidas'},
      {'label': 'Maçã', 'file': 'maca', 'category': 'comidas'},
      {'label': 'Pão', 'file': 'pao', 'category': 'comidas'},
      {'label': 'Mamãe', 'file': 'mamae', 'category': 'pessoas'},
      {'label': 'Papai', 'file': 'papai', 'category': 'pessoas'},
      {'label': 'Sim', 'file': 'sim', 'category': 'objetos'},
      {'label': 'Não', 'file': 'nao', 'category': 'objetos'},
    ];

    return List.generate(data.length, (i) {
      final item = data[i];
      return PictogramCard(
        id: 'seed_${item['file']}',
        label: item['label']!,
        imagePath: 'assets/images/cards/${item['file']}.png',
        isCustomImage: false,
        category: item['category']!,
        order: i,
      );
    });
  }
}
