import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'package:test_app_project/features/splash/presentation/pages/SignInScreen.dart';
import 'home_screen_full.dart';

// --- Professional Palette ---
class AppColors {
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color accentTeal = Color(0xFF1B9AAA);
  static const Color gold = Color(0xFFD4AF37);
  static const Color gradientStart = Color(0xFF1B9AAA);
  static const Color gradientEnd = Color(0xFF0D1B2A);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _logoScaleController;
  late AnimationController _logoRotateController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;
  late AnimationController _bounceController;
  late AnimationController _rippleController;

  // Animations
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rippleAnimation;

  // Particle positions
  final List<_Particle> _particles = [];
  final int _particleCount = 25;

  @override
  void initState() {
    super.initState();
    _initializeParticles();
    _setupAnimations();
    _startAnimationSequence();
    _navigateToNextScreen();
  }

  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(_Particle(
        x:  random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 4 + 2,
        speed: random.nextDouble() * 0.5 + 0.2,
        opacity: random.nextDouble() * 0.5 + 0.2,
      ));
    }
  }

  void _setupAnimations() {
    // Logo Scale Animation (bounce in effect)
    _logoScaleController = AnimationController(
      vsync: this,
      duration:  const Duration(milliseconds: 1200),
    );

    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween:  Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves. easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin:  1.2, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_logoScaleController);

    // Logo Rotate Animation (subtle 3D effect)
    _logoRotateController = AnimationController(
      vsync: this,
      duration:  const Duration(milliseconds: 1800),
    );

    _logoRotateAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: math.pi * 2)
            .chain(CurveTween(curve: Curves.easeInOutBack)),
        weight: 100,
      ),
    ]).animate(_logoRotateController);

    // Pulse Animation (breathing effect)
    _pulseController = AnimationController(
      vsync: this,
      duration:  const Duration(milliseconds: 1500),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin:  1.0, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 50),
    ]).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves. easeInOut));

    // Glow Animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween:  Tween(begin: 0.3, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 50),
    ]).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    // Text Animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _textController, curve: Curves. easeOutCubic));

    // Particle Animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    // Shimmer Animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds:  2000),
    );

    _shimmerAnimation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Bounce Animation (for floating effect)
    _bounceController = AnimationController(
      vsync: this,
      duration:  const Duration(milliseconds: 1200),
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween:  Tween(begin: 0, end: -10), weight: 50),
      TweenSequenceItem(tween: Tween(begin:  -10, end: 0), weight: 50),
    ]).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));

    // Ripple Animation
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _rippleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  void _startAnimationSequence() async {
    // Start particle animation immediately
    _particleController.repeat();

    // Start logo scale animation
    await Future.delayed(const Duration(milliseconds: 200));
    _logoScaleController.forward();

    // Start rotate animation
    await Future.delayed(const Duration(milliseconds: 150));
    _logoRotateController.forward();

    // Start ripple effect
    await Future.delayed(const Duration(milliseconds: 400));
    _rippleController. repeat();

    // Start glow animation
    await Future.delayed(const Duration(milliseconds: 600));
    _glowController. repeat();

    // Start text animation
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();

    // Start pulse and bounce after main animations
    await Future.delayed(const Duration(milliseconds: 400));
    _pulseController. repeat();
    _bounceController. repeat();
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _logoScaleController.dispose();
    _logoRotateController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    _bounceController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    // Changed to 2.5 seconds as requested
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;

        Widget nextScreen;
        if (user != null) {
          nextScreen = const HomeScreen();
        } else {
          nextScreen = const SignInScreen();
        }

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve:  Curves.easeOut,
                ),
                child:  SlideTransition(
                  position:  Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve:  Curves.easeOutCubic,
                  )),
                  child: child,
                ),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin:  Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientStart.withOpacity(0.08),
              Colors.white,
              Colors.grey.shade50,
              Colors.white,
              AppColors.gradientEnd.withOpacity(0.05),
            ],
            stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles background
            _buildParticlesBackground(),

            // Gradient orbs
            _buildGradientOrbs(),

            // Ripple effects behind logo
            _buildRippleEffects(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo - FULL IMAGE VISIBLE
                  _buildAnimatedLogo(),

                  const SizedBox(height: 30),

                  // Animated Text
                  _buildAnimatedText(),

                  const SizedBox(height: 50),

                  // Loading indicator
                  _buildLoadingIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticlesBackground() {
    return AnimatedBuilder(
      animation: _particleController,
      builder:  (context, child) {
        return CustomPaint(
          size: Size. infinite,
          painter: _ParticlesPainter(
            particles: _particles,
            progress: _particleController.value,
          ),
        );
      },
    );
  }

  Widget _buildGradientOrbs() {
    return Stack(
      children: [
        // Top-left orb
        Positioned(
          top: -100,
          left: -100,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors. accentTeal.withOpacity(0.15),
                        AppColors.accentTeal.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Bottom-right orb
        Positioned(
          bottom: -150,
          right: -150,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 2 - _pulseAnimation.value,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.gold.withOpacity(0.12),
                        AppColors.gold.withOpacity(0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Center glow
        Positioned. fill(
          child: AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Center(
                child: Container(
                  width: 280 * _glowAnimation.value,
                  height: 280 * _glowAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape. circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accentTeal
                            .withOpacity(0.08 * _glowAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRippleEffects() {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(3, (index) {
              final delay = index * 0.3;
              final progress =
              ((_rippleController.value + delay) % 1.0).clamp(0.0, 1.0);

              return Container(
                width: 180 + (progress * 120),
                height: 180 + (progress * 120),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.gold.withOpacity((1 - progress) * 0.4),
                    width: 2 * (1 - progress),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation:  Listenable.merge([
        _logoScaleController,
        _logoRotateController,
        _pulseController,
        _bounceController,
        _glowController,
      ]),
      builder: (context, child) {
        // Calculate 3D rotation effect
        final rotateValue = _logoRotateAnimation.value;
        const perspective = 0.001;

        return Transform. translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              .. setEntry(3, 2, perspective)
              ..rotateY(math.sin(rotateValue) * 0.08)
              ..rotateX(math.cos(rotateValue) * 0.04)
              ..scale(_logoScaleAnimation.value *
                  (_pulseController.isAnimating ? _pulseAnimation.value : 1.0)),
            child: _buildFullLogo(),
          ),
        );
      },
    );
  }

  // ============================================
  // FULL LOGO - No circular cropping
  // ============================================
  Widget _buildFullLogo() {
    const double logoWidth = 220;
    const double logoHeight = 220;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow effect
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              width: logoWidth + 60,
              height: logoHeight + 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentTeal
                        .withOpacity(0.25 * _glowAnimation.value),
                    blurRadius:  40 * _glowAnimation.value,
                    spreadRadius: 10 * _glowAnimation.value,
                  ),
                  BoxShadow(
                    color:
                    AppColors.gold.withOpacity(0.15 * _glowAnimation.value),
                    blurRadius:  50 * _glowAnimation.value,
                    spreadRadius: 5 * _glowAnimation.value,
                  ),
                ],
              ),
            );
          },
        ),

        // Logo container - FULL IMAGE with rounded corners
        Container(
          width: logoWidth,
          height:  logoHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.gold,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: AppColors.gold.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: Image.asset(
              'assets/images/main_app_logo.jpg',
              width: logoWidth,
              height:  logoHeight,
              fit: BoxFit.contain, // Changed to contain to show full logo
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackLogo(logoWidth, logoHeight);
              },
            ),
          ),
        ),

        // Shimmer overlay effect
        AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: Container(
                width: logoWidth,
                height: logoHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + _shimmerAnimation.value * 2, -1),
                    end:  Alignment(_shimmerAnimation.value * 2, 1),
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.25),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            );
          },
        ),

        // Rotating decorative ring
        AnimatedBuilder(
          animation: _logoRotateController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _logoRotateAnimation.value,
              child: Container(
                width: logoWidth + 40,
                height: logoHeight + 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: AppColors.accentTeal. withOpacity(0.25),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Corner dots
                    Positioned(
                      top: -5,
                      left: (logoWidth + 40) / 2 - 5,
                      child:  _buildGlowingDot(),
                    ),
                    Positioned(
                      bottom: -5,
                      left: (logoWidth + 40) / 2 - 5,
                      child: _buildGlowingDot(),
                    ),
                    Positioned(
                      top: (logoHeight + 40) / 2 - 5,
                      left: -5,
                      child: _buildGlowingDot(),
                    ),
                    Positioned(
                      top: (logoHeight + 40) / 2 - 5,
                      right: -5,
                      child: _buildGlowingDot(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGlowingDot() {
    return AnimatedBuilder(
      animation: _glowController,
      builder:  (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors. gold,
            boxShadow: [
              BoxShadow(
                color:  AppColors.gold.withOpacity(0.6 * _glowAnimation.value),
                blurRadius: 8 * _glowAnimation.value,
                spreadRadius: 2 * _glowAnimation.value,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFallbackLogo(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientStart,
            AppColors.gradientEnd,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ID',
              style: TextStyle(
                fontSize: width * 0.3,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            Text(
              'ASPIRE',
              style: TextStyle(
                fontSize: width * 0.12,
                fontWeight: FontWeight.w500,
                color: AppColors.gold,
                letterSpacing: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textFadeAnimation.value. clamp(0.0, 1.0),
          child: SlideTransition(
            position:  _textSlideAnimation,
            child: Column(
              children: [
                // App Name with shimmer effect
                _buildShimmerText(
                  'ID Aspire',
                  style: const TextStyle(
                    fontSize:  38,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Tagline
                AnimatedBuilder(
                  animation:  _pulseController,
                  builder:  (context, child) {
                    return Transform.scale(
                      scale: 0.98 + (_pulseAnimation.value - 1) * 0.5,
                      child: const Text(
                        'Ascend to Leadership',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentTeal,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Test your knowledge and unlock\nyour potential',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerText(String text, {required TextStyle style}) {
    return AnimatedBuilder(
      animation:  _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin:  Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                AppColors.primaryNavy,
                AppColors. accentTeal,
                AppColors.gold,
                AppColors. accentTeal,
                AppColors.primaryNavy,
              ],
              stops: [
                0.0,
                (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                _shimmerAnimation.value.clamp(0.0, 1.0),
                (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                1.0,
              ],
            ).createShader(bounds);
          },
          child: Text(
            text,
            style:  style. copyWith(color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textFadeAnimation.value.clamp(0.0, 1.0),
          child: Column(
            children: [
              // Animated progress bar
              _AnimatedProgressBar(),
              const SizedBox(height: 12),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors. grey.shade500,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Particles Painter
class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlesPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final y = (particle.y + progress * particle.speed) % 1.0;
      final x =
          particle.x + math.sin(progress * math.pi * 2 + particle.y * 10) * 0.02;

      final paint = Paint()
        ..color = AppColors.accentTeal.withOpacity(particle.opacity * 0.4)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x * size.width, y * size. height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}

// Particle data class
class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

// Animated Progress Bar
class _AnimatedProgressBar extends StatefulWidget {
  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:  const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
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
          width: 180,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              // Animated gradient bar
              Positioned(
                left: _animation.value * 90,
                child: Container(
                  width:  90,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.accentTeal,
                        AppColors.gold,
                        AppColors.accentTeal,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}