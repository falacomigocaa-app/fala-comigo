import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/features/parental_area/data/access_grants.dart';

void main() {
  final startsAt = DateTime.utc(2026, 9, 23);
  final expiresAt = DateTime.utc(2026, 12, 22);

  AccessGrant grant({AccessGrantStatus status = AccessGrantStatus.active}) =>
      AccessGrant(
        id: 'grant-1',
        organizationName: 'Clínica Caminhos',
        organizationKind: OrganizationKind.clinic,
        personName: 'Terapeuta responsável',
        role: 'Profissional ABA',
        scopes: const ['Tarefas e retornos', 'Perfil de comunicação'],
        status: status,
        startsAt: startsAt,
        expiresAt: expiresAt,
        purpose: 'Coordenação autorizada com a família',
      );

  test('preserva o escopo e o estado ao serializar um vínculo', () {
    final restored = AccessGrant.fromMap(grant().toMap());

    expect(restored.id, 'grant-1');
    expect(restored.organizationKind, OrganizationKind.clinic);
    expect(restored.scopes, ['Tarefas e retornos', 'Perfil de comunicação']);
    expect(restored.status, AccessGrantStatus.active);
    expect(restored.canRevoke, isTrue);
  });

  test('revogar um vínculo não altera conta familiar nem escopo histórico', () {
    final revoked = grant().copyWith(status: AccessGrantStatus.revoked);

    expect(revoked.status, AccessGrantStatus.revoked);
    expect(revoked.canRevoke, isFalse);
    expect(revoked.scopes, grant().scopes);
    expect(revoked.expiresAt, expiresAt);
  });

  test('convite pendente pode ser revogado antes do aceite', () {
    final pending = grant(status: AccessGrantStatus.pending);

    expect(pending.statusLabel, 'Aguardando aceite');
    expect(pending.canRevoke, isTrue);
  });
}
