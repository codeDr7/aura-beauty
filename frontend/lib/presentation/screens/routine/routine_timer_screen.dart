import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/aura_button.dart';

class RoutineTimerScreen extends ConsumerStatefulWidget {
  final String routineId;
  final List<RoutineStep>? steps;

  const RoutineTimerScreen({
    super.key,
    this.routineId = '',
    this.steps,
  });

  @override
  ConsumerState<RoutineTimerScreen> createState() => _RoutineTimerScreenState();
}

class _RoutineTimerScreenState extends ConsumerState<RoutineTimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  Timer? _timer;

  int _currentStep = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isComplete = false;
  bool _showSummary = false;
  bool _showAward = false;

  final List<StepTiming> _stepTimings = [];

  List<RoutineStep> get _steps => widget.steps ?? _defaultSteps;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _timerController, curve: Curves.easeInOut),
    );
    _resetForStep(0);
  }

  void _resetForStep(int index) {
    _currentStep = index;
    _remainingSeconds = _steps[index].durationSeconds;
    _isRunning = false;
    _isPaused = false;
    _progressController.value = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isPaused) {
      setState(() => _isPaused = false);
    } else {
      _stepTimings.add(StepTiming(stepName: _steps[_currentStep].title));
    }
    setState(() => _isRunning = true);
    _timerController.repeat(reverse: true);
    _progressController.forward(from: _progressController.value);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _stepTimings.last.elapsed++;
          _progressController.value =
              (_steps[_currentStep].durationSeconds - _remainingSeconds) /
                  _steps[_currentStep].durationSeconds;
        } else {
          timer.cancel();
          _timerController.stop();
          _isRunning = false;
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timerController.stop();
    setState(() => _isPaused = true);
  }

  void _completeStep() {
    _stepTimings.last.completed = true;
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        _resetForStep(_currentStep);
      });
    } else {
      setState(() {
        _showSummary = true;
        _isComplete = true;
      });
      _triggerAward();
    }
  }

  void _triggerAward() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showAward = true);
    });
  }

  String get _formattedTime {
    final min = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  double get _timerProgress {
    if (_steps.isEmpty) return 0;
    return (_steps[_currentStep].durationSeconds - _remainingSeconds) /
        _steps[_currentStep].durationSeconds;
  }

  void _goNext() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        _resetForStep(_currentStep);
      });
    } else {
      _completeStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSummary) return _buildSummaryScreen();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.softCharcoal, Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _buildTimerContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _timer?.cancel();
              context.pop();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
            ),
          ),
          const Spacer(),
          Text(
            '${_currentStep + 1} of ${_steps.length}',
            style: AppTypography.bodySmall.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerContent() {
    return Column(
      children: [
        _buildStepProgress(),
        const SizedBox(height: 24),
        Expanded(
          child: _buildCircularTimer(),
        ),
        _buildStepInfo(),
        const SizedBox(height: 24),
        _buildControls(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStepProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Row(
        children: List.generate(_steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = _stepTimings.length > i && _stepTimings[i].completed;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isDone
                    ? AppColors.matteGold
                    : isActive
                        ? AppColors.matteGold.withOpacity(0.5)
                        : Colors.white.withOpacity(0.1),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCircularTimer() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isRunning ? _pulseAnimation.value : 1.0,
          child: Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(280, 280),
                    painter: _TimerPainter(
                      progress: _timerProgress,
                      isRunning: _isRunning,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.matteGold, Color(0xFFFFD700)],
                        ).createShader(bounds),
                        child: Text(
                          _formattedTime,
                          style: AppTypography.heroTitle.copyWith(
                            fontSize: 56,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isComplete ? 'Complete!' : _isPaused ? 'Paused' : _isRunning ? '' : '',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.matteGold.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            _steps[_currentStep].title,
            style: AppTypography.sectionTitle.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (_steps[_currentStep].description != null) ...[
            Text(
              _steps[_currentStep].description!,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (_steps[_currentStep].product != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.matteGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.matteGold.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.spa_outlined, size: 16, color: AppColors.matteGold),
                  const SizedBox(width: 6),
                  Text(
                    _steps[_currentStep].product!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.matteGold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          if (_isRunning || _isPaused)
            Expanded(
              child: AuraButton(
                label: _isPaused ? 'Resume' : 'Pause',
                isSecondary: true,
                onPressed: _isPaused ? _startTimer : _pauseTimer,
              ),
            ),
          if (!_isRunning && !_isPaused && !_isComplete) ...[
            Expanded(
              child: AuraButton(
                label: 'Start',
                onPressed: _startTimer,
                trailingIcon: Icons.play_arrow_rounded,
              ),
            ),
          ],
          if (_remainingSeconds <= 0 && (_isRunning || _isComplete)) ...[
            const SizedBox(width: 12),
            Expanded(
              child: AuraButton(
                label: _currentStep < _steps.length - 1 ? 'Next Step' : 'Finish',
                onPressed: _goNext,
                trailingIcon: Icons.arrow_forward_rounded,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.softCharcoal, Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_showAward) _buildAwardAnimation(),
                  const SizedBox(height: 24),
                  Text(
                    'Routine Complete!',
                    style: AppTypography.sectionTitle.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You completed ${_steps.length} steps',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white60),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Step Timing',
                          style: AppTypography.cardTitle.copyWith(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(_stepTimings.length, (i) {
                          final st = _stepTimings[i];
                          final min = (st.elapsed ~/ 60).toString().padLeft(2, '0');
                          final sec = (st.elapsed % 60).toString().padLeft(2, '0');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.matteGold.withOpacity(0.15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.matteGold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    st.stepName,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$min:$sec',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.matteGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuraButton(
                    label: 'Back to Routine',
                    onPressed: () => context.pop(),
                    trailingIcon: Icons.check_rounded,
                  ),
                  const SizedBox(height: 16),
                  AuraButton(
                    label: 'Repeat Routine',
                    isSecondary: true,
                    onPressed: () {
                      setState(() {
                        _showSummary = false;
                        _showAward = false;
                        _isComplete = false;
                        _currentStep = 0;
                        _stepTimings.clear();
                        _resetForStep(0);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAwardAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.matteGold, Color(0xFFFFD700)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.matteGold.withOpacity(0.4 * value),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, color: Colors.white, size: 40),
                SizedBox(height: 4),
                Text('+25 XP', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Manrope')),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RoutineStep {
  final String title;
  final String? description;
  final String? product;
  final int durationSeconds;

  const RoutineStep({
    required this.title,
    this.description,
    this.product,
    required this.durationSeconds,
  });
}

class StepTiming {
  final String stepName;
  int elapsed;
  bool completed;

  StepTiming({required this.stepName, this.elapsed = 0, this.completed = false});
}

const _defaultSteps = [
  RoutineStep(
    title: 'Cleanse',
    description: 'Apply cleanser with gentle circular motions',
    product: 'Gentle Foaming Cleanser',
    durationSeconds: 60,
  ),
  RoutineStep(
    title: 'Tone',
    description: 'Apply toner with cotton pad or hands',
    product: 'Hydrating Toner',
    durationSeconds: 30,
  ),
  RoutineStep(
    title: 'Serum',
    description: 'Gently press serum into skin',
    product: 'Vitamin C Brightening Serum',
    durationSeconds: 60,
  ),
  RoutineStep(
    title: 'Moisturize',
    description: 'Massage moisturizer upward',
    product: 'Daily Moisture Cream',
    durationSeconds: 60,
  ),
  RoutineStep(
    title: 'Sunscreen',
    description: 'Apply evenly to face and neck',
    product: 'SPF 50 PA+++',
    durationSeconds: 60,
  ),
];

class _TimerPainter extends CustomPainter {
  final double progress;
  final bool isRunning;

  _TimerPainter({required this.progress, required this.isRunning});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawCircle(center, radius - 28, bgPaint);

    final ghostPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.matteGold.withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 14, ghostPaint);

    final grad = SweepGradient(
      startAngle: -pi / 2,
      endAngle: -pi / 2 + 2 * pi * progress,
      colors: const [AppColors.matteGold, Color(0xFFFFD700)],
    );

    final progressPaint = Paint()
      ..shader = grad.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 28),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );

    if (progress > 0) {
      final dotAngle = -pi / 2 + 2 * pi * progress;
      final dotX = center.dx + (radius) * cos(dotAngle);
      final dotY = center.dy + (radius) * sin(dotAngle);

      final dotPaint = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), 6, dotPaint);

      final glowPaint = Paint()
        ..color = AppColors.matteGold.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(dotX, dotY), 10, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_TimerPainter old) => old.progress != progress || old.isRunning != isRunning;
}
