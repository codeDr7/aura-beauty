import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/routine.dart';
import '../../../domain/entities/community.dart';
import '../../widgets/common/aura_top_bar.dart';
import '../../widgets/common/aura_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/product_card.dart';
import '../../widgets/common/score_indicator.dart';
import '../../providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _onRefresh() async {
    await ref.read(homeProvider.notifier).loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AuraTopBar(onProfileTap: null),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.matteGold))
                  : state.error != null && state.routines.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cloud_off, size: 48, color: AppColors.onSurfaceVariant.withOpacity(0.5)),
                              const SizedBox(height: 12),
                              Text('Could not load data', style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: _onRefresh,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _onRefresh,
                          color: AppColors.matteGold,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _WelcomeSection(greeting: state.greeting),
                                const SizedBox(height: AppSpacing.lg),
                                _ScoreCardsSection(skinScore: state.skinScore, hairScore: state.hairScore),
                                if (state.routines.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.lg),
                                  _TodaysRoutine(routines: state.routines),
                                ],
                                if (state.recommendations.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.lg),
                                  _RecommendedProducts(products: state.recommendations),
                                ],
                                if (state.challenges.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.lg),
                                  _ActiveChallenges(challenges: state.challenges),
                                ],
                                if (state.highlights.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.lg),
                                  _CommunityHighlights(posts: state.highlights),
                                ],
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
  final String greeting;
  const _WelcomeSection({required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal)),
          const SizedBox(height: 4),
          Text('Ready to glow today?', style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ScoreCardsSection extends StatelessWidget {
  final int skinScore;
  final int hairScore;
  const _ScoreCardsSection({required this.skinScore, required this.hairScore});

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
                  ScoreIndicator(score: skinScore > 0 ? skinScore : 72, label: 'Skin Score', size: 90, strokeWidth: 6),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => context.go('/progress'),
                    child: Text('View Details', style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
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
                  ScoreIndicator(score: hairScore > 0 ? hairScore : 65, label: 'Hair Score', size: 90, strokeWidth: 6),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => context.go('/progress'),
                    child: Text('View Details', style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
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
  final List<Routine> routines;
  const _TodaysRoutine({required this.routines});

  @override
  Widget build(BuildContext context) {
    final display = routines.take(2).toList();
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: "Today's Routine",
            subtitle: '${routines.fold(0, (sum, r) => sum + r.steps.where((s) => !s.isCompleted).length)} steps remaining',
            trailingLabel: 'View All',
            onTrailingTap: () => context.go('/routine'),
          ),
          const SizedBox(height: 4),
          Row(
            children: display.map((r) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: display.indexOf(r) < display.length - 1 ? 10 : 0),
                  child: AuraCard(
                    padding: AppSpacing.cardPadding,
                    hasGoldAccent: display.indexOf(r) == 0,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(display.indexOf(r) == 0 ? Icons.wb_sunny : Icons.nightlight_round, size: 16, color: display.indexOf(r) == 0 ? AppColors.matteGold : AppColors.primary),
                            const SizedBox(width: 6),
                            Flexible(child: Text(r.name, style: AppTypography.titleMedium.copyWith(fontSize: 14, color: AppColors.softCharcoal), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(r.type, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: r.progress, backgroundColor: AppColors.outlineVariant.withOpacity(0.5), valueColor: AlwaysStoppedAnimation(display.indexOf(r) == 0 ? AppColors.sageGreen : AppColors.matteGold), minHeight: 4, borderRadius: BorderRadius.circular(2)),
                      ],
                    ),
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

class _RecommendedProducts extends StatelessWidget {
  final List<Product> products;
  const _RecommendedProducts({required this.products});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Recommended for You', trailingLabel: 'Shop All', onTrailingTap: () => context.go('/discover')),
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: products.take(8).map((p) {
                return Padding(
                  padding: EdgeInsets.only(left: products.indexOf(p) == 0 ? 0 : 10),
                  child: ProductCard(
                    imageUrl: p.imageUrl ?? '',
                    name: p.name,
                    subtitle: p.subtitle ?? p.brand,
                    price: p.price,
                    badgeLabel: p.isRecommended ? 'Recommended' : null,
                    onAddToBag: () {},
                    onTap: () {},
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveChallenges extends StatelessWidget {
  final List<Challenge> challenges;
  const _ActiveChallenges({required this.challenges});

  @override
  Widget build(BuildContext context) {
    final challenge = challenges.isNotEmpty ? challenges.first : null;
    if (challenge == null) return const SizedBox.shrink();
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Active Challenges', trailingLabel: 'See All', onTrailingTap: () => context.go('/community')),
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
                      decoration: BoxDecoration(color: AppColors.sageGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text('${challenge.durationDays} Days', style: AppTypography.caption.copyWith(color: AppColors.sageGreen, fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    if (challenge.remainingDays > 0) Text('${challenge.remainingDays} days left', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(challenge.title, style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
                const SizedBox(height: 6),
                Text(challenge.description ?? '', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                if (challenge.progress > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(value: challenge.progress, backgroundColor: AppColors.outlineVariant.withOpacity(0.5), valueColor: const AlwaysStoppedAnimation(AppColors.matteGold), minHeight: 6, borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(width: 10),
                      Text('${(challenge.progress * 100).toInt()}%', style: AppTypography.labelMedium.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityHighlights extends StatelessWidget {
  final List<CommunityPost> posts;
  const _CommunityHighlights({required this.posts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Community Highlights', trailingLabel: 'View Feed', onTrailingTap: () => context.go('/community')),
          ...posts.take(2).map((post) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AuraCard(
              padding: AppSpacing.cardPadding,
              body: Row(
                children: [
                  CircleAvatar(radius: 22, backgroundColor: AppColors.warmNude, child: Icon(Icons.person, color: AppColors.primary, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.userName, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal)),
                        const SizedBox(height: 2),
                        Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                        if (post.likes > 0 || post.comments > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (post.likes > 0) Row(children: [Icon(Icons.favorite_border, size: 12, color: AppColors.onSurfaceVariant), const SizedBox(width: 2), Text('${post.likes}', style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant))]),
                              if (post.likes > 0 && post.comments > 0) const SizedBox(width: 8),
                              if (post.comments > 0) Row(children: [Icon(Icons.chat_bubble_outline, size: 12, color: AppColors.onSurfaceVariant), const SizedBox(width: 2), Text('${post.comments}', style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant))]),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
