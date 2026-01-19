import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularPercentageIndicator extends StatelessWidget {
  final double percentage;
  final double size;

  const CircularPercentageIndicator({
    Key? key,
    required this.percentage,
    this.size = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CircularPercentagePainter(
          percentage: percentage,
          progressColor: const Color(0xFFD4AF37),
          backgroundColor: Colors.grey.shade200,
        ),
        child: Center(
          child: Text(
            '${percentage.toStringAsFixed(percentage == percentage.roundToDouble() ? 0 : 1)}%',
            style: TextStyle(
              fontSize: size * 0.2,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D121F),
            ),
          ),
        ),
      ),
    );
  }
}

class CircularPercentagePainter extends CustomPainter {
  final double percentage;
  final Color progressColor;
  final Color backgroundColor;

  CircularPercentagePainter({
    required this.percentage,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 8;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
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
    return oldDelegate.percentage != percentage;
  }
}