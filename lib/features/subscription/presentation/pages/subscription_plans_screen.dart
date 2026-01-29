import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entity/subscription_plan.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';
import '../../data/services/payment_service.dart';
import '../widgets/plan_card.dart';

// --- Professional Palette ---
class AppColors {
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color accentTeal = Color(0xFF1B9AAA);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color silverBorder = Color(0xFFDDE1E6);
  static const Color secondaryText = Color(0xFF6D7175);
  static const Color labelText = Color(0xFF8A9099);
  static const Color gold = Color(0xFFD4AF37);
  static const Color gradientStart = Color(0xFF1B9AAA);
  static const Color gradientEnd = Color(0xFF0D1B2A);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
}

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen>
    with SingleTickerProviderStateMixin {
  bool _isIndia = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadPlans();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves. easeOut),
    );
    _animController.forward();
  }

  void _loadPlans() {
    context.read<SubscriptionBloc>().add(LoadSubscriptionPlans());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getTierColor(String tier) {
    switch (tier. toUpperCase()) {
      case 'FREE':
        return AppColors.secondaryText;
      case 'BRONZE':
        return AppColors.bronze;
      case 'SILVER':
        return AppColors.silver;
      case 'GOLD':
        return AppColors.gold;
      default:
        return AppColors.accentTeal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            _showSuccessDialog(state. subscription);
          } else if (state is PaymentFailure) {
            _showErrorDialog(state.error);
          } else if (state is FreeTrialActivated) {
            _showFreeTrialDialog(state.subscription);
          } else if (state is SubscriptionPlansLoaded) {
            setState(() {
              _isIndia = state.isIndia;
            });
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return _buildLoadingView();
          }

          if (state is SubscriptionPlansLoaded) {
            return _buildPlansView(state. plans, state.selectedPlan);
          }

          if (state is PaymentProcessing) {
            return _buildProcessingView();
          }

          // Default:  reload plans
          return _buildLoadingView();
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      decoration:  const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end:  Alignment.bottomCenter,
          colors:  [AppColors.gradientStart, AppColors.gradientEnd],
          stops: [0.0, 0.3],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color:  Colors.white,
              strokeWidth: 3,
            ),
            SizedBox(height:  20),
            Text(
              'Loading Plans...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight:  FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansView(
      List<SubscriptionPlan> plans,
      SubscriptionPlan?  selectedPlan,
      ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children:  [
          // Header
          _buildHeader(),

          // Plans List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location & Currency Info
                  _buildLocationInfo(),

                  const SizedBox(height: 20),

                  // Plans
                  ... plans.asMap().entries.map((entry) {
                    final index = entry.key;
                    final plan = entry.value;
                    final isSelected = selectedPlan?.id == plan.id;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration:  Duration(milliseconds: 400 + (index * 100)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child:  Opacity(
                            opacity: value. clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child:  Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PlanCard(
                          plan: plan,
                          isSelected: isSelected,
                          isIndia: _isIndia,
                          onTap:  () {
                            context.read<SubscriptionBloc>().add(
                              SelectPlan(plan),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 10),

                  // Features comparison
                  _buildFeaturesComparison(),

                  const SizedBox(height: 20),

                  // FAQ Section
                  _buildFAQSection(),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),

          // Bottom Button
          _buildBottomButton(selectedPlan),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topCenter,
          end:  Alignment.bottomCenter,
          colors:  [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius. circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:  Colors.white. withOpacity(0.2),
                      borderRadius: BorderRadius. circular(10),
                    ),
                    child:  const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size:  22,
                    ),
                  ),
                ),
                const Spacer(),
                // Help Button
                GestureDetector(
                  onTap:  _showHelpDialog,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration:  BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius. circular(10),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Title
            const Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color:  Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the plan that best fits your learning goals',
              style: TextStyle(
                fontSize: 14,
                color:  Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.silverBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors. accentTeal. withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons. location_on_outlined,
              color:  AppColors.accentTeal,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isIndia ? 'Detected Location:  India' : 'Detected Location: International',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight. w600,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isIndia
                      ? 'Prices shown in INR • Payment via Razorpay'
                      :  'Prices shown in USD • Payment via Stripe',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.labelText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:  const EdgeInsets. symmetric(horizontal: 10, vertical: 4),
            decoration:  BoxDecoration(
              color: _isIndia ? Colors.orange. shade100 : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _isIndia ? '🇮🇳 INR' : '🌍 USD',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight. w600,
                color: _isIndia ? Colors.orange.shade800 : Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesComparison() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius:  BorderRadius.circular(16),
        border: Border.all(color: AppColors.silverBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children:  [
              Icon(
                Icons. compare_arrows_rounded,
                color:  AppColors.accentTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Plan Comparison',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildComparisonRow('Mock Tests', ['2', '10', 'Unlimited', 'Unlimited']),
          _buildComparisonRow('Analytics', ['Basic', 'Detailed', 'Advanced', 'Advanced']),
          _buildComparisonRow('Support', ['Email', 'Priority', 'Priority', 'VIP']),
          _buildComparisonRow('Certificates', ['✗', '✓', '✓', '✓']),
          _buildComparisonRow('Duration', ['2 Weeks', '2 Months', '1 Year', 'Lifetime']),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String feature, List<String> values) {
    final tiers = ['FREE', 'BRONZE', 'SILVER', 'GOLD'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 11,
                color:  AppColors.labelText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ... List.generate(4, (index) {
            return Expanded(
              child:  Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  values[index],
                  textAlign: TextAlign. center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight. w600,
                    color: _getTierColor(tiers[index]),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children:  [
            Icon(
              Icons. quiz_outlined,
              color:  AppColors.accentTeal,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize:  16,
                fontWeight: FontWeight.bold,
                color: AppColors. primaryNavy,
              ),
            ),
          ],
        ),
        const SizedBox(height:  12),
        _buildFAQItem(
          'Can I cancel my subscription? ',
          'Yes, you can cancel anytime.  You will retain access until the end of your billing period.',
        ),
        _buildFAQItem(
          'What payment methods are accepted?',
          _isIndia
              ? 'We accept all major Indian payment methods via Razorpay including UPI, cards, and net banking.'
              :  'We accept all major credit/debit cards via Stripe.',
        ),
        _buildFAQItem(
          'Is the Gold plan really lifetime?',
          'Yes!  The Gold plan provides lifetime access with no recurring payments.',
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets. all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius:  BorderRadius.circular(12),
        border: Border.all(color: AppColors.silverBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color:  AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: TextStyle(
              fontSize: 12,
              color:  AppColors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(SubscriptionPlan?  selectedPlan) {
    final bool hasSelection = selectedPlan != null;
    final tierColor = hasSelection ?  _getTierColor(selectedPlan. tier) : AppColors.labelText;

    return Container(
      padding:  const EdgeInsets. all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black. withOpacity(0.08),
            blurRadius: 15,
            offset:  const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize. min,
          children: [
            // Selected Plan Summary
            if (hasSelection)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration:  BoxDecoration(
                  color: tierColor. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: tierColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment. spaceBetween,
                  children:  [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: tierColor,
                          size:  18,
                        ),
                        const SizedBox(width:  8),
                        Text(
                          '${selectedPlan. name} (${selectedPlan. tier})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:  FontWeight.w600,
                            color: tierColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      selectedPlan.getDisplayPrice(_isIndia),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight. bold,
                        color: tierColor,
                      ),
                    ),
                  ],
                ),
              ),

            // Subscribe Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child:  ElevatedButton(
                onPressed: hasSelection ? () => _handlePayment(selectedPlan) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:  hasSelection ? tierColor : AppColors.silverBorder,
                  foregroundColor:  Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius. circular(14),
                  ),
                  elevation: hasSelection ? 4 : 0,
                  shadowColor: tierColor.withOpacity(0.4),
                  disabledBackgroundColor: AppColors.silverBorder,
                  disabledForegroundColor: AppColors.labelText,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment. center,
                  children: [
                    Icon(
                      hasSelection
                          ? (selectedPlan. priceINR == 0
                          ? Icons. card_giftcard_rounded
                          : Icons.lock_open_rounded)
                          : Icons.touch_app_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      hasSelection
                          ?  (selectedPlan.priceINR == 0
                          ?  'START FREE TRIAL'
                          : 'PROCEED TO PAYMENT')
                          :  'SELECT A PLAN',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight. w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Security Badge
            Padding(
              padding:  const EdgeInsets. only(top: 12),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: AppColors.labelText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Secure payment powered by ${_isIndia ?  "Razorpay" : "Stripe"}',
                    style: TextStyle(
                      fontSize:  11,
                      color: AppColors.labelText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    return Container(
      decoration: const BoxDecoration(
        gradient:  LinearGradient(
          begin:  Alignment.topCenter,
          end:  Alignment.bottomCenter,
          colors: [AppColors.gradientStart, AppColors. gradientEnd],
        ),
      ),
      child: Center(
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding:  const EdgeInsets. all(24),
              decoration:  BoxDecoration(
                color: Colors.white. withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Processing Payment...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color:  Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Please wait while we process your payment',
              style: TextStyle(
                fontSize: 14,
                color:  Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration:  BoxDecoration(
                color: Colors. white.withOpacity(0.1),
                borderRadius: BorderRadius. circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize. min,
                children: [
                  Icon(
                    Icons.security_rounded,
                    size: 16,
                    color: Colors.white. withOpacity(0.9),
                  ),
                  const SizedBox(width:  8),
                  Text(
                    'Secure Transaction',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white. withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePayment(SubscriptionPlan plan) async {
    final user = FirebaseAuth.instance. currentUser;
    if (user == null) {
      _showErrorDialog('Please sign in to continue');
      return;
    }

    // Check if it's a free plan
    if (plan.priceINR == 0) {
      // Activate free trial
      context.read<SubscriptionBloc>().add(
        ActivateFreeTrial(user. uid),
      );
      return;
    }

    // Check user location
    final locationService = LocationService();
    final isIndia = await locationService.isUserInIndia();

    print('====================================');
    print('PAYMENT PROCESSING');
    print('User ID: ${user.uid}');
    print('Plan: ${plan.name} (${plan.tier})');
    print('Location: ${isIndia ? "India" : "International"}');
    print('Gateway: ${isIndia ? "Razorpay" : "Stripe"}');
    print('Amount: ${isIndia ? "₹${plan.priceINR}" :  "\$${plan.priceUSD}"}');
    print('====================================');

    if (! mounted) return;

    // Start payment
    context.read<SubscriptionBloc>().add(
      StartPayment(
        plan: plan,
        userId: user.uid,
        isIndia: isIndia,
      ),
    );
  }

  void _showSuccessDialog(UserSubscription subscription) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:  (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:  const EdgeInsets. all(16),
              decoration: BoxDecoration(
                color: Colors.green. shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons. check_circle_rounded,
                color: Colors.green. shade600,
                size:  48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color:  AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your ${subscription.planName} subscription is now active.',
              textAlign: TextAlign. center,
              style: TextStyle(
                fontSize: 14,
                color:  AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding:  const EdgeInsets. symmetric(horizontal: 12, vertical: 6),
              decoration:  BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                subscription.isUnlimited
                    ? 'Lifetime Access'
                    :  'Valid until:  ${subscription.formattedEndDate}',
                style:  TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight. w600,
                  color: AppColors.accentTeal,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator. of(context).pop();
                  Navigator. of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'START LEARNING',
                  style: TextStyle(
                    fontWeight: FontWeight. w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFreeTrialDialog(UserSubscription subscription) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize:  MainAxisSize.min,
          children:  [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:  AppColors.accentTeal.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: AppColors.accentTeal,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Free Trial Activated!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color:  AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Enjoy 2 weeks of free access to explore our platform.',
              textAlign: TextAlign. center,
              style: TextStyle(
                fontSize: 14,
                color:  AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration:  BoxDecoration(
                color: AppColors.lightGray,
                borderRadius:  BorderRadius.circular(8),
              ),
              child: Text(
                'Valid until: ${subscription. formattedEndDate}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentTeal,
                ),
              ),
            ),
            const SizedBox(height:  16),
            Text(
              'Includes:  2 Mock Tests, Basic Analytics',
              textAlign: TextAlign. center,
              style: TextStyle(
                fontSize: 12,
                color:  AppColors.labelText,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style:  ElevatedButton. styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors. white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius:  BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'START EXPLORING',
                  style: TextStyle(
                    fontWeight:  FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius. circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:  const EdgeInsets. all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape:  BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors. red. shade600,
                size: 48,
              ),
            ),
            const SizedBox(height:  20),
            const Text(
              'Payment Failed',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color:  AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error,
              textAlign: TextAlign.center,
              style:  TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondaryText,
                      side: BorderSide(color: AppColors. silverBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(fontWeight: FontWeight. w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors. accentTeal,
                      foregroundColor: Colors.white,
                      padding:  const EdgeInsets. symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius. circular(10),
                      ),
                    ),
                    child: const Text(
                      'TRY AGAIN',
                      style:  TextStyle(fontWeight: FontWeight.w700),
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

  void _showHelpDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors. white,
          borderRadius: BorderRadius. only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height:  4,
              decoration: BoxDecoration(
                color: AppColors.silverBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding:  const EdgeInsets. all(20),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Need Help?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight. bold,
                      color: AppColors. primaryNavy,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:  AppColors.lightGray,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:  const Icon(
                        Icons.close_rounded,
                        color: AppColors.secondaryText,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHelpItem(
                      Icons.credit_card_rounded,
                      'Payment Issues',
                      'If your payment fails, please check your card details and try again.  Contact support if the issue persists.',
                    ),
                    _buildHelpItem(
                      Icons. autorenew_rounded,
                      'Auto-Renewal',
                      'Subscriptions (except Gold) auto-renew.  You can disable this in the subscription settings.',
                    ),
                    _buildHelpItem(
                      Icons. cancel_rounded,
                      'Cancellation',
                      'You can cancel anytime. Access continues until the end of your billing period.',
                    ),
                    _buildHelpItem(
                      Icons.upgrade_rounded,
                      'Upgrading',
                      'Upgrade anytime!  The price difference will be prorated based on remaining time.',
                    ),
                    _buildHelpItem(
                      Icons. support_agent_rounded,
                      'Contact Support',
                      'Email us at support@idaspire.com for any queries or issues.',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors. silverBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration:  BoxDecoration(
              color: AppColors.accentTeal. withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.accentTeal,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight. w600,
                    color: AppColors. primaryNavy,
                  ),
                ),
                const SizedBox(height:  4),
                Text(
                  description,
                  style:  TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    height: 1.4,
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