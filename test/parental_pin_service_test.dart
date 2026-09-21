import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/core/services/parental_pin_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final Map<String, String> fakeStorage = {};

  setUp(() {
    fakeStorage.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      final args = call.arguments is Map
          ? Map<String, dynamic>.from(call.arguments as Map)
          : <String, dynamic>{};
      switch (call.method) {
        case 'write':
          fakeStorage[args['key'] as String] = args['value'] as String;
          return null;
        case 'read':
          return fakeStorage[args['key'] as String];
        case 'delete':
          fakeStorage.remove(args['key'] as String);
          return null;
        case 'deleteAll':
          fakeStorage.clear();
          return null;
        case 'readAll':
          return fakeStorage;
        case 'containsKey':
          return fakeStorage.containsKey(args['key'] as String);
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('ParentalPinService', () {
    test('não aceita nenhum PIN antes da configuração inicial', () async {
      expect(await ParentalPinService.hasPin(), isFalse);
      expect(await ParentalPinService.checkPin('1234'), isFalse);
    });

    test('armazena um verificador e aceita o PIN configurado', () async {
      await ParentalPinService.setPin('4826');

      expect(await ParentalPinService.hasPin(), isTrue);
      expect(await ParentalPinService.checkPin('4826'), isTrue);
      expect(await ParentalPinService.checkPin('9999'), isFalse);
    });

    test('rejeita PIN padrão, repetido ou com formato inválido', () async {
      await expectLater(ParentalPinService.setPin('1234'), throwsFormatException);
      await expectLater(ParentalPinService.setPin('0000'), throwsFormatException);
      await expectLater(ParentalPinService.setPin('1111'), throwsFormatException);
      await expectLater(ParentalPinService.setPin('123'), throwsFormatException);
    });

    test('uma falha inicia bloqueio progressivo antes de nova tentativa', () async {
      await ParentalPinService.setPin('4826');

      expect(await ParentalPinService.checkPin('9999'), isFalse);
      expect(await ParentalPinService.remainingLockout(), isNotNull);
      expect(await ParentalPinService.checkPin('4826'), isFalse);
    });

    test('trocar o PIN invalida o anterior', () async {
      await ParentalPinService.setPin('4826');
      await Future<void>.delayed(const Duration(seconds: 1));
      await ParentalPinService.setPin('7391');

      expect(await ParentalPinService.checkPin('4826'), isFalse);
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(await ParentalPinService.checkPin('7391'), isTrue);
    });
  });
}
