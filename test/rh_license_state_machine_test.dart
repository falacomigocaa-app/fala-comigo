import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/core/authorization/rh_license_state_machine.dart';

void main() {
  test('convite pode ser aceito uma vez e virar ativo', () {
    final decision = RhLicenseStateMachine.decide(
      from: RhLicenseState.invited,
      to: RhLicenseState.active,
      actorAuthorized: true,
      reason: null,
    );

    expect(decision.allowed, isTrue);
  });

  test('convite expirado não pode ser reativado', () {
    final decision = RhLicenseStateMachine.decide(
      from: RhLicenseState.expired,
      to: RhLicenseState.active,
      actorAuthorized: true,
      reason: 'novo período exige novo convite',
    );

    expect(decision.reason, RhLicenseTransitionReason.transitionNotAllowed);
  });

  test('licença ativa pode entrar em transição de continuidade', () {
    final decision = RhLicenseStateMachine.decide(
      from: RhLicenseState.active,
      to: RhLicenseState.grace,
      actorAuthorized: true,
      reason: null,
    );

    expect(decision.allowed, isTrue);
  });

  test('transição de suspensão exige motivo', () {
    final decision = RhLicenseStateMachine.decide(
      from: RhLicenseState.active,
      to: RhLicenseState.suspended,
      actorAuthorized: true,
      reason: '  ',
    );

    expect(decision.reason, RhLicenseTransitionReason.reasonRequired);
  });

  test('revogação exige ator autorizado e motivo', () {
    expect(
      RhLicenseStateMachine.decide(
        from: RhLicenseState.active,
        to: RhLicenseState.revoked,
        actorAuthorized: false,
        reason: 'solicitação administrativa',
      ).reason,
      RhLicenseTransitionReason.actorNotAuthorized,
    );
    expect(
      RhLicenseStateMachine.decide(
        from: RhLicenseState.active,
        to: RhLicenseState.revoked,
        actorAuthorized: true,
        reason: null,
      ).reason,
      RhLicenseTransitionReason.reasonRequired,
    );
  });

  test('licença revogada é terminal', () {
    for (final target in RhLicenseState.values.where(
      (state) => state != RhLicenseState.revoked,
    )) {
      final decision = RhLicenseStateMachine.decide(
        from: RhLicenseState.revoked,
        to: target,
        actorAuthorized: true,
        reason: 'não deve reativar',
      );

      expect(decision.reason, RhLicenseTransitionReason.transitionNotAllowed);
    }
  });

  test('licença suspensa pode ser reativada somente por operador autorizado',
      () {
    expect(
      RhLicenseStateMachine.decide(
        from: RhLicenseState.suspended,
        to: RhLicenseState.active,
        actorAuthorized: false,
        reason: null,
      ).reason,
      RhLicenseTransitionReason.actorNotAuthorized,
    );
    expect(
      RhLicenseStateMachine.decide(
        from: RhLicenseState.suspended,
        to: RhLicenseState.active,
        actorAuthorized: true,
        reason: null,
      ).allowed,
      isTrue,
    );
  });

  test('transição para o mesmo estado não gera evento duplicado', () {
    final decision = RhLicenseStateMachine.decide(
      from: RhLicenseState.active,
      to: RhLicenseState.active,
      actorAuthorized: true,
      reason: null,
    );

    expect(decision.reason, RhLicenseTransitionReason.alreadyInTargetState);
  });
}
