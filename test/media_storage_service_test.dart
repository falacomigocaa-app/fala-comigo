import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/core/services/media_storage_service_io.dart';

void main() {
  test('rejeita origem de mídia inexistente', () async {
    expect(
      () => MediaStorageService.persistFile(
        '/tmp/fala_comigo_missing_source_9f4c.jpg',
      ),
      throwsA(isA<FileSystemException>()),
    );
  });

  test('materialização de caminho ausente falha sem produzir arquivo',
      () async {
    expect(
      () => MediaStorageService.materializeForReading(
        '/tmp/fala_comigo_missing_media_9f4c.jpg.fcm',
      ),
      throwsA(isA<FileSystemException>()),
    );
  });
}
