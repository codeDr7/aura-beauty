import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/onboarding_provider.dart';
import 'step_personal_info.dart';
import 'step_skin_assessment.dart';
import 'step_hair_assessment.dart';
import 'step_lifestyle_assessment.dart';
import 'step_results.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  static const _totalSteps = 5;

  static const _stepTitles = [
    'Personal Information',
    'Skin Assessment',
    'Hair Assessment',
    'Lifestyle Assessment',
    'Your Results',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final pageController = ref.read(onboardingProvider.notifier).pageController;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _ProgressBar(currentStep: state.currentStep, totalSteps: _totalSteps),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _totalSteps,
                onPageChanged: (index) {
                  ref.read(onboardingProvider.notifier).goToStep(index);
                },
                itemBuilder: (context, index) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeInOut,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildStep(index, key: ValueKey(index)),
                  );
                },
              ),
            ),
            _BottomBar(
              currentStep: state.currentStep,
              totalSteps: _totalSteps,
              onBack: () => ref.read(onboardingProvider.notifier).previousStep(),
              onNext: () {
                if (state.currentStep < _totalSteps - 1) {
                  ref.read(onboardingProvider.notifier).nextStep();
                }
              },
              onSubmit: () {
                ref.read(onboardingProvider.notifier).submitAll();
                context.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int index, {required Key key}) {
    switch (index) {
      case 0:
        return const StepPersonalInfo(key: key);
      case 1:
        return const StepSkinAssessment(key: key);
      case 2:
        return const StepHairAssessment(key: key);
      case 3:
        return const StepLifestyleAssessment(key: key);
      case 4:
        return const StepResults(key: key);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _ProgressBar({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontalPadding,
        MediaQuery.of(context).padding.top + AppSpacing.md,
        AppSpacing.pageHorizontalPadding,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'AURA',
                style: AppTypography.brandName.copyWith(
                  color: AppColors.primary,
                  fontSize: 18,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / totalSteps,
              backgroundColor: AppColors.outlineVariant.withOpacity(0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.matteGold),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${currentStep + 1} of $totalSteps',
            style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const _BottomBar({
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == totalSteps - 1;
    final isFirstStep = currentStep == 0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontalPadding,
        AppSpacing.md,
        AppSpacing.pageHorizontalPadding,
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.ivoryWhite.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Back',
                  style: AppTypography.buttonLabel.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            ),
          if (!isFirstStep) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLastStep ? onSubmit : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.matteGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isLastStep ? 'Complete' : 'Continue',
                style: AppTypography.buttonLabel.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
