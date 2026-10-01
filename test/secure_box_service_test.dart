import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:fala_comigo/core/services/secure_box_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final secureValues = <String, String>{};
  late Directory root;

  setUpAll(() async {
    root =
        await Directory.systemTemp.createTemp('fala_comigo_secure_box_test_');
    final hiveDirectory = '${root.path}/hive';
    Hive.init(hiveDirectory);
    SecureBoxService.configureHiveDirectory(hiveDirectory);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(secureStorageChannel, (call) async {
      final args = call.arguments is Map
          ? Map<String, dynamic>.from(call.arguments as Map)
          : <String, dynamic>{};
      switch (call.method) {
        case 'write':
          secureValues[args['key'] as String] = args['value'] as String;
          return null;
        case 'read':
          return secureValues[args['key'] as String];
        case 'delete':
          secureValues.remove(args['key'] as String);
          return null;
        case 'containsKey':
          return secureValues.containsKey(args['key'] as String);
        default:
          return null;
      }
    });
  });

  tearDownAll(() async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(secureStorageChannel, null);
    await Hive.close();
    await root.delete(recursive: true);
  });

  test('recupera backup interrompido antes de abrir qualquer box', () async {
    final original = File('${root.path}/hive/not_yet_opened.hive');
    final backup = File('${original.path}.fcm-backup');
    final temporary = File('${backup.path}.tmp');
    final knownBytes = [12, 34, 56, 78];
    await original.parent.create(recursive: true);
    await original.writeAsBytes([0]);
    await backup.writeAsBytes(knownBytes);
    await temporary.writeAsBytes([99]);

    await SecureBoxService.recoverPendingHiveSnapshots();

    expect(await original.readAsBytes(), knownBytes);
    expect(await backup.exists(), isFalse);
    expect(await temporary.exists(), isFalse);
  });

  test('box cifrada válida abre e remove o snapshot transitório', () async {
    const name = 'encrypted_valid';
    final key = Hive.generateSecureKey();
    final original = await Hive.openBox<String>(
      name,
      encryptionCipher: HiveAesCipher(key),
    );
    await original.put('profile', 'valor válido');
    await original.close();
    secureValues['fala_comigo_hive_encryption_key'] = base64UrlEncode(key);

    final reopened = await SecureBoxService.openSecureBox<String>(name);
    expect(reopened.get('profile'), 'valor válido');
    expect(
      await File('${root.path}/hive/$name.hive.fcm-backup').exists(),
      isFalse,
    );
    await reopened.close();
  });

  test('falha fechada sem apagar uma box legada em plaintext', () async {
    const name = 'legacy_plaintext';
    final legacy = await Hive.openBox<String>(name);
    await legacy.put('profile', 'valor preservado');
    await legacy.close();

    secureValues['fala_comigo_hive_encryption_key'] =
        base64UrlEncode(Hive.generateSecureKey());

    await expectLater(
      SecureBoxService.openSecureBox<String>(name),
      throwsA(isA<SecureBoxOpenException>()),
    );

    expect(await Hive.boxExists(name), isTrue);
    final preserved = await Hive.openBox<String>(name);
    expect(preserved.get('profile'), 'valor preservado');
    await preserved.close();
  });

  test('chave divergente não substitui uma box cifrada existente', () async {
    const name = 'encrypted_wrong_key';
    final originalKey = Hive.generateSecureKey();
    final original = await Hive.openBox<String>(
      name,
      encryptionCipher: HiveAesCipher(originalKey),
    );
    await original.put('profile', 'valor cifrado preservado');
    await original.close();

    secureValues['fala_comigo_hive_encryption_key'] =
        base64UrlEncode(Hive.generateSecureKey());

    await expectLater(
      SecureBoxService.openSecureBox<String>(name),
      throwsA(isA<SecureBoxOpenException>()),
    );

    expect(await Hive.boxExists(name), isTrue);
    final preserved = await Hive.openBox<String>(
      name,
      encryptionCipher: HiveAesCipher(originalKey),
    );
    expect(preserved.get('profile'), 'valor cifrado preservado');
    await preserved.close();
  });
}
