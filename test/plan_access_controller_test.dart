import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/core/plans/plan_access_controller.dart';
import 'package:fala_comigo/core/plans/plan_catalog.dart';
import 'package:fala_comigo/core/plans/plan_models.dart';

void main() {
  final issuedAt = DateTime.utc(2026, 9, 22);

  test('catálogo público começa com planos acessíveis e sem cobrança definida',
      () {
    expect(PlanCatalog.publicPlans.map((plan) => plan.id), [
      'essential',
      'family',
      'connected_care',
      'sponsored',
    ]);
    expect(PlanCatalog.essential.isFree, isTrue);
    expect(PlanCatalog.family.pricePending, isTrue);
    expect(PlanCatalog.organization.publiclyVisible, isFalse);
  });

  test('plano Essencial mantém comunicação e controles offline disponíveis',
      () {
    final access = PlanAccessController(plan: PlanCatalog.essential);

    expect(access.canUse(PlanFeature.offlineCommunication), isTrue);
    expect(access.canUse(PlanFeature.parentalControls), isTrue);
    expect(access.canUse(PlanFeature.accessibility), isTrue);
    expect(access.canUse(PlanFeature.localStorage), isTrue);
    expect(access.canUse(PlanFeature.remoteBackup), isFalse);
    expect(access.communicationRemainsAvailable, isTrue);
  });

  test(
      'portal RH pode ser contratado sem conceder acesso ao benefício familiar',
      () {
    final access = PlanAccessController.fromLicense(
      PlanLicense(
        id: 'organization-license-1',
        planId: PlanCatalog.organization.id,
        status: LicenseStatus.active,
        issuedAt: issuedAt,
      ),
    );

    expect(access.canUse(PlanFeature.organizationPortal), isTrue);
    expect(access.canUse(PlanFeature.benefitAdministration), isTrue);
    expect(access.canUse(PlanFeature.aggregateReporting), isTrue);
    expect(access.canUse(PlanFeature.sponsoredLicense), isFalse);
    expect(access.canUse(PlanFeature.careNetwork), isFalse);
    expect(access.communicationRemainsAvailable, isTrue);
  });

  test('licença patrocinada da família não concede portal ou dados de RH', () {
    final access = PlanAccessController.fromLicense(
      PlanLicense(
        id: 'sponsored-license-1',
        planId: PlanCatalog.sponsored.id,
        status: LicenseStatus.active,
        issuedAt: issuedAt,
        sponsorOrganizationId: 'sponsor-1',
      ),
    );

    expect(access.canUse(PlanFeature.sponsoredLicense), isTrue);
    expect(access.canUse(PlanFeature.organizationPortal), isFalse);
    expect(access.canUse(PlanFeature.benefitAdministration), isFalse);
    expect(access.canUse(PlanFeature.aggregateReporting), isFalse);
    expect(access.communicationRemainsAvailable, isTrue);
  });

  test('licença ativa libera somente os recursos do plano escolhido', () {
    final access = PlanAccessController.fromLicense(
      PlanLicense(
        id: 'license-family-1',
        planId: PlanCatalog.family.id,
        status: LicenseStatus.active,
        issuedAt: issuedAt,
      ),
    );

    expect(access.canUse(PlanFeature.remoteBackup), isTrue);
    expect(access.canUse(PlanFeature.multiDevice), isTrue);
    expect(access.canUse(PlanFeature.careNetwork), isFalse);
    expect(access.remoteStorageLimitBytes, 524288000);
    expect(access.maxCareConnections, 0);
  });

  test('período de transição mantém recursos remotos e suspensão não', () {
    final grace = PlanAccessController.fromLicense(
      PlanLicense(
        id: 'license-care-1',
        planId: PlanCatalog.connectedCare.id,
        status: LicenseStatus.grace,
        issuedAt: issuedAt,
      ),
    );
    final suspended = PlanAccessController.fromLicense(
      PlanLicense(
        id: 'license-care-2',
        planId: PlanCatalog.connectedCare.id,
        status: LicenseStatus.suspended,
        issuedAt: issuedAt,
      ),
    );

    expect(grace.canUse(PlanFeature.careNetwork), isTrue);
    expect(grace.maxCareConnections, 5);
    expect(suspended.canUse(PlanFeature.careNetwork), isFalse);
    expect(suspended.communicationRemainsAvailable, isTrue);
  });

  test('licenças expirada e revogada preservam somente o núcleo offline', () {
    for (final status in [LicenseStatus.expired, LicenseStatus.revoked]) {
      final access = PlanAccessController.fromLicense(
        PlanLicense(
          id: 'license-$status',
          planId: PlanCatalog.connectedCare.id,
          status: status,
          issuedAt: issuedAt,
        ),
      );

      expect(access.canUse(PlanFeature.remoteBackup), isFalse);
      expect(access.canUse(PlanFeature.careNetwork), isFalse);
      expect(access.communicationRemainsAvailable, isTrue);
    }
  });

  test('status desconhecido é restaurado como convite pendente', () {
    final license = PlanLicense.fromMap({
      'id': 'license-unknown-status',
      'planId': PlanCatalog.family.id,
      'status': 'future_status',
      'issuedAt': issuedAt.toIso8601String(),
    });

    expect(license.status, LicenseStatus.invited);
    expect(
        PlanAccessController.fromLicense(license).communicationRemainsAvailable,
        isTrue);
  });

  test('plano e licença podem ser serializados sem dados clínicos', () {
    final plan = PlanCatalog.sponsored;
    final license = PlanLicense(
      id: 'sponsored-license-1',
      planId: plan.id,
      status: LicenseStatus.active,
      issuedAt: issuedAt,
      sponsorOrganizationId: 'sponsor-1',
    );

    final restoredPlan = Plan.fromMap(plan.toMap());
    final restoredLicense = PlanLicense.fromMap(license.toMap());

    expect(restoredPlan.id, plan.id);
    expect(restoredPlan.features, plan.features);
    expect(restoredLicense.status, LicenseStatus.active);
    expect(restoredLicense.sponsorOrganizationId, 'sponsor-1');
    expect(license.toMap().keys, isNot(contains('diagnosis')));
    expect(license.toMap().keys, isNot(contains('childContent')));
  });
}
