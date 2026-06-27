import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/aura_top_bar.dart';
import '../../widgets/common/aura_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/product_card.dart';
import '../../widgets/common/score_indicator.dart';
import '../../widgets/common/loading_shimmer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLoading = false;

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AuraTopBar(
              onProfileTap: null,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.matteGold))
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppColors.matteGold,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _WelcomeSection(),
                            const SizedBox(height: AppSpacing.lg),
                            _ScoreCardsSection(),
                            const SizedBox(height: AppSpacing.lg),
                            _TodaysRoutine(),
                            const SizedBox(height: AppSpacing.lg),
                            _RecommendedProducts(),
                            const SizedBox(height: AppSpacing.lg),
                            _ActiveChallenges(),
                            const SizedBox(height: AppSpacing.lg),
                            _CommunityHighlights(),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good morning, Sarah',
            style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal),
          ),
          const SizedBox(height: 4),
          Text(
            'Ready to glow today?',
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ScoreCardsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Row(
        children: [
          Expanded(
            child: AuraCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              body: Column(
                children: [
                  const ScoreIndicator(score: 72, label: 'Skin Score', size: 90, strokeWidth: 6),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => context.go('/progress'),
                    child: Text(
                      'View Details',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.matteGold,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AuraCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              body: Column(
                children: [
                  const ScoreIndicator(score: 65, label: 'Hair Score', size: 90, strokeWidth: 6),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => context.go('/progress'),
                    child: Text(
                      'View Details',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.matteGold,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
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

class _TodaysRoutine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: "Today's Routine",
            subtitle: '2 steps remaining',
            trailingLabel: 'View All',
            onTrailingTap: () => context.go('/routine'),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: AuraCard(
                  padding: AppSpacing.cardPadding,
                  hasGoldAccent: true,
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny, size: 16, color: AppColors.matteGold),
                          const SizedBox(width: 6),
                          Text('Morning', style: AppTypography.titleMedium.copyWith(fontSize: 14, color: AppColors.softCharcoal)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Cleanse • Tone • Moisturize', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: 0.6, backgroundColor: AppColors.outlineVariant.withOpacity(0.5), valueColor: const AlwaysStoppedAnimation(AppColors.sageGreen), minHeight: 4, borderRadius: BorderRadius.circular(2)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AuraCard(
                  padding: AppSpacing.cardPadding,
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.nightlight_round, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('Evening', style: AppTypography.titleMedium.copyWith(fontSize: 14, color: AppColors.softCharcoal)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Double Cleanse • Serum • Cream', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: 0.3, backgroundColor: AppColors.outlineVariant.withOpacity(0.5), valueColor: const AlwaysStoppedAnimation(AppColors.matteGold), minHeight: 4, borderRadius: BorderRadius.circular(2)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendedProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Recommended for You',
            trailingLabel: 'Shop All',
            onTrailingTap: () => context.go('/discover'),
          ),
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                ProductCard(
                  imageUrl: '',
                  name: 'Hydrating Serum',
                  subtitle: 'Vitamin C + HA',
                  price: '\$48.00',
                  badgeLabel: 'Best Seller',
                  onAddToBag: () {},
                  onTap: () {},
                ),
                const SizedBox(width: 10),
                ProductCard(
                  imageUrl: '',
                  name: 'Retinol Night Cream',
                  subtitle: 'Anti-Aging',
                  price: '\$65.00',
                  badgeLabel: 'New',
                  onAddToBag: () {},
                  onTap: () {},
                ),
                const SizedBox(width: 10),
                ProductCard(
                  imageUrl: '',
                  name: 'Gentle Cleanser',
                  subtitle: 'For Sensitive Skin',
                  price: '\$32.00',
                  onAddToBag: () {},
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveChallenges extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Active Challenges',
            trailingLabel: 'See All',
            onTrailingTap: () => context.go('/community'),
          ),
          AuraCard(
            padding: AppSpacing.cardPadding,
            hasGoldAccent: true,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.sageGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('14 Days', style: AppTypography.caption.copyWith(color: AppColors.sageGreen, fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    Text('3 days left', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 10),
                Text('14-Day Glow Journey', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
                const SizedBox(height: 6),
                Text('Complete your daily routine to earn the Glow Master badge', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(value: 0.64, backgroundColor: AppColors.outlineVariant.withOpacity(0.5), valueColor: const AlwaysStoppedAnimation(AppColors.matteGold), minHeight: 6, borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(width: 10),
                    Text('64%', style: AppTypography.labelMedium.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityHighlights extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Community Highlights',
            trailingLabel: 'View Feed',
            onTrailingTap: () => context.go('/community'),
          ),
          AuraCard(
            padding: AppSpacing.cardPadding,
            body: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.warmNude,
                  child: const Icon(Icons.person, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aisha M.', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal)),
                      const SizedBox(height: 2),
                      Text('Just completed my 14-day glow challenge! My skin has never looked better ✨', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
