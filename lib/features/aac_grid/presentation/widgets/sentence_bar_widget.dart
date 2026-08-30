import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/providers/cards_provider.dart';

/// Barra horizontal que acumula os cartões selecionados pelo usuário
/// para montar uma frase (ex: "Eu Quero" + "Comer" + "Maçã") e um
/// botão de ação destacado para falar a frase inteira em voz alta.
class SentenceBarWidget extends ConsumerWidget {
  const SentenceBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentence = ref.watch(sentenceBarProvider);
    final notifier = ref.read(sentenceBarProvider.notifier);

    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(bottom: BorderSide(color: AppTheme.cardBorder, width: 1.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: sentence.isEmpty
                ? const Center(
                    child: Text(
                      'Toque nos cartões para montar uma frase',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: sentence.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final card = sentence[index];
                      return GestureDetector(
                        onTap: () => notifier.removeAt(index),
                        child: Container(
                          width: 72,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: card.isCustomImage
                                      ? Image.file(File(card.imagePath), fit: BoxFit.cover)
                                      : Image.asset(card.imagePath, fit: BoxFit.cover),
                                ),
                              ),
                              Text(
                                card.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(width: 12),
          // Botão "Falar Frase Inteira" — destacado em verde.
          ElevatedButton.icon(
            onPressed: sentence.isEmpty
                ? null
                : () async {
                    await TtsService.instance.speak(notifier.spokenText);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(64, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.volume_up, size: 28),
            label: const Text('Falar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: sentence.isEmpty ? null : notifier.clear,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Limpar frase',
            iconSize: 30,
          ),
        ],
      ),
    );
  }
}
