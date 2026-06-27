import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class AuraButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isFullWidth;
  final IconData? trailingIcon;
  final bool isLoading;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const AuraButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isSecondary = false,
    this.isFullWidth = true,
    this.trailingIcon,
    this.isLoading = false,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = isFullWidth ? (width ?? double.infinity) : width;

    return SizedBox(
      width: effectiveWidth,
      height: 56,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          padding: padding ?? AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButtons),
            side: isSecondary
                ? BorderSide(
                    color: onPressed != null ? AppColors.matteGold : AppColors.outlineVariant,
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
          backgroundColor: isSecondary
              ? Colors.transparent
              : (onPressed != null ? AppColors.matteGold : AppColors.outlineVariant),
          foregroundColor: isSecondary
              ? (onPressed != null ? AppColors.matteGold : AppColors.outline)
              : Colors.white,
          elevation: isSecondary ? 0 : 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSecondary ? AppColors.matteGold : Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTypography.buttonLabel.copyWith(
                      color: isSecondary
                          ? (onPressed != null ? AppColors.matteGold : AppColors.outline)
                          : Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      trailingIcon,
                      size: 18,
                      color: isSecondary
                          ? (onPressed != null ? AppColors.matteGold : AppColors.outline)
                          : Colors.white,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
