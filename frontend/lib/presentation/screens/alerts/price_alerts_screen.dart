import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_gradients.dart';
import '../../widgets/common/aura_card.dart';
import '../../widgets/common/aura_button.dart';
import '../../widgets/common/section_header.dart';

class PriceAlertsScreen extends ConsumerStatefulWidget {
  const PriceAlertsScreen({super.key});

  @override
  ConsumerState<PriceAlertsScreen> createState() => _PriceAlertsScreenState();
}

class _PriceAlertsScreenState extends ConsumerState<PriceAlertsScreen> {
  final List<_PriceAlert> _alerts = [
    _PriceAlert(
      id: '1',
      productName: 'La Mer Crème de la Mer',
      brand: 'La Mer',
      currentPrice: 195.00,
      targetPrice: 175.00,
      originalPrice: 210.00,
      isActive: true,
    ),
    _PriceAlert(
      id: '2',
      productName: 'Drunk Elephant Protini Cream',
      brand: 'Drunk Elephant',
      currentPrice: 62.00,
      targetPrice: 55.00,
      originalPrice: 68.00,
      isActive: true,
    ),
    _PriceAlert(
      id: '3',
      productName: 'Augustinus Bader Cream',
      brand: 'Augustinus Bader',
      currentPrice: 280.00,
      targetPrice: 250.00,
      originalPrice: 290.00,
      isActive: false,
    ),
    _PriceAlert(
      id: '4',
      productName: 'SK-II Facial Treatment Essence',
      brand: 'SK-II',
      currentPrice: 185.00,
      targetPrice: 175.00,
      originalPrice: 199.00,
      isActive: true,
    ),
    _PriceAlert(
      id: '5',
      productName: 'Sunday Riley Good Genes',
      brand: 'Sunday Riley',
      currentPrice: 81.00,
      targetPrice: 75.00,
      originalPrice: 85.00,
      isActive: true,
    ),
  ];

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  void _toggleAlert(int index) {
    setState(() {
      _alerts[index].isActive = !_alerts[index].isActive;
    });
  }

  void _deleteAlert(int index) {
    setState(() {
      _alerts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.matteGold,
          child: _alerts.isEmpty ? _buildEmptyState() : _buildAlertList(),
        ),
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppGradients.goldenButton,
          boxShadow: [
            BoxShadow(
              color: AppColors.matteGold.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAlertList() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: AppSpacing.pageHorizontalPadding,
        right: AppSpacing.pageHorizontalPadding,
        top: 12,
        bottom: AppSpacing.xxl + 56,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(_alerts.length, (i) {
            final alert = _alerts[i];
            return Padding(
              padding: EdgeInsets.only(bottom: i < _alerts.length - 1 ? 10 : 0),
              child: _AlertCard(
                alert: alert,
                onToggle: () => _toggleAlert(i),
                onDelete: () => _deleteAlert(i),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final activeCount = _alerts.where((a) => a.isActive).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
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
              child: Text(
                '$activeCount active',
                style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Price Alerts',
          style: AppTypography.sectionTitle.copyWith(color: AppColors.softCharcoal, fontSize: 30),
        ),
        const SizedBox(height: 4),
        Text(
          'Get notified when prices drop to your target',
          style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 80),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.matteGold.withOpacity(0.08),
                    ),
                    child: const Icon(Icons.notifications_outlined, size: 40, color: AppColors.matteGold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No price alerts yet',
                    style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add products you\'re watching and we\'ll notify you when prices drop.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AuraButton(
                    label: 'Add Your First Alert',
                    onPressed: () {},
                    width: 220,
                    isFullWidth: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceAlert {
  final String id;
  final String productName;
  final String brand;
  final double currentPrice;
  final double targetPrice;
  final double originalPrice;
  bool isActive;

  _PriceAlert({
    required this.id,
    required this.productName,
    required this.brand,
    required this.currentPrice,
    required this.targetPrice,
    required this.originalPrice,
    required this.isActive,
  });

  double get progress {
    final drop = originalPrice - currentPrice;
    final target = originalPrice - targetPrice;
    if (target <= 0) return 1.0;
    return (drop / target).clamp(0.0, 1.0);
  }

  double get savingsPercent {
    final saved = originalPrice - currentPrice;
    return ((saved / originalPrice) * 100).roundToDouble();
  }
}

class _AlertCard extends StatelessWidget {
  final _PriceAlert alert;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _AlertCard({
    required this.alert,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error, size: 28),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: alert.isActive ? AppColors.surface : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: alert.isActive
                ? AppColors.outlineVariant.withOpacity(0.5)
                : AppColors.outlineVariant.withOpacity(0.3),
          ),
          boxShadow: alert.isActive
              ? [BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.warmNude.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.spa_outlined, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.productName,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: alert.isActive ? AppColors.softCharcoal : AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.brand,
                        style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: alert.isActive,
                  onChanged: (_) => onToggle(),
                  activeColor: AppColors.matteGold,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(
                      '\$${alert.currentPrice.toStringAsFixed(2)}',
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 18,
                        color: alert.isActive ? AppColors.softCharcoal : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Target', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(
                      '\$${alert.targetPrice.toStringAsFixed(2)}',
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 18,
                        color: alert.isActive ? AppColors.matteGold : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (alert.savingsPercent > 0 ? AppColors.sageGreen : AppColors.warning).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    alert.savingsPercent > 0 ? '-${alert.savingsPercent.toStringAsFixed(0)}%' : '0%',
                    style: AppTypography.caption.copyWith(
                      color: alert.savingsPercent > 0 ? AppColors.sageGreen : AppColors.warning,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: alert.progress,
                      backgroundColor: AppColors.outlineVariant.withOpacity(0.5),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        alert.isActive ? AppColors.matteGold : AppColors.outlineVariant,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(alert.progress * 100).toInt()}%',
                  style: AppTypography.labelMedium.copyWith(
                    color: alert.isActive ? AppColors.matteGold : AppColors.outlineVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
