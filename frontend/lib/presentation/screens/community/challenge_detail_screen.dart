import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/aura_top_bar.dart';
import '../../widgets/common/aura_button.dart';

class ChallengeDetailScreen extends ConsumerWidget {
  final String challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AuraTopBar(
              showBackButton: true,
              title: 'Challenge',
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontalPadding,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontalPadding,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.matteGold.withOpacity(0.3), AppColors.sageGreen.withOpacity(0.3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.emoji_events_outlined, size: 48, color: AppColors.matteGold),
                            const SizedBox(height: 8),
                            Text('14-Day Glow Journey', style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal, fontSize: 20)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _InfoChip(icon: Icons.timer_outlined, label: '14 Days'),
                        const SizedBox(width: 10),
                        _InfoChip(icon: Icons.people_outlined, label: '1,240 Participants'),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.sageGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Active', style: AppTypography.caption.copyWith(color: AppColors.sageGreen, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Transform your skin with a complete 14-day daily routine. Follow morning and evening skincare steps, track your progress, and earn the Glow Master badge!',
                      style: AppTypography.bodyMain.copyWith(color: AppColors.softCharcoal, height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Your Progress', style: AppTypography.titleMedium.copyWith(color: AppColors.softCharcoal)),
                        const Spacer(),
                        Text('64%', style: AppTypography.cardTitle.copyWith(color: AppColors.matteGold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: 0.64,
                        backgroundColor: AppColors.outlineVariant.withOpacity(0.5),
                        valueColor: const AlwaysStoppedAnimation(AppColors.matteGold),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Daily Tasks', style: AppTypography.titleMedium.copyWith(color: AppColors.softCharcoal)),
                    const SizedBox(height: 12),
                    _TaskTile(title: 'Morning Routine', subtitle: 'Cleanse, Tone, Moisturize, SPF', isCompleted: true),
                    _TaskTile(title: 'Evening Routine', subtitle: 'Double Cleanse, Serum, Night Cream', isCompleted: true),
                    _TaskTile(title: 'Drink 8 Glasses of Water', subtitle: 'Hydration from within', isCompleted: true),
                    _TaskTile(title: 'Take Progress Photo', subtitle: 'Day 11 documentation', isCompleted: false),
                    _TaskTile(title: 'Evening Routine', subtitle: 'Double Cleanse, Serum, Night Cream', isCompleted: false),
                    _TaskTile(title: 'Journal Entry', subtitle: 'Note how your skin feels', isCompleted: false),
                    const SizedBox(height: 24),
                    AuraButton(
                      label: 'Join Challenge',
                      onPressed: () {},
                    ),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ivoryWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.matteGold),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;

  const _TaskTile({required this.title, required this.subtitle, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted ? AppColors.sageGreen.withOpacity(0.3) : AppColors.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.sageGreen : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? AppColors.sageGreen : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppColors.onSurfaceVariant : AppColors.softCharcoal,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  )),
                  Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
