import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_gradients.dart';
import '../../widgets/common/aura_button.dart';
import '../../widgets/common/aura_card.dart';
import '../../widgets/common/score_indicator.dart';
import '../../widgets/common/section_header.dart';

class SkinAnalysisScreen extends ConsumerStatefulWidget {
  const SkinAnalysisScreen({super.key});

  @override
  ConsumerState<SkinAnalysisScreen> createState() => _SkinAnalysisScreenState();
}

class _SkinAnalysisScreenState extends ConsumerState<SkinAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;
  bool _isScanning = false;
  bool _showResults = false;
  bool _showHistory = false;

  final _metrics = [
    _SkinMetric(label: 'Hydration', score: 78, icon: Icons.water_drop),
    _SkinMetric(label: 'Pores', score: 65, icon: Icons.blur_on),
    _SkinMetric(label: 'Texture', score: 82, icon: Icons.grain),
    _SkinMetric(label: 'Pigmentation', score: 58, icon: Icons.palette_outlined),
    _SkinMetric(label: 'Redness', score: 71, icon: Icons.thermostat_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _scanAnimation = CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  void _startAnalysis() {
    setState(() {
      _isScanning = true;
      _showResults = false;
    });
    _scanController.forward(from: 0);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _showResults = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showHistory) return _buildHistoryScreen();

    return Scaffold(
      body: SafeArea(
        child: _showResults
            ? _buildResultsScreen()
            : _buildCameraPreview(),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Column(
      children: [
        _buildHeader(isResults: false),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2B2B2B),
                      Color(0xFF1A1A1A),
                      Color(0xFF0D0D0D),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.matteGold.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.matteGold.withOpacity(0.05),
                              Colors.transparent,
                              AppColors.matteGold.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                      if (_isScanning)
                        _buildScanAnimation()
                      else
                        _buildIdleState(),
                      _buildFaceOverlay(),
                    ],
                  ),
                ),
              ),
              if (!_isScanning) _buildStartButton(),
            ],
          ),
        ),
        if (!_isScanning) ...[
          const SizedBox(height: 16),
          _buildScanInfo(),
        ],
      ],
    );
  }

  Widget _buildIdleState() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [
                  AppColors.matteGold,
                  AppColors.warmNude,
                  Colors.transparent,
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
            child: const Center(
              child: Icon(Icons.face_retouching_natural, size: 48, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScanAnimation() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 400),
          painter: _ScanRingPainter(progress: _scanAnimation.value),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.matteGold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Analyzing...',
                  style: TextStyle(
                    color: AppColors.matteGold,
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFaceOverlay() {
    return CustomPaint(
      size: const Size(300, 400),
      painter: _FaceOvalPainter(),
    );
  }

  Widget _buildStartButton() {
    return Positioned(
      bottom: 40,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.goldenButton,
              boxShadow: [
                BoxShadow(
                  color: AppColors.matteGold.withOpacity(0.4 * _pulseAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              onPressed: _startAnalysis,
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScanInfo() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        children: [
          Text(
            'Start Analysis',
            style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal),
          ),
          const SizedBox(height: 4),
          Text(
            'Position your face in the center oval',
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({required bool isResults}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isResults
                    ? AppColors.warmNude.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: isResults ? AppColors.softCharcoal : Colors.white70,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          if (_showResults)
            GestureDetector(
              onTap: () => setState(() => _showHistory = true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.matteGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history, size: 14, color: AppColors.matteGold),
                    const SizedBox(width: 4),
                    Text('History', style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    final overallScore = (_metrics.map((m) => m.score).reduce((a, b) => a + b) / _metrics.length).round();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isResults: true),
              const SizedBox(height: 16),
              Center(
                child: ScoreIndicator(
                  score: overallScore.toDouble(),
                  label: 'Overall Skin Score',
                  size: 140,
                  strokeWidth: 10,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildMetricsSection(),
              const SizedBox(height: AppSpacing.md),
              _buildSummaryCard(overallScore),
              const SizedBox(height: AppSpacing.md),
              _buildRecommendations(),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: AppSpacing.horizontalPadding,
                child: AuraButton(
                  label: 'New Analysis',
                  isSecondary: true,
                  onPressed: () => setState(() {
                    _showResults = false;
                    _isScanning = false;
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsSection() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Skin Metrics'),
          ...List.generate(_metrics.length, (i) {
            final metric = _metrics[i];
            return Padding(
              padding: EdgeInsets.only(bottom: i < _metrics.length - 1 ? 10 : 0),
              child: Container(
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
                        color: AppColors.matteGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(metric.icon, size: 20, color: AppColors.matteGold),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(metric.label, style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.softCharcoal,
                          )),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: metric.score / 100,
                              backgroundColor: AppColors.outlineVariant.withOpacity(0.5),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                metric.score >= 75
                                    ? AppColors.sageGreen
                                    : metric.score >= 50
                                        ? AppColors.matteGold
                                        : AppColors.warning,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${metric.score}',
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 18,
                        color: metric.score >= 75
                            ? AppColors.sageGreen
                            : metric.score >= 50
                                ? AppColors.matteGold
                                : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int overallScore) {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppGradients.auraGold,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Analysis Summary',
                  style: AppTypography.cardTitle.copyWith(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              overallScore >= 75
                  ? 'Your skin is in great condition! Keep up your routine with focus on sun protection and hydration.'
                  : overallScore >= 50
                      ? 'Your skin shows good baseline health. Focus on hydration and consider adding targeted treatments for pigmentation and texture.'
                      : 'Your skin needs some extra care. We recommend a gentle barrier-repair routine and consulting with a dermatologist.',
              style: AppTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.9)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Recommendations'),
          _RecommendationChip(
            icon: Icons.water_drop,
            label: 'Increase hydration with HA serum',
            color: AppColors.sageGreen,
          ),
          const SizedBox(height: 6),
          _RecommendationChip(
            icon: Icons.wb_sunny,
            label: 'Use SPF 50+ daily',
            color: AppColors.matteGold,
          ),
          const SizedBox(height: 6),
          _RecommendationChip(
            icon: Icons.blur_on,
            label: 'Add niacinamide for pore care',
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryScreen() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showHistory = false),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.warmNude.withOpacity(0.3),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: AppColors.softCharcoal, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Analysis History', style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: AppSpacing.horizontalPadding,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _HistoryEntry(date: 'Jun 20, 2026', score: 71, metrics: _metrics),
                    const SizedBox(height: 8),
                    _HistoryEntry(date: 'Jun 13, 2026', score: 68, metrics: [
                      _SkinMetric(label: 'Hydration', score: 72, icon: Icons.water_drop),
                      _SkinMetric(label: 'Pores', score: 60, icon: Icons.blur_on),
                      _SkinMetric(label: 'Texture', score: 75, icon: Icons.grain),
                      _SkinMetric(label: 'Pigmentation', score: 62, icon: Icons.palette_outlined),
                      _SkinMetric(label: 'Redness', score: 69, icon: Icons.thermostat_outlined),
                    ]),
                    const SizedBox(height: 8),
                    _HistoryEntry(date: 'Jun 6, 2026', score: 64, metrics: [
                      _SkinMetric(label: 'Hydration', score: 65, icon: Icons.water_drop),
                      _SkinMetric(label: 'Pores', score: 55, icon: Icons.blur_on),
                      _SkinMetric(label: 'Texture', score: 70, icon: Icons.grain),
                      _SkinMetric(label: 'Pigmentation', score: 58, icon: Icons.palette_outlined),
                      _SkinMetric(label: 'Redness', score: 72, icon: Icons.thermostat_outlined),
                    ]),
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

class _SkinMetric {
  final String label;
  final int score;
  final IconData icon;

  const _SkinMetric({
    required this.label,
    required this.score,
    required this.icon,
  });
}

class _ScanRingPainter extends CustomPainter {
  final double progress;

  _ScanRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringPaint = Paint()
      ..color = AppColors.matteGold.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, 100, ringPaint);
    canvas.drawCircle(center, 80, ringPaint);

    final dotPaint = Paint()..color = AppColors.matteGold;
    final angle = 2 * pi * progress;
    for (int i = 0; i < 12; i++) {
      final dotAngle = angle + (i * pi / 6);
      final dx = center.dx + 100 * cos(dotAngle);
      final dy = center.dy + 100 * sin(dotAngle);
      final alpha = ((sin(angle * 2 - i * 0.5) + 1) / 2 * 255).toInt();
      dotPaint.color = AppColors.matteGold.withAlpha(alpha.clamp(50, 255));
      canvas.drawCircle(Offset(dx, dy), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ScanRingPainter old) => old.progress != progress;
}

class _FaceOvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ovalRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.65,
      height: size.height * 0.55,
    );

    final paint = Paint()
      ..color = AppColors.matteGold.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawOval(ovalRect, paint);

    final glowPaint = Paint()
      ..color = AppColors.matteGold.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    canvas.drawOval(ovalRect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecommendationChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _RecommendationChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.softCharcoal)),
          ),
        ],
      ),
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  final String date;
  final int score;
  final List<_SkinMetric> metrics;

  const _HistoryEntry({
    required this.date,
    required this.score,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          ScoreIndicator(
            score: score.toDouble(),
            label: '',
            size: 60,
            strokeWidth: 4,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.softCharcoal,
                )),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: metrics.map((m) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.matteGold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('${m.label} ${m.score}', style: AppTypography.caption.copyWith(
                      color: AppColors.matteGold,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    )),
                  )).toList(),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
        ],
      ),
    );
  }
}
