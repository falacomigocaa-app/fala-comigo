import 'package:hive_flutter/hive_flutter.dart';

import 'media_storage_service.dart';
import 'parental_pin_service.dart';
import 'parental_session_service.dart';
import 'secure_box_service.dart';
import 'diagnostics_service.dart';
import '../plans/plan_license_store.dart';

/// Remove os dados criados pelo Fala Comigo neste dispositivo.
class DataWipeService {
  DataWipeService._();

  static const _boxNames = [
    'pictogram_cards',
    'app_settings',
    'transition_alerts',
    'visual_routine',
    'parent_reminders',
    'patient_profile',
    'behavior_logs',
    'video_diary',
    planLicenseBoxName,
    DiagnosticsService.boxName,
  ];

  static Future<void> deleteAllLocalData() async {
    ParentalSessionService.lock();
    for (final name in _boxNames) {
      if (Hive.isBoxOpen(name)) {
        await Hive.box(name).close();
      }
      try {
        await Hive.deleteBoxFromDisk(name);
      } on HiveError {
        // A caixa pode ainda não existir em uma instalação nova.
      }
    }
    await MediaStorageService.clearAllMedia();
    await MediaStorageService.deleteEncryptionKey();
    DiagnosticsService.resetAfterDataWipe();
    await SecureBoxService.deleteEncryptionKey();
    await ParentalPinService.clearCredentials();

    // Recria caixas vazias com uma nova chave para que o app continue
    // utilizável sem exigir uma reinicialização do processo Flutter.
    await SecureBoxService.openSecureBoxWithMigration('pictogram_cards');
    await SecureBoxService.openSecureBoxWithMigration('app_settings');
    await SecureBoxService.openSecureBoxWithMigration('transition_alerts');
    await SecureBoxService.openSecureBox('visual_routine');
    await SecureBoxService.openSecureBox('parent_reminders');
    await SecureBoxService.openSecureBox('patient_profile');
    await SecureBoxService.openSecureBox('behavior_logs');
    await SecureBoxService.openSecureBox('video_diary');
    await SecureBoxService.openSecureBox(planLicenseBoxName);
    await DiagnosticsService.init();
  }
}
