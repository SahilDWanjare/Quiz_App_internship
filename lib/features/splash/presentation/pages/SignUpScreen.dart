import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/SummitLogo.dart';
import 'registration_screen.dart';
import 'home_screen_full.dart';

// --- Professional Palette (Same as SignIn) ---
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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeToTerms = false;

  // Animation Controllers
  late AnimationController _entryController;

  // Entry Animations
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _socialFade;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _passwordController.addListener(() {
      setState(() {});
    });
  }

  void _setupAnimations() {
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve:  const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _formSlide = Tween<Offset>(
      begin: const Offset(-0.1, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent:  _entryController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _socialFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _nameController.dispose();
    _emailController. dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey. currentState!.validate()) {
      if (! _agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Please agree to the Terms & Conditions'),
              ],
            ),
            backgroundColor: Colors.orange. shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }

      context.read<AuthBloc>().add(
        SignUpWithEmailEvent(
          name: _nameController. text. trim(),
          email: _emailController. text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _navigateBackToSignIn() {
    Navigator.of(context).pop();
  }

  /// Check if user has completed registration
  Future<bool> _checkRegistrationStatus(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          . collection('registrations')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking registration:  $e');
      return false;
    }
  }

  /// Navigate based on registration status
  Future<void> _navigateAfterAuth(AuthAuthenticated state) async {
    // For new signups, always go to registration
    if (state.isNewUser) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegistrationScreen()),
      );
      return;
    }

    // For existing users (Google/Facebook), check registration status
    final isRegistered = await _checkRegistrationStatus(state.userId);

    if (mounted) {
      if (isRegistered) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RegistrationScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger. of(context).showSnackBar(
              SnackBar(
                content:  Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state. message)),
                  ],
                ),
                backgroundColor: Colors. red. shade600,
                behavior: SnackBarBehavior. floating,
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
                _buildLogoHeader(),
                _buildFormSection(),
                _buildSocialSection(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return FadeTransition(
      opacity: _logoFade,
      child:  ScaleTransition(
        scale: _logoScale,
        child:  Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: const Center(
            child:  SummitLogo(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return FadeTransition(
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
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight. bold,
                    color: AppColors.primaryNavy,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height:  6),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                    children:  [
                      const TextSpan(text: 'Join the '),
                      TextSpan(
                        text: 'executive network',
                        style: TextStyle(
                          color: AppColors.accentTeal,
                          fontWeight: FontWeight. w600,
                        ),
                      ),
                      const TextSpan(text: ' today'),
                    ],
                  ),
                ),
                const SizedBox(height:  28),

                // Name Field
                _buildAnimatedTextField(
                  controller: _nameController,
                  label: 'FULL NAME',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded,
                  delay: 0,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Email Field
                _buildAnimatedTextField(
                  controller: _emailController,
                  label: 'EMAIL ADDRESS',
                  hint: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  delay:  1,
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
                const SizedBox(height: 18),

                // Password Field
                _buildAnimatedTextField(
                  controller: _passwordController,
                  label: 'PASSWORD',
                  hint: 'Create a strong password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleObscure: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  delay:  2,
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

                _buildPasswordStrengthIndicator(),
                _buildTermsCheckbox(),
                const SizedBox(height: 24),

                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return _buildCreateAccountButton(
                      isLoading:  isLoading,
                      onPressed:  isLoading ? null :  _handleSignUp,
                    );
                  },
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?  ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    _AnimatedTextButton(
                      text: 'Sign In',
                      onTap: _navigateBackToSignIn,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    TextInputType?  keyboardType,
    String? Function(String?)? validator,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (delay * 150)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset:  Offset(-30 * (1 - value), 0),
          child:  Opacity(
            opacity: value,
            child:  child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.labelText,
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
              fontWeight: FontWeight. w500,
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
                  color: AppColors.labelText,
                  size: 20,
                ),
              )
                  : null,
              filled: true,
              fillColor: AppColors.inputBackground,
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
                  color: AppColors.inputBorder,
                  width:  1,
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
                borderRadius:  BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.red. shade400,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius. circular(14),
                borderSide:  BorderSide(
                  color: Colors.red.shade400,
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
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController. text;
    int strength = 0;

    if (password. length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    Color getColor() {
      if (strength <= 1) return Colors.red. shade400;
      if (strength <= 2) return Colors.orange.shade400;
      if (strength <= 3) return Colors.yellow. shade700;
      return Colors.green.shade500;
    }

    String getLabel() {
      if (password.isEmpty) return '';
      if (strength <= 1) return 'Weak';
      if (strength <= 2) return 'Fair';
      if (strength <= 3) return 'Good';
      return 'Strong';
    }

    return AnimatedCrossFade(
      firstChild: const SizedBox(height: 16),
      secondChild:  Padding(
        padding:  const EdgeInsets. only(top: 12, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize. min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:  BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween:  Tween(begin:  0, end: strength / 5),
                      duration: const Duration(milliseconds:  300),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: AppColors.silverBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(getColor()),
                          minHeight: 4,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position:  Tween<Offset>(
                          begin: const Offset(0.2, 0),
                          end:  Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    getLabel(),
                    key: ValueKey(getLabel()),
                    style: TextStyle(
                      fontSize:  12,
                      fontWeight: FontWeight. w600,
                      color: getColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Use 8+ characters with uppercase, numbers & symbols',
              style:  TextStyle(
                fontSize: 11,
                color: AppColors.labelText,
              ),
            ),
          ],
        ),
      ),
      crossFadeState: password.isEmpty
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 300),
      sizeCurve: Curves.easeOutCubic,
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () {
        setState(() => _agreeToTerms = !_agreeToTerms);
      },
      child:  Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration:  const Duration(milliseconds: 200),
            width: 22,
            height:  22,
            decoration: BoxDecoration(
              color:  _agreeToTerms ? AppColors.accentTeal : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _agreeToTerms
                    ? AppColors.accentTeal
                    : AppColors.silverBorder,
                width:  1.5,
              ),
            ),
            child: _agreeToTerms
                ? const Icon(
              Icons.check,
              size: 14,
              color: Colors.white,
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style:  const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppColors.accentTeal,
                      fontWeight:  FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.accentTeal,
                      fontWeight:  FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAccountButton({
    required bool isLoading,
    VoidCallback? onPressed,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds:  800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset:  Offset(-20 * (1 - value), 0),
          child: Transform.scale(
            scale: 0.9 + (0.1 * value),
            alignment: Alignment.centerLeft,
            child:  Opacity(
              opacity: value,
              child: child,
            ),
          ),
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: 56,
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
                ?  const SizedBox(
              height:  22,
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
                  'CREATE ACCOUNT',
                  style: TextStyle(
                    fontWeight: FontWeight. w700,
                    fontSize: 15,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialSection() {
    return FadeTransition(
      opacity: _socialFade,
      child:  Padding(
        padding:  const EdgeInsets. symmetric(horizontal: 30),
        child: Column(
          children: [
            Row(
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
                    'Or sign up with',
                    style: TextStyle(
                      fontSize:  12,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height:  1,
                    color: AppColors.silverBorder,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child:  TweenAnimationBuilder<double>(
                    tween:  Tween(begin:  0.0, end: 1.0),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform. translate(
                        offset: Offset(-30 * (1 - value), 0),
                        child: Transform.scale(
                          scale: value,
                          child: child,
                        ),
                      );
                    },
                    child: _SocialLoginButton(
                      icon: const GoogleIcon(size: 20),
                      label: 'Google',
                      onPressed: () {
                        context.read<AuthBloc>().add(SignInWithGoogleEvent());
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds:  600),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset:  Offset(-30 * (1 - value), 0),
                        child:  Transform.scale(
                          scale: value,
                          child: child,
                        ),
                      );
                    },
                    child:  _SocialLoginButton(
                      icon: const FacebookIcon(size: 20),
                      label:  'Facebook',
                      onPressed:  () {
                        context.read<AuthBloc>().add(SignInWithFacebookEvent());
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Animated Text Button
// ============================================================================
class _AnimatedTextButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _AnimatedTextButton({
    required this.text,
    required this.onTap,
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
    _controller. dispose();
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
        _controller.reverse();
      },
      child:  AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration:  const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius. circular(6),
                color: _isPressed
                    ? AppColors.accentTeal. withOpacity(0.1)
                    :  Colors.transparent,
              ),
              child:  Text(
                widget. text,
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

// ============================================================================
// Social Login Button Widget
// ============================================================================
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
        height: 52,
        decoration: BoxDecoration(
          color: _isPressed ?  AppColors.lightGray : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isPressed ? AppColors. accentTeal : AppColors.silverBorder,
            width:  _isPressed ? 1.5 : 1,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.icon,
            const SizedBox(width: 10),
            Text(
              widget.label,
              style:  const TextStyle(
                fontSize: 14,
                fontWeight:  FontWeight.w600,
                color:  AppColors.primaryNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Google Icon Widget
// ============================================================================
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

// ============================================================================
// Facebook Icon Widget
// ============================================================================
class FacebookIcon extends StatelessWidget {
  final double size;

  const FacebookIcon({Key?  key, this.size = 24}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color:  Color(0xFF1877F2),
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