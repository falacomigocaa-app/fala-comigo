import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/core/services/parental_pin_service.dart';

/// Testes do serviço de PIN da Área do Responsável — a parte mais
/// crítica de segurança do app. O "cofre seguro" do sistema
/// (flutter_secure_storage) é simulado com um mapa em memória, já
/// que o cofre de verdade só existe num aparelho real.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final Map<String, String> fakeStorage = {};

  setUp(() {
    fakeStorage.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'write':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          fakeStorage[args['key'] as String] = args['value'] as String;
          return null;
        case 'read':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          return fakeStorage[args['key'] as String];
        case 'delete':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          fakeStorage.remove(args['key'] as String);
          return null;
        case 'deleteAll':
          fakeStorage.clear();
          return null;
        case 'readAll':
          return fakeStorage;
        case 'containsKey':
          final args = Map<String, dynamic>.from(call.arguments as Map);
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
    test('aceita o PIN padrão "1234" quando nenhum PIN foi definido ainda', () async {
      final isValid = await ParentalPinService.checkPin('1234');
      expect(isValid, isTrue);
    });

    test('rejeita um PIN errado quando nenhum PIN foi definido ainda', () async {
      final isValid = await ParentalPinService.checkPin('0000');
      expect(isValid, isFalse);
    });

    test('depois de trocar o PIN, o PIN antigo deixa de funcionar', () async {
      await ParentalPinService.setPin('7777');

      final oldPinResult = await ParentalPinService.checkPin('1234');
      final newPinResult = await ParentalPinService.checkPin('7777');

      expect(oldPinResult, isFalse);
      expect(newPinResult, isTrue);
    });

    test('PIN errado após a troca continua sendo rejeitado', () async {
      await ParentalPinService.setPin('5555');
      final isValid = await ParentalPinService.checkPin('9999');
      expect(isValid, isFalse);
    });
  });
}
