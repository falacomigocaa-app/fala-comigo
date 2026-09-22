import 'dart:io';

import 'package:flutter/material.dart';

import '../services/media_storage_service_io.dart';

/// Exibe uma mídia privada após materializar uma cópia temporária no cache.
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
    return FutureBuilder<File>(
      future: MediaStorageService.materializeForReading(path),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Icon(Icons.image_not_supported_outlined, size: 48);
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        return Image.file(
          snapshot.data!,
          fit: fit,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_not_supported_outlined, size: 48),
        );
      },
    );
  }
}
