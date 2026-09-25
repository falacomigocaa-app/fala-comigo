import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/core/services/media_storage_service_web.dart'
    as web_storage;
import 'package:fala_comigo/core/widgets/secure_media_image_web.dart';

void main() {
  test('bloqueia mídia personalizada Web com erro explícito', () async {
    expect(
      () => web_storage.MediaStorageService.persistFile('/tmp/photo.jpg'),
      throwsA(
        isA<UnsupportedError>().having(
          (error) => error.message,
          'message',
          contains('não estão disponíveis na versão Web'),
        ),
      ),
    );

    expect(
      () => web_storage.MediaStorageService.materializeForReading('private'),
      throwsA(
        isA<UnsupportedError>().having(
          (error) => error.message,
          'message',
          contains('não está disponível na versão Web'),
        ),
      ),
    );
  });

  testWidgets('exibe placeholder acessível para imagem privada Web', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SecureMediaImage(path: 'private-photo.fcm')),
      ),
    );

    expect(
      find.byTooltip('Imagem personalizada indisponível nesta versão Web'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });
}
