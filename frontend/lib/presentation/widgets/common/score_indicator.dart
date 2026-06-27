import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ScoreIndicator extends StatefulWidget {
  final double score;
  final String label;
  final double size;
  final double strokeWidth;

  const ScoreIndicator({
    super.key,
    required this.score,
    required this.label,
    this.size = 120,
    this.strokeWidth = 8,
  });

  @override
  State<ScoreIndicator> createState() => _ScoreIndicatorState();
}

class _ScoreIndicatorState extends State<ScoreIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(ScoreIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _scoreColor {
    if (widget.score >= 85) return AppColors.matteGold;
    if (widget.score >= 70) return AppColors.sageGreen;
    if (widget.score >= 40) return AppColors.warning;
    return AppColors.error;
  }

  List<Color> get _gradientColors {
    if (widget.score >= 85) return [AppColors.matteGold, const Color(0xFFD4B896)];
    if (widget.score >= 70) return [AppColors.sageGreen, const Color(0xFFC4CEB8)];
    if (widget.score >= 40) return [AppColors.warning, const Color(0xFFFFCC80)];
    return [AppColors.error, const Color(0xFFEF9A9A)];
  }

  @override
  Widget build(BuildContext context) {
    final clampedScore = widget.score.clamp(0, 100);
    final radius = widget.size / 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            listenable: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: _ScorePainter(
                  progress: _animation.value,
                  score: clampedScore,
                  scoreColor: _scoreColor,
                  gradientColors: _gradientColors,
                  strokeWidth: widget.strokeWidth,
                  radius: radius,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        listenable: _animation,
                        builder: (context, child) {
                          final displayScore = (clampedScore * _animation.value).round();
                          return Text(
                            '$displayScore',
                            style: AppTypography.heroTitleMobile.copyWith(
                              color: _scoreColor,
                              fontSize: widget.size * 0.3,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

class _ScorePainter extends CustomPainter {
  final double progress;
  final double score;
  final Color scoreColor;
  final List<Color> gradientColors;
  final double strokeWidth;
  final double radius;

  _ScorePainter({
    required this.progress,
    required this.score,
    required this.scoreColor,
    required this.gradientColors,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final bgPaint = Paint()
      ..color = AppColors.outlineVariant.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final sweepAngle = (score / 100) * 2 * pi * progress;

    final gradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: -pi / 2 + sweepAngle,
      colors: gradientColors,
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ScorePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.score != score;
  }
}
