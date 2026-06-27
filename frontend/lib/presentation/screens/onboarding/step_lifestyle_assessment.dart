import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/onboarding_provider.dart';

class StepLifestyleAssessment extends ConsumerWidget {
  const StepLifestyleAssessment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding.copyWith(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lifestyle Assessment', style: AppTypography.sectionTitle.copyWith(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            'Your lifestyle affects your beauty — let us factor it in',
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          _LifestyleCard(
            question: 'Sleep Quality',
            icon: Icons.nightlight_round,
            options: const ['Poor', 'Fair', 'Good', 'Excellent'],
            emojis: const ['😴', '🙂', '😊', '🌟'],
            selected: state.lifestyleAssessment.sleepQuality,
            onSelect: (v) => ref.read(onboardingProvider.notifier).updateLifestyleAssessment(sleepQuality: v),
          ),
          const SizedBox(height: 16),
          _LifestyleCard(
            question: 'Water Intake',
            icon: Icons.water_drop,
            options: const ['Low', 'Medium', 'High'],
            selected: state.lifestyleAssessment.waterIntake,
            onSelect: (v) => ref.read(onboardingProvider.notifier).updateLifestyleAssessment(waterIntake: v),
          ),
          const SizedBox(height: 16),
          _LifestyleCard(
            question: 'Activity Level',
            icon: Icons.fitness_center,
            options: const ['Sedentary', 'Light', 'Moderate', 'Active'],
            selected: state.lifestyleAssessment.activityLevel,
            onSelect: (v) => ref.read(onboardingProvider.notifier).updateLifestyleAssessment(activityLevel: v),
          ),
          const SizedBox(height: 16),
          _LifestyleCard(
            question: 'Stress Level',
            icon: Icons.psychology_outlined,
            options: const ['Low', 'Medium', 'High'],
            selected: state.lifestyleAssessment.stressLevel,
            onSelect: (v) => ref.read(onboardingProvider.notifier).updateLifestyleAssessment(stressLevel: v),
          ),
          const SizedBox(height: 16),
          _LifestyleCard(
            question: 'Sun Exposure',
            icon: Icons.wb_sunny,
            options: const ['Minimal', 'Moderate', 'Frequent'],
            selected: state.lifestyleAssessment.sunExposure,
            onSelect: (v) => ref.read(onboardingProvider.notifier).updateLifestyleAssessment(sunExposure: v),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _LifestyleCard extends StatelessWidget {
  final String question;
  final IconData icon;
  final List<String> options;
  final List<String>? emojis;
  final String selected;
  final ValueChanged<String> onSelect;

  const _LifestyleCard({
    required this.question,
    required this.icon,
    required this.options,
    this.emojis,
    required this.selected,
    required this.onSelect,
  });

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
          Row(
            children: [
              Icon(icon, size: 22, color: AppColors.matteGold),
              const SizedBox(width: 10),
              Text(
                question,
                style: AppTypography.titleMedium.copyWith(color: AppColors.softCharcoal),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.asMap().entries.map((entry) {
              final idx = entry.key;
              final option = entry.value;
              final isSelected = selected == option;
              return GestureDetector(
                onTap: () => onSelect(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.matteGold : AppColors.ivoryWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.matteGold : AppColors.outlineVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (emojis != null && idx < emojis!.length)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(emojis![idx], style: const TextStyle(fontSize: 16)),
                        ),
                      Text(
                        option,
                        style: AppTypography.bodySmall.copyWith(
                          color: isSelected ? Colors.white : AppColors.softCharcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
