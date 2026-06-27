import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class AuraBottomNav extends StatelessWidget {
  final int currentIndex;

  const AuraBottomNav({super.key, required this.currentIndex});

  static const _navItems = [
    _NavItem(label: 'Home', icon: Icons.home_rounded, activeIcon: Icons.home_rounded, route: '/home'),
    _NavItem(label: 'Discover', icon: Icons.explore_outlined, activeIcon: Icons.explore, route: '/discover'),
    _NavItem(label: 'Community', icon: Icons.forum_outlined, activeIcon: Icons.forum, route: '/community'),
    _NavItem(label: 'Progress', icon: Icons.trending_up_outlined, activeIcon: Icons.trending_up, route: '/progress'),
    _NavItem(label: 'Profile', icon: Icons.person_outlined, activeIcon: Icons.person, route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.ivoryWhite.withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isActive = index == currentIndex;
              return _NavBarItem(
                item: item,
                isActive: isActive,
                onTap: () {
                  if (index != currentIndex) {
                    context.go(item.route);
                  }
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? AppColors.matteGold.withOpacity(0.12) : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.matteGold.withOpacity(0.15) : Colors.transparent,
                ),
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  size: 24,
                  color: isActive ? AppColors.matteGold : AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: (isActive ? AppTypography.labelMedium.copyWith(color: AppColors.matteGold) : AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
            ),
          ],
        ),
      ),
    );
  }
}
