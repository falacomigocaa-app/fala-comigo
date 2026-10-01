import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Falha explícita ao abrir uma box cifrada sem descartar os dados originais.
class SecureBoxOpenException implements Exception {
  const SecureBoxOpenException(
    this.boxName,
    this.cause, {
    this.nativeSnapshotRestored = false,
  });

  final String boxName;
  final Object cause;
  final bool nativeSnapshotRestored;

  @override
  String toString() {
    final recovery = nativeSnapshotRestored
        ? 'O snapshot nativo do arquivo original foi restaurado.'
        : 'A recuperação deste armazenamento ainda não foi validada.';
    return 'Não foi possível abrir a caixa protegida "$boxName". $recovery '
        'Migração automática foi suspensa para evitar perda ou corrupção. '
        'Causa: $cause';
  }
}

/// Abre Hive Boxes com AES-256 e protege o arquivo contra recovery destrutivo.
class SecureBoxService {
  SecureBoxService._();

  static const _storage = FlutterSecureStorage();
  static const _keyStorageKey = 'fala_comigo_hive_encryption_key';
  static String? _hiveDirectoryPath;

  /// Informa o diretório passado a Hive.init/Hive.initFlutter no runtime nativo.
  /// No Web, onde Hive usa IndexedDB, não existe arquivo para snapshot.
  static void configureHiveDirectory(String path) {
    _hiveDirectoryPath = path;
  }

  /// Recupera backups interrompidos de todas as boxes antes de Hive abri-las.
  static Future<void> recoverPendingHiveSnapshots() async {
    final directoryPath = _hiveDirectoryPath;
    if (directoryPath == null) return;
    final directory = Directory(directoryPath);
    if (!await directory.exists()) return;

    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      final path = entity.path;
      if (path.endsWith('.fcm-backup.tmp')) {
        await entity.delete();
        continue;
      }
      if (!path.endsWith('.fcm-backup')) continue;

      final originalPath = path.substring(
        0,
        path.length - '.fcm-backup'.length,
      );
      final original = File(originalPath);
      if (await original.exists()) await original.delete();
      await entity.rename(originalPath);
    }
  }

  static Future<List<int>> _getOrCreateEncryptionKey() async {
    final existing = await _storage.read(key: _keyStorageKey);
    if (existing != null) {
      return base64Url.decode(existing);
    }
    final key = Hive.generateSecureKey();
    await _storage.write(key: _keyStorageKey, value: base64UrlEncode(key));
    return key;
  }

  /// Abre (ou cria) uma box cifrada. Antes de abrir uma box existente no native,
  /// mantém cópia recuperável dos bytes. Hive pode recuperar uma chave errada
  /// como uma box vazia; se o arquivo mudar durante a abertura, o snapshot é
  /// restaurado e a operação falha fechada. Boxes legadas não são migradas
  /// automaticamente até existir fluxo validado de backup e recuperação.
  static Future<Box<T>> openSecureBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) return Hive.box<T>(name);

    final key = await _getOrCreateEncryptionKey();
    final snapshot = await _HiveFileSnapshot.capture(
      _hiveDirectoryPath,
      name,
    );
    Box<T>? openedBox;
    try {
      openedBox = await Hive.openBox<T>(
        name,
        encryptionCipher: HiveAesCipher(key),
      );
      if (snapshot != null && await snapshot.wasChangedByOpen()) {
        await openedBox.close();
        openedBox = null;
        throw StateError(
          'Hive tentou recuperar ou reescrever a caixa; o arquivo original será restaurado.',
        );
      }
      await snapshot?.discard();
      return openedBox;
    } catch (error) {
      if (Hive.isBoxOpen(name)) {
        try {
          await Hive.box<T>(name).close();
        } catch (_) {
          // Preservar a falha original; a recuperação do arquivo é prioritária.
        }
      }
      try {
        await snapshot?.restore();
      } catch (restoreError) {
        throw SecureBoxOpenException(
          name,
          StateError(
              'Falha de abertura: $error. Falha ao restaurar backup: $restoreError'),
        );
      }
      throw SecureBoxOpenException(
        name,
        error,
        nativeSnapshotRestored: snapshot != null,
      );
    }
  }

  static Future<void> deleteEncryptionKey() async {
    await _storage.delete(key: _keyStorageKey);
  }
}

class _HiveFileSnapshot {
  _HiveFileSnapshot(this._entries, this._boxFile);

  final List<_HiveFileEntry> _entries;
  final File _boxFile;

  static Future<_HiveFileSnapshot?> capture(
    String? directoryPath,
    String name,
  ) async {
    if (directoryPath == null) return null;
    if (name.contains('/') || name.contains('\\')) {
      throw ArgumentError.value(name, 'name', 'Nome de box inválido.');
    }
    final base = Directory(directoryPath);
    final boxFile =
        File('${base.path}${Platform.pathSeparator}${name.toLowerCase()}.hive');
    final compactedFile = File('${boxFile.path}c');

    // Um processo pode ter sido interrompido enquanto Hive reescrevia a box.
    // Sidecars só são criados depois de cópia verificada; portanto, restaurá-los
    // é seguro antes de iniciar outra tentativa de abertura.
    for (final file in [boxFile, compactedFile]) {
      final backup = File('${file.path}.fcm-backup');
      final temporary = File('${backup.path}.tmp');
      if (await backup.exists()) {
        if (await file.exists()) await file.delete();
        await backup.rename(file.path);
      }
      if (await temporary.exists()) await temporary.delete();
    }

    if (!await boxFile.exists() && !await compactedFile.exists()) return null;
    final entries = <_HiveFileEntry>[];
    for (final file in [boxFile, compactedFile]) {
      final backup = File('${file.path}.fcm-backup');
      final temporary = File('${backup.path}.tmp');
      if (!await file.exists()) {
        entries.add(_HiveFileEntry(file, backup, temporary, null));
        continue;
      }
      final bytes = await file.readAsBytes();
      await file.copy(temporary.path);
      if (!_sameBytes(bytes, await temporary.readAsBytes())) {
        await temporary.delete();
        throw FileSystemException(
            'Não foi possível verificar o backup Hive.', file.path);
      }
      await temporary.rename(backup.path);
      entries.add(_HiveFileEntry(file, backup, temporary, bytes));
    }
    return _HiveFileSnapshot(entries, boxFile);
  }

  Future<bool> wasChangedByOpen() async {
    final mainEntry = _entries.first;
    final expected = mainEntry.bytes ?? _entries[1].bytes;
    if (expected == null) return false;
    if (!await _boxFile.exists()) return true;
    return !_sameBytes(expected, await _boxFile.readAsBytes());
  }

  Future<void> restore() async {
    for (final entry in _entries) {
      if (await entry.backup.exists()) {
        if (await entry.original.exists()) await entry.original.delete();
        await entry.backup.rename(entry.original.path);
      } else if (entry.bytes == null && await entry.original.exists()) {
        await entry.original.delete();
      }
      if (await entry.temporary.exists()) await entry.temporary.delete();
    }
  }

  Future<void> discard() async {
    for (final entry in _entries) {
      if (await entry.backup.exists()) await entry.backup.delete();
      if (await entry.temporary.exists()) await entry.temporary.delete();
    }
  }

  static bool _sameBytes(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}

class _HiveFileEntry {
  const _HiveFileEntry(this.original, this.backup, this.temporary, this.bytes);

  final File original;
  final File backup;
  final File temporary;
  final List<int>? bytes;
}
