import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/core/authorization/rh_authorization_policy.dart';

void main() {
  final now = DateTime.utc(2026, 9, 23, 12);

  RhAuthorizationRequest request({
    bool authenticated = true,
    bool accountActive = true,
    bool sameOrganization = true,
    RhRole role = RhRole.benefitAdministrator,
    Set<String> entitlements = const {
      RhAuthorizationPolicy.portalEntitlement,
      RhAuthorizationPolicy.benefitEntitlement,
      RhAuthorizationPolicy.aggregateEntitlement,
    },
    RhOperation operation = RhOperation.viewProgram,
    String purpose = 'benefit_administration',
    String? requiredPurpose,
    String? scope,
    String? requiredScope,
    DateTime? expiresAt,
    bool consentValid = false,
    bool aggregateMeetsThreshold = true,
    bool auditReady = true,
  }) {
    return RhAuthorizationRequest(
      authenticated: authenticated,
      accountActive: accountActive,
      sameOrganization: sameOrganization,
      role: role,
      entitlements: entitlements,
      operation: operation,
      purpose: purpose,
      requiredPurpose: requiredPurpose,
      scope: scope,
      requiredScope: requiredScope,
      now: now,
      expiresAt: expiresAt,
      consentValid: consentValid,
      aggregateMeetsThreshold: aggregateMeetsThreshold,
      auditReady: auditReady,
    );
  }

  test('administrador com produto e finalidade corretos pode ver o programa',
      () {
    final decision = RhAuthorizationPolicy.decide(request());

    expect(decision.allowed, isTrue);
    expect(decision.reason, RhAuthorizationReason.allowed);
  });

  test('nega sessão ausente, conta inativa e organização divergente', () {
    expect(
      RhAuthorizationPolicy.decide(request(authenticated: false)).reason,
      RhAuthorizationReason.unauthenticated,
    );
    expect(
      RhAuthorizationPolicy.decide(request(accountActive: false)).reason,
      RhAuthorizationReason.accountInactive,
    );
    expect(
      RhAuthorizationPolicy.decide(request(sameOrganization: false)).reason,
      RhAuthorizationReason.organizationScopeMismatch,
    );
  });

  test('papel sem entitlement administrativo não acessa licença', () {
    final decision = RhAuthorizationPolicy.decide(
      request(
        role: RhRole.support,
        entitlements: const {RhAuthorizationPolicy.portalEntitlement},
        operation: RhOperation.manageLicense,
      ),
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason, RhAuthorizationReason.entitlementMissing);
  });

  test('licença patrocinada não é suficiente para entrar no portal RH', () {
    final decision = RhAuthorizationPolicy.decide(
      request(
        entitlements: const {'sponsoredLicense'},
        operation: RhOperation.viewProgram,
      ),
    );

    expect(decision.reason, RhAuthorizationReason.entitlementMissing);
  });

  test('relatório agregado abaixo do limiar é suprimido', () {
    final decision = RhAuthorizationPolicy.decide(
      request(
        operation: RhOperation.viewAggregateReport,
        aggregateMeetsThreshold: false,
      ),
    );

    expect(decision.reason, RhAuthorizationReason.aggregateThresholdNotMet);
  });

  test('RH nunca acessa conteúdo familiar, exportação ou consentimento clínico',
      () {
    for (final operation in [
      RhOperation.viewFamilyContent,
      RhOperation.exportFamilyContent,
      RhOperation.createCareAuthorization,
    ]) {
      final decision = RhAuthorizationPolicy.decide(
        request(operation: operation),
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, RhAuthorizationReason.operationNotAllowed);
    }
  });

  test('finalidade, escopo e prazo inválidos são negados', () {
    expect(
      RhAuthorizationPolicy.decide(
        request(
          requiredPurpose: 'benefit_administration',
          purpose: 'support',
        ),
      ).reason,
      RhAuthorizationReason.purposeMismatch,
    );
    expect(
      RhAuthorizationPolicy.decide(
        request(
          scope: 'family_content',
          requiredScope: 'benefit_program',
        ),
      ).reason,
      RhAuthorizationReason.scopeMissing,
    );
    expect(
      RhAuthorizationPolicy.decide(
        request(expiresAt: now.subtract(const Duration(minutes: 1))),
      ).reason,
      RhAuthorizationReason.authorizationExpired,
    );
  });

  test('auditoria é obrigatória para toda operação administrativa', () {
    final decision = RhAuthorizationPolicy.decide(
      request(auditReady: false),
    );

    expect(decision.reason, RhAuthorizationReason.auditRequirementsMissing);
  });
}
