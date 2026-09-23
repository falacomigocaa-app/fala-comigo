import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

const _settingsBoxName = 'app_settings';
const _rewardsKey = 'communication_rewards';
const _tapCountKey = 'communication_card_tap_count';

class CommunicationReward {
  final String id;
  final String title;
  final String message;
  final String emoji;

  const CommunicationReward({
    required this.id,
    required this.title,
    required this.message,
    required this.emoji,
  });
}

const communicationRewards = [
  CommunicationReward(
    id: 'first_card',
    title: 'Primeira escolha',
    message: 'Você escolheu um cartão.',
    emoji: '✨',
  ),
  CommunicationReward(
    id: 'explorer',
    title: 'Explorador de cartões',
    message: 'Você explorou vários cartões.',
    emoji: '🔎',
  ),
  CommunicationReward(
    id: 'first_phrase',
    title: 'Minha frase',
    message: 'Você montou uma frase.',
    emoji: '💬',
  ),
  CommunicationReward(
    id: 'category_choice',
    title: 'Eu escolhi',
    message: 'Você escolheu uma categoria.',
    emoji: '🌈',
  ),
];

final communicationRewardsProvider =
    StateNotifierProvider<CommunicationRewardsNotifier, Set<String>>(
  (ref) => CommunicationRewardsNotifier(),
);

class CommunicationRewardsNotifier extends StateNotifier<Set<String>> {
  CommunicationRewardsNotifier() : super(_loadRewards());

  static Set<String> _loadRewards() {
    if (!Hive.isBoxOpen(_settingsBoxName)) return <String>{};
    final saved = Hive.box(_settingsBoxName).get(_rewardsKey);
    if (saved is! List) return <String>{};
    return saved.whereType<String>().toSet();
  }

  CommunicationReward? recordCardTap({required bool categoryChosen}) {
    if (!Hive.isBoxOpen(_settingsBoxName)) return null;
    final box = Hive.box(_settingsBoxName);
    final tapCount = (box.get(_tapCountKey) as int? ?? 0) + 1;
    box.put(_tapCountKey, tapCount);

    final ids = {...state};
    if (tapCount >= 1) ids.add('first_card');
    if (tapCount >= 5) ids.add('explorer');
    if (categoryChosen) ids.add('category_choice');
    return _commitAndFindNewReward(ids);
  }

  CommunicationReward? recordSentenceSpoken(int length) {
    if (length < 2) return null;
    final ids = {...state, 'first_phrase'};
    return _commitAndFindNewReward(ids);
  }

  CommunicationReward? recordCategoryChoice() {
    final ids = {...state, 'category_choice'};
    return _commitAndFindNewReward(ids);
  }

  CommunicationReward? _commitAndFindNewReward(Set<String> next) {
    final newIds = next.difference(state);
    if (newIds.isEmpty) return null;
    final newId = newIds.first;
    state = next;
    if (Hive.isBoxOpen(_settingsBoxName)) {
      Hive.box(_settingsBoxName).put(_rewardsKey, state.toList());
    }
    return communicationRewards.firstWhere((reward) => reward.id == newId);
  }
}
