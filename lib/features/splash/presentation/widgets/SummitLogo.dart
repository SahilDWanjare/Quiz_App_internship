import 'package:flutter/material.dart';

class SummitLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;

  const SummitLogo({
    Key? key,
    this.size = 100,
    this.showText = false,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Image Container
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            // shape: BoxShape. ,
            color: Colors. white,
            boxShadow: [
              // BoxShadow(
              //   color:  Colors.black.withOpacity(0.1),
              //   blurRadius: 20,
              //   offset: const Offset(0, 10),
              // ),
            ],
          ),
          child: Container(
            child: Image.asset(
              'assets/images/main_app_logo.jpg',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image fails to load
                return _buildFallbackLogo();
              },
            ),
          ),
        ),

        // Optional Text Below Logo
        if (showText) ...[
          SizedBox(height: size * 0.15),
          Text(
            'Summit',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              color: textColor ?? const Color(0xFF0D1B2A),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  // Fallback logo if image fails to load
  Widget _buildFallbackLogo() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape:  BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1B9AAA),
            Color(0xFF0D1B2A),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.landscape_rounded,
          size: size * 0.5,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Alternative Logo with Mountains Design
class SummitLogoWithMountains extends StatelessWidget {
  final double size;
  final bool showText;

  const SummitLogoWithMountains({
    Key?  key,
    this.size = 100,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize. min,
      children: [
        // Mountain Logo
        SizedBox(
          width: size * 1.5,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Left Mountain
              Positioned(
                left: 0,
                bottom: 0,
                child:  CustomPaint(
                  size: Size(size * 0.8, size * 0.6),
                  painter: MountainPainter(color: const Color(0xFF5B7FE8)),
                ),
              ),
              // Center Mountain
              Positioned(
                left: size * 0.35,
                bottom: 0,
                child: CustomPaint(
                  size: Size(size * 0.85, size * 0.7),
                  painter: MountainPainter(color: const Color(0xFF4A90E2)),
                ),
              ),
              // Right Mountain
              Positioned(
                right: 0,
                bottom: 0,
                child: CustomPaint(
                  size: Size(size * 0.9, size * 0.65),
                  painter: MountainPainter(color: const Color(0xFF50C878)),
                ),
              ),
              // Trees
              Positioned(
                top: 0,
                left:  size * 0.2,
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

        // Text
        if (showText) ...[
          SizedBox(height:  size * 0.2),
          Text(
            'ID Aspire',
            style: TextStyle(
              fontSize: size * 0.28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTree(double height, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.arrow_drop_up,
          color:  color,
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

// Circular Logo with Border
class SummitCircularLogo extends StatelessWidget {
  final double size;
  final Color borderColor;
  final double borderWidth;

  const SummitCircularLogo({
    Key?  key,
    this.size = 100,
    this.borderColor = const Color(0xFFD4AF37),
    this.borderWidth = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width:  borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.3),
            blurRadius:  15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/main_app_logo.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF0D1B2A),
              child: Center(
                child: Text(
                  'S',
                  style: TextStyle(
                    fontSize: size * 0.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Mountain Painter
class MountainPainter extends CustomPainter {
  final Color color;

  MountainPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle. fill;

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