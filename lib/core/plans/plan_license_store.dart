import 'package:hive_flutter/hive_flutter.dart';

import '../services/secure_box_service.dart';
import 'plan_models.dart';

const planLicenseBoxName = 'plan_license';
const _currentLicenseKey = 'current_license';

/// Persiste somente o estado administrativo da licença, nunca conteúdo da
/// criança, diagnóstico ou registros de comunicação.
class PlanLicenseStore {
  PlanLicenseStore._();

  static Future<Box> _box() async {
    if (Hive.isBoxOpen(planLicenseBoxName)) {
      return Hive.box(planLicenseBoxName);
    }
    return SecureBoxService.openSecureBoxWithMigration(planLicenseBoxName);
  }

  static Future<PlanLicense?> load() async {
    final box = await _box();
    final raw = box.get(_currentLicenseKey);
    if (raw is! Map) return null;

    try {
      return PlanLicense.fromMap(Map<dynamic, dynamic>.from(raw));
    } on FormatException {
      await box.delete(_currentLicenseKey);
      return null;
    } on TypeError {
      await box.delete(_currentLicenseKey);
      return null;
    }
  }

  static Future<void> save(PlanLicense license) async {
    final box = await _box();
    await box.put(_currentLicenseKey, license.toMap());
  }

  static Future<void> clear() async {
    final box = await _box();
    await box.delete(_currentLicenseKey);
  }
}
