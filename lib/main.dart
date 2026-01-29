import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/registration/presentation/bloc/RegistrationBloc.dart';
import 'features/splash/presentation/pages/SplashScreen.dart';
import 'features/splash/presentation/pages/SignInScreen.dart';
import 'features/splash/presentation/pages/home_screen_full.dart';
import 'features/subscription/presentation/bloc/subscription_bloc.dart';
import 'features/assessment/presentation/bloc/quiz_bloc.dart';

// --- Professional Palette (Same as Registration Screen) ---
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

// Global instance of NoScreenshot
final NoScreenshot _noScreenshot = NoScreenshot.instance;

// Global location service for payment gateway selection
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? currentPosition;
  String? currentCountry;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<bool> initialize() async {
    try {
      final hasPermission = await _handleLocationPermission();
      if (hasPermission) {
        await _getCurrentLocation();
        _isInitialized = true;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Location initialization error: $e');
      return false;
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled');
      return false;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied');
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );
      debugPrint(
          '📍 Location: ${currentPosition?.latitude}, ${currentPosition?.longitude}');
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }
}

// Global location service instance
final locationService = LocationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Initializing Firebase...');
  await Firebase.initializeApp();
  print('✓ Firebase initialized successfully');

  // Initialize Stripe
  Stripe.publishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  print('✓ Stripe initialized');

  // Initialize Dependencies
  await initializeDependencies();
  print('✓ Dependencies initialized');

  // Enable Screenshot Prevention
  await _noScreenshot.screenshotOff();
  print('🔒 Screenshot prevention enabled');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (_) => sl<RegistrationBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<SubscriptionBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<QuizBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Summit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// App Flow States
enum AppFlowState {
  splash,
  locationPermission,
  authentication,
}

/// AuthWrapper listens to auth state changes and navigates accordingly
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  AppFlowState _currentFlowState = AppFlowState.splash;
  bool _locationPermissionHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableScreenshotPrevention();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash for minimum 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Check if location permission has been handled before
    final permissionStatus = await Permission.location.status;

    if (permissionStatus.isGranted) {
      // Permission already granted, initialize location and proceed to auth
      await locationService.initialize();
      _proceedToAuthentication();
    } else {
      // Show location permission screen
      if (mounted) {
        setState(() {
          _currentFlowState = AppFlowState.locationPermission;
        });
      }
    }
  }

  void _proceedToAuthentication() {
    if (mounted) {
      setState(() {
        _locationPermissionHandled = true;
        _currentFlowState = AppFlowState.authentication;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    final granted = await locationService.initialize();

    if (granted) {
      debugPrint('✓ Location permission granted');
    } else {
      debugPrint('✗ Location permission denied');
    }

    // Proceed to authentication regardless of permission result
    _proceedToAuthentication();
  }

  Future<void> _skipLocationPermission() async {
    debugPrint('⏭ Location permission skipped');
    _proceedToAuthentication();
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  Future<void> _enableScreenshotPrevention() async {
    await _noScreenshot.screenshotOff();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _enableScreenshotPrevention();

      // Re-check permission when app is resumed (user might have changed settings)
      if (_currentFlowState == AppFlowState.locationPermission) {
        _checkPermissionAfterSettings();
      }
    }
  }

  Future<void> _checkPermissionAfterSettings() async {
    final permissionStatus = await Permission.location.status;
    if (permissionStatus.isGranted) {
      await locationService.initialize();
      _proceedToAuthentication();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentFlowState) {
      case AppFlowState.splash:
        return const SplashScreen();

      case AppFlowState.locationPermission:
        return _LocationPermissionScreen(
          onAllowPressed: _requestLocationPermission,
          onSkipPressed: _skipLocationPermission,
          onOpenSettingsPressed: _openAppSettings,
        );

      case AppFlowState.authentication:
        return BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          builder: (context, state) {
            // Show loading while checking auth status
            if (state is AuthLoading || state is AuthInitial) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.accentTeal,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // User is authenticated -> Go to HomeScreen
            if (state is AuthAuthenticated) {
              return const HomeScreen();
            }

            // User is not authenticated -> Go to SignInScreen
            return const SignInScreen();
          },
        );
    }
  }
}

/// Location Permission Screen
class _LocationPermissionScreen extends StatefulWidget {
  final VoidCallback onAllowPressed;
  final VoidCallback onSkipPressed;
  final VoidCallback onOpenSettingsPressed;

  const _LocationPermissionScreen({
    required this.onAllowPressed,
    required this.onSkipPressed,
    required this.onOpenSettingsPressed,
  });

  @override
  State<_LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<_LocationPermissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPermanentlyDenied = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfPermanentlyDenied();
    _setupAnimations();
  }

  Future<void> _checkIfPermanentlyDenied() async {
    final status = await Permission.location.status;
    if (mounted) {
      setState(() {
        _isPermanentlyDenied = status.isPermanentlyDenied;
      });
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleAllowPressed() {
    setState(() {
      _isLoading = true;
    });
    widget.onAllowPressed();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: isSmallScreen ? 16 : 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Section
                      Column(
                        children: [
                          SizedBox(height: isSmallScreen ? 20 : 40),

                          // Location Icon
                          Container(
                            width: isSmallScreen ? 100 : 120,
                            height: isSmallScreen ? 100 : 120,
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: isSmallScreen ? 70 : 85,
                                height: isSmallScreen ? 70 : 85,
                                decoration: BoxDecoration(
                                  color: AppColors.accentTeal.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    size: isSmallScreen ? 40 : 48,
                                    color: AppColors.accentTeal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 24 : 36),

                          // Title
                          Text(
                            'Enable Location',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 24 : 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Subtitle
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                                color: AppColors.secondaryText,
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(
                                    text: 'We need your location to provide '),
                                TextSpan(
                                  text: 'best payment options',
                                  style: TextStyle(
                                    color: AppColors.accentTeal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(
                                    text: ' available in your region.'),
                              ],
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 24 : 32),

                          // Benefits
                          _buildBenefitItem(
                            icon: Icons.payment_rounded,
                            title: 'Local Payment Methods',
                            description:
                            'Access payment options specific to your country',
                            isSmallScreen: isSmallScreen,
                          ),
                          SizedBox(height: isSmallScreen ? 10 : 14),
                          _buildBenefitItem(
                            icon: Icons.currency_exchange_rounded,
                            title: 'Local Currency',
                            description:
                            'Pay in your local currency without extra fees',
                            isSmallScreen: isSmallScreen,
                          ),
                          SizedBox(height: isSmallScreen ? 10 : 14),
                          _buildBenefitItem(
                            icon: Icons.security_rounded,
                            title: 'Secure Transactions',
                            description:
                            'Region-specific security for your safety',
                            isSmallScreen: isSmallScreen,
                          ),
                        ],
                      ),

                      // Bottom Section
                      Column(
                        children: [
                          SizedBox(height: isSmallScreen ? 20 : 32),

                          // Permanently denied message
                          if (_isPermanentlyDenied)
                            Container(
                              padding: const EdgeInsets.all(14),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.orange.shade700,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Location permission was denied. Please enable it from Settings.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade800,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Allow/Open Settings Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : (_isPermanentlyDenied
                                  ? widget.onOpenSettingsPressed
                                  : _handleAllowPressed),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentTeal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                disabledBackgroundColor:
                                AppColors.accentTeal.withOpacity(0.6),
                                shadowColor:
                                AppColors.accentTeal.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isPermanentlyDenied
                                        ? Icons.settings_rounded
                                        : Icons.location_on_rounded,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _isPermanentlyDenied
                                        ? 'OPEN SETTINGS'
                                        : 'ALLOW LOCATION ACCESS',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Skip Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: TextButton(
                              onPressed:
                              _isLoading ? null : widget.onSkipPressed,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.secondaryText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: AppColors.silverBorder,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Skip for now',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 20),

                          // Privacy Note
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 14,
                                  color: AppColors.labelText,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Your location is only used for payment processing',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.labelText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.inputBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 40 : 44,
            height: isSmallScreen ? 40 : 44,
            decoration: BoxDecoration(
              color: AppColors.accentTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.accentTeal,
              size: isSmallScreen ? 20 : 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}