import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Protege a área parental sem guardar o PIN em texto puro.
///
/// O PIN é convertido em um verificador PBKDF2-HMAC-SHA256 com salt aleatório
/// e armazenado no Keystore/Keychain por flutter_secure_storage. Tentativas
/// inválidas têm atraso progressivo e bloqueio temporário após cinco falhas.
class ParentalPinService {
  ParentalPinService._();

  static const _storage = FlutterSecureStorage();
  static const _saltKey = 'fala_comigo_parental_pin_salt_v2';
  static const _verifierKey = 'fala_comigo_parental_pin_verifier_v2';
  static const _failedAttemptsKey = 'fala_comigo_parental_pin_failed_attempts_v2';
  static const _lockoutUntilKey = 'fala_comigo_parental_pin_lockout_until_v2';
  static const _iterations = 100000;
  static final _random = Random.secure();

  static Pbkdf2 get _kdf => Pbkdf2.hmacSha256(
        iterations: _iterations,
        bits: 256,
      );

  static Future<bool> hasPin() async {
    final salt = await _storage.read(key: _saltKey);
    final verifier = await _storage.read(key: _verifierKey);
    return salt != null && verifier != null;
  }

  static Future<Duration?> remainingLockout() async {
    final raw = await _storage.read(key: _lockoutUntilKey);
    final until = int.tryParse(raw ?? '');
    if (until == null) return null;
    final remaining = DateTime.fromMillisecondsSinceEpoch(until).difference(DateTime.now());
    if (remaining <= Duration.zero) {
      await _storage.delete(key: _lockoutUntilKey);
      return null;
    }
    return remaining;
  }

  static Future<bool> checkPin(String input) async {
    if (!await hasPin()) return false;
    if (await remainingLockout() != null) return false;

    final saltEncoded = await _storage.read(key: _saltKey);
    final expectedEncoded = await _storage.read(key: _verifierKey);
    if (saltEncoded == null || expectedEncoded == null) return false;

    final derived = await _derive(input, base64Url.decode(saltEncoded));
    final expected = base64Url.decode(expectedEncoded);
    if (_constantTimeEquals(derived, expected)) {
      await _clearFailures();
      return true;
    }

    await _recordFailure();
    return false;
  }

  static Future<void> setPin(String newPin) async {
    _validatePin(newPin);
    final salt = List<int>.generate(16, (_) => _random.nextInt(256));
    final verifier = await _derive(newPin, salt);
    await _storage.write(key: _saltKey, value: base64UrlEncode(salt));
    await _storage.write(key: _verifierKey, value: base64UrlEncode(verifier));
    await _clearFailures();
  }

  static void _validatePin(String pin) {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw const FormatException('O PIN deve conter exatamente quatro dígitos.');
    }
    if (pin == '1234' || pin == '0000' || RegExp(r'^(\d)\1{3}$').hasMatch(pin)) {
      throw const FormatException('Escolha um PIN menos previsível.');
    }
  }

  static Future<List<int>> _derive(String pin, List<int> salt) async {
    final key = await _kdf.deriveKeyFromPassword(password: pin, nonce: salt);
    return await key.extractBytes();
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    var difference = a.length ^ b.length;
    final length = min(a.length, b.length);
    for (var i = 0; i < length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }

  static Future<void> _recordFailure() async {
    final raw = await _storage.read(key: _failedAttemptsKey);
    final failures = (int.tryParse(raw ?? '') ?? 0) + 1;
    await _storage.write(key: _failedAttemptsKey, value: '$failures');

    final seconds = failures >= 5 ? 30 : min(1 << (failures - 1), 8);
    final until = DateTime.now().add(Duration(seconds: seconds)).millisecondsSinceEpoch;
    await _storage.write(key: _lockoutUntilKey, value: '$until');
  }

  static Future<void> _clearFailures() async {
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockoutUntilKey);
  }
}
