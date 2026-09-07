import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gerencia o PIN de 4 dígitos do "Parental Gate" de forma segura.
///
/// O PIN é guardado no cofre seguro do sistema (Android Keystore /
/// iOS Keychain via flutter_secure_storage), nunca em texto puro no
/// código-fonte. Se nenhum PIN foi definido ainda pelo responsável,
/// usa "1234" como valor padrão inicial (mesmo comportamento de
/// antes), mas agora o responsável pode trocá-lo a qualquer momento.
class ParentalPinService {
  ParentalPinService._();

  static const _storage = FlutterSecureStorage();
  static const _pinStorageKey = 'fala_comigo_parental_pin';
  static const _defaultPin = '1234';

  /// Verifica se o PIN informado confere com o PIN salvo (ou o
  /// padrão, caso nenhum tenha sido definido ainda).
  static Future<bool> checkPin(String input) async {
    final saved = await _storage.read(key: _pinStorageKey);
    return input == (saved ?? _defaultPin);
  }

  /// Define um novo PIN, substituindo o anterior (ou o padrão).
  static Future<void> setPin(String newPin) async {
    await _storage.write(key: _pinStorageKey, value: newPin);
  }
}
