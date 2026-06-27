import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../widgets/common/aura_top_bar.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuraTopBar(title: 'The Journal'),
              Padding(
                padding: AppSpacing.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Curated stories at the intersection of science, beauty, and luxury.',
                        style: AppTypography.bodyMain.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      height: 2, width: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.matteGold, AppColors.matteGold.withOpacity(0.0)]),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildFeaturedArticle(),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildRecentStories(),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildTopicsSection(),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildNewsletterCta(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedArticle() {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.radiusCards),
              topRight: Radius.circular(AppSpacing.radiusCards),
            ),
            child: SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.warmNude, child: const Center(child: Icon(Icons.image_outlined, size: 48, color: AppColors.matteGold))),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AppColors.softCharcoal.withOpacity(0.85)],
                          stops: const [0.35, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16, left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.softCharcoal.withOpacity(0.80), borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                      child: Text('DERMATOLOGY', style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontSize: 11, letterSpacing: 2.0)),
                    ),
                  ),
                  Positioned(
                    left: 20, right: 20, bottom: 20,
                    child: Text('The Science of Skin Barrier Repair', style: AppTypography.sectionTitle.copyWith(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(
                left: BorderSide(color: AppColors.softCharcoal.withOpacity(0.05)),
                right: BorderSide(color: AppColors.softCharcoal.withOpacity(0.05)),
                bottom: BorderSide(color: AppColors.softCharcoal.withOpacity(0.05)),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppSpacing.radiusCards),
                bottomRight: Radius.circular(AppSpacing.radiusCards),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Discover how to strengthen your skin barrier with the right ingredients and routine.',
                    style: AppTypography.bodyMain.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.sm),
                Text('8 min read', style: AppTypography.caption.copyWith(color: AppColors.outline)),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.softCharcoal,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        side: BorderSide(color: AppColors.softCharcoal.withOpacity(0.08)),
                      ),
                    ),
                    child: Text('READ ARTICLE', style: AppTypography.bodySmall.copyWith(color: AppColors.softCharcoal, letterSpacing: 2.0, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentStories() {
    final articles = [
      ('Ingredients', 'Retinol vs Bakuchiol: A Modern Comparison', '6 min read'),
      ('Routines', 'The Perfect Morning Skincare Sequence', '10 min read'),
      ('Hair Science', 'Understanding Hair Porosity', '7 min read'),
    ];
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RECENT STORIES', style: AppTypography.bodySmall.copyWith(color: AppColors.matteGold, letterSpacing: 4.0, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.md),
          ...articles.asMap().entries.map((e) {
            return Padding(
              padding: EdgeInsets.only(top: e.key > 0 ? AppSpacing.md : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Container(
                      width: 100, height: 100,
                      color: AppColors.warmNude,
                      child: const Center(child: Icon(Icons.image_outlined, size: 28, color: AppColors.matteGold)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.value.$1.toUpperCase(), style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontSize: 11, letterSpacing: 2.0)),
                        const SizedBox(height: 6),
                        Text(e.value.$2, style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text(e.value.$3, style: AppTypography.caption.copyWith(color: AppColors.outline)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopicsSection() {
    const topics = ['Dermatology', 'Ingredients', 'Routines', 'Hair Science'];
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EXPLORE TOPICS', style: AppTypography.bodySmall.copyWith(color: AppColors.matteGold, letterSpacing: 4.0, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm, runSpacing: AppSpacing.sm,
            children: topics.map((topic) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                child: Text(topic, style: AppTypography.caption.copyWith(color: AppColors.softCharcoal)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsletterCta() {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(color: AppColors.softCharcoal, borderRadius: BorderRadius.circular(32)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NEWSLETTER', style: AppTypography.bodySmall.copyWith(color: AppColors.matteGold, letterSpacing: 4.0, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.md),
            Text('Stay Informed', style: AppTypography.sectionTitle.copyWith(color: Colors.white)),
            const SizedBox(height: AppSpacing.sm),
            Text('Subscribe to our weekly editorial digest for the latest in beauty science.',
                style: AppTypography.bodyMain.copyWith(color: Colors.white.withOpacity(0.70))),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.matteGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                ),
                child: Text('SUBSCRIBE', style: AppTypography.bodySmall.copyWith(color: Colors.white, letterSpacing: 2.0, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
