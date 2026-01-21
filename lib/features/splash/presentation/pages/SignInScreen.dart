import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/SummitLogo.dart';
import 'SignUpScreen.dart';
import 'registration_screen.dart';
import 'home_screen_full.dart';

// --- Professional Palette ---
class AppColors {
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color accentTeal = Color(0xFF1B9AAA);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color silverBorder = Color(0xFFDDE1E6);
  static const Color secondaryText = Color(0xFF6D7175);
  static const Color inputBackground = Color(0xFFF5F7FA);
  static const Color inputBorder = Color(0xFFE8EAED);
  static const Color inputText = Color(0xFF5A6169);
  static const Color labelText = Color(0xFF8A9099);
}

// Custom Page Route for Sign In -> Sign Up (Slide Right with Fade)
class SignUpPageRoute extends PageRouteBuilder {
  final Widget page;

  SignUpPageRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves. easeOutCubic,
        reverseCurve:  Curves.easeInCubic,
      );

      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end:  Offset.zero,
      ).animate(curvedAnimation);

      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve:  const Interval(0.0, 0.6, curve: Curves. easeOut),
      ));

      final scaleAnimation = Tween<double>(
        begin: 0.95,
        end:  1.0,
      ).animate(curvedAnimation);

      final secondarySlide = Tween<Offset>(
        begin:  Offset. zero,
        end: const Offset(-0.3, 0.0),
      ).animate(CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves. easeInOut,
      ));

      final secondaryFade = Tween<double>(
        begin: 1.0,
        end: 0.7,
      ).animate(secondaryAnimation);

      return SlideTransition(
        position: secondarySlide,
        child: FadeTransition(
          opacity:  secondaryFade,
          child: SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            ),
          ),
        ),
      );
    },
  );
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _keepSignedIn = false;
  bool _obscurePassword = true;
  bool _isNavigating = false; // Prevent multiple navigation attempts

  // Entry animation controller
  late AnimationController _entryController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _socialFade;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Logo animations
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve:  const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve:  const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // Form animations
    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent:  _entryController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Social section fade
    _socialFade = Tween<double>(begin:  0.0, end: 1.0).animate(
      CurvedAnimation(
        parent:  _entryController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _entryController. forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _emailController.dispose();
    _passwordController. dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignInWithEmailEvent(
          email:  _emailController.text. trim(),
          password: _passwordController. text,
        ),
      );
    }
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(SignUpPageRoute(page: const SignUpScreen()));
  }

  /// Check if user has completed registration in Firestore
  Future<bool> _checkRegistrationStatus(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('registrations')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking registration status: $e');
      return false;
    }
  }

  /// Navigate based on registration status
  Future<void> _navigateAfterAuth(AuthAuthenticated state) async {
    // Prevent multiple navigation attempts
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      // Check if user has completed registration
      final isRegistered = await _checkRegistrationStatus(state.userId);

      if (mounted) {
        if (isRegistered) {
          // User is registered, go to home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          // User not registered, go to registration
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder:  (_) => const RegistrationScreen()),
          );
        }
      }
    } catch (e) {
      print('Navigation error: $e');
      _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            _isNavigating = false; // Reset navigation flag on error
            ScaffoldMessenger. of(context).showSnackBar(
              SnackBar(
                content:  Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red. shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius. circular(10),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state is AuthAuthenticated) {
            // Navigate based on registration status
            _navigateAfterAuth(state);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // --- Clean Header Section with Logo ---
                _buildLogoHeader(),

                // --- Login Form Section ---
                FadeTransition(
                  opacity: _formFade,
                  child: SlideTransition(
                    position: _formSlide,
                    child:  Padding(
                      padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back! ',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight. bold,
                                color: AppColors.primaryNavy,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors. secondaryText,
                                  height: 1.4,
                                ),
                                children:  [
                                  const TextSpan(text: 'Access your '),
                                  TextSpan(
                                    text:  'executive dashboard',
                                    style: TextStyle(
                                      color: AppColors.accentTeal,
                                      fontWeight: FontWeight. w600,
                                    ),
                                  ),
                                  const TextSpan(text: ' and unlock insights.'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Email Field
                            _buildLightGrayTextField(
                              controller: _emailController,
                              label:  'EMAIL',
                              hint: 'Enter your email address',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            _buildLightGrayTextField(
                              controller: _passwordController,
                              label: 'PASSWORD',
                              hint: 'Enter your password',
                              prefixIcon: Icons.lock_outline_rounded,
                              isPassword: true,
                              obscureText:  _obscurePassword,
                              onToggleObscure: () {
                                setState(
                                        () => _obscurePassword = !_obscurePassword);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Remember Me & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(
                                            () => _keepSignedIn = !_keepSignedIn);
                                  },
                                  child:  Row(
                                    children: [
                                      AnimatedContainer(
                                        duration:
                                        const Duration(milliseconds:  200),
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: _keepSignedIn
                                              ? AppColors.accentTeal
                                              : Colors.transparent,
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          border: Border.all(
                                            color: _keepSignedIn
                                                ? AppColors.accentTeal
                                                : AppColors.silverBorder,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: _keepSignedIn
                                            ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Keep me signed in',
                                        style:  TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight. w500,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.accentTeal,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Sign In Button
                            BlocBuilder<AuthBloc, AuthState>(
                              builder:  (context, state) {
                                final isLoading = state is AuthLoading;
                                return _buildSignInButton(
                                  isLoading: isLoading || _isNavigating,
                                  onPressed: (isLoading || _isNavigating)
                                      ?  null
                                      : _handleSignIn,
                                );
                              },
                            ),
                            const SizedBox(height: 20),

                            // Sign Up Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                _AnimatedTextButton(
                                  text: 'Create Account',
                                  onTap: _navigateToSignUp,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // --- Social Login Section ---
                FadeTransition(
                  opacity: _socialFade,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.silverBorder,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets. symmetric(horizontal: 16),
                              child: Text(
                                'Or continue with',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors. secondaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child:  Container(
                                height: 1,
                                color:  AppColors.silverBorder,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialLoginButton(
                            icon: const GoogleIcon(size: 22),
                            label: 'Google',
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add(SignInWithGoogleEvent());
                            },
                          ),
                          const SizedBox(width: 16),
                          _SocialLoginButton(
                            icon:  const FacebookIcon(size: 22),
                            label: 'Facebook',
                            onPressed: () {
                              context
                                  . read<AuthBloc>()
                                  .add(SignInWithFacebookEvent());
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Clean Logo Header with SummitLogo
  Widget _buildLogoHeader() {
    return FadeTransition(
      opacity: _logoFade,
      child: ScaleTransition(
        scale: _logoScale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              // Summit Logo (Mountain style)
              SummitLogo(),
              SizedBox(height:  16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLightGrayTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    TextInputType?  keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight. w600,
            color: AppColors. labelText,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.inputText,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: AppColors.accentTeal,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.labelText. withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: AppColors.labelText,
              size: 20,
            ),
            suffixIcon: isPassword
                ? IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscureText
                    ? Icons. visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors. labelText,
                size: 20,
              ),
            )
                : null,
            filled: true,
            fillColor: AppColors. inputBackground,
            border:  OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:  BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors. inputBorder,
                width: 1,
              ),
            ),
            focusedBorder:  OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.accentTeal,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.red. shade400,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius:  BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.red. shade400,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical:  16,
            ),
            errorStyle: TextStyle(
              color: Colors. red.shade600,
              fontSize:  12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton({
    required bool isLoading,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height:  56,
      child:  ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentTeal,
          foregroundColor:  Colors.white,
          elevation: isLoading ?  0 : 4,
          shadowColor: AppColors.accentTeal. withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'SIGN IN',
                style: TextStyle(
                  fontWeight: FontWeight. w700,
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Animated Text Button for navigation
class _AnimatedTextButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _AnimatedTextButton({
    required this.text,
    required this. onTap,
  });

  @override
  State<_AnimatedTextButton> createState() => _AnimatedTextButtonState();
}

class _AnimatedTextButtonState extends State<_AnimatedTextButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp:  (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller. reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration:  BoxDecoration(
                borderRadius: BorderRadius. circular(4),
                color:  _isPressed
                    ? AppColors. accentTeal. withOpacity(0.1)
                    :  Colors.transparent,
              ),
              child:  Text(
                widget.text,
                style: TextStyle(
                  fontSize: 14,
                  color: _isPressed
                      ? AppColors.accentTeal.withOpacity(0.8)
                      : AppColors.accentTeal,
                  fontWeight:  FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Social Login Button Widget
class _SocialLoginButton extends StatefulWidget {
  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this. onPressed,
  });

  @override
  State<_SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<_SocialLoginButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration:  const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration:  BoxDecoration(
          color: _isPressed ?  AppColors.lightGray : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isPressed ? AppColors. accentTeal : AppColors.silverBorder,
            width: _isPressed ? 1.5 : 1,
          ),
          boxShadow:  _isPressed
              ? []
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize. min,
          children: [
            widget.icon,
            const SizedBox(width: 10),
            Text(
              widget.label,
              style:  const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Google Icon Widget
class GoogleIcon extends StatelessWidget {
  final double size;

  const GoogleIcon({Key? key, this.size = 24}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _GoogleIconPainter(),
      ),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final Paint bluePaint = Paint().. color = const Color(0xFF4285F4);
    final Paint greenPaint = Paint()..color = const Color(0xFF34A853);
    final Paint yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final Paint redPaint = Paint()..color = const Color(0xFFEA4335);

    final Path path = Path();
    final double scale = s / 24.0;

    path.moveTo(23.52 * scale, 12.27 * scale);
    path.cubicTo(23.52 * scale, 11.48 * scale, 23.45 * scale, 10.73 * scale,
    23.32 * scale, 10.0 * scale);
    path.lineTo(12.0 * scale, 10.0 * scale);
    path.lineTo(12.0 * scale, 14.26 * scale);
    path.lineTo(18.47 * scale, 14.26 * scale);
    path.cubicTo(18.22 * scale, 15.63 * scale, 17.45 * scale, 16.79 * scale,
    16.28 * scale, 17.57 * scale);
    path.lineTo(16.28 * scale, 20.34 * scale);
    path.lineTo(20.05 * scale, 20.34 * scale);
    path.cubicTo(22.24 * scale, 18.34 * scale, 23.52 * scale, 15.52 * scale,
    23.52 * scale, 12.27 * scale);
    path.close();
    canvas.drawPath(path, bluePaint);

    path.reset();
    path.moveTo(12.0 * scale, 23.5 * scale);
    path.cubicTo(14.97 * scale, 23.5 * scale, 17.46 * scale, 22.53 * scale,
    20.05 * scale, 20.34 * scale);
    path.lineTo(16.28 * scale, 17.57 * scale);
    path.cubicTo(15.24 * scale, 18.27 * scale, 13.93 * scale, 18.69 * scale,
    12.0 * scale, 18.69 * scale);
    path.cubicTo(9.14 * scale, 18.69 * scale, 6.71 * scale, 16.67 * scale,
    5.84 * scale, 13.97 * scale);
    path.lineTo(1.95 * scale, 13.97 * scale);
    path.lineTo(1.95 * scale, 16.83 * scale);
    path.cubicTo(4.45 * scale, 21.04 * scale, 7.94 * scale, 23.5 * scale,
    12.0 * scale, 23.5 * scale);
    path.close();
    canvas.drawPath(path, greenPaint);

    path.reset();
    path.moveTo(5.84 * scale, 13.97 * scale);
    path.cubicTo(5.62 * scale, 13.27 * scale, 5.5 * scale, 12.52 * scale,
    5.5 * scale, 11.75 * scale);
    path.cubicTo(5.5 * scale, 10.98 * scale, 5.62 * scale, 10.23 * scale,
    5.84 * scale, 9.53 * scale);
    path.lineTo(5.84 * scale, 6.67 * scale);
    path.lineTo(1.95 * scale, 6.67 * scale);
    path.cubicTo(1.07 * scale, 8.41 * scale, 0.5 * scale, 10.32 * scale,
    0.5 * scale, 12.0 * scale);
    path.cubicTo(0.5 * scale, 13.68 * scale, 1.07 * scale, 15.59 * scale,
    1.95 * scale, 16.83 * scale);
    path.lineTo(5.84 * scale, 13.97 * scale);
    path.close();
    canvas.drawPath(path, yellowPaint);

    path.reset();
    path.moveTo(12.0 * scale, 4.81 * scale);
    path.cubicTo(14.1 * scale, 4.81 * scale, 15.97 * scale, 5.55 * scale,
    17.42 * scale, 6.93 * scale);
    path.lineTo(20.17 * scale, 4.18 * scale);
    path.cubicTo(17.96 * scale, 2.13 * scale, 15.23 * scale, 0.5 * scale,
    12.0 * scale, 0.5 * scale);
    path.cubicTo(7.94 * scale, 0.5 * scale, 4.45 * scale, 2.96 * scale,
    1.95 * scale, 6.67 * scale);
    path.lineTo(5.84 * scale, 9.53 * scale);
    path.cubicTo(6.71 * scale, 6.83 * scale, 9.14 * scale, 4.81 * scale,
    12.0 * scale, 4.81 * scale);
    path.close();
    canvas.drawPath(path, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Facebook Icon Widget
class FacebookIcon extends StatelessWidget {
  final double size;

  const FacebookIcon({Key? key, this. size = 24}) : super(key:  key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1877F2),
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _FacebookIconPainter(),
      ),
    );
  }
}

class _FacebookIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final double scale = s / 24.0;

    final Paint whitePaint = Paint()
      ..color = Colors.white
      .. style = PaintingStyle.fill;

    final Path path = Path();

    path.moveTo(15.12 * scale, 12.0 * scale);
    path.lineTo(13.0 * scale, 12.0 * scale);
    path.lineTo(13.0 * scale, 20.0 * scale);
    path.lineTo(9.5 * scale, 20.0 * scale);
    path.lineTo(9.5 * scale, 12.0 * scale);
    path.lineTo(7.5 * scale, 12.0 * scale);
    path.lineTo(7.5 * scale, 9.0 * scale);
    path.lineTo(9.5 * scale, 9.0 * scale);
    path.lineTo(9.5 * scale, 7.13 * scale);
    path.cubicTo(9.5 * scale, 5.12 * scale, 10.69 * scale, 4.0 * scale,
        12.57 * scale, 4.0 * scale);
    path.cubicTo(13.46 * scale, 4.0 * scale, 14.5 * scale, 4.17 * scale,
        14.5 * scale, 4.17 * scale);
    path.lineTo(14.5 * scale, 6.13 * scale);
    path.lineTo(13.36 * scale, 6.13 * scale);
    path.cubicTo(12.38 * scale, 6.13 * scale, 12.0 * scale, 6.73 * scale,
        12.0 * scale, 7.35 * scale);
    path.lineTo(12.0 * scale, 9.0 * scale);
    path.lineTo(14.39 * scale, 9.0 * scale);
    path.lineTo(13.99 * scale, 12.0 * scale);
    path.close();

    canvas.drawPath(path, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}