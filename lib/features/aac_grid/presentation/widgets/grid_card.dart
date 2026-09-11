import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/hyperfocus_theme.dart';
import '../../domain/models/pictogram_card.dart';

/// Cartão individual exibido na grade de pictogramas.
///
/// Ao ser tocado, amplia levemente com destaque luminoso (feedback
/// visual, na cor do tema de hiperfoco escolhido pelos pais) e
/// dispara [onTap] — que, na tela pai, aciona o TTS. Latência da
/// animação mantida curta (~120ms) para não atrasar o feedback
/// sonoro.
class GridCard extends ConsumerStatefulWidget {
  final PictogramCard card;
  final VoidCallback onTap;
  final double scale;

  const GridCard({
    super.key,
    required this.card,
    required this.onTap,
    this.scale = 1.0,
  });

  @override
  ConsumerState<GridCard> createState() => _GridCardState();
}

class _GridCardState extends ConsumerState<GridCard> {
  bool _pressed = false;

  void _handleTap() {
    setState(() => _pressed = true);
    widget.onTap();
    Future.delayed(AppConstants.cardTapAnimationDuration, () {
      if (mounted) setState(() => _pressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = widget.card.isCustomImage
        ? Image.file(File(widget.card.imagePath), fit: BoxFit.cover)
        : Image.asset(widget.card.imagePath, fit: BoxFit.cover);

    final themeColor = ref.watch(hyperfocusThemeProvider).primaryColor;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _pressed ? 1.06 : 1.0,
        duration: AppConstants.cardTapAnimationDuration,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: AppConstants.minTouchTarget,
            minHeight: AppConstants.minTouchTarget,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _pressed ? themeColor : AppTheme.cardBorder,
              width: _pressed ? 3 : 1.5,
            ),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageWidget,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.card.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
