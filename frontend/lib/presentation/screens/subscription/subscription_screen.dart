import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/aura_top_bar.dart';
import '../../widgets/common/aura_card.dart';
import '../../widgets/common/aura_button.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isAnnual = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AuraTopBar(
              showBackButton: true,
              title: 'Subscription',
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
                    Text('Choose Your Plan', style: AppTypography.sectionTitle.copyWith(fontSize: 28, color: AppColors.softCharcoal)),
                    const SizedBox(height: 8),
                    Text('Unlock the full potential of your beauty journey', style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _ToggleOption(label: 'Monthly', isSelected: !_isAnnual, onTap: () => setState(() => _isAnnual = false)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ToggleOption(label: 'Annual', isSelected: _isAnnual, onTap: () => setState(() => _isAnnual = true)),
                        ),
                        if (_isAnnual)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.sageGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('Save 20%', style: AppTypography.caption.copyWith(color: AppColors.sageGreen, fontWeight: FontWeight.w600)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _PlanCard(
                      title: 'Free',
                      price: _isAnnual ? '\$0/yr' : '\$0/mo',
                      description: 'Get started with basic features',
                      features: const ['Basic skin assessment', 'Daily routine tracking', 'Limited product recommendations', 'Community access'],
                      isCurrent: true,
                      isRecommended: false,
                      buttonLabel: 'Current Plan',
                      onButtonTap: null,
                    ),
                    const SizedBox(height: 14),
                    _PlanCard(
                      title: 'Aura Plus',
                      price: _isAnnual ? '\$49/yr' : '\$4.99/mo',
                      description: 'Elevate your beauty routine',
                      features: const ['Full skin & hair assessment', 'AI beauty coach access', 'Unlimited product recommendations', 'Progress analytics & charts', 'Challenge participation', 'Priority community support'],
                      isCurrent: false,
                      isRecommended: true,
                      buttonLabel: 'Subscribe',
                      onButtonTap: () {},
                    ),
                    const SizedBox(height: 14),
                    _PlanCard(
                      title: 'Aura Premium',
                      price: _isAnnual ? '\$99/yr' : '\$9.99/mo',
                      description: 'The ultimate beauty experience',
                      features: const ['Everything in Aura Plus', 'Personalized beauty advisor', 'Ingredient analysis', 'Before/after photo analysis', 'Exclusive community groups', 'Early access to features', 'VIP support'],
                      isCurrent: false,
                      isRecommended: false,
                      buttonLabel: 'Subscribe',
                      onButtonTap: () {},
                    ),
                    const SizedBox(height: 24),
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

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.matteGold : AppColors.ivoryWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.matteGold : AppColors.outlineVariant),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isSelected ? Colors.white : AppColors.softCharcoal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final List<String> features;
  final bool isCurrent;
  final bool isRecommended;
  final String buttonLabel;
  final VoidCallback? onButtonTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.description,
    required this.features,
    required this.isCurrent,
    required this.isRecommended,
    required this.buttonLabel,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isRecommended ? AppColors.matteGold : AppColors.outlineVariant.withOpacity(0.5),
          width: isRecommended ? 1.5 : 0.5,
        ),
        boxShadow: isRecommended
            ? [BoxShadow(color: AppColors.matteGold.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))]
            : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal, fontSize: 20)),
              const Spacer(),
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.matteGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Recommended', style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: AppTypography.heroTitleMobile.copyWith(fontSize: 28, color: AppColors.softCharcoal)),
              if (!isCurrent) ...[
                const SizedBox(width: 4),
                Text(_getPeriodLabel(), style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(description, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: AppColors.sageGreen),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: AppTypography.bodySmall.copyWith(color: AppColors.softCharcoal))),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          if (isCurrent)
            AuraButton(
              label: buttonLabel,
              onPressed: null,
              isSecondary: true,
            )
          else
            AuraButton(
              label: buttonLabel,
              onPressed: onButtonTap,
            ),
        ],
      ),
    );
  }

  String _getPeriodLabel() {
    if (price.contains('/yr')) return 'per year';
    return 'per month';
  }
}
