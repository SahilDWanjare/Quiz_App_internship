import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app_project/features/splash/presentation/pages/quiz_history_screen.dart';
import 'package:test_app_project/features/splash/presentation/pages/subscription_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'SignInScreen.dart';
import 'personal_information_screen.dart';
import '../widgets/CustomTextField.dart';

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
  static const Color success = Color(0xFF4CAF50);
}

// --- Edit Profile Screen ---
class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  const EditProfileScreen({Key? key, required this. initialData}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _designationController;
  late TextEditingController _mobileController;
  late TextEditingController _addressController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget. initialData['name']);
    _companyController = TextEditingController(text: widget.initialData['companyName']);
    _designationController = TextEditingController(text: widget.initialData['designation']);
    _mobileController = TextEditingController(text: widget. initialData['mobileNo']);
    _addressController = TextEditingController(text: widget. initialData['address']);
  }

  @override
  void dispose() {
    _nameController. dispose();
    _companyController.dispose();
    _designationController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!. validate()) return;

    setState(() => _isUpdating = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      await FirebaseFirestore.instance. collection('registrations').doc(user.uid).update({
        'name': _nameController.text. trim(),
        'companyName': _companyController.text. trim(),
        'designation': _designationController.text.trim(),
        'mobileNo': _mobileController.text.trim(),
        'address': _addressController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Profile Updated Successfully! '),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior. floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:  Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Update failed: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red. shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Gradient Header
          _buildHeader(),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      icon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _companyController,
                      label: 'Company',
                      hint: 'Enter company name',
                      icon: Icons.business_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _designationController,
                      label: 'Designation',
                      hint: 'Enter your role',
                      icon: Icons. badge_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _mobileController,
                      label:  'Mobile',
                      hint: 'Enter phone number',
                      icon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      hint:  'Enter your address',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Update Button
          _buildUpdateButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient:  LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment. bottomCenter,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius. only(
          bottomLeft:  Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child:  Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white. withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border. all(
                          color: Colors.white. withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors. white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height:  20),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color:  Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 3),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label. toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.labelText,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height:  8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius. circular(14),
            border: Border.all(color: AppColors.silverBorder, width: 1),
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors. primaryNavy,
              fontWeight:  FontWeight.w500,
            ),
            decoration:  InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.labelText,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:  Icon(
                  icon,
                  color: AppColors.accentTeal,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: _isUpdating ? null : _updateProfile,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: _isUpdating
                  ? null
                  : const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
                begin: Alignment.centerLeft,
                end:  Alignment.centerRight,
              ),
              color: _isUpdating ? AppColors.silverBorder : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isUpdating
                  ? null
                  : [
                BoxShadow(
                  color:  AppColors.accentTeal.withOpacity(0.4),
                  blurRadius:  12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child:  Center(
              child: _isUpdating
                  ? const SizedBox(
                height:  24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : const Row(
                mainAxisAlignment:  MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_outlined, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'UPDATE PROFILE',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors. white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Main Profile Screen ---
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // Registration data
  Map<String, dynamic>? _registrationData;
  bool _isLoadingData = true;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchRegistrationData();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration:  const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve:  Curves.easeOut),
    );

    _animController.forward();
  }

  Future<void> _fetchRegistrationData() async {
    final user = FirebaseAuth.instance. currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('registrations')
            .doc(user.uid)
            .get();

        if (mounted) {
          setState(() {
            if (doc.exists) {
              _registrationData = doc.data();
            }
            _isLoadingData = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoadingData = false);
      }
    } else {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // FIXED: Sign out method
  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);

    try {
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        // Navigate to SignIn and clear stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSigningOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children:  [
                const Icon(Icons. error_outline, color: Colors. white, size: 20),
                const SizedBox(width:  12),
                Expanded(child: Text('Sign out failed: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red. shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance. currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          FadeTransition(
            opacity:  _fadeAnimation,
            child:  SingleChildScrollView(
              child:  Column(
                children: [
                  // Gradient Header
                  _buildProfileHeader(user),

                  // Profile Content
                  Padding(
                    padding: const EdgeInsets. all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Professional Info Card
                        if (_registrationData != null) ...[
                          _buildProfessionalInfoCard(),
                          const SizedBox(height:  24),
                        ],

                        // Account Section
                        const Text(
                          'Account',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.labelText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height:  12),

                        _buildProfileCard(
                          icon: Icons. person_outline_rounded,
                          title: 'Personal Information',
                          subtitle: 'Update your personal details',
                          onTap: () async {
                            if (_registrationData != null) {
                              final result = await Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      EditProfileScreen(initialData: _registrationData!),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return SlideTransition(
                                      position:  Tween<Offset>(
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

                              if (result == true) {
                                _fetchRegistrationData();
                              }
                            } else {
                              _showComingSoonToast('Loading data...');
                            }
                          },
                        ),
                        const SizedBox(height:  10),

                        _buildProfileCard(
                          icon: Icons. history_rounded,
                          title: 'Assessment History',
                          subtitle: 'View your past attempts',
                          onTap:  () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                const QuizHistoryScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return SlideTransition(
                                    position:  Tween<Offset>(
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
                        const SizedBox(height: 10),

                        _buildProfileCard(
                          icon: Icons.workspace_premium_rounded,
                          title: 'Subscription',
                          subtitle: 'Manage your subscription',
                          badgeText: 'PRO',
                          badgeColor: AppColors.gold,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                const SubscriptionScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves. easeOutCubic,
                                    )),
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 400),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Preferences Section
                        const Text(
                          'Preferences',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.labelText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildProfileCard(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          subtitle:  'Manage notification preferences',
                          onTap: () => _showComingSoonToast('Notifications'),
                        ),
                        const SizedBox(height: 10),

                        _buildProfileCard(
                          icon: Icons. security_rounded,
                          title: 'Privacy & Security',
                          subtitle: 'Manage your account security',
                          onTap: () => _showComingSoonToast('Privacy & Security'),
                        ),
                        const SizedBox(height:  10),

                        _buildProfileCard(
                          icon:  Icons.help_outline_rounded,
                          title: 'Help & Support',
                          subtitle:  'Get help or contact us',
                          onTap:  () => _showComingSoonToast('Help & Support'),
                        ),

                        const SizedBox(height: 30),

                        // Sign Out Button
                        _buildSignOutButton(),

                        const SizedBox(height: 20),

                        // App Version
                        const Center(
                          child: Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.labelText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay for Sign Out
          if (_isSigningOut)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.accentTeal,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Signing Out...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:  FontWeight.w600,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please wait',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User?  user) {
    final displayName = _registrationData? ['name'] ?? user?.displayName ?? 'User';
    final designation = _registrationData?['designation'] ?? 'Professional';
    final companyName = _registrationData? ['companyName'] ?? '';

    return Container(
      width:  double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius. only(
          bottomLeft:  Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 3),
                ),
                child:  Center(
                  child: Text(
                    _getInitials(displayName),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors. white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors. white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                designation,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors. white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (companyName.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  companyName,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors. white.withOpacity(0.7),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white. withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size:  16,
                      color: Colors. white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors. white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildProfessionalInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment. bottomRight,
          colors: [
            AppColors.accentTeal.withOpacity(0.1),
            AppColors.primaryNavy.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentTeal. withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment. start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:  const Icon(
                  Icons.business_center_rounded,
                  color: AppColors.accentTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width:  14),
              const Text(
                'Professional Details',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.business_rounded, 'Company', _registrationData? ['companyName'] ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.badge_outlined, 'Designation', _registrationData? ['designation'] ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone_android_rounded, 'Mobile', _registrationData?['mobileNo'] ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on_outlined, 'Address', _registrationData?['address'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.labelText),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.labelText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style:  const TextStyle(
              fontSize:  14,
              color: AppColors.primaryNavy,
              fontWeight:  FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badgeText,
    Color? badgeColor,
  }) {
    return GestureDetector(
      onTap:  onTap,
      child:  Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius. circular(16),
          border: Border.all(color: AppColors.silverBorder, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height:  48,
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child:  Icon(icon, color: AppColors.accentTeal, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? AppColors.gold).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style:  TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: badgeColor ?? AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style:  const TextStyle(
                      fontSize:  12,
                      color: AppColors.labelText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.labelText,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return GestureDetector(
      onTap: () => _showSignOutDialog(context),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius. circular(16),
          border: Border.all(color: Colors.red. shade400, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 22, color: Colors.red.shade600),
            const SizedBox(width: 10),
            Text(
              'SIGN OUT',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.red.shade600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:  Icon(
                Icons.logout_rounded,
                color: Colors.red.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of your account?',
          style:  TextStyle(
            fontSize: 14,
            color: AppColors.secondaryText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: AppColors.labelText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors. red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:  BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical:  10),
            ),
            child:  const Text(
              'SIGN OUT',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}