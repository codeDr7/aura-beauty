import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../widgets/common/aura_top_bar.dart';

class VanityScreen extends ConsumerWidget {
  const VanityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: AppSpacing.pagePadding.copyWith(top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuraTopBar(title: 'Virtual Vanity'),
                const SizedBox(height: AppSpacing.lg),
                _buildHarmonyReport(),
                const SizedBox(height: AppSpacing.xl),
                _buildRoutineFilter(),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildProductGrid(),
                const SizedBox(height: AppSpacing.xl),
                _buildShelfDivider(),
                const SizedBox(height: AppSpacing.xl),
                _buildRegisterProductSlot(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHarmonyReport() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmNude.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCards),
        border: const Border(
          left: BorderSide(color: AppColors.matteGold, width: 2),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Harmony Report', style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal)),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.errorContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppSpacing.radiusButtons),
              border: Border.all(color: AppColors.error.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: AppSpacing.unit),
                    Text('CONFLICT DETECTED', style: AppTypography.bodySmall.copyWith(color: AppColors.error, letterSpacing: 2.0, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Retinol + Vitamin C: Potential for irritation. Use in separate routines.',
                    style: AppTypography.caption.copyWith(color: AppColors.onErrorContainer)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _buildStatItem('Products Tracked', '12')),
              const SizedBox(width: AppSpacing.gutter),
              Expanded(child: _buildStatItem('Active Expirations', '2')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTypography.cardTitle.copyWith(color: AppColors.matteGold)),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildRoutineFilter() {
    final filters = ['All Products', 'Morning Ritual', 'Evening Ritual', 'Weekly Treatment'];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCards),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ROUTINE FILTER', style: AppTypography.bodySmall.copyWith(color: AppColors.matteGold, letterSpacing: 4.0, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.md),
          ...filters.asMap().entries.map((e) {
            final isActive = e.key == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? AppColors.matteGold : Colors.transparent,
                      border: Border.all(color: isActive ? AppColors.matteGold : AppColors.outline.withOpacity(0.3)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(e.value, style: AppTypography.bodyMain.copyWith(
                    color: isActive ? AppColors.softCharcoal : AppColors.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('YOUR SHELF', style: AppTypography.bodySmall.copyWith(color: AppColors.matteGold, letterSpacing: 4.0, fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.gutter,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.48,
          ),
          itemCount: 4,
          itemBuilder: (context, index) => _buildProductCard(index),
        ),
      ],
    );
  }

  Widget _buildProductCard(int index) {
    final names = ['Vitamin C Serum', 'Hyaluronic Dew', 'Retinol Night Oil', 'Gentle Cleanse'];
    final brands = ['LUMINA', 'AURA', 'LUMINA', 'AURA'];
    final expiry = ['Dec 2026', 'Mar 2026', 'Aug 2026', 'Jan 2027'];
    final usagePct = [0.3, 0.85, 0.15, 0.5];
    final isExpiring = usagePct[index] > 0.7;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCards),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                ),
                child: Center(
                  child: Icon(Icons.spa_outlined, color: AppColors.matteGold, size: 40),
                ),
              ),
            ),
            if (isExpiring)
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(AppSpacing.radiusButtons)),
                  child: Text('Expiring Soon', style: AppTypography.caption.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(brands[index], style: AppTypography.caption.copyWith(color: AppColors.matteGold, letterSpacing: 2.0, fontSize: 10)),
        const SizedBox(height: 4),
        Text(names[index], style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: AppSpacing.unit),
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.onSurfaceVariant.withOpacity(0.6)),
            const SizedBox(width: 4),
            Text(expiry[index], style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant.withOpacity(0.6), fontSize: 11)),
          ],
        ),
        const SizedBox(height: AppSpacing.unit),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: SizedBox(
            height: 3,
            child: LinearProgressIndicator(
              value: usagePct[index],
              backgroundColor: AppColors.outlineVariant.withOpacity(0.4),
              valueColor: AlwaysStoppedAnimation<Color>(isExpiring ? AppColors.error : AppColors.matteGold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShelfDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.matteGold.withOpacity(0.4))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('Lower Shelf', style: AppTypography.caption.copyWith(color: AppColors.matteGold.withOpacity(0.4), fontStyle: FontStyle.italic)),
        ),
        Expanded(child: Container(height: 1, color: AppColors.matteGold.withOpacity(0.4))),
      ],
    );
  }

  Widget _buildRegisterProductSlot() {
    return GestureDetector(
      onTap: () {},
      child: DashedBorder(
        color: AppColors.outline,
        strokeWidth: 2,
        radius: AppSpacing.radiusCards,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.matteGold.withOpacity(0.4)),
                ),
                child: const Icon(Icons.add, color: AppColors.matteGold, size: 24),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('REGISTER PRODUCT', style: AppTypography.bodySmall.copyWith(color: AppColors.matteGold, letterSpacing: 4.0, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashGap;

  const DashedBorder({
    super.key,
    required this.child,
    this.color = AppColors.outline,
    this.strokeWidth = 2,
    this.radius = 24,
    this.dashWidth = 8,
    this.dashGap = 5,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        radius: radius,
        dashWidth: dashWidth,
        dashGap: dashGap,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashGap;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2,
    this.radius = 24,
    this.dashWidth = 8,
    this.dashGap = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        final extractPath = metric.extractPath(distance, end);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
