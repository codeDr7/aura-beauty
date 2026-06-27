import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/onboarding_provider.dart';

class StepPersonalInfo extends ConsumerWidget {
  const StepPersonalInfo({super.key});

  final List<String> ageRanges = const [
    '18-24', '25-34', '35-44', '45-54', '55+',
  ];

  final List<String> countries = const [
    'United States', 'Canada', 'United Kingdom', 'Australia', 'UAE',
    'Saudi Arabia', 'India', 'Other',
  ];

  final List<String> climates = const [
    'Tropical', 'Dry', 'Temperate', 'Continental', 'Polar',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding.copyWith(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: AppTypography.sectionTitle.copyWith(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            'Help us personalize your beauty journey',
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          _LabeledField(
            label: 'Full Name',
            child: TextFormField(
              initialValue: state.personalInfo.name,
              decoration: const InputDecoration(
                hintText: 'Enter your full name',
                prefixIcon: Icon(Icons.person_outlined, size: 20),
              ),
              onChanged: (v) => ref.read(onboardingProvider.notifier).updatePersonalInfo(name: v),
            ),
          ),
          const SizedBox(height: 20),
          _LabeledField(
            label: 'Age Range',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ageRanges.map((range) {
                final selected = state.personalInfo.ageRange == range;
                return ChoiceChip(
                  label: Text(range, style: AppTypography.bodySmall.copyWith(
                    color: selected ? Colors.white : AppColors.softCharcoal,
                  )),
                  selected: selected,
                  onSelected: (_) => ref.read(onboardingProvider.notifier).updatePersonalInfo(ageRange: range),
                  selectedColor: AppColors.matteGold,
                  backgroundColor: AppColors.ivoryWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected ? AppColors.matteGold : AppColors.outlineVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          _LabeledField(
            label: 'Gender',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Female', 'Male', 'Non-binary', 'Prefer not to say'].map((g) {
                final selected = state.personalInfo.gender == g;
                return ChoiceChip(
                  label: Text(g, style: AppTypography.bodySmall.copyWith(
                    color: selected ? Colors.white : AppColors.softCharcoal,
                  )),
                  selected: selected,
                  onSelected: (_) => ref.read(onboardingProvider.notifier).updatePersonalInfo(gender: g),
                  selectedColor: AppColors.matteGold,
                  backgroundColor: AppColors.ivoryWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected ? AppColors.matteGold : AppColors.outlineVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          _LabeledField(
            label: 'Country',
            child: DropdownButtonFormField<String>(
              value: state.personalInfo.country.isEmpty ? null : state.personalInfo.country,
              decoration: const InputDecoration(
                hintText: 'Select your country',
                prefixIcon: Icon(Icons.public_outlined, size: 20),
              ),
              items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => ref.read(onboardingProvider.notifier).updatePersonalInfo(country: v ?? ''),
            ),
          ),
          const SizedBox(height: 20),
          _LabeledField(
            label: 'Climate',
            child: DropdownButtonFormField<String>(
              value: state.personalInfo.climate.isEmpty ? null : state.personalInfo.climate,
              decoration: const InputDecoration(
                hintText: 'Select your climate',
                prefixIcon: Icon(Icons.wb_sunny_outlined, size: 20),
              ),
              items: climates.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => ref.read(onboardingProvider.notifier).updatePersonalInfo(climate: v ?? ''),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.softCharcoal,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
