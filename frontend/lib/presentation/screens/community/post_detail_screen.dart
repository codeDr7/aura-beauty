import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/aura_top_bar.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _comments = const [
    _CommentData(name: 'Lina K.', text: 'This is amazing! I\'ve been using the same serum and love it 💕', time: '1 hour ago'),
    _CommentData(name: 'Noor A.', text: 'How long did it take to see results?', time: '45 min ago'),
    _CommentData(name: 'Maya R.', text: 'About 2 weeks for me! Consistency is key ✨', time: '30 min ago'),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AuraTopBar(
              showBackButton: true,
              title: 'Post',
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontalPadding,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontalPadding,
                  0,
                ),
                children: [
                  _PostHeader(),
                  const SizedBox(height: 12),
                  Text(
                    'Just discovered the most amazing vitamin C serum! My dark spots are fading so fast. Has anyone else tried it? ✨',
                    style: AppTypography.bodyMain.copyWith(color: AppColors.softCharcoal, height: 1.6),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColors.warmNude.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Icon(Icons.image_outlined, size: 48, color: AppColors.outlineVariant)),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _ActionRow(icon: Icons.favorite_outlined, count: '24', color: AppColors.error),
                      const SizedBox(width: 24),
                      _ActionRow(icon: Icons.chat_bubble_outlined, count: '8', color: AppColors.onSurfaceVariant),
                      const Spacer(),
                      _ActionRow(icon: Icons.bookmark_outlined, count: null, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 16),
                      _ActionRow(icon: Icons.share_outlined, count: null, color: AppColors.onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.outlineVariant),
                  const SizedBox(height: 12),
                  Text('Comments', style: AppTypography.titleMedium.copyWith(color: AppColors.softCharcoal)),
                  const SizedBox(height: 12),
                  ..._comments.map((c) => _CommentCard(comment: c)),
                ],
              ),
            ),
            _CommentInput(
              controller: _commentController,
              onSend: (text) {
                if (text.trim().isNotEmpty) {
                  _commentController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.warmNude,
          child: const Text('M', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Maya R.', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal)),
              Text('2 hours ago', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
        const Icon(Icons.more_horiz, color: AppColors.onSurfaceVariant, size: 20),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String? count;
  final Color color;

  const _ActionRow({required this.icon, this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: color),
          if (count != null) ...[
            const SizedBox(width: 4),
            Text(count!, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final _CommentData comment;

  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.warmNude.withOpacity(0.5),
            child: Text(comment.name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(comment.name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal, fontSize: 13)),
                      const Spacer(),
                      Text(comment.time, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment.text, style: AppTypography.bodySmall.copyWith(color: AppColors.softCharcoal, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;

  const _CommentInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        8,
        AppSpacing.md,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.ivoryWhite.withOpacity(0.95),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant.withOpacity(0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: onSend,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onSend(controller.text),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.matteGold),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentData {
  final String name;
  final String text;
  final String time;

  const _CommentData({required this.name, required this.text, required this.time});
}
