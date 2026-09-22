import 'plan_models.dart';

/// Catálogo local e versionável dos planos. A cobrança real será conectada
/// depois, sem espalhar preços ou regras pela interface.
class PlanCatalog {
  PlanCatalog._();

  static const essential = Plan(
    id: 'essential',
    name: 'Essencial',
    description: 'Comunicação básica com privacidade e funcionamento offline.',
    monthlyPriceCents: 0,
    features: {
      PlanFeature.offlineCommunication,
      PlanFeature.parentalControls,
      PlanFeature.accessibility,
      PlanFeature.localStorage,
    },
  );

  static const family = Plan(
    id: 'family',
    name: 'Família',
    description: 'Recursos remotos opcionais para continuar o cuidado em mais de um dispositivo.',
    monthlyPriceCents: null,
    features: {
      PlanFeature.offlineCommunication,
      PlanFeature.parentalControls,
      PlanFeature.accessibility,
      PlanFeature.localStorage,
      PlanFeature.remoteBackup,
      PlanFeature.multiDevice,
    },
    remoteStorageLimitBytes: 524288000,
  );

  static const connectedCare = Plan(
    id: 'connected_care',
    name: 'Cuidado Conectado',
    description: 'Vínculos autorizados com profissionais e escolas, sempre com escopo e prazo.',
    monthlyPriceCents: null,
    features: {
      PlanFeature.offlineCommunication,
      PlanFeature.parentalControls,
      PlanFeature.accessibility,
      PlanFeature.localStorage,
      PlanFeature.remoteBackup,
      PlanFeature.multiDevice,
      PlanFeature.careNetwork,
    },
    remoteStorageLimitBytes: 1073741824,
    maxCareConnections: 5,
  );

  static const sponsored = Plan(
    id: 'sponsored',
    name: 'Patrocinado',
    description: 'Acesso financiado por uma empresa ou instituição sem expor o conteúdo familiar.',
    monthlyPriceCents: null,
    features: {
      PlanFeature.offlineCommunication,
      PlanFeature.parentalControls,
      PlanFeature.accessibility,
      PlanFeature.localStorage,
      PlanFeature.remoteBackup,
      PlanFeature.multiDevice,
      PlanFeature.sponsoredLicense,
    },
    remoteStorageLimitBytes: 524288000,
  );

  static const organization = Plan(
    id: 'organization',
    name: 'Organização',
    description: 'Recursos administrativos para organizações com vínculos autorizados.',
    monthlyPriceCents: 0,
    features: {
      PlanFeature.accessibility,
      PlanFeature.organizationPortal,
      PlanFeature.prioritySupport,
    },
    publiclyVisible: false,
  );

  static const List<Plan> all = [
    essential,
    family,
    connectedCare,
    sponsored,
    organization,
  ];

  static List<Plan> get publicPlans =>
      List.unmodifiable(all.where((plan) => plan.publiclyVisible));

  static Plan? findById(String id) {
    for (final plan in all) {
      if (plan.id == id) return plan;
    }
    return null;
  }
}
