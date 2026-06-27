import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class AuraCard extends StatelessWidget {
  final Widget? header;
  final Widget? body;
  final Widget? footer;
  final Widget? image;
  final bool hasGoldAccent;
  final bool isDark;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final VoidCallback? onTap;

  const AuraCard({
    super.key,
    this.header,
    this.body,
    this.footer,
    this.image,
    this.hasGoldAccent = false,
    this.isDark = false,
    this.padding,
    this.margin,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.darkSurfaceContainerLow : AppColors.surface;
    final borderColor = isDark ? AppColors.darkOutlineVariant : AppColors.outlineVariant;

    Widget card = Container(
      height: height,
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCards),
        border: Border.all(color: borderColor.withOpacity(0.5), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasGoldAccent)
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.matteGold,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppSpacing.radiusCards),
                ),
              ),
            ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (image != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.radiusCards),
                    ),
                    child: image,
                  ),
                if (header != null)
                  Padding(
                    padding: padding ?? AppSpacing.cardPadding,
                    child: header,
                  ),
                if (body != null)
                  Padding(
                    padding: (header == null ? (padding ?? AppSpacing.cardPadding) : EdgeInsets.only(
                      left: padding?.horizontal ?? AppSpacing.md,
                      right: padding?.horizontal ?? AppSpacing.md,
                      bottom: padding?.vertical ?? AppSpacing.md,
                    )),
                    child: body,
                  ),
                if (footer != null)
                  Padding(
                    padding: EdgeInsets.only(
                      left: padding?.horizontal ?? AppSpacing.md,
                      right: padding?.horizontal ?? AppSpacing.md,
                      bottom: padding?.vertical ?? AppSpacing.md,
                    ),
                    child: footer,
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}

class AuraCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;

  const AuraCardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.cardTitle.copyWith(color: titleColor ?? AppColors.softCharcoal),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
