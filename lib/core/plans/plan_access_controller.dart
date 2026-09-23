import 'plan_catalog.dart';
import 'plan_models.dart';

/// Resolve permissões comerciais sem conceder autorização clínica.
///
/// Este controlador pode ser usado agora no aplicativo local. No futuro, o
/// backend deverá repetir as regras para qualquer recurso remoto.
class PlanAccessController {
  final Plan plan;
  final PlanLicense? license;

  const PlanAccessController({required this.plan, this.license});

  factory PlanAccessController.fromLicense(PlanLicense license) {
    final plan = PlanCatalog.findById(license.planId) ?? PlanCatalog.essential;
    return PlanAccessController(plan: plan, license: license);
  }

  bool canUse(PlanFeature feature) {
    if (feature.isOfflineCore) return true;
    if (license == null || !license!.keepsRemoteAccess) return false;
    return plan.features.contains(feature);
  }

  int get remoteStorageLimitBytes =>
      canUse(PlanFeature.remoteBackup) ? plan.remoteStorageLimitBytes : 0;

  int get maxCareConnections =>
      canUse(PlanFeature.careNetwork) ? plan.maxCareConnections : 0;

  /// O acesso básico permanece disponível em qualquer estado administrativo.
  bool get communicationRemainsAvailable =>
      canUse(PlanFeature.offlineCommunication);
}

/// Permissões do plano Essencial, usadas antes de qualquer licença remota.
final essentialPlanAccess = PlanAccessController(plan: PlanCatalog.essential);
