import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app_project/features/splash/presentation/pages/SignInScreen.dart';
import 'home_screen_full.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Check if user is already signed in
        final user = FirebaseAuth.instance.currentUser;

        Widget nextScreen;
        if (user != null) {
          // User is signed in, go to home
          nextScreen = const HomeScreen();
        } else {
          // User not signed in, go to sign in
          nextScreen = const SignInScreen();
        }

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Mountains Logo
            Stack(
              alignment: Alignment.center,
              children: [
                // Left Mountain (Blue)
                SlideInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 200),
                  child: _buildMountain(
                    width: 120,
                    height: 90,
                    color: const Color(0xFF5B7FE8),
                    isLeft: true,
                  ),
                ),
                // Center Mountain (Light Blue)
                SlideInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 400),
                  child: _buildMountain(
                    width: 130,
                    height: 100,
                    color: const Color(0xFF4A90E2),
                    isCenter: true,
                  ),
                ),
                // Right Mountain (Green)
                SlideInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 600),
                  child: _buildMountain(
                    width: 140,
                    height: 95,
                    color: const Color(0xFF50C878),
                    isRight: true,
                  ),
                ),
                // Trees
                Positioned(
                  top: -20,
                  left: -30,
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 800),
                    child: _buildTree(
                      height: 25,
                      color: const Color(0xFF5B7FE8),
                    ),
                  ),
                ),
                Positioned(
                  top: -30,
                  left: 5,
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 1000),
                    child: _buildTree(
                      height: 30,
                      color: const Color(0xFF4A90E2),
                    ),
                  ),
                ),
                Positioned(
                  top: -25,
                  right: -10,
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 1200),
                    child: _buildTree(
                      height: 28,
                      color: const Color(0xFF50C878),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Animated Summit Text
            FadeIn(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 1400),
              child: const Text(
                'ID Aspire',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D121F),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FadeIn(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 1600),
              child: const Text(
                'Lets test your knowledge and know\nyour potential',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9E9E9E),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMountain({
    required double width,
    required double height,
    required Color color,
    bool isLeft = false,
    bool isCenter = false,
    bool isRight = false,
  }) {
    return CustomPaint(
      size: Size(width, height),
      painter: MountainPainter(
        color: color,
        isLeft: isLeft,
        isCenter: isCenter,
        isRight: isRight,
      ),
    );
  }

  Widget _buildTree({
    required double height,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          Icons.arrow_drop_up,
          color: color,
          size: height * 0.6,
        ),
        Icon(
          Icons.arrow_drop_up,
          color: color,
          size: height * 0.5,
        ),
      ],
    );
  }
}

class MountainPainter extends CustomPainter {
  final Color color;
  final bool isLeft;
  final bool isCenter;
  final bool isRight;

  MountainPainter({
    required this.color,
    this.isLeft = false,
    this.isCenter = false,
    this.isRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(size.width * 0.5, 0);
      path.lineTo(size.width, size.height);
    } else if (isCenter) {
      path.moveTo(0, size.height);
      path.lineTo(size.width * 0.5, 0);
      path.lineTo(size.width, size.height);
    } else if (isRight) {
      path.moveTo(0, size.height);
      path.lineTo(size.width * 0.5, 0);
      path.lineTo(size.width, size.height);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}