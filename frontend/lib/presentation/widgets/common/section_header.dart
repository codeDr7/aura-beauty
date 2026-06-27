import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class SectionHeader extends StatelessWidget {
  final String? overline;
  final String title;
  final String? subtitle;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    this.overline,
    required this.title,
    this.subtitle,
    this.trailingLabel,
    this.onTrailingTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (overline != null) ...[
            Text(
              overline!.toUpperCase(),
              style: AppTypography.overline.copyWith(color: AppColors.matteGold, letterSpacing: 2.0),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.sectionTitle.copyWith(
                        color: AppColors.softCharcoal,
                        fontSize: 26,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingLabel != null)
                GestureDetector(
                  onTap: onTrailingTap,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      trailingLabel!,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.matteGold,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.matteGold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
