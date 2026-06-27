import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/score_indicator.dart';
import '../../widgets/common/aura_button.dart';

class StepResults extends ConsumerStatefulWidget {
  const StepResults({super.key});

  @override
  ConsumerState<StepResults> createState() => _StepResultsState();
}

class _StepResultsState extends ConsumerState<StepResults> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding.copyWith(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Results', style: AppTypography.sectionTitle.copyWith(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            'Here\'s your personalized beauty profile',
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const ScoreIndicator(score: 72, label: 'Skin Score', size: 110),
                  ScoreIndicator(
                    score: 65,
                    label: 'Hair Score',
                    size: 110,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _fadeIn,
            child: Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Beauty Summary',
                    style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Based on your assessment, you have combination skin with mild sensitivity. '
                    'Your hair is wavy with medium density. '
                    'We recommend focusing on hydration and sun protection as key areas.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _fadeIn,
            child: Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.track_changes, size: 20, color: AppColors.matteGold),
                      const SizedBox(width: 8),
                      Text(
                        'Recommended Focus Areas',
                        style: AppTypography.titleMedium.copyWith(color: AppColors.softCharcoal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FocusChip(label: 'Hydration Boost'),
                  const SizedBox(height: 8),
                  _FocusChip(label: 'Sun Protection Daily'),
                  const SizedBox(height: 8),
                  _FocusChip(label: 'Gentle Cleansing Routine'),
                  const SizedBox(height: 8),
                  _FocusChip(label: 'Scalp Care & Hair Nourishment'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _fadeIn,
            child: AuraButton(
              label: 'Start Your Journey',
              onPressed: () => context.go('/home'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _FocusChip extends StatelessWidget {
  final String label;

  const _FocusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warmNude.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.matteGold,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.softCharcoal),
          ),
        ],
      ),
    );
  }
}
