import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'plan_access_controller.dart';
import 'plan_models.dart';

/// Estado comercial local. O aplicativo inicia no Essencial e não depende de
/// conta ou internet para funcionar.
class PlanAccessNotifier extends StateNotifier<PlanAccessController> {
  PlanAccessNotifier() : super(essentialPlanAccess);

  void activateLicense(PlanLicense license) {
    state = PlanAccessController.fromLicense(license);
  }

  void returnToEssential() {
    state = essentialPlanAccess;
  }
}

final planAccessProvider = StateNotifierProvider<PlanAccessNotifier,
    PlanAccessController>((ref) => PlanAccessNotifier());

/// Atalho para telas que precisam esconder ou explicar um recurso remoto.
final hasRemoteBackupProvider = Provider<bool>((ref) {
  return ref.watch(planAccessProvider).canUse(PlanFeature.remoteBackup);
});

final hasCareNetworkProvider = Provider<bool>((ref) {
  return ref.watch(planAccessProvider).canUse(PlanFeature.careNetwork);
});
