import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/aura_top_bar.dart';
import '../../widgets/common/aura_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/score_indicator.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _periodTabController;
  String _selectedPeriod = 'Weekly';

  @override
  void initState() {
    super.initState();
    _periodTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _periodTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: const [
            AuraTopBar(title: 'Progress'),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatsRow(),
                    SizedBox(height: AppSpacing.lg),
                    _ScoreTrendChart(),
                    SizedBox(height: AppSpacing.lg),
                    _BeforeAfterSection(),
                    SizedBox(height: AppSpacing.lg),
                    _ProgressTimeline(),
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

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Row(
        children: [
          _StatCard(label: 'Streak', value: '12', icon: Icons.local_fire_department, color: AppColors.warning),
          const SizedBox(width: 10),
          _StatCard(label: 'Entries', value: '48', icon: Icons.assignment_outlined, color: AppColors.sageGreen),
          const SizedBox(width: 10),
          _StatCard(label: 'Improvement', value: '+15%', icon: Icons.trending_up, color: AppColors.matteGold),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: AppTypography.cardTitle.copyWith(fontSize: 18, color: AppColors.softCharcoal)),
            Text(label, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _ScoreTrendChart extends StatelessWidget {
  const _ScoreTrendChart();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionHeader(title: 'Skin Score Trend'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.ivoryWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['W', 'M', 'A'].map((p) {
                    final isSelected = p == 'W';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.matteGold : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(p, style: AppTypography.caption.copyWith(color: isSelected ? Colors.white : AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(color: AppColors.outlineVariant.withOpacity(0.3), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    if (value.toInt() >= 0 && value.toInt() < days.length) {
                      return Padding(padding: const EdgeInsets.only(top: 4), child: Text(days[value.toInt()], style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)));
                    }
                    return const SizedBox.shrink();
                  })),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 60), const FlSpot(1, 62), const FlSpot(2, 65),
                      const FlSpot(3, 63), const FlSpot(4, 68), const FlSpot(5, 70),
                      const FlSpot(6, 72),
                    ],
                    isCurved: true,
                    color: AppColors.matteGold,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppColors.matteGold.withOpacity(0.1)),
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

class _BeforeAfterSection extends StatelessWidget {
  const _BeforeAfterSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Before & After', subtitle: 'Your transformation journey'),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.warmNude.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Before', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.outlineVariant),
                      const SizedBox(height: 4),
                      Text('Tap to add', style: AppTypography.caption.copyWith(color: AppColors.outlineVariant)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('After', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.outlineVariant),
                      const SizedBox(height: 4),
                      Text('Tap to add', style: AppTypography.caption.copyWith(color: AppColors.outlineVariant)),
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

class _ProgressTimeline extends StatelessWidget {
  const _ProgressTimeline();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Recent Activity'),
          _TimelineEntry(date: 'Today', title: 'Morning Routine Completed', subtitle: 'Skin score updated to 72', icon: Icons.check_circle, color: AppColors.sageGreen),
          const SizedBox(height: 4),
          _TimelineEntry(date: 'Yesterday', title: 'New Product Added', subtitle: 'Vitamin C Serum logged', icon: Icons.add_circle_outline, color: AppColors.matteGold),
          const SizedBox(height: 4),
          _TimelineEntry(date: '3 days ago', title: 'Challenge Progress', subtitle: '14-Day Glow: Day 11 completed', icon: Icons.emoji_events_outlined, color: AppColors.warning),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final String date;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _TimelineEntry({required this.date, required this.title, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal)),
                Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Text(date, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
