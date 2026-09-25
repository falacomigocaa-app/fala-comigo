import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/features/aac_grid/data/providers/communication_rewards_provider.dart';

void main() {
  test('mantém o catálogo de recompensas sem pontos ou ranking', () {
    expect(communicationRewards.map((reward) => reward.id), [
      'first_card',
      'explorer',
      'first_phrase',
      'category_choice',
    ]);
    expect(
      communicationRewards.every((reward) => reward.message.isNotEmpty),
      isTrue,
    );
  });
}
