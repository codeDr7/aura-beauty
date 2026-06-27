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

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final _filters = ['All', 'Skincare', 'Haircare', 'Body'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: const [
            AuraTopBar(title: 'Discover'),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SearchBar(),
                    SizedBox(height: AppSpacing.md),
                    _FilterChips(),
                    SizedBox(height: AppSpacing.lg),
                    _IngredientLibrary(),
                    SizedBox(height: AppSpacing.lg),
                    _FeaturedArticles(),
                    SizedBox(height: AppSpacing.lg),
                    _ClimateMatching(),
                    SizedBox(height: AppSpacing.lg),
                    _FeaturedProducts(),
                    SizedBox(height: AppSpacing.xxl),
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

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.ivoryWhite,
          borderRadius: BorderRadius.circular(18),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search products, ingredients...',
            hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant.withOpacity(0.6)),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 22),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.matteGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 20),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: ['All', 'Skincare', 'Haircare', 'Body', 'Wellness', 'Tools'].map((f) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                selected: f == 'All',
                selectedColor: AppColors.matteGold,
                backgroundColor: AppColors.ivoryWhite,
                labelStyle: TextStyle(color: f == 'All' ? Colors.white : AppColors.softCharcoal),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: f == 'All' ? AppColors.matteGold : AppColors.outlineVariant),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _IngredientLibrary extends StatelessWidget {
  const _IngredientLibrary();

  final _ingredients = const [
    ('Vitamin C', 'Brightening', Icons.wb_sunny),
    ('Hyaluronic Acid', 'Hydration', Icons.water_drop),
    ('Retinol', 'Anti-Aging', Icons.auto_awesome),
    ('Niacinamide', 'Pore Care', Icons.blur_on),
    ('Ceramides', 'Barrier', Icons.shield_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Ingredient Library',
            trailingLabel: 'Explore All',
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _ingredients.length,
              itemBuilder: (context, index) {
                final ing = _ingredients[index];
                return Container(
                  width: 130,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(ing.$3, color: AppColors.matteGold, size: 24),
                      const SizedBox(height: 6),
                      Text(ing.$1, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal), textAlign: TextAlign.center),
                      Text(ing.$2, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedArticles extends StatelessWidget {
  const _FeaturedArticles();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Education',
            subtitle: 'Learn from the experts',
            trailingLabel: 'Read More',
          ),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _ArticleCard(title: 'The Ultimate Guide to Retinol', category: 'Anti-Aging', reads: '12k reads'),
                const SizedBox(width: 10),
                _ArticleCard(title: 'Understanding Your Skin Barrier', category: 'Skincare 101', reads: '8.5k reads'),
                const SizedBox(width: 10),
                _ArticleCard(title: 'Summer Hair Care Routine', category: 'Haircare', reads: '6k reads'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final String title;
  final String category;
  final String reads;

  const _ArticleCard({required this.title, required this.category, required this.reads});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.matteGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(category, style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 14, color: AppColors.softCharcoal)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.menu_book_outlined, size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(reads, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClimateMatching extends StatelessWidget {
  const _ClimateMatching();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.warmNude.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Smart Discovery: Climate Matching',
                style: AppTypography.sectionTitle.copyWith(color: AppColors.softCharcoal)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Our AI analyzes your local humidity, UV index, and pollution levels to recommend a dynamic skincare regimen that adapts to your environment.',
              style: AppTypography.bodyMain.copyWith(color: AppColors.onSurfaceVariant, height: 1.7),
            ),
            const SizedBox(height: AppSpacing.lg),
            _climateChip(Icons.wb_sunny_outlined, 'YOUR CLIMATE', 'Arid & High UV'),
            const SizedBox(height: AppSpacing.sm),
            _climateChip(Icons.recommend_outlined, 'RECOMMENDATION', 'Hydration Lock Kit'),
          ],
        ),
      ),
    );
  }

  Widget _climateChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.matteGold, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant.withOpacity(0.6), fontSize: 10, letterSpacing: 1)),
              Text(value, style: AppTypography.bodyMain.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturedProducts extends StatelessWidget {
  const _FeaturedProducts();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Featured Products',
            trailingLabel: 'View All',
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.75,
            children: const [
              ProductCard(imageUrl: '', name: 'Vitamin C Serum', subtitle: 'Brightening', price: '\$52.00', badgeLabel: 'Popular', width: double.infinity),
              ProductCard(imageUrl: '', name: 'Hyaluronic Dew', subtitle: 'Hydration', price: '\$44.00', width: double.infinity),
              ProductCard(imageUrl: '', name: 'Retinol Night Oil', subtitle: 'Anti-Aging', price: '\$68.00', badgeLabel: 'New', width: double.infinity),
              ProductCard(imageUrl: '', name: 'Gentle Cleanse', subtitle: 'Daily wash', price: '\$28.00', width: double.infinity),
            ],
          ),
        ],
      ),
    );
  }
}
