import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/aura_top_bar.dart';
import '../../widgets/common/aura_card.dart';
import '../../widgets/common/section_header.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AuraTopBar(title: 'Community'),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.matteGold,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              indicatorColor: AppColors.matteGold,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: 'Feed'),
                Tab(text: 'Groups'),
                Tab(text: 'Challenges'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _FeedTab(),
                  _GroupsTab(),
                  _ChallengesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontalPadding,
        AppSpacing.md,
        AppSpacing.pageHorizontalPadding,
        AppSpacing.xxl,
      ),
      itemCount: _posts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _PostComposer(),
          );
        }
        return _PostCard(post: _posts[index - 1]);
      },
    );
  }
}

class _PostComposer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.warmNude,
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Share your beauty journey...',
              style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant.withOpacity(0.6)),
            ),
          ),
          const Icon(Icons.image_outlined, color: AppColors.sageGreen, size: 22),
          const SizedBox(width: 12),
          const Icon(Icons.emoji_emotions_outlined, color: AppColors.matteGold, size: 22),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final _PostData post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.warmNude,
                child: Text(post.name[0], style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal)),
                    Text(post.time, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: AppColors.onSurfaceVariant, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.content, style: AppTypography.bodySmall.copyWith(color: AppColors.softCharcoal, height: 1.5)),
          if (post.hasImage) ...[
            const SizedBox(height: 12),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.warmNude.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: Icon(Icons.image_outlined, size: 40, color: AppColors.outlineVariant)),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _ActionIcon(icon: Icons.favorite_outline, count: post.likes, color: AppColors.error),
              const SizedBox(width: 20),
              _ActionIcon(icon: Icons.chat_bubble_outline, count: post.comments, color: AppColors.onSurfaceVariant),
              const Spacer(),
              _ActionIcon(icon: Icons.bookmark_outline, count: null, color: AppColors.onSurfaceVariant),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final int? count;
  final Color color;

  const _ActionIcon({required this.icon, this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          if (count != null) ...[
            const SizedBox(width: 4),
            Text('$count', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}

class _GroupsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontalPadding, AppSpacing.lg, AppSpacing.pageHorizontalPadding, AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Groups', style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _GroupCard(name: 'Skincare Enthusiasts', members: '2.4k', color: AppColors.sageGreen),
                _GroupCard(name: 'Hair Care Queens', members: '1.8k', color: AppColors.matteGold),
                _GroupCard(name: 'Clean Beauty', members: '3.1k', color: AppColors.warmNude),
                _GroupCard(name: 'Wellness Warriors', members: '950', color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String name;
  final String members;
  final Color color;

  const _GroupCard({required this.name, required this.members, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.groups, color: Colors.white, size: 22),
          ),
          const Spacer(),
          Text(name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal)),
          const SizedBox(height: 2),
          Text('$members members', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ChallengesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontalPadding, AppSpacing.md, AppSpacing.pageHorizontalPadding, AppSpacing.xxl),
      itemCount: _challenges.length,
      itemBuilder: (context, index) {
        final challenge = _challenges[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
          ),
          child: Column(
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
                    child: Text('${challenge.duration} Days', style: AppTypography.caption.copyWith(color: AppColors.sageGreen, fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  Text('${challenge.remaining}d left', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 10),
              Text(challenge.title, style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
              const SizedBox(height: 4),
              Text(challenge.description, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: challenge.progress,
                      backgroundColor: AppColors.outlineVariant.withOpacity(0.5),
                      valueColor: const AlwaysStoppedAnimation(AppColors.matteGold),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${(challenge.progress * 100).round()}%', style: AppTypography.labelMedium.copyWith(color: AppColors.matteGold)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('${challenge.participants} participants', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PostData {
  final String name;
  final String time;
  final String content;
  final bool hasImage;
  final int likes;
  final int comments;

  const _PostData({required this.name, required this.time, required this.content, this.hasImage = false, this.likes = 0, this.comments = 0});
}

class _ChallengeData {
  final String title;
  final String description;
  final int duration;
  final int remaining;
  final double progress;
  final int participants;

  const _ChallengeData({required this.title, required this.description, required this.duration, required this.remaining, required this.progress, required this.participants});
}

const _posts = [
  _PostData(name: 'Maya R.', time: '2 hours ago', content: 'Just discovered the most amazing vitamin C serum! My dark spots are fading so fast. Has anyone else tried it? ✨', hasImage: true, likes: 24, comments: 8),
  _PostData(name: 'Lina K.', time: '5 hours ago', content: 'Day 7 of my 14-day glow challenge and I can already see a difference! Consistency is key 💪', likes: 15, comments: 3),
  _PostData(name: 'Noor A.', time: '1 day ago', content: 'Anyone have recommendations for a good sunscreen that doesn\'t leave a white cast?', likes: 31, comments: 12),
];

const _challenges = [
  _ChallengeData(title: '14-Day Glow Journey', description: 'Transform your skin with a complete daily routine', duration: 14, remaining: 3, progress: 0.78, participants: 1240),
  _ChallengeData(title: 'Hydration Heroes', description: 'Drink your way to better skin', duration: 7, remaining: 1, progress: 0.85, participants: 890),
  _ChallengeData(title: 'Sleep Beauty Reset', description: 'Improve your sleep for better beauty results', duration: 21, remaining: 14, progress: 0.33, participants: 567),
];
