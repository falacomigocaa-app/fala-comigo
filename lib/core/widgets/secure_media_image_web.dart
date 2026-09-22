import 'package:flutter/material.dart';

/// Placeholder acessível enquanto a mídia personalizada Web não possui
/// armazenamento cifrado equivalente ao fluxo nativo.
class SecureMediaImage extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const SecureMediaImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Tooltip(
        message: 'Imagem personalizada indisponível nesta versão Web',
        child: Icon(Icons.image_not_supported_outlined, size: 48),
      ),
    );
  }
}
