import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/core/authorization/rh_audit_event.dart';

void main() {
  RhAuditEvent event({
    String actorId = 'operator-demo-01',
    String organizationId = 'organization-demo-01',
    String reason = 'convite administrativo criado',
  }) {
    return RhAuditEvent(
      id: 'audit-demo-0001',
      actorId: actorId,
      organizationId: organizationId,
      operation: 'benefit_invitation.create',
      resourceType: 'BenefitLicense',
      resourceId: 'license-demo-014',
      result: RhAuditResult.allowed,
      reason: reason,
      occurredAt: DateTime.utc(2026, 9, 23, 12),
    );
  }

  test('evento administrativo válido serializa somente campos mínimos', () {
    final json = event().toJson();

    expect(json['actorId'], 'operator-demo-01');
    expect(json['organizationId'], 'organization-demo-01');
    expect(json['resourceType'], 'BenefitLicense');
    expect(json.containsKey('diagnosis'), isFalse);
    expect(json.containsKey('content'), isFalse);
    expect(json.containsKey('media'), isFalse);
  });

  test('evento negado também exige motivo para auditoria', () {
    final denied = RhAuditEvent(
      id: 'audit-demo-0002',
      actorId: 'operator-demo-01',
      organizationId: 'organization-demo-01',
      operation: 'family_content.export',
      resourceType: 'FamilyContent',
      resourceId: 'blocked-resource',
      result: RhAuditResult.denied,
      reason: 'operation_not_allowed',
      occurredAt: DateTime.utc(2026, 9, 23, 12),
    );

    expect(denied.isValid, isTrue);
    expect(denied.toJson()['result'], 'denied');
  });

  test('identidade, organização, operação e motivo vazios invalidam evento',
      () {
    expect(event(actorId: '').isValid, isFalse);
    expect(event(organizationId: '').isValid, isFalse);
    expect(event(reason: '').isValid, isFalse);
  });

  test('evento inválido não pode ser serializado', () {
    expect(() => event(actorId: '').toJson(), throwsStateError);
  });

  test('timestamp é normalizado para UTC', () {
    final json = event().toJson();

    expect(json['occurredAt'], '2026-09-23T12:00:00.000Z');
  });
}
