import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/core/authorization/rh_authorization_policy.dart';

void main() {
  final now = DateTime.utc(2026, 9, 23, 12);
  const adminEntitlements = {
    RhAuthorizationPolicy.portalEntitlement,
    RhAuthorizationPolicy.benefitEntitlement,
    RhAuthorizationPolicy.aggregateEntitlement,
  };

  RhAuthorizationRequest request({
    required RhOperation operation,
    bool sameOrganization = true,
    RhRole role = RhRole.benefitAdministrator,
    Set<String> entitlements = adminEntitlements,
  }) {
    return RhAuthorizationRequest(
      authenticated: true,
      accountActive: true,
      sameOrganization: sameOrganization,
      role: role,
      entitlements: entitlements,
      operation: operation,
      purpose: 'benefit_administration',
      requiredPurpose: null,
      scope: null,
      requiredScope: null,
      now: now,
      expiresAt: null,
      consentValid: false,
      aggregateMeetsThreshold: true,
      auditReady: true,
    );
  }

  test('organização cruzada nega todas as operações administrativas', () {
    for (final operation in [
      RhOperation.viewProgram,
      RhOperation.manageLicense,
      RhOperation.viewAggregateReport,
    ]) {
      final decision = RhAuthorizationPolicy.decide(
        request(operation: operation, sameOrganization: false),
      );

      expect(decision.allowed, isFalse, reason: operation.name);
      expect(
        decision.reason,
        RhAuthorizationReason.organizationScopeMismatch,
      );
    }
  });

  test('organização cruzada é negada antes de avaliar entitlement ou limiar',
      () {
    final decision = RhAuthorizationPolicy.decide(
      request(
        operation: RhOperation.viewAggregateReport,
        sameOrganization: false,
        entitlements: const {},
      ),
    );

    expect(decision.reason, RhAuthorizationReason.organizationScopeMismatch);
  });

  test('papéis de família, clínica e escola não administram o programa RH', () {
    for (final role in [RhRole.family, RhRole.clinician, RhRole.school]) {
      final decision = RhAuthorizationPolicy.decide(
        request(operation: RhOperation.viewProgram, role: role),
      );

      expect(decision.allowed, isFalse, reason: role.name);
      expect(decision.reason, RhAuthorizationReason.entitlementMissing);
    }
  });

  test('suporte sem entitlement de benefício não administra licenças', () {
    final decision = RhAuthorizationPolicy.decide(
      request(
        operation: RhOperation.manageLicense,
        role: RhRole.support,
        entitlements: const {RhAuthorizationPolicy.portalEntitlement},
      ),
    );

    expect(decision.reason, RhAuthorizationReason.entitlementMissing);
  });

  test('administrador da própria organização pode consultar somente agregados',
      () {
    final decision = RhAuthorizationPolicy.decide(
      request(operation: RhOperation.viewAggregateReport),
    );

    expect(decision.allowed, isTrue);
  });
}
