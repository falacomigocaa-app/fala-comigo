import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Armazena mídias privadas cifradas dentro da área exclusiva do aplicativo.
///
/// Novos arquivos usam AES-GCM-256, que fornece confidencialidade e
/// autenticação de integridade. A chave aleatória fica apenas no Keystore do
/// Android/Keychain do iOS através de flutter_secure_storage.
class MediaStorageService {
  MediaStorageService._();

  static const _subfolder = 'fala_comigo_media';
  static const _temporarySubfolder = 'fala_comigo_media_preview';
  static const _keyStorageKey = 'fala_comigo_media_key_v1';
  static const _fileMagic = 'FCM1';
  static const _nonceLength = 12;
  static const _macLength = 16;
  static const _maxFileBytes = 100 * 1024 * 1024;
  static const _allowedExtensions = {
    '.png',
    '.jpg',
    '.jpeg',
    '.webp',
    '.mp4',
    '.m4a',
    '.aac',
    '.wav',
    '.3gp',
  };
  static final _algorithm = AesGcm.with256bits();
  static final _random = Random.secure();
  static const _storage = FlutterSecureStorage();
  static final Map<String, Future<File>> _previewCache = {};

  /// Copia [sourcePath] para a área privada e grava somente a versão cifrada.
  /// O caminho retornado é o identificador persistente a ser salvo no Hive.
  static Future<String> persistFile(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException('Mídia de origem não encontrada', sourcePath);
    }
    final size = await source.length();
    if (size > _maxFileBytes) {
      throw const FileSystemException('Mídia excede o limite permitido.');
    }

    final mediaDir = await _mediaDirectory();
    final extension = _safeExtension(sourcePath);
    if (!_allowedExtensions.contains(extension)) {
      throw const FormatException('Formato de mídia não permitido.');
    }
    final fileName =
        '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 32).toRadixString(16)}$extension.fcm';
    final destination = File('${mediaDir.path}/$fileName');
    final secretBox = await _algorithm.encrypt(
      await source.readAsBytes(),
      secretKey: await _getOrCreateKey(),
    );

    await destination.writeAsBytes(
      <int>[...utf8.encode(_fileMagic), ...secretBox.concatenation()],
      flush: true,
    );
    return destination.path;
  }

  /// Materializa uma cópia temporária somente para widgets, players ou
  /// compartilhamento que exigem um arquivo legível pelo sistema.
  static Future<File> materializeForReading(String path) {
    return _previewCache.putIfAbsent(path, () => _materialize(path));
  }

  /// Remove a mídia cifrada. Caminhos fora da pasta privada são ignorados.
  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (!await _isOwnedPath(file)) return;
    if (await file.exists()) await file.delete();

    final preview = _previewCache.remove(path);
    if (preview != null) {
      final previewFile = await preview;
      if (await previewFile.exists()) await previewFile.delete();
    }
  }

  static Future<void> clearAllMedia() async {
    final appDir = await getApplicationDocumentsDirectory();
    final temporaryDir = await getTemporaryDirectory();
    for (final path in [
      '${appDir.path}/$_subfolder',
      '${appDir.path}/transition_alerts_audio',
      '${temporaryDir.path}/$_temporarySubfolder',
      '${temporaryDir.path}/fala_comigo_audio_recordings',
    ]) {
      final directory = Directory(path);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
    _previewCache.clear();
  }

  /// Remove a chave de mídia para que arquivos remanescentes não possam ser
  /// descriptografados após uma exclusão total dos dados locais.
  static Future<void> deleteEncryptionKey() async {
    await _storage.delete(key: _keyStorageKey);
  }

  static Future<File> _materialize(String path) async {
    final source = File(path);
    if (!await source.exists()) {
      throw FileSystemException('Mídia não encontrada', path);
    }
    if (!await _isOwnedPath(source)) {
      throw const FileSystemException('Caminho de mídia não autorizado.');
    }

    final bytes = await source.readAsBytes();
    final isEncrypted = bytes.length >= _fileMagic.length &&
        utf8.decode(bytes.take(_fileMagic.length).toList(),
                allowMalformed: true) ==
            _fileMagic;
    final plainBytes = isEncrypted
        ? await _decrypt(bytes.sublist(_fileMagic.length))
        : bytes; // compatibilidade com arquivos criados antes da cifra.

    final temporaryDir = Directory(
      '${(await getTemporaryDirectory()).path}/$_temporarySubfolder',
    );
    await temporaryDir.create(recursive: true);
    final extension = _safeExtension(path, fallback: '.bin');
    final temporary = File(
      '${temporaryDir.path}/${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 32).toRadixString(16)}$extension',
    );
    await temporary.writeAsBytes(plainBytes, flush: true);
    return temporary;
  }

  static Future<List<int>> _decrypt(List<int> encoded) async {
    final secretBox = SecretBox.fromConcatenation(
      encoded,
      nonceLength: _nonceLength,
      macLength: _macLength,
    );
    try {
      return await _algorithm.decrypt(
        secretBox,
        secretKey: await _getOrCreateKey(),
      );
    } on SecretBoxAuthenticationError {
      throw const FormatException('A mídia está corrompida ou foi alterada.');
    }
  }

  static Future<SecretKey> _getOrCreateKey() async {
    final existing = await _storage.read(key: _keyStorageKey);
    if (existing != null) return SecretKey(base64Url.decode(existing));

    final key = List<int>.generate(32, (_) => _random.nextInt(256));
    await _storage.write(key: _keyStorageKey, value: base64UrlEncode(key));
    return SecretKey(key);
  }

  static Future<Directory> _mediaDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/$_subfolder');
    await mediaDir.create(recursive: true);
    return mediaDir;
  }

  static Future<bool> _isOwnedPath(File file) async {
    final mediaDir = await _mediaDirectory();
    final appDir = await getApplicationDocumentsDirectory();
    final legacyAudioDir = Directory('${appDir.path}/transition_alerts_audio');
    if (!await file.exists()) return false;
    final filePath = await file.resolveSymbolicLinks();
    final mediaPath = await mediaDir.resolveSymbolicLinks();
    final legacyAudioPath = await legacyAudioDir.exists()
        ? await legacyAudioDir.resolveSymbolicLinks()
        : '';
    return filePath.startsWith('$mediaPath${Platform.pathSeparator}') ||
        filePath.startsWith('$legacyAudioPath${Platform.pathSeparator}');
  }

  static String _safeExtension(String path, {String fallback = ''}) {
    final name = path.split(Platform.pathSeparator).last;
    final withoutCipherSuffix = name.endsWith('.fcm')
        ? name.substring(0, name.length - '.fcm'.length)
        : name;
    final dot = withoutCipherSuffix.lastIndexOf('.');
    if (dot <= 0 || dot == withoutCipherSuffix.length - 1) return fallback;
    final extension = withoutCipherSuffix.substring(dot).toLowerCase();
    return RegExp(r'^\.[a-z0-9]{1,8}$').hasMatch(extension)
        ? extension
        : fallback;
  }
}
