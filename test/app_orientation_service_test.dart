import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:fala_comigo/core/services/app_orientation_service.dart';
import 'package:fala_comigo/features/aac_grid/data/providers/cards_provider.dart';

void main() {
  late Directory root;

  setUpAll(() async {
    root = await Directory.systemTemp.createTemp('fala_orientation_test_');
    Hive.init(root.path);
    await Hive.openBox<dynamic>('app_settings');
  });

  setUp(() async {
    await Hive.box<dynamic>('app_settings').clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await root.delete(recursive: true);
  });

  test('usa paisagem como padrão quando nenhuma preferência foi salva', () {
    expect(AppOrientationService.load(), ChildOrientation.landscape);
  });

  test('recupera orientação vertical salva para o próximo início', () async {
    await Hive.box<dynamic>('app_settings')
        .put('child_orientation', 'portrait');

    expect(AppOrientationService.load(), ChildOrientation.portrait);
  });

  test('restaura e persiste a escala dos botões', () async {
    final settings = Hive.box<dynamic>('app_settings');
    await settings.put('button_scale', 1.4);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(buttonScaleProvider), 1.4);

    final notifier = container.read(buttonScaleProvider.notifier);
    notifier.setScale(1.2);
    await notifier.persist();

    expect(settings.get('button_scale'), 1.2);
  });
}
