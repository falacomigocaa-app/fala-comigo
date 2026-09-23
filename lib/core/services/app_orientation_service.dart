import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

enum ChildOrientation { landscape, portrait }

const _boxName = 'app_settings';
const _key = 'child_orientation';

class AppOrientationService {
  AppOrientationService._();

  static ChildOrientation load() {
    final value = Hive.box(_boxName).get(_key);
    return ChildOrientation.values.firstWhere(
      (orientation) => orientation.name == value,
      orElse: () => ChildOrientation.landscape,
    );
  }

  static Future<void> applyChildOrientation() async {
    final orientation = load();
    await SystemChrome.setPreferredOrientations(
      orientation == ChildOrientation.landscape
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
  }

  static Future<void> applyParentalOrientation() {
    return SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

class ChildOrientationNotifier extends StateNotifier<ChildOrientation> {
  ChildOrientationNotifier() : super(AppOrientationService.load());

  Future<void> setOrientation(ChildOrientation orientation) async {
    final box = Hive.box(_boxName);
    await box.put(_key, orientation.name);
    state = orientation;
    await AppOrientationService.applyChildOrientation();
  }
}

final childOrientationProvider =
    StateNotifierProvider<ChildOrientationNotifier, ChildOrientation>(
        (ref) => ChildOrientationNotifier());

String childOrientationDescription(ChildOrientation orientation) {
  switch (orientation) {
    case ChildOrientation.landscape:
      return 'Recomendado: oferece mais largura para organizar cartões grandes e reduzir mudanças visuais durante a comunicação.';
    case ChildOrientation.portrait:
      return 'Use quando o aparelho fica em pé. A grade se adapta à largura disponível, mas pode mostrar menos cartões por linha.';
  }
}

String childOrientationLabel(ChildOrientation orientation) {
  switch (orientation) {
    case ChildOrientation.landscape:
      return 'Paisagem';
    case ChildOrientation.portrait:
      return 'Vertical';
  }
}

String childOrientationIcon(ChildOrientation orientation) {
  switch (orientation) {
    case ChildOrientation.landscape:
      return '▰';
    case ChildOrientation.portrait:
      return '▯';
  }
}
