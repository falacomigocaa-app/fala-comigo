import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'secure_box_service.dart';

/// Registra falhas técnicas de forma local, minimizada e sem conteúdo de
/// cartões, frases, nomes, diagnósticos, fotos, áudio ou vídeo.
///
/// O relatório pode ser exportado pelo responsável para análise de suporte.
/// O envio automático para terceiros não faz parte deste serviço.
class DiagnosticsService {
  DiagnosticsService._();

  static const boxName = 'diagnostics';
  static const _maxEvents = 200;
  static const _maxMessageLength = 800;
  static const _maxStackLength = 3000;
  static Box? _box;
  static final List<Map<String, dynamic>> _memoryEvents = [];
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      _box = await SecureBoxService.openSecureBoxWithMigration(boxName);
    } catch (_) {
      // Diagnóstico nunca pode impedir o app de abrir.
      _box = null;
    } finally {
      _initialized = true;
    }
  }

  static void captureFlutterError(FlutterErrorDetails details) {
    capture(
      kind: 'flutter_error',
      error: details.exception,
      stackTrace: details.stack,
      context: details.context?.toDescription(),
    );
  }

  static bool capturePlatformError(Object error, StackTrace stackTrace) {
    capture(
      kind: 'platform_error',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  }

  static void capture({
    required String kind,
    Object? error,
    StackTrace? stackTrace,
    String? context,
    Map<String, Object?> metadata = const {},
  }) {
    final event = <String, dynamic>{
      'schemaVersion': 1,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'kind': _sanitize(kind, 80),
      'message':
          _sanitize(error?.toString() ?? 'Sem mensagem', _maxMessageLength),
      'stackTrace': _sanitize(stackTrace?.toString() ?? '', _maxStackLength),
      'context': _sanitize(context ?? '', 200),
      'platform': _platformName(),
      'isWeb': kIsWeb,
      'metadata': _sanitizeMetadata(metadata),
    };

    _memoryEvents.add(event);
    _trim(_memoryEvents);

    final box = _box;
    if (box != null && !box.isOpen) return;
    try {
      final key =
          '${DateTime.now().microsecondsSinceEpoch}-${math.Random().nextInt(1000)}';
      box?.put(key, event);
      if (box != null) {
        final keys = box.keys.toList();
        final excess = keys.length - _maxEvents;
        for (var i = 0; i < excess; i++) {
          box.delete(keys[i]);
        }
      }
    } catch (_) {
      // Falhas no logger são deliberadamente silenciosas.
    }
  }

  static String exportReportJson() {
    final events = <Map<String, dynamic>>[..._memoryEvents];
    final box = _box;
    if (box != null && box.isOpen) {
      for (final value in box.values) {
        if (value is Map) {
          final event = Map<String, dynamic>.from(value);
          if (!events.any((item) => item['timestamp'] == event['timestamp'])) {
            events.add(event);
          }
        }
      }
    }
    events.sort((a, b) => '${a['timestamp']}'.compareTo('${b['timestamp']}'));
    return const JsonEncoder.withIndent('  ').convert({
      'schemaVersion': 1,
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'platform': _platformName(),
      'isWeb': kIsWeb,
      'eventCount': events.length,
      'events': events,
    });
  }

  static int get eventCount {
    final box = _box;
    return box != null && box.isOpen
        ? math.max(_memoryEvents.length, box.length)
        : _memoryEvents.length;
  }

  static Future<void> clear() async {
    _memoryEvents.clear();
    final box = _box;
    if (box != null && box.isOpen) await box.clear();
  }

  static void resetAfterDataWipe() {
    _box = null;
    _initialized = false;
    _memoryEvents.clear();
  }

  static String _platformName() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  static Map<String, String> _sanitizeMetadata(Map<String, Object?> metadata) {
    return metadata.map(
      (key, value) {
        final sanitizedKey = _sanitize(key, 80);
        final isSensitiveKey = RegExp(
          r'password|token|secret|api[_-]?key',
          caseSensitive: false,
        ).hasMatch(sanitizedKey);
        return MapEntry(
          sanitizedKey,
          isSensitiveKey
              ? '[REDACTED]'
              : _sanitize(value?.toString() ?? '', 200),
        );
      },
    );
  }

  static String _sanitize(String value, int maxLength) {
    var sanitized = value
        .replaceAll(
          RegExp(
            r'(password|token|secret|api[_-]?key)\s*[=:]\s*[^\s,;]+',
            caseSensitive: false,
          ),
          '[REDACTED]',
        )
        .replaceAll(
            RegExp(r'(/home/[^\s]+|/data/user/[^\s]+|[A-Za-z]:\\[^\s]+)'),
            '[PATH_REDACTED]')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (sanitized.length > maxLength)
      sanitized = '${sanitized.substring(0, maxLength)}…';
    return sanitized;
  }

  static void _trim(List<Map<String, dynamic>> events) {
    if (events.length <= _maxEvents) return;
    events.removeRange(0, events.length - _maxEvents);
  }
}

/// Mantém a referência ao dispatcher importada nesta unidade para garantir
/// que as plataformas Flutter suportadas sejam vinculadas no build.
PlatformDispatcher get diagnosticsPlatformDispatcher =>
    PlatformDispatcher.instance;
