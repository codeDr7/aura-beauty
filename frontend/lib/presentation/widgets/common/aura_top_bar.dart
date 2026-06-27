import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class AuraTopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final VoidCallback? onProfileTap;
  final String? profileImageUrl;
  final List<Widget>? actions;
  final String? title;
  final bool transparent;

  const AuraTopBar({
    super.key,
    this.showBackButton = false,
    this.onProfileTap,
    this.profileImageUrl,
    this.actions,
    this.title,
    this.transparent = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final totalHeight = AppSpacing.appBarHeight + topPadding;

    if (transparent) {
      return Container(
        padding: EdgeInsets.only(top: topPadding),
        height: totalHeight,
        child: _buildContent(context),
      );
    }

    return Container(
      padding: EdgeInsets.only(top: topPadding),
      height: totalHeight,
      decoration: BoxDecoration(
        color: AppColors.ivoryWhite.withOpacity(0.92),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: AppSpacing.appBarHeight,
            padding: AppSpacing.horizontalPadding,
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Row(
      children: [
        if (showBackButton)
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warmNude.withOpacity(0.3),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.softCharcoal,
                size: 20,
              ),
            ),
          ),
        if (showBackButton) const SizedBox(width: 12),
        Expanded(
          child: title != null
              ? Text(
                  title!,
                  style: AppTypography.titleMedium.copyWith(color: AppColors.softCharcoal),
                  textAlign: TextAlign.center,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AURA',
                      style: AppTypography.brandName.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 6.0,
                      ),
                    ),
                  ],
                ),
        ),
        if (onProfileTap != null)
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.matteGold, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: profileImageUrl != null
                    ? Image.network(
                        profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _defaultAvatar(),
                      )
                    : _defaultAvatar(),
              ),
            ),
          ),
        if (actions != null) ...actions!,
      ],
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: AppColors.warmNude,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: 20,
      ),
    );
  }
}
