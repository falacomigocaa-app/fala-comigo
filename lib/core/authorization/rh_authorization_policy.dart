/// Operações administrativas e de cuidado que podem ser avaliadas pelo servidor.
enum RhOperation {
  viewProgram,
  manageLicense,
  viewAggregateReport,
  viewFamilyContent,
  exportFamilyContent,
  createCareAuthorization,
}

enum RhRole { benefitAdministrator, support, family, clinician, school }

enum RhAuthorizationReason {
  allowed,
  unauthenticated,
  accountInactive,
  organizationScopeMismatch,
  entitlementMissing,
  productScopeMismatch,
  purposeMismatch,
  scopeMissing,
  authorizationExpired,
  consentMissing,
  aggregateThresholdNotMet,
  operationNotAllowed,
  auditRequirementsMissing,
}

class RhAuthorizationDecision {
  final bool allowed;
  final RhAuthorizationReason reason;

  const RhAuthorizationDecision._(this.allowed, this.reason);

  const RhAuthorizationDecision.allow()
      : this._(true, RhAuthorizationReason.allowed);

  const RhAuthorizationDecision.deny(RhAuthorizationReason reason)
      : this._(false, reason);
}

/// Pedido mínimo que o backend deve avaliar antes de executar uma operação.
///
/// A classe não recebe conteúdo familiar, diagnóstico, mídia ou identificadores
/// de criança. Ela avalia somente identidade, organização, finalidade, escopo
/// e estado administrativo.
class RhAuthorizationRequest {
  final bool authenticated;
  final bool accountActive;
  final bool sameOrganization;
  final RhRole role;
  final Set<String> entitlements;
  final RhOperation operation;
  final String purpose;
  final String? requiredPurpose;
  final String? scope;
  final String? requiredScope;
  final DateTime now;
  final DateTime? expiresAt;
  final bool consentValid;
  final bool aggregateMeetsThreshold;
  final bool auditReady;

  const RhAuthorizationRequest({
    required this.authenticated,
    required this.accountActive,
    required this.sameOrganization,
    required this.role,
    required this.entitlements,
    required this.operation,
    required this.purpose,
    required this.requiredPurpose,
    required this.scope,
    required this.requiredScope,
    required this.now,
    required this.expiresAt,
    required this.consentValid,
    required this.aggregateMeetsThreshold,
    required this.auditReady,
  });
}

class RhAuthorizationPolicy {
  RhAuthorizationPolicy._();

  static const portalEntitlement = 'organizationPortal';
  static const benefitEntitlement = 'benefitAdministration';
  static const aggregateEntitlement = 'aggregateReporting';

  static RhAuthorizationDecision decide(RhAuthorizationRequest request) {
    if (!request.authenticated) {
      return const RhAuthorizationDecision.deny(
        RhAuthorizationReason.unauthenticated,
      );
    }
    if (!request.accountActive) {
      return const RhAuthorizationDecision.deny(
        RhAuthorizationReason.accountInactive,
      );
    }
    if (!request.sameOrganization) {
      return const RhAuthorizationDecision.deny(
        RhAuthorizationReason.organizationScopeMismatch,
      );
    }
    if (!request.auditReady) {
      return const RhAuthorizationDecision.deny(
        RhAuthorizationReason.auditRequirementsMissing,
      );
    }
    if (request.expiresAt != null &&
        !request.now.isBefore(request.expiresAt!)) {
      return const RhAuthorizationDecision.deny(
        RhAuthorizationReason.authorizationExpired,
      );
    }

    if (request.operation == RhOperation.viewFamilyContent ||
        request.operation == RhOperation.exportFamilyContent ||
        request.operation == RhOperation.createCareAuthorization) {
      return const RhAuthorizationDecision.deny(
        RhAuthorizationReason.operationNotAllowed,
      );
    }

    if (request.operation == RhOperation.viewProgram ||
        request.operation == RhOperation.manageLicense) {
      if (request.role != RhRole.benefitAdministrator ||
          !request.entitlements.contains(portalEntitlement) ||
          !request.entitlements.contains(benefitEntitlement)) {
        return const RhAuthorizationDecision.deny(
          RhAuthorizationReason.entitlementMissing,
        );
      }
    }

    if (request.operation == RhOperation.viewAggregateReport) {
      if (request.role != RhRole.benefitAdministrator ||
          !request.entitlements.contains(portalEntitlement) ||
          !request.entitlements.contains(aggregateEntitlement)) {
        return const RhAuthorizationDecision.deny(
          RhAuthorizationReason.entitlementMissing,
        );
      }
      if (!request.aggregateMeetsThreshold) {
        return const RhAuthorizationDecision.deny(
          RhAuthorizationReason.aggregateThresholdNotMet,
        );
      }
    }

    if (request.requiredPurpose != null &&
        request.purpose != request.requiredPurpose) {
      return const RhAuthorizationDecision.deny(
        RhAuthorizationReason.purposeMismatch,
      );
    }
    if (request.requiredScope != null &&
        request.scope != request.requiredScope) {
      return const RhAuthorizationDecision.deny(
        RhAuthorizationReason.scopeMissing,
      );
    }
    if (request.requiredPurpose == 'care_coordination' &&
        !request.consentValid) {
      return const RhAuthorizationDecision.deny(
        RhAuthorizationReason.consentMissing,
      );
    }

    return const RhAuthorizationDecision.allow();
  }
}
