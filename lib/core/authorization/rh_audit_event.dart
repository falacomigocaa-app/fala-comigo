enum RhAuditResult { allowed, denied }

/// Evento administrativo sem campos de conteúdo familiar ou clínico.
class RhAuditEvent {
  final String id;
  final String actorId;
  final String organizationId;
  final String operation;
  final String resourceType;
  final String resourceId;
  final RhAuditResult result;
  final String reason;
  final DateTime occurredAt;

  const RhAuditEvent({
    required this.id,
    required this.actorId,
    required this.organizationId,
    required this.operation,
    required this.resourceType,
    required this.resourceId,
    required this.result,
    required this.reason,
    required this.occurredAt,
  });

  bool get isValid {
    return id.trim().isNotEmpty &&
        actorId.trim().isNotEmpty &&
        organizationId.trim().isNotEmpty &&
        operation.trim().isNotEmpty &&
        resourceType.trim().isNotEmpty &&
        resourceId.trim().isNotEmpty &&
        reason.trim().isNotEmpty;
  }

  Map<String, Object> toJson() {
    if (!isValid) {
      throw StateError('Invalid RH audit event');
    }
    return {
      'id': id,
      'actorId': actorId,
      'organizationId': organizationId,
      'operation': operation,
      'resourceType': resourceType,
      'resourceId': resourceId,
      'result': result.name,
      'reason': reason,
      'occurredAt': occurredAt.toUtc().toIso8601String(),
    };
  }
}
