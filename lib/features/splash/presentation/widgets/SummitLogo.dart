import 'package:flutter/material.dart';

class SummitLogo extends StatelessWidget {
  final double size;

  const SummitLogo({
    Key? key,
    this.size = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size * 1.5,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Left Mountain (Blue)
              Positioned(
                left: 0,
                bottom: 0,
                child: CustomPaint(
                  size: Size(size * 0.8, size * 0.6),
                  painter: MountainPainter(
                    color: const Color(0xFF5B7FE8),
                  ),
                ),
              ),
              // Center Mountain (Light Blue)
              Positioned(
                left: size * 0.35,
                bottom: 0,
                child: CustomPaint(
                  size: Size(size * 0.85, size * 0.7),
                  painter: MountainPainter(
                    color: const Color(0xFF4A90E2),
                  ),
                ),
              ),
              // Right Mountain (Green)
              Positioned(
                right: 0,
                bottom: 0,
                child: CustomPaint(
                  size: Size(size * 0.9, size * 0.65),
                  painter: MountainPainter(
                    color: const Color(0xFF50C878),
                  ),
                ),
              ),
              // Trees
              Positioned(
                top: 0,
                left: size * 0.2,
                child: _buildTree(size * 0.15, const Color(0xFF5B7FE8)),
              ),
              Positioned(
                top: -5,
                left: size * 0.45,
                child: _buildTree(size * 0.18, const Color(0xFF4A90E2)),
              ),
              Positioned(
                top: 2,
                right: size * 0.35,
                child: _buildTree(size * 0.16, const Color(0xFF50C878)),
              ),
            ],
          ),
        ),
        SizedBox(height: size * 0.2),
        Text(
          'ID Aspire',
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0D121F),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTree(double height, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.arrow_drop_up,
          color: color,
          size: height * 0.6,
        ),
        Transform.translate(
          offset: Offset(0, -height * 0.15),
          child: Icon(
            Icons.arrow_drop_up,
            color: color,
            size: height * 0.5,
          ),
        ),
      ],
    );
  }
}

class MountainPainter extends CustomPainter {
  final Color color;

  MountainPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.5, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}