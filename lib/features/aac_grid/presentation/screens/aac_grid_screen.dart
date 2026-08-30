import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../parental_area/presentation/screens/parental_gate_screen.dart';
import '../../data/providers/cards_provider.dart';
import '../widgets/grid_card.dart';
import '../widgets/sentence_bar_widget.dart';

/// Tela principal do app: grade interativa de pictogramas baseada
/// em PECS, com feedback de voz imediato em português.
class AACGridScreen extends ConsumerWidget {
  const AACGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCards = ref.watch(cardsListProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final scale = ref.watch(buttonScaleProvider);

    final visibleCards = selectedCategory == 'todas'
        ? allCards
        : allCards.where((c) => c.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior com filtro de categoria e acesso restrito
            // ao Painel dos Pais/Educadores.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _CategoryChip(
                            label: 'Todas',
                            selected: selectedCategory == 'todas',
                            onTap: () => ref.read(selectedCategoryProvider.notifier).state = 'todas',
                          ),
                          ...AppConstants.categoryLabels.entries.map(
                            (e) => _CategoryChip(
                              label: e.value,
                              selected: selectedCategory == e.key,
                              onTap: () => ref.read(selectedCategoryProvider.notifier).state = e.key,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 28),
                    tooltip: 'Área do Responsável',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ParentalGateScreen()),
                    ),
                  ),
                ],
              ),
            ),

            // Construtor de frases (Sentence Bar).
            const SentenceBarWidget(),

            // Grade de pictogramas.
            Expanded(
              child: visibleCards.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum cartão nesta categoria ainda.\nAdicione pelo Painel dos Pais.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Colunas responsivas: mais colunas em telas largas
                        // (tablets em paisagem), menos em celulares.
                        final width = constraints.maxWidth;
                        final crossAxisCount = (width / (110 * scale)).floor().clamp(3, 8);

                        return GridView.builder(
                          padding: const EdgeInsets.all(AppConstants.gridSpacing),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: AppConstants.gridSpacing,
                            mainAxisSpacing: AppConstants.gridSpacing,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: visibleCards.length,
                          itemBuilder: (context, index) {
                            final card = visibleCards[index];
                            return GridCard(
                              card: card,
                              scale: scale,
                              onTap: () {
                                TtsService.instance.speak(card.label);
                                ref.read(sentenceBarProvider.notifier).addToSentence(card);
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primary.withOpacity(0.18),
        labelStyle: TextStyle(
          color: selected ? AppTheme.primary : AppTheme.textDark,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: selected ? AppTheme.primary : AppTheme.cardBorder),
        ),
        backgroundColor: AppTheme.surface,
      ),
    );
  }
}
