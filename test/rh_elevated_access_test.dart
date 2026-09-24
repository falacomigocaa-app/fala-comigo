import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/core/authorization/rh_elevated_access.dart';

void main() {
  final now = DateTime.utc(2026, 9, 23, 12);

  RhElevatedAccessDecision decision({
    bool requesterActive = true,
    bool approverAuthorized = true,
    bool sameOrganization = true,
    String purpose = 'investigar falha administrativa',
    RhElevatedScope scope = RhElevatedScope.auditMetadata,
    DateTime? expiresAt,
    bool withoutExpiration = false,
    DateTime? revokedAt,
  }) {
    return RhElevatedAccessPolicy.decide(
      requesterActive: requesterActive,
      approverAuthorized: approverAuthorized,
      sameOrganization: sameOrganization,
      purpose: purpose,
      scope: scope,
      now: now,
      expiresAt: withoutExpiration
          ? null
          : expiresAt ?? now.add(const Duration(minutes: 30)),
      revokedAt: revokedAt,
    );
  }

  test('suporte aprovado pode acessar metadados por tempo curto', () {
    expect(decision().allowed, isTrue);
  });

  test('operador inativo ou sem aprovação não recebe acesso elevado', () {
    expect(
      decision(requesterActive: false).reason,
      RhElevatedAccessReason.requesterInactive,
    );
    expect(
      decision(approverAuthorized: false).reason,
      RhElevatedAccessReason.approverMissing,
    );
  });

  test('acesso elevado nunca atravessa organizações', () {
    expect(
      decision(sameOrganization: false).reason,
      RhElevatedAccessReason.organizationScopeMismatch,
    );
  });

  test('motivo vazio é negado', () {
    expect(
      decision(purpose: '   ').reason,
      RhElevatedAccessReason.purposeRequired,
    );
  });

  test('conteúdo familiar e clínico são escopos proibidos', () {
    for (final scope in [
      RhElevatedScope.familyContent,
      RhElevatedScope.clinicalContent,
    ]) {
      expect(
        decision(scope: scope).reason,
        RhElevatedAccessReason.scopeNotAllowed,
      );
    }
  });

  test('prazo ausente, expirado ou longo demais é negado', () {
    expect(
      decision(withoutExpiration: true).reason,
      RhElevatedAccessReason.expirationRequired,
    );
    expect(
      decision(expiresAt: now.subtract(const Duration(minutes: 1))).reason,
      RhElevatedAccessReason.expirationRequired,
    );
    expect(
      decision(expiresAt: now.add(const Duration(hours: 3))).reason,
      RhElevatedAccessReason.expirationTooLong,
    );
  });

  test('acesso já revogado não pode continuar válido', () {
    expect(
      decision(revokedAt: now.subtract(const Duration(seconds: 1))).reason,
      RhElevatedAccessReason.alreadyRevoked,
    );
  });

  test('revogação futura não invalida antes da hora', () {
    expect(
      decision(revokedAt: now.add(const Duration(minutes: 10))).allowed,
      isTrue,
    );
  });
}
