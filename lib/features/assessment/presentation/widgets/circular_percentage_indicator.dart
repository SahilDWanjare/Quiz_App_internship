import 'package:flutter/material.dart';
import 'dart:math' as math;

// --- Professional Palette ---
class AppColors {
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color accentTeal = Color(0xFF1B9AAA);
  static const Color silverBorder = Color(0xFFDDE1E6);
  static const Color gold = Color(0xFFD4AF37);
  static const Color success = Color(0xFF4CAF50);
}

class CircularPercentageIndicator extends StatefulWidget {
  final double percentage;
  final double size;
  final bool animate;
  final Duration animationDuration;
  final Color?  progressColor;
  final Color?  backgroundColor;
  final double strokeWidth;

  const CircularPercentageIndicator({
    Key? key,
    required this.percentage,
    this.size = 120,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds:  1500),
    this.progressColor,
    this.backgroundColor,
    this.strokeWidth = 8,
  }) : super(key: key);

  @override
  State<CircularPercentageIndicator> createState() =>
      _CircularPercentageIndicatorState();
}

class _CircularPercentageIndicatorState
    extends State<CircularPercentageIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:  widget.animationDuration,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.percentage,
    ).animate(CurvedAnimation(
      parent:  _controller,
      curve:  Curves.easeOutCubic,
    ));

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CircularPercentageIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percentage,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getProgressColor(double percentage) {
    if (widget.progressColor != null) return widget.progressColor!;

    if (percentage >= 90) {
      return AppColors.success;
    } else if (percentage >= 70) {
      return AppColors.gold;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentPercentage = _animation.value;
        final progressColor = _getProgressColor(currentPercentage);

        return Container(
          width:  widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color:  Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:  Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CustomPaint(
            painter: CircularPercentagePainter(
              percentage: currentPercentage,
              progressColor: progressColor,
              backgroundColor: widget.backgroundColor ?? AppColors.silverBorder,
              strokeWidth:  widget.strokeWidth,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${currentPercentage.toStringAsFixed(currentPercentage == currentPercentage.roundToDouble() ? 0 : 1)}%',
                    style: TextStyle(
                      fontSize: widget.size * 0.22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  Text(
                    'SCORE',
                    style: TextStyle(
                      fontSize: widget. size * 0.08,
                      fontWeight: FontWeight.w600,
                      color: AppColors.silverBorder,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CircularPercentagePainter extends CustomPainter {
  final double percentage;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  CircularPercentagePainter({
    required this.percentage,
    required this.progressColor,
    required this.backgroundColor,
    this.strokeWidth = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (strokeWidth + 4);

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * (percentage / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularPercentagePainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.progressColor != progressColor;
  }
}