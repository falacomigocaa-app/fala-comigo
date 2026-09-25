import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ParentalInfoBanner extends StatelessWidget {
  final IconData icon;
  final String eyebrow;
  final String message;

  const ParentalInfoBanner({
    super.key,
    required this.icon,
    required this.eyebrow,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppTheme.professionalBackground,
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            AppTheme.professionalBackground,
            AppTheme.professionalSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.professionalAccent, size: 23),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: AppTheme.professionalAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.35,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ParentalSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ParentalSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: child,
    );
  }
}

InputDecoration parentalInputDecoration({
  required String labelText,
  String? hintText,
  IconData? icon,
}) {
  final prefixIcon = icon == null ? null : Icon(icon, size: 20);
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: const Color(0xFFF7F9FC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppTheme.cardBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppTheme.cardBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
    ),
  );
}

class ParentalSectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? description;

  const ParentalSectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.05,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 5),
          Text(
            description!,
            style: const TextStyle(
              color: AppTheme.mutedText,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
