import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app_project/features/splash/presentation/pages/profile_screen.dart';
import 'package:test_app_project/features/splash/presentation/pages/subscription_screen.dart';
import 'package:test_app_project/features/splash/presentation/pages/study_material_screen.dart';
import 'package:test_app_project/features/splash/presentation/pages/analytics_screen.dart';
import '../../../subscription/presentation/bloc/subscription_bloc.dart';
import '../../../subscription/presentation/bloc/subscription_event.dart';
import '../../../subscription/presentation/bloc/subscription_state.dart';
import '../../../subscription/presentation/pages/subscription_plans_screen.dart';
import '../../../assessment/presentation/pages/instruction_screen.dart';

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
  static const Color gold = Color(0xFFD4AF37);
  static const Color gradientStart = Color(0xFF1B9AAA);
  static const Color gradientEnd = Color(0xFF0D1B2A);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  PageController? _pageController;
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;

  Map<String, dynamic>? _registrationData;
  String? _activeTappedFeature;
  double _progressPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _setupAnimations();
    _checkSubscription();
    _fetchUserData();
    _calculateProgress();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController!, curve: Curves.easeOut),
    );
    _fadeController!.forward();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('registrations')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          setState(() {
            _registrationData = doc.data();
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> _calculateProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Calculate progress based on study material completion
        // This is a placeholder - replace with your actual logic
        final progressDoc = await FirebaseFirestore.instance
            .collection('user_progress')
            .doc(user.uid)
            .get();

        if (progressDoc.exists && mounted) {
          final data = progressDoc.data();
          final completedItems = data?['completed_items'] ?? 0;
          final totalItems = data?['total_items'] ?? 100;
          setState(() {
            _progressPercentage = (completedItems / totalItems) * 100;
          });
        } else {
          setState(() {
            _progressPercentage = 0.0; // Default 0% if no data
          });
        }
      } catch (e) {
        print('Error calculating progress: $e');
        setState(() {
          _progressPercentage = 0.0;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void _checkSubscription() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<SubscriptionBloc>().add(
        CheckSubscriptionStatus(user.uid),
      );
    }
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    _pageController?.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _showComingSoonToast(String feature) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('$feature - Coming Soon!'),
          ],
        ),
        backgroundColor: AppColors.accentTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onFeatureTap(String featureName) {
    setState(() {
      _activeTappedFeature = featureName;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _activeTappedFeature = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pageController == null || _fadeAnimation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation!,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            _buildHomeContent(),
            const ProfileScreen(),
            const SubscriptionScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeContent() {
    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text('Subscription activated successfully!'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          _checkSubscription();
        } else if (state is PaymentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.error)),
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
        final isSubscribed = state is SubscriptionActive;

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildGradientHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildTaglineSection(),
                    const SizedBox(height: 30),
                    _buildFeatureCards(isSubscribed),
                    const SizedBox(height: 24),
                    // _buildProgressCard(),
                    // const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradientHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName =
        _registrationData?['name'] ?? user?.displayName ?? 'User';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.gradientStart,
            AppColors.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayName.split(' ')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  _buildProfileAvatar(displayName),
                ],
              ),
              const SizedBox(height: 24),
              _buildAppLogo(),
              const SizedBox(height: 5),
              // Column(
              //   children: [
              //     const Text(
              //       'ID Aspire',
              //       style: TextStyle(
              //         fontSize: 28,
              //         fontWeight: FontWeight.w600,
              //         color: Colors.white,
              //         letterSpacing: -0.5,
              //       ),
              //     ),
              //     Text(
              //       'Empowering Future Directors',
              //       style: TextStyle(
              //         fontSize: 13,
              //         fontWeight: FontWeight.w500,
              //         color: Colors.white.withOpacity(0.7),
              //         letterSpacing: -0.3,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    const double logoSize = 150;

    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: AppColors.gold,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.gold.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/main_app_logo.jpg',
          width: logoSize,
          height: logoSize,
          // fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackLogo(logoSize);
          },
        ),
      ),
    );
  }

  Widget _buildFallbackLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B9AAA),
            Color(0xFF0D1B2A),
          ],
        ),
      ),
      child: Center(
        child: Text(
          'ID',
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String displayName) {
    return GestureDetector(
      onTap: () => _onNavItemTapped(1),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.gold,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            _getInitials(displayName),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Widget _buildTaglineSection() {
    return Column(
      children: [
        const Text(
          'Ascend to Boardroom Leadership',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),

      ],
    );
  }

  Widget _buildFeatureCards(bool isSubscribed) {
    return Row(
      children: [
        Expanded(
          child: _buildFeatureCard(
            icon: Icons.menu_book_rounded,
            label: 'STUDY\nMATERIAL',
            isActive: _activeTappedFeature == 'STUDY MATERIAL',
            onTap: () {
              _onFeatureTap('STUDY MATERIAL');
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                  const StudyMaterialScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFeatureCard(
            icon: Icons.analytics_outlined,
            label: 'ANALYTICS\nDASHBOARD',
            isActive: _activeTappedFeature == 'ANALYTICS DASHBOARD',
            onTap: () {
              _onFeatureTap('ANALYTICS DASHBOARD');
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                  const AnalyticsScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFeatureCard(
            icon: Icons.assignment_turned_in_rounded,
            label: 'PRACTICE\nTESTS',
            isActive: _activeTappedFeature == 'PRACTICE TESTS',
            isHighlighted: true,
            onTap: () {
              _onFeatureTap('PRACTICE TESTS');
              if (isSubscribed) {
                _proceedToTest();
              } else {
                _navigateToSubscription();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted
                ? AppColors.accentTeal
                : (isActive ? AppColors.accentTeal.withOpacity(0.5) : AppColors.silverBorder),
            width: isHighlighted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isHighlighted
                  ? AppColors.accentTeal.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isHighlighted ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isHighlighted
                    ? AppColors.accentTeal.withOpacity(0.1)
                    : AppColors.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isHighlighted ? AppColors.accentTeal : AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryNavy,
                letterSpacing: 0.3,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildProgressCard() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(24),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(
  //         color: AppColors.silverBorder,
  //         width: 1,
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         RichText(
  //           text: TextSpan(
  //             style: const TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w600,
  //               color: AppColors.primaryNavy,
  //             ),
  //             children: [
  //               const TextSpan(text: 'OVERALL PREPARATION: '),
  //               TextSpan(
  //                 text: '${_progressPercentage.toInt()}%',
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   color: AppColors.accentTeal,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         ClipRRect(
  //           borderRadius: BorderRadius.circular(10),
  //           child: LinearProgressIndicator(
  //             value: _progressPercentage / 100,
  //             minHeight: 12,
  //             backgroundColor: AppColors.lightGray,
  //             valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         Text(
  //           _progressPercentage > 0 ? 'Keep Going!' : 'Start Your Journey!',
  //           style: TextStyle(
  //             fontSize: 13,
  //             color: AppColors.secondaryText,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'HOME',
                isSelected: _selectedIndex == 0,
                onTap: () => _onNavItemTapped(0),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'PROFILE',
                isSelected: _selectedIndex == 1,
                onTap: () => _onNavItemTapped(1),
              ),
              _NavItem(
                icon: Icons.credit_card_rounded,
                label: 'SUBSCRIPTION',
                isSelected: _selectedIndex == 2,
                onTap: () => _onNavItemTapped(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSubscription() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BlocProvider.value(
              value: context.read<SubscriptionBloc>(),
              child: const SubscriptionPlansScreen(),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _proceedToTest() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const InstructionScreen(assessmentId: 'assessment_1'),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

// ============================================================================
// Nav Item Widget
// ============================================================================
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.accentTeal : AppColors.labelText,
            size: 26,
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.accentTeal,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}