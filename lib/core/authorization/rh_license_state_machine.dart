enum RhLicenseState { invited, active, grace, suspended, expired, revoked }

enum RhLicenseTransitionReason {
  allowed,
  actorNotAuthorized,
  reasonRequired,
  transitionNotAllowed,
  alreadyInTargetState,
}

class RhLicenseTransitionDecision {
  final bool allowed;
  final RhLicenseTransitionReason reason;

  const RhLicenseTransitionDecision._(this.allowed, this.reason);

  const RhLicenseTransitionDecision.allow()
    : this._(true, RhLicenseTransitionReason.allowed);

  const RhLicenseTransitionDecision.deny(RhLicenseTransitionReason reason)
    : this._(false, reason);
}

class RhLicenseStateMachine {
  RhLicenseStateMachine._();

  static RhLicenseTransitionDecision decide({
    required RhLicenseState from,
    required RhLicenseState to,
    required bool actorAuthorized,
    required String? reason,
  }) {
    if (!actorAuthorized) {
      return const RhLicenseTransitionDecision.deny(
        RhLicenseTransitionReason.actorNotAuthorized,
      );
    }
    if (from == to) {
      return const RhLicenseTransitionDecision.deny(
        RhLicenseTransitionReason.alreadyInTargetState,
      );
    }
    if (_requiresReason(to) && (reason == null || reason.trim().isEmpty)) {
      return const RhLicenseTransitionDecision.deny(
        RhLicenseTransitionReason.reasonRequired,
      );
    }
    if (!_allowedTargets(from).contains(to)) {
      return const RhLicenseTransitionDecision.deny(
        RhLicenseTransitionReason.transitionNotAllowed,
      );
    }
    return const RhLicenseTransitionDecision.allow();
  }

  static bool _requiresReason(RhLicenseState target) {
    return target == RhLicenseState.suspended ||
        target == RhLicenseState.expired ||
        target == RhLicenseState.revoked;
  }

  static Set<RhLicenseState> _allowedTargets(RhLicenseState state) {
    switch (state) {
      case RhLicenseState.invited:
        return {RhLicenseState.active, RhLicenseState.expired};
      case RhLicenseState.active:
        return {
          RhLicenseState.grace,
          RhLicenseState.suspended,
          RhLicenseState.expired,
          RhLicenseState.revoked,
        };
      case RhLicenseState.grace:
        return {
          RhLicenseState.active,
          RhLicenseState.suspended,
          RhLicenseState.expired,
          RhLicenseState.revoked,
        };
      case RhLicenseState.suspended:
        return {
          RhLicenseState.active,
          RhLicenseState.expired,
          RhLicenseState.revoked,
        };
      case RhLicenseState.expired:
        return {RhLicenseState.revoked};
      case RhLicenseState.revoked:
        return {};
    }
  }
}
