import 'package:hive/hive.dart';

part 'pictogram_card.g.dart';

/// Categorias usadas para organizar os cartões na grade,
/// facilitando a navegação para crianças no espectro autista.
enum CardCategory {
  acoes,
  pessoas,
  comidas,
  sentimentos,
  lugares,
  objetos,
  personalizado,
}

/// Representa um único cartão de comunicação (pictograma).
///
/// Cada cartão tem um rótulo (o que é falado pelo TTS), um caminho
/// de imagem (asset padrão ou foto adicionada pelos pais) e uma
/// categoria para organização.
@HiveType(typeId: 0)
class PictogramCard extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  String imagePath;

  @HiveField(3)
  bool isCustomImage;

  @HiveField(4)
  String category;

  @HiveField(5)
  int order;

  PictogramCard({
    required this.id,
    required this.label,
    required this.imagePath,
    this.isCustomImage = false,
    this.category = 'personalizado',
    this.order = 0,
  });
}
