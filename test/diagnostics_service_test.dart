import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/core/services/diagnostics_service.dart';

void main() {
  setUp(() async {
    await DiagnosticsService.init();
    await DiagnosticsService.clear();
  });

  test('exporta erro estruturado e remove valores sensíveis óbvios', () {
    DiagnosticsService.capture(
      kind: 'test_error',
      error: 'token=abc123 falha em /home/user/private/file.txt',
      metadata: {'screen': 'test', 'password': 'não deveria sair'},
    );

    final report = jsonDecode(DiagnosticsService.exportReportJson())
        as Map<String, dynamic>;
    final events = report['events'] as List<dynamic>;
    final event = events.single as Map<String, dynamic>;

    expect(report['schemaVersion'], 1);
    expect(event['kind'], 'test_error');
    expect(event['message'], contains('[REDACTED]'));
    expect(event['message'], isNot(contains('abc123')));
    expect(event['message'], isNot(contains('/home/user')));
    expect((event['metadata'] as Map<String, dynamic>)['password'],
        contains('[REDACTED]'));
  });

  test('mantém o relatório limitado a 200 eventos', () {
    for (var i = 0; i < 220; i++) {
      DiagnosticsService.capture(kind: 'test', error: 'erro $i');
    }

    final report = jsonDecode(DiagnosticsService.exportReportJson())
        as Map<String, dynamic>;
    expect(report['eventCount'], lessThanOrEqualTo(200));
  });
}
