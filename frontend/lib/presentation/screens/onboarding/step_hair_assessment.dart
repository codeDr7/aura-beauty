import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/onboarding_provider.dart';

class StepHairAssessment extends ConsumerWidget {
  const StepHairAssessment({super.key});

  static const _hairTypes = [
    ('Straight', Icons.height),
    ('Wavy', Icons.waves),
    ('Curly', Icons.rotate_right),
    ('Coily', Icons.replay),
  ];

  static const _textureOptions = ['Fine', 'Medium', 'Thick'];
  static const _thicknessOptions = ['Thin', 'Average', 'Dense'];
  static const _densityOptions = ['Low', 'Medium', 'High'];
  static const _scalpOptions = ['Normal', 'Dry', 'Oily', 'Dandruff-prone', 'Sensitive'];

  static const _issues = ['Hair Loss', 'Dandruff', 'Dryness', 'Frizz', 'Damage', 'Split Ends'];

  static const _goals = [
    'Hair Growth', 'Hair Repair', 'Volume', 'Hydration', 'Frizz Control', 'Scalp Health',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding.copyWith(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hair Assessment', style: AppTypography.sectionTitle.copyWith(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            'Help us understand your hair type and concerns',
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          _QuestionCard(
            question: 'Hair Type',
            child: Row(
              children: _hairTypes.map((ht) {
                final selected = state.hairAssessment.hairType == ht.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(onboardingProvider.notifier).updateHairAssessment(hairType: ht.$1),
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
                          Icon(ht.$2, color: selected ? Colors.white : AppColors.primary, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            ht.$1,
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
            question: 'Hair Texture',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _textureOptions.map((t) {
                final selected = state.hairAssessment.texture == t;
                return ChoiceChip(
                  label: Text(t, style: AppTypography.bodySmall.copyWith(
                    color: selected ? Colors.white : AppColors.softCharcoal,
                  )),
                  selected: selected,
                  onSelected: (_) => ref.read(onboardingProvider.notifier).updateHairAssessment(texture: t),
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
            question: 'Hair Thickness',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _thicknessOptions.map((t) {
                final selected = state.hairAssessment.thickness == t;
                return ChoiceChip(
                  label: Text(t, style: AppTypography.bodySmall.copyWith(
                    color: selected ? Colors.white : AppColors.softCharcoal,
                  )),
                  selected: selected,
                  onSelected: (_) => ref.read(onboardingProvider.notifier).updateHairAssessment(thickness: t),
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
            question: 'Hair Density',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _densityOptions.map((d) {
                final selected = state.hairAssessment.density == d;
                return ChoiceChip(
                  label: Text(d, style: AppTypography.bodySmall.copyWith(
                    color: selected ? Colors.white : AppColors.softCharcoal,
                  )),
                  selected: selected,
                  onSelected: (_) => ref.read(onboardingProvider.notifier).updateHairAssessment(density: d),
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
            question: 'Scalp Condition',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _scalpOptions.map((s) {
                final selected = state.hairAssessment.scalpCondition == s;
                return ChoiceChip(
                  label: Text(s, style: AppTypography.bodySmall.copyWith(
                    color: selected ? Colors.white : AppColors.softCharcoal,
                  )),
                  selected: selected,
                  onSelected: (_) => ref.read(onboardingProvider.notifier).updateHairAssessment(scalpCondition: s),
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
            question: 'Hair Issues',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _issues.map((i) {
                final selected = state.hairAssessment.issues.contains(i);
                return FilterChip(
                  label: Text(i, style: AppTypography.bodySmall.copyWith(
                    color: selected ? Colors.white : AppColors.softCharcoal,
                  )),
                  selected: selected,
                  onSelected: (_) => ref.read(onboardingProvider.notifier).toggleHairIssue(i),
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
          const SizedBox(height: 16),
          _QuestionCard(
            question: 'Hair Goals',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _goals.map((g) {
                final selected = state.hairAssessment.goals.contains(g);
                return FilterChip(
                  label: Text(g, style: AppTypography.bodySmall.copyWith(
                    color: selected ? Colors.white : AppColors.softCharcoal,
                  )),
                  selected: selected,
                  onSelected: (_) => ref.read(onboardingProvider.notifier).toggleHairGoal(g),
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
