/// Recursos controlados pelo catálogo comercial do Fala Comigo.
enum PlanFeature {
  offlineCommunication,
  parentalControls,
  accessibility,
  localStorage,
  remoteBackup,
  multiDevice,
  careNetwork,
  sponsoredLicense,
  organizationPortal,
  benefitAdministration,
  aggregateReporting,
  prioritySupport,
}

extension PlanFeatureMetadata on PlanFeature {
  /// Recursos básicos que nunca dependem de pagamento ou conexão.
  bool get isOfflineCore => switch (this) {
    PlanFeature.offlineCommunication ||
    PlanFeature.parentalControls ||
    PlanFeature.accessibility ||
    PlanFeature.localStorage => true,
    _ => false,
  };

  String get key => name;
}

/// Estados possíveis de uma licença, independentemente do provedor de cobrança.
enum LicenseStatus { invited, active, grace, suspended, expired, revoked }

/// Definição comercial de um plano. Valores são armazenados em centavos para
/// evitar cálculos monetários com ponto flutuante.
class Plan {
  final String id;
  final String name;
  final String description;
  final int? monthlyPriceCents;
  final Set<PlanFeature> features;
  final int remoteStorageLimitBytes;
  final int maxCareConnections;
  final bool publiclyVisible;

  const Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPriceCents,
    required this.features,
    this.remoteStorageLimitBytes = 0,
    this.maxCareConnections = 0,
    this.publiclyVisible = true,
  });

  bool get isFree => monthlyPriceCents == 0;

  bool get pricePending => monthlyPriceCents == null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'monthlyPriceCents': monthlyPriceCents,
      'features': features.map((feature) => feature.key).toList(),
      'remoteStorageLimitBytes': remoteStorageLimitBytes,
      'maxCareConnections': maxCareConnections,
      'publiclyVisible': publiclyVisible,
    };
  }

  factory Plan.fromMap(Map<dynamic, dynamic> map) {
    final featureKeys = (map['features'] as List<dynamic>? ?? const <dynamic>[])
        .map((value) => value.toString())
        .toSet();

    return Plan(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      monthlyPriceCents: map['monthlyPriceCents'] as int?,
      features: PlanFeature.values
          .where((feature) => featureKeys.contains(feature.key))
          .toSet(),
      remoteStorageLimitBytes: map['remoteStorageLimitBytes'] as int? ?? 0,
      maxCareConnections: map['maxCareConnections'] as int? ?? 0,
      publiclyVisible: map['publiclyVisible'] as bool? ?? true,
    );
  }
}

/// Licença administrativa. Não contém diagnóstico, conteúdo de comunicação
/// ou qualquer dado clínico da família.
class PlanLicense {
  final String id;
  final String planId;
  final LicenseStatus status;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final String? sponsorOrganizationId;

  const PlanLicense({
    required this.id,
    required this.planId,
    required this.status,
    required this.issuedAt,
    this.expiresAt,
    this.sponsorOrganizationId,
  });

  bool get keepsRemoteAccess =>
      status == LicenseStatus.active || status == LicenseStatus.grace;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'planId': planId,
      'status': status.name,
      'issuedAt': issuedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'sponsorOrganizationId': sponsorOrganizationId,
    };
  }

  factory PlanLicense.fromMap(Map<dynamic, dynamic> map) {
    final statusName = map['status'] as String? ?? LicenseStatus.invited.name;
    final status = LicenseStatus.values.firstWhere(
      (value) => value.name == statusName,
      orElse: () => LicenseStatus.invited,
    );

    return PlanLicense(
      id: map['id'] as String,
      planId: map['planId'] as String,
      status: status,
      issuedAt: DateTime.parse(map['issuedAt'] as String),
      expiresAt: (map['expiresAt'] as String?) == null
          ? null
          : DateTime.parse(map['expiresAt'] as String),
      sponsorOrganizationId: map['sponsorOrganizationId'] as String?,
    );
  }
}
