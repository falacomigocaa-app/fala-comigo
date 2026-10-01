import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/media_storage_service_io.dart';

/// Exibe uma mídia privada após materializar uma cópia temporária no cache.
class SecureMediaImage extends StatefulWidget {
  final String path;
  final BoxFit fit;

  const SecureMediaImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
  });

  @override
  State<SecureMediaImage> createState() => _SecureMediaImageState();
}

class _SecureMediaImageState extends State<SecureMediaImage> {
  late Future<Uint8List> _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant SecureMediaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) _loadImage();
  }

  void _loadImage() {
    _imageBytes = MediaStorageService.readBytesForDisplay(widget.path)
        .then(Uint8List.fromList);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageBytes,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Icon(Icons.image_not_supported_outlined, size: 48);
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        return Image.memory(
          snapshot.data!,
          fit: widget.fit,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_not_supported_outlined, size: 48),
        );
      },
    );
  }
}
