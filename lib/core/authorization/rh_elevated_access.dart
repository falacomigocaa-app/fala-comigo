enum RhElevatedScope {
  benefitAdministration,
  auditMetadata,
  familyContent,
  clinicalContent,
}

enum RhElevatedAccessReason {
  allowed,
  requesterInactive,
  approverMissing,
  organizationScopeMismatch,
  purposeRequired,
  scopeNotAllowed,
  expirationRequired,
  expirationTooLong,
  alreadyRevoked,
}

class RhElevatedAccessDecision {
  final bool allowed;
  final RhElevatedAccessReason reason;

  const RhElevatedAccessDecision._(this.allowed, this.reason);

  const RhElevatedAccessDecision.allow()
      : this._(true, RhElevatedAccessReason.allowed);

  const RhElevatedAccessDecision.deny(RhElevatedAccessReason reason)
      : this._(false, reason);
}

class RhElevatedAccessPolicy {
  RhElevatedAccessPolicy._();

  static const maxDuration = Duration(hours: 2);

  static RhElevatedAccessDecision decide({
    required bool requesterActive,
    required bool approverAuthorized,
    required bool sameOrganization,
    required String purpose,
    required RhElevatedScope scope,
    required DateTime now,
    required DateTime? expiresAt,
    required DateTime? revokedAt,
  }) {
    if (!requesterActive) {
      return const RhElevatedAccessDecision.deny(
        RhElevatedAccessReason.requesterInactive,
      );
    }
    if (!approverAuthorized) {
      return const RhElevatedAccessDecision.deny(
        RhElevatedAccessReason.approverMissing,
      );
    }
    if (!sameOrganization) {
      return const RhElevatedAccessDecision.deny(
        RhElevatedAccessReason.organizationScopeMismatch,
      );
    }
    if (purpose.trim().isEmpty) {
      return const RhElevatedAccessDecision.deny(
        RhElevatedAccessReason.purposeRequired,
      );
    }
    if (scope == RhElevatedScope.familyContent ||
        scope == RhElevatedScope.clinicalContent) {
      return const RhElevatedAccessDecision.deny(
        RhElevatedAccessReason.scopeNotAllowed,
      );
    }
    if (expiresAt == null || !expiresAt.isAfter(now)) {
      return const RhElevatedAccessDecision.deny(
        RhElevatedAccessReason.expirationRequired,
      );
    }
    if (expiresAt.difference(now) > maxDuration) {
      return const RhElevatedAccessDecision.deny(
        RhElevatedAccessReason.expirationTooLong,
      );
    }
    if (revokedAt != null && !now.isBefore(revokedAt)) {
      return const RhElevatedAccessDecision.deny(
        RhElevatedAccessReason.alreadyRevoked,
      );
    }
    return const RhElevatedAccessDecision.allow();
  }
}
