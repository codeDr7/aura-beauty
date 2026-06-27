import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/aura_top_bar.dart';
import '../../widgets/common/aura_card.dart';
import '../../widgets/common/section_header.dart';

class RoutineScreen extends ConsumerStatefulWidget {
  final String routineId;

  const RoutineScreen({super.key, this.routineId = ''});

  @override
  ConsumerState<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends ConsumerState<RoutineScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AuraTopBar(
              showBackButton: true,
              title: 'My Routine',
            ),
            Padding(
              padding: AppSpacing.horizontalPadding,
              child: Row(
                children: [
                  _RoutineTab(label: 'Morning', isActive: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0)),
                  const SizedBox(width: 10),
                  _RoutineTab(label: 'Evening', isActive: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.sageGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('68% adherence', style: AppTypography.caption.copyWith(color: AppColors.sageGreen, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontalPadding,
                  0,
                  AppSpacing.pageHorizontalPadding,
                  AppSpacing.xxl,
                ),
                itemCount: _selectedTab == 0 ? _morningSteps.length : _eveningSteps.length,
                itemBuilder: (context, index) {
                  final steps = _selectedTab == 0 ? _morningSteps : _eveningSteps;
                  return _RoutineStepCard(step: steps[index], index: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _RoutineTab({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.matteGold : AppColors.ivoryWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isActive ? AppColors.matteGold : AppColors.outlineVariant),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isActive ? Colors.white : AppColors.softCharcoal,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _RoutineStepCard extends StatefulWidget {
  final _StepData step;
  final int index;

  const _RoutineStepCard({required this.step, required this.index});

  @override
  State<_RoutineStepCard> createState() => _RoutineStepCardState();
}

class _RoutineStepCardState extends State<_RoutineStepCard> {
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isCompleted ? AppColors.sageGreen.withOpacity(0.3) : AppColors.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isCompleted = !_isCompleted),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isCompleted ? AppColors.sageGreen : Colors.transparent,
                border: Border.all(
                  color: _isCompleted ? AppColors.sageGreen : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: _isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.step.title,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _isCompleted ? AppColors.onSurfaceVariant : AppColors.softCharcoal,
                    decoration: _isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.step.product,
                  style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.step.duration,
                  style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warmNude.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('02:00', style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepData {
  final String title;
  final String product;
  final String duration;

  const _StepData({required this.title, required this.product, required this.duration});
}

const _morningSteps = [
  _StepData(title: 'Cleanse', product: 'Gentle Foaming Cleanser', duration: '01:00'),
  _StepData(title: 'Tone', product: 'Hydrating Toner', duration: '00:30'),
  _StepData(title: 'Vitamin C Serum', product: 'Brightening Vitamin C', duration: '01:00'),
  _StepData(title: 'Moisturize', product: 'Daily Moisture Cream', duration: '01:00'),
  _StepData(title: 'Sunscreen', product: 'SPF 50 PA+++', duration: '01:00'),
];

const _eveningSteps = [
  _StepData(title: 'Double Cleanse', product: 'Oil & Foam Cleanser', duration: '02:00'),
  _StepData(title: 'Exfoliate', product: 'Gentle AHA/BHA (3x/wk)', duration: '01:00'),
  _StepData(title: 'Retinol Serum', product: 'Retinol Night Oil', duration: '01:00'),
  _StepData(title: 'Eye Cream', product: 'Hydrating Eye Treatment', duration: '00:30'),
  _StepData(title: 'Night Cream', product: 'Rich Recovery Cream', duration: '01:00'),
];
