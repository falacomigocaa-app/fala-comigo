import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Abre Hive Boxes com criptografia AES-256 para dados sensíveis do
/// app (perfil do paciente, registros de comportamento, diário de
/// vídeo). A chave de criptografia é gerada uma única vez e guardada
/// no cofre seguro do sistema operacional (Android Keystore / iOS
/// Keychain via flutter_secure_storage) — nunca fica em texto puro
/// no código-fonte nem dentro do próprio banco de dados.
class SecureBoxService {
  SecureBoxService._();

  static const _storage = FlutterSecureStorage();
  static const _keyStorageKey = 'fala_comigo_hive_encryption_key';

  static Future<List<int>> _getOrCreateEncryptionKey() async {
    final existing = await _storage.read(key: _keyStorageKey);
    if (existing != null) {
      return base64Url.decode(existing);
    }
    final key = Hive.generateSecureKey();
    await _storage.write(key: _keyStorageKey, value: base64UrlEncode(key));
    return key;
  }

  /// Abre (ou cria) uma Box criptografada com o nome informado.
  static Future<Box> openSecureBox(String name) async {
    final key = await _getOrCreateEncryptionKey();
    return Hive.openBox(name, encryptionCipher: HiveAesCipher(key));
  }
}
