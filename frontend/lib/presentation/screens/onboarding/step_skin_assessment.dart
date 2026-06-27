import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/onboarding_provider.dart';

class StepSkinAssessment extends ConsumerWidget {
  const StepSkinAssessment({super.key});

  static const _skinTypes = [
    ('Oily', Icons.water_drop),
    ('Dry', Icons.blur_on),
    ('Combination', Icons.compare_arrows),
    ('Normal', Icons.spa),
  ];

  static const _sensitivityLevels = ['Not Sensitive', 'Mildly Sensitive', 'Moderately Sensitive', 'Highly Sensitive'];
  static const _acneOptions = ['None', 'Occasional', 'Moderate', 'Severe'];
  static const _pigmentationOptions = ['None', 'Minor', 'Moderate', 'Significant'];
  static const _wrinkleOptions = ['None', 'Fine Lines', 'Moderate', 'Advanced'];

  static const _goals = [
    'Clear Skin', 'Brightening', 'Anti Aging', 'Acne Control', 'Hydration', 'Even Tone',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding.copyWith(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skin Assessment', style: AppTypography.sectionTitle.copyWith(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            'Tell us about your skin to get personalized recommendations',
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          _QuestionCard(
            question: 'Skin Type',
            child: Row(
              children: _skinTypes.map((st) {
                final selected = state.skinAssessment.skinType == st.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(onboardingProvider.notifier).updateSkinAssessment(skinType: st.$1),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.matteGold : AppColors.ivoryWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? AppColors.matteGold : AppColors.outlineVariant,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(st.$2, color: selected ? Colors.white : AppColors.primary, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            st.$1,
                            style: AppTypography.caption.copyWith(
                              color: selected ? Colors.white : AppColors.softCharcoal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _QuestionCard(
            question: 'Sensitivity Level',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sensitivityLevels.map((s) {
                final selected = state.skinAssessment.sensitivity == s;
                return ChoiceChip(
                  label: Text(s, style: AppTypography.bodySmall.copyWith(
                    color: selected ? Colors.white : AppColors.softCharcoal,
                  )),
                  selected: selected,
                  onSelected: (_) => ref.read(onboardingProvider.notifier).updateSkinAssessment(sensitivity: s),
                  selectedColor: AppColors.matteGold,
                  backgroundColor: AppColors.ivoryWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: selected ? AppColors.matteGold : AppColors.outlineVariant),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _QuestionCard(
            question: 'Acne / Blemishes',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _acneOptions.map((a) {
                final selected = state.skinAssessment.acne == a;
                return ChoiceChip(
                  label: Text(a, style: AppTypography.bodySmall.copyWith(
                    color: selected ? Colors.white : AppColors.softCharcoal,
                  )),
                  selected: selected,
                  onSelected: (_) => ref.read(onboardingProvider.notifier).updateSkinAssessment(acne: a),
                  selectedColor: AppColors.matteGold,
                  backgroundColor: AppColors.ivoryWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: selected ? AppColors.matteGold : AppColors.outlineVariant),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _QuestionCard(
            question: 'Pigmentation / Dark Spots',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _pigmentationOptions.map((p) {
                final selected = state.skinAssessment.pigmentation == p;
                return ChoiceChip(
                  label: Text(p, style: AppTypography.bodySmall.copyWith(
                    color: selected ? Colors.white : AppColors.softCharcoal,
                  )),
                  selected: selected,
                  onSelected: (_) => ref.read(onboardingProvider.notifier).updateSkinAssessment(pigmentation: p),
                  selectedColor: AppColors.matteGold,
                  backgroundColor: AppColors.ivoryWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: selected ? AppColors.matteGold : AppColors.outlineVariant),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _QuestionCard(
            question: 'Wrinkles & Fine Lines',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _wrinkleOptions.map((w) {
                final selected = state.skinAssessment.wrinkles == w;
                return ChoiceChip(
                  label: Text(w, style: AppTypography.bodySmall.copyWith(
                    color: selected ? Colors.white : AppColors.softCharcoal,
                  )),
                  selected: selected,
                  onSelected: (_) => ref.read(onboardingProvider.notifier).updateSkinAssessment(wrinkles: w),
                  selectedColor: AppColors.matteGold,
                  backgroundColor: AppColors.ivoryWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: selected ? AppColors.matteGold : AppColors.outlineVariant),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _QuestionCard(
            question: 'Skin Goals',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _goals.map((g) {
                final selected = state.skinAssessment.goals.contains(g);
                return FilterChip(
                  label: Text(g, style: AppTypography.bodySmall.copyWith(
                    color: selected ? Colors.white : AppColors.softCharcoal,
                  )),
                  selected: selected,
                  onSelected: (_) => ref.read(onboardingProvider.notifier).toggleSkinGoal(g),
                  selectedColor: AppColors.matteGold,
                  backgroundColor: AppColors.ivoryWhite,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: selected ? AppColors.matteGold : AppColors.outlineVariant),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;
  final Widget child;

  const _QuestionCard({required this.question, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: AppTypography.titleMedium.copyWith(color: AppColors.softCharcoal),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
