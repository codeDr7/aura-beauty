import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoadingShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: const [
                Color(0xFFE8E4DE),
                Color(0xFFF2EFEA),
                Color(0xFFE8E4DE),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;

  const ShimmerCard({super.key, this.height = 180, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingShimmer(width: 120, height: 14, borderRadius: 4),
          SizedBox(height: 12),
          LoadingShimmer(height: 12, borderRadius: 4),
          SizedBox(height: 8),
          LoadingShimmer(width: 180, height: 12, borderRadius: 4),
          SizedBox(height: 8),
          LoadingShimmer(width: 100, height: 12, borderRadius: 4),
          Spacer(),
          LoadingShimmer(height: 40, borderRadius: 12),
        ],
      ),
    );
  }
}

class ShimmerProductGrid extends StatelessWidget {
  const ShimmerProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LoadingShimmer(width: 140, height: 140, borderRadius: 16),
              const SizedBox(height: 10),
              const LoadingShimmer(width: 120, height: 12, borderRadius: 4),
              const SizedBox(height: 4),
              const LoadingShimmer(width: 80, height: 10, borderRadius: 4),
              const SizedBox(height: 4),
              const LoadingShimmer(width: 60, height: 12, borderRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
}
