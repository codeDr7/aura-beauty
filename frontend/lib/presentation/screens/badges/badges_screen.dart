import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_gradients.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/aura_card.dart';

class BadgesScreen extends ConsumerStatefulWidget {
  const BadgesScreen({super.key});

  @override
  ConsumerState<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends ConsumerState<BadgesScreen> {
  String _selectedCategory = 'All';

  final _categories = ['All', 'Streak', 'Assessment', 'Routine', 'Community', 'Progress', 'Milestone'];

  final _allBadges = [
    _BadgeData(name: '3-Day Streak', category: 'Streak', earned: true, icon: Icons.local_fire_department, progress: 1.0),
    _BadgeData(name: '7-Day Streak', category: 'Streak', earned: true, icon: Icons.local_fire_department, progress: 1.0),
    _BadgeData(name: '30-Day Streak', category: 'Streak', earned: false, icon: Icons.local_fire_department, progress: 0.45),
    _BadgeData(name: 'Skin Assessment', category: 'Assessment', earned: true, icon: Icons.face_retouching_natural, progress: 1.0),
    _BadgeData(name: 'Hair Assessment', category: 'Assessment', earned: true, icon: Icons.auto_fix_high, progress: 1.0),
    _BadgeData(name: 'Full Assessment', category: 'Assessment', earned: false, icon: Icons.assignment_turned_in, progress: 0.7),
    _BadgeData(name: 'Routine Master', category: 'Routine', earned: false, icon: Icons.spa, progress: 0.6),
    _BadgeData(name: 'Night Owl', category: 'Routine', earned: true, icon: Icons.nightlight_round, progress: 1.0),
    _BadgeData(name: 'Morning Star', category: 'Routine', earned: false, icon: Icons.wb_sunny, progress: 0.3),
    _BadgeData(name: 'Social Butterfly', category: 'Community', earned: true, icon: Icons.forum, progress: 1.0),
    _BadgeData(name: 'Challenge Champ', category: 'Community', earned: false, icon: Icons.emoji_events, progress: 0.8),
    _BadgeData(name: 'Helping Hand', category: 'Community', earned: false, icon: Icons.volunteer_activism, progress: 0.1),
    _BadgeData(name: 'Product Tester', category: 'Progress', earned: false, icon: Icons.science, progress: 0.5),
    _BadgeData(name: 'Photo Pro', category: 'Progress', earned: true, icon: Icons.camera_alt, progress: 1.0),
    _BadgeData(name: 'Consistency King', category: 'Progress', earned: false, icon: Icons.trending_up, progress: 0.25),
    _BadgeData(name: 'First Entry', category: 'Milestone', earned: true, icon: Icons.celebration, progress: 1.0),
    _BadgeData(name: '10 Entries', category: 'Milestone', earned: true, icon: Icons.auto_awesome, progress: 1.0),
    _BadgeData(name: '50 Entries', category: 'Milestone', earned: false, icon: Icons.stars, progress: 0.38),
  ];

  List<_BadgeData> get _filteredBadges {
    if (_selectedCategory == 'All') return _allBadges;
    return _allBadges.where((b) => b.category == _selectedCategory).toList();
  }

  int get _earnedCount => _allBadges.where((b) => b.earned).length;

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.matteGold,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.lg),
                _buildStatsCard(),
                const SizedBox(height: AppSpacing.lg),
                _buildCategoryChips(),
                const SizedBox(height: AppSpacing.md),
                _buildBadgesGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: AppSpacing.horizontalPadding.copyWith(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.warmNude.withOpacity(0.3),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: AppColors.softCharcoal, size: 20),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.matteGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$_earnedCount Earned', style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Achievement\nBadges',
            style: AppTypography.sectionTitle.copyWith(color: AppColors.softCharcoal, fontSize: 34),
          ),
          const SizedBox(height: 4),
          Text(
            '$_earnedCount of ${_allBadges.length} badges collected',
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppGradients.auraGold,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCards),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_earnedCount}/${_allBadges.length}', style: AppTypography.heroTitleMobile.copyWith(color: Colors.white, fontSize: 32)),
                  const SizedBox(height: 4),
                  Text('Badges Earned', style: AppTypography.bodySmall.copyWith(color: Colors.white70)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _earnedCount / _allBadges.length,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Icon(Icons.emoji_events, color: Colors.white, size: 36),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Top 15%',
                      style: AppTypography.caption.copyWith(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.matteGold : AppColors.ivoryWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.matteGold : AppColors.outlineVariant,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: AppTypography.bodySmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.softCharcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBadgesGrid() {
    final badges = _filteredBadges;
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: _selectedCategory == 'All' ? 'All Badges' : _selectedCategory,
            subtitle: '${badges.length} badges',
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final badge = badges[index];
              return _BadgeCard(badge: badge);
            },
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final _BadgeData badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badge.earned ? AppColors.surface : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: badge.earned ? AppColors.matteGold.withOpacity(0.4) : AppColors.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badge.earned ? AppColors.matteGold.withOpacity(0.15) : Colors.transparent,
                  border: Border.all(
                    color: badge.earned ? AppColors.matteGold : AppColors.outlineVariant,
                    width: 2,
                  ),
                ),
                child: Icon(
                  badge.icon,
                  size: 24,
                  color: badge.earned ? AppColors.matteGold : AppColors.outlineVariant,
                ),
              ),
              if (!badge.earned)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_outlined, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            badge.name,
            style: AppTypography.caption.copyWith(
              color: badge.earned ? AppColors.softCharcoal : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!badge.earned) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: badge.progress,
                backgroundColor: AppColors.outlineVariant.withOpacity(0.5),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.matteGold),
                minHeight: 3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${(badge.progress * 100).toInt()}%',
              style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant, fontSize: 9),
            ),
          ],
        ],
      ),
    );
  }
}

class _BadgeData {
  final String name;
  final String category;
  final bool earned;
  final IconData icon;
  final double progress;

  const _BadgeData({
    required this.name,
    required this.category,
    required this.earned,
    required this.icon,
    required this.progress,
  });
}
