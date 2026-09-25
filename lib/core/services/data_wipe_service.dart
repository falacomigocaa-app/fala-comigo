import 'package:hive_flutter/hive_flutter.dart';

import 'media_storage_service.dart';
import 'parental_pin_service.dart';
import 'parental_session_service.dart';
import 'secure_box_service.dart';
import '../plans/plan_license_store.dart';
import '../../features/aac_grid/data/providers/seed_cards.dart';
import '../../features/aac_grid/domain/models/pictogram_card.dart';

/// Remove os dados criados pelo Fala Comigo neste dispositivo.
class DataWipeService {
  DataWipeService._();

  static const _boxNames = [
    'pictogram_cards',
    'app_settings',
    'transition_alerts',
    'patient_profile',
    'behavior_logs',
    'video_diary',
    'visual_routine',
    'parent_access_grants',
    'shared_tasks',
    'shared_task_sync_queue',
    'communication_profile',
    'communication_plans',
    'care_appointments',
    planLicenseBoxName,
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
    // A remoção da chave torna cópias residuais ilegíveis após o wipe.
    await MediaStorageService.clearAllMedia();
    await MediaStorageService.deleteEncryptionKey();
    await SecureBoxService.deleteEncryptionKey();
    await ParentalPinService.clearCredentials();

    // Recria caixas vazias com uma nova chave para que o app continue
    // utilizável sem exigir uma reinicialização do processo Flutter.
    final cardsBox =
        await SecureBoxService.openSecureBoxWithMigration<PictogramCard>(
          'pictogram_cards',
        );
    for (final card in SeedCards.defaultCards()) {
      await cardsBox.put(card.id, card);
    }
    await SecureBoxService.openSecureBoxWithMigration('app_settings');
    await SecureBoxService.openSecureBoxWithMigration('transition_alerts');
    await SecureBoxService.openSecureBox('patient_profile');
    await SecureBoxService.openSecureBox('behavior_logs');
    await SecureBoxService.openSecureBox('video_diary');
    await SecureBoxService.openSecureBox('visual_routine');
    await SecureBoxService.openSecureBox('parent_access_grants');
    await SecureBoxService.openSecureBox('shared_tasks');
    await SecureBoxService.openSecureBox('shared_task_sync_queue');
    await SecureBoxService.openSecureBox('communication_profile');
    await SecureBoxService.openSecureBox('communication_plans');
    await SecureBoxService.openSecureBox('care_appointments');
    await SecureBoxService.openSecureBox(planLicenseBoxName);
  }
}
