import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/aura_top_bar.dart';
import '../../widgets/common/aura_card.dart';
import '../../widgets/common/aura_button.dart';
import '../../widgets/common/score_indicator.dart';
import '../../../domain/entities/user.dart';
import '../../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    ref.listen(profileProvider, (prev, next) {
      if (prev == null || (!prev.isLoading && next.isLoading)) { return; }
      if (!next.isLoading && next.error != null && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile: ${next.error}')),
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (profileState.userProfile == null && !profileState.isLoading) {
        ref.read(profileProvider.notifier).loadProfile();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AuraTopBar(title: 'Profile'),
            Expanded(
              child: profileState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : profileState.error != null && profileState.userProfile == null
                      ? Center(child: Text('Could not load profile', style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant)))
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _UserHeader(user: profileState.userProfile),
                              const SizedBox(height: AppSpacing.lg),
                              const _BeautyProfileCard(),
                              const SizedBox(height: AppSpacing.lg),
                              const _AssessmentScores(),
                              const SizedBox(height: AppSpacing.lg),
                              const _SubscriptionCard(),
                              const SizedBox(height: AppSpacing.lg),
                              const _SettingsList(),
                              const SizedBox(height: AppSpacing.lg),
                              _SignOutButton(),
                              const SizedBox(height: AppSpacing.xxl),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  final User? user;
  const _UserHeader({this.user});

  @override
  Widget build(BuildContext context) {
    final displayName = user?.name ?? 'User';
    final tier = user?.subscriptionTier ?? 'Free';
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.warmNude,
                child: const Icon(Icons.person, size: 44, color: AppColors.primary),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.matteGold,
                  ),
                  child: const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(displayName, style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.matteGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$tier Member', style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatItem(value: '0', label: 'Entries'),
              Container(width: 1, height: 24, color: AppColors.outlineVariant),
              _StatItem(value: '0', label: 'Posts'),
              Container(width: 1, height: 24, color: AppColors.outlineVariant),
              _StatItem(value: '0', label: 'Challenges'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(value, style: AppTypography.cardTitle.copyWith(fontSize: 18, color: AppColors.softCharcoal)),
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _BeautyProfileCard extends StatelessWidget {
  const _BeautyProfileCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: AuraCard(
        padding: AppSpacing.cardPadding,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite_outline, size: 18, color: AppColors.matteGold),
                const SizedBox(width: 8),
                Text('Beauty Profile', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Text('Edit', style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ProfileRow(label: 'Skin Type', value: 'Combination'),
            _ProfileRow(label: 'Concerns', value: 'Hydration, Aging'),
            _ProfileRow(label: 'Sensitivity', value: 'Mild'),
            _ProfileRow(label: 'Hair Type', value: 'Wavy, Medium'),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          Text(value, style: AppTypography.bodySmall.copyWith(color: AppColors.softCharcoal, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AssessmentScores extends StatelessWidget {
  const _AssessmentScores();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Row(
        children: [
          Expanded(
            child: AuraCard(
              padding: const EdgeInsets.all(16),
              body: Column(
                children: [
                  const ScoreIndicator(score: 72, label: 'Skin', size: 80, strokeWidth: 5),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {},
                    child: Text('Reassess', style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AuraCard(
              padding: const EdgeInsets.all(16),
              body: Column(
                children: [
                  const ScoreIndicator(score: 65, label: 'Hair', size: 80, strokeWidth: 5),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {},
                    child: Text('Reassess', style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: AuraCard(
        hasGoldAccent: true,
        padding: AppSpacing.cardPadding,
        body: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aura Plus', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
                  const SizedBox(height: 4),
                  Text('Active • Renews Dec 15, 2026', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/subscription'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.matteGold),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Upgrade', style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
          const SizedBox(height: 12),
          _SettingsItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () => context.go('/settings')),
          _SettingsItem(icon: Icons.language_outlined, label: 'Language', onTap: () => context.go('/settings'), trailing: 'English'),
          _SettingsItem(icon: Icons.dark_mode_outlined, label: 'Theme', onTap: () => context.go('/settings'), trailing: 'Light'),
          _SettingsItem(icon: Icons.lock_outlined, label: 'Privacy', onTap: () => context.go('/settings')),
          _SettingsItem(icon: Icons.info_outline, label: 'About', onTap: () => context.go('/settings')),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;

  const _SettingsItem({required this.icon, required this.label, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.softCharcoal))),
              if (trailing != null) ...[
                Text(trailing!, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(width: 4),
              ],
              const Icon(Icons.chevron_right, size: 18, color: AppColors.outlineVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: AuraButton(
        label: 'Sign Out',
        isSecondary: true,
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Sign Out'),
              content: const Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                TextButton(onPressed: () { Navigator.pop(ctx); context.go('/login'); }, child: const Text('Sign Out')),
              ],
            ),
          );
        },
      ),
    );
  }
}
