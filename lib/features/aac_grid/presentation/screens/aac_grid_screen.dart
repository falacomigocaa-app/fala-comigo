import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/hyperfocus_theme.dart';
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
    final tapBehavior = ref.watch(cardTapBehaviorProvider);
    final hyperfocusTheme = ref.watch(hyperfocusThemeProvider);
    final themeColor = hyperfocusTheme.primaryColor;
    final tapSemanticHint = switch (tapBehavior) {
      CardTapBehavior.speakAndAdd => 'Toque para falar e adicionar à frase',
      CardTapBehavior.addOnly => 'Toque para adicionar à frase sem falar',
      CardTapBehavior.speakOnly => 'Toque para falar sem adicionar à frase',
    };

    final visibleCards = filterCardsByCategory(allCards, selectedCategory);

    return Scaffold(
      backgroundColor: hyperfocusTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            _HyperfocusBackground(theme: hyperfocusTheme),
            Column(
              children: [
                // Cabeçalho infantil e filtros; o acesso parental fica separado
                // para não competir com os cartões de comunicação.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 12, 0),
                  child: Row(
                    children: [
                      if (hyperfocusTheme != HyperfocusTheme.padrao) ...[
                        Text(hyperfocusTheme.emoji,
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                      ],
                      const Expanded(
                        child: Text(
                          'Fala Comigo',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_off_outlined,
                                size: 16, color: AppTheme.accentGreen),
                            SizedBox(width: 5),
                            Text('Offline',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.accentGreen)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, size: 27),
                        tooltip: 'Área do Responsável',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const ParentalGateScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                  child: SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _CategoryChip(
                          label: 'Todas',
                          selected: selectedCategory == 'todas',
                          color: themeColor,
                          onTap: () => ref
                              .read(selectedCategoryProvider.notifier)
                              .state = 'todas',
                        ),
                        ...AppConstants.categoryLabels.entries.map(
                          (e) => _CategoryChip(
                            label: e.value,
                            selected: selectedCategory == e.key,
                            color: themeColor,
                            onTap: () => ref
                                .read(selectedCategoryProvider.notifier)
                                .state = e.key,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Construtor de frases (Sentence Bar).
                const SentenceBarWidget(),

                // Grade de pictogramas.
                Expanded(
                  child: visibleCards.isEmpty
                      ? Center(
                          child: Container(
                            margin: const EdgeInsets.all(24),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.surface.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppTheme.cardBorder),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.grid_view_outlined,
                                    size: 42, color: AppTheme.primary),
                                SizedBox(height: 12),
                                Text(
                                  'Nenhum cartão nesta categoria ainda.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AppTheme.textDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'O responsável pode adicionar cartões pelo painel.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AppTheme.mutedText, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            // Colunas responsivas: mais colunas em telas largas
                            // (tablets em paisagem), menos em celulares.
                            final width = constraints.maxWidth;
                            final crossAxisCount =
                                (width / (110 * scale)).floor().clamp(3, 8);

                            return GridView.builder(
                              padding: const EdgeInsets.all(
                                  AppConstants.gridSpacing),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
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
                                  semanticHint: tapSemanticHint,
                                  onTap: () {
                                    if (tapBehavior !=
                                        CardTapBehavior.addOnly) {
                                      TtsService.instance.speak(card.label);
                                    }
                                    if (tapBehavior !=
                                        CardTapBehavior.speakOnly) {
                                      ref
                                          .read(sentenceBarProvider.notifier)
                                          .addToSentence(card);
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
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
  final Color color;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        selectedColor: color.withValues(alpha: 0.18),
        labelStyle: TextStyle(
          color: selected ? color : AppTheme.textDark,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: selected ? color : AppTheme.cardBorder),
        ),
        backgroundColor: AppTheme.surface,
      ),
    );
  }
}

/// Padrão decorativo sutil com o emoji do tema de hiperfoco ativo,
/// espalhado com baixa opacidade atrás da grade — reforça a
/// identificação visual com o interesse da criança sem atrapalhar
/// a leitura dos cartões.
class _HyperfocusBackground extends StatelessWidget {
  final HyperfocusTheme theme;

  const _HyperfocusBackground({required this.theme});

  @override
  Widget build(BuildContext context) {
    if (theme == HyperfocusTheme.padrao) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.07,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const tile = 72.0;
              final cols = (constraints.maxWidth / tile).ceil() + 1;
              final rows = (constraints.maxHeight / tile).ceil() + 1;
              return Wrap(
                children: List.generate(cols * rows, (i) {
                  return SizedBox(
                    width: tile,
                    height: tile,
                    child: Center(
                      child: Text(
                        theme.emoji,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}
