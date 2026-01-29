import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../subscription/presentation/bloc/subscription_bloc.dart';
import '../../../subscription/presentation/bloc/subscription_event.dart';
import '../../../subscription/presentation/bloc/subscription_state.dart';
import '../../../subscription/presentation/pages/subscription_plans_screen.dart';
import '../../../subscription/domain/entity/subscription_plan.dart';

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

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isIndia = true;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  void _checkSubscription() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<SubscriptionBloc>().add(
        CheckSubscriptionStatus(user. uid),
      );
    }
  }

  // Update the _getTierColor method in subscription_screen.dart
  Color _getTierColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'FREE':
        return AppColors.secondaryText;
      case 'BRONZE':
        return AppColors.bronze;
      case 'SILVER':
        return const Color(0xFF2E7D32); // Green shade
      case 'GOLD':
        return AppColors.gold;
      default:
        return AppColors.accentTeal;
    }
  }

  IconData _getTierIcon(String tier) {
    switch (tier.toUpperCase()) {
      case 'FREE':
        return Icons. card_giftcard_rounded;
      case 'BRONZE':
        return Icons.workspace_premium_outlined;
      case 'SILVER':
        return Icons.workspace_premium_rounded;
      case 'GOLD':
        return Icons.diamond_rounded;
      default:
        return Icons.card_membership_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            ScaffoldMessenger. of(context).showSnackBar(
              SnackBar(
                content:  Row(
                  children: const [
                    Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                    SizedBox(width:  12),
                    Text('Subscription activated successfully!'),
                  ],
                ),
                backgroundColor: Colors.green. shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius. circular(10),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
            _checkSubscription();
          } else if (state is FreeTrialActivated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle_outline, color:  Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Free trial activated!  Enjoy 2 weeks free.'),
                  ],
                ),
                backgroundColor: Colors. green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
            _checkSubscription();
          } else if (state is SubscriptionCancelled) {
            ScaffoldMessenger. of(context).showSnackBar(
              SnackBar(
                content:  Row(
                  children: const [
                    Icon(Icons.info_outline, color:  Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Subscription cancelled'),
                  ],
                ),
                backgroundColor: Colors.orange.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state is PaymentFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children:  [
                    const Icon(Icons.error_outline, color:  Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.error)),
                  ],
                ),
                backgroundColor:  Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state is SubscriptionPlansLoaded) {
            setState(() {
              _isIndia = state.isIndia;
            });
          }
        },
        builder: (context, state) {
          UserSubscription?  subscription;
          bool isSubscribed = false;

          if (state is SubscriptionActive) {
            subscription = state. subscription;
            isSubscribed = true;
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment. start,
                children: [
                  // Header
                  _buildHeader(),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:  CrossAxisAlignment.start,
                      children: [
                        // Current Subscription Card
                        _buildCurrentSubscriptionCard(
                          isSubscribed: isSubscribed,
                          subscription: subscription,
                        ),

                        const SizedBox(height: 24),

                        // Subscription Plans Section
                        const Text(
                          'Available Plans',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:  FontWeight.bold,
                            color:  AppColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Plan Cards
                        _buildPlanCard(
                          name: 'Evaluation',
                          tier: 'FREE',
                          priceINR: 0,
                          priceUSD: 0,
                          duration: '2 Weeks',
                          description: 'Free trial',
                          features:  [
                            'Text content access',
                            '2 Mock Tests (20 Qs each)',
                            'Basic Analytics',
                          ],
                          isCurrentPlan: subscription?. planTier == 'FREE',
                          isPopular: false,
                          isBestValue: false,
                        ),

                        const SizedBox(height: 12),

                        _buildPlanCard(
                          name:  'Pro',
                          tier: 'BRONZE',
                          priceINR: 149,
                          priceUSD: 2,
                          duration:  '2 Months',
                          description: 'Bronze plan',
                          features: [
                            '10 Mock Tests',
                            'Detailed Analytics',
                            'Priority Support',
                          ],
                          isCurrentPlan: subscription?.planTier == 'BRONZE',
                          isPopular: true,
                          isBestValue: false,
                        ),

                        const SizedBox(height:  12),

                        _buildPlanCard(
                          name: 'Annual',
                          tier: 'SILVER',
                          priceINR: 999,
                          priceUSD: 10,
                          duration: '1 Year',
                          description: 'Silver plan',
                          features: [
                            'Unlimited Mock Tests',
                            'Advanced Analytics',
                            'Certificate of Completion',
                          ],
                          isCurrentPlan: subscription?.planTier == 'SILVER',
                          isPopular: false,
                          isBestValue: true,
                        ),

                        const SizedBox(height:  12),

                        _buildPlanCard(
                          name: 'Unlimited',
                          tier: 'GOLD',
                          priceINR: 1999,
                          priceUSD:  20,
                          duration: 'Lifetime',
                          description: 'Gold plan',
                          features: [
                            'Lifetime Access',
                            'All Future Updates',
                            'VIP Support',
                          ],
                          isCurrentPlan:  subscription?.planTier == 'GOLD',
                          isPopular: false,
                          isBestValue: false,
                        ),

                        const SizedBox(height: 24),

                        // Features Section
                        _buildFeaturesSection(isSubscribed),

                        const SizedBox(height: 24),

                        // Manage Subscription Section (only if subscribed)
                        if (isSubscribed && subscription != null) ...[
                          _buildManageSubscriptionSection(subscription),
                          const SizedBox(height: 24),
                        ],

                        // Payment Methods Info
                        _buildPaymentMethodsInfo(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscription',
            style: TextStyle(
              fontSize:  28,
              fontWeight: FontWeight.bold,
              color:  Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your subscription and unlock premium features',
            style: TextStyle(
              fontSize: 14,
              color:  Colors.white. withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          // Location indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration:  BoxDecoration(
              color: Colors. white. withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize. min,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.white. withOpacity(0.9),
                ),
                const SizedBox(width: 4),
                Text(
                  _isIndia ? 'India (INR) • Razorpay' :  'International (USD) • Stripe',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white. withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard({
    required bool isSubscribed,
    UserSubscription? subscription,
  }) {
    final tierColor = subscription != null
        ? _getTierColor(subscription.planTier)
        : AppColors.secondaryText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isSubscribed && subscription?. planTier != 'FREE'
            ? LinearGradient(
          colors: [
            tierColor.withOpacity(0.9),
            tierColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isSubscribed ?  null : AppColors.lightGray,
        borderRadius: BorderRadius.circular(20),
        border: isSubscribed
            ? Border.all(color: tierColor, width: 2)
            : Border.all(color: AppColors.silverBorder, width: 1),
        boxShadow:  isSubscribed
            ?  [
          BoxShadow(
            color: tierColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ]
            :  null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration:  BoxDecoration(
                  color: isSubscribed
                      ? Colors.white. withOpacity(0.2)
                      :  AppColors.accentTeal. withOpacity(0.1),
                  borderRadius: BorderRadius. circular(12),
                ),
                child: Icon(
                  _getTierIcon(subscription?.planTier ??  'FREE'),
                  color: isSubscribed ?  Colors.white : AppColors.accentTeal,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Current Plan',
                          style: TextStyle(
                            fontSize:  12,
                            color: isSubscribed
                                ? Colors. white.withOpacity(0.8)
                                : AppColors.labelText,
                            fontWeight: FontWeight. w500,
                          ),
                        ),
                        if (isSubscribed) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:  Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius. circular(10),
                            ),
                            child:  Text(
                              subscription! .planTier,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight. w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSubscribed ?  subscription!.planName : 'No Active Plan',
                      style: TextStyle(
                        fontSize:  22,
                        fontWeight: FontWeight. bold,
                        color: isSubscribed ?  Colors.white : AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSubscribed && subscription?. planTier == 'GOLD')
                const Icon(
                  Icons.diamond,
                  color:  Colors.white,
                  size: 32,
                ),
            ],
          ),
          if (isSubscribed && subscription != null) ...[
            const SizedBox(height: 16),
            // Subscription details
            Container(
              padding:  const EdgeInsets. all(12),
              decoration:  BoxDecoration(
                color: Colors. white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child:  Column(
                children: [
                  _buildDetailRow(
                    Icons.calendar_today_rounded,
                    'Start Date',
                    subscription.formattedStartDate,
                    isLight: true,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.event_rounded,
                    'Expires',
                    subscription.isUnlimited
                        ? 'Lifetime Access'
                        :  subscription.formattedEndDate,
                    isLight: true,
                  ),
                  if (! subscription.isUnlimited) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.timer_outlined,
                      'Days Remaining',
                      '${subscription. daysRemaining} days',
                      isLight: true,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.payment_rounded,
                    'Amount Paid',
                    '${subscription.currency} ${subscription.amount. toStringAsFixed(0)}',
                    isLight: true,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons. autorenew_rounded,
                    'Auto-Renew',
                    subscription.autoRenew ? 'Enabled' : 'Disabled',
                    isLight: true,
                  ),
                ],
              ),
            ),
          ],
          if (! isSubscribed) ...[
            const SizedBox(height:  16),
            Text(
              'Start your free trial or upgrade to premium',
              style:  TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children:  [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final user = FirebaseAuth. instance.currentUser;
                      if (user != null) {
                        context. read<SubscriptionBloc>().add(
                          ActivateFreeTrial(user. uid),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentTeal,
                      side: const BorderSide(color: AppColors.accentTeal, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'FREE TRIAL',
                      style: TextStyle(
                        fontWeight: FontWeight. w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:  _navigateToPlans,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentTeal,
                      foregroundColor: Colors. white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'UPGRADE',
                      style:  TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize:  12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isLight = false}) {
    return Row(
      children:  [
        Icon(
          icon,
          size: 16,
          color: isLight ? Colors.white. withOpacity(0.8) : AppColors.labelText,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 12,
            color: isLight ? Colors.white.withOpacity(0.7) : AppColors.labelText,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight. w600,
            color: isLight ?  Colors.white :  AppColors.primaryNavy,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String name,
    required String tier,
    required double priceINR,
    required double priceUSD,
    required String duration,
    required String description,
    required List<String> features,
    required bool isCurrentPlan,
    required bool isPopular,
    required bool isBestValue,
  }) {
    final tierColor = _getTierColor(tier);
    final price = _isIndia ? '₹${priceINR.toInt()}' : '\$${priceUSD.toInt()}';
    final isFree = priceINR == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentPlan ?  tierColor. withOpacity(0.08) : AppColors.lightGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlan ? tierColor :  AppColors.silverBorder,
          width: isCurrentPlan ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment. spaceBetween,
            children: [
              Row(
                children:  [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:  tierColor.withOpacity(0.15),
                      borderRadius: BorderRadius. circular(8),
                    ),
                    child:  Icon(
                      _getTierIcon(tier),
                      color: tierColor,
                      size:  20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight. bold,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:  tierColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tier,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight. w700,
                                color: tierColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$duration • $description',
                        style: TextStyle(
                          fontSize:  11,
                          color: AppColors.labelText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children:  [
                  Text(
                    isFree ? 'FREE' : price,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight. bold,
                      color: tierColor,
                    ),
                  ),
                  if (isPopular)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration:  BoxDecoration(
                        color: AppColors.accentTeal,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child:  const Text(
                        'POPULAR',
                        style: TextStyle(
                          fontSize:  8,
                          fontWeight: FontWeight. w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (isBestValue)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration:  BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius. circular(6),
                      ),
                      child: const Text(
                        'BEST VALUE',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (isCurrentPlan)
                    Container(
                      margin:  const EdgeInsets. only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'CURRENT',
                        style:  TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight. w700,
                          color: Colors. white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing:  12,
            runSpacing: 6,
            children:  features.map((feature) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: tierColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    feature,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          if (! isCurrentPlan && !isFree) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _navigateToPlans,
                style:  OutlinedButton. styleFrom(
                  foregroundColor:  tierColor,
                  side: BorderSide(color: tierColor, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'SELECT PLAN',
                  style: TextStyle(
                    fontWeight: FontWeight. w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(bool isSubscribed) {
    final features = [
      {'icon': Icons.assignment_turned_in_rounded, 'title': 'Mock Exams', 'locked': ! isSubscribed},
      {'icon': Icons.analytics_rounded, 'title':  'Analytics', 'locked':  !isSubscribed},
      {'icon':  Icons.card_membership_rounded, 'title': 'Certificates', 'locked':  !isSubscribed},
      {'icon':  Icons.menu_book_rounded, 'title': 'Courses', 'locked':  true, 'comingSoon': true},
      {'icon': Icons. videocam_rounded, 'title': 'Webinars', 'locked': true, 'comingSoon': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight. bold,
            color: AppColors.primaryNavy,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing:  10,
          runSpacing: 10,
          children:  features.map((feature) {
            final isLocked = feature['locked'] as bool;
            final isComingSoon = feature['comingSoon'] as bool?  ??  false;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration:  BoxDecoration(
                color: isLocked ? AppColors. lightGray : AppColors.accentTeal. withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isLocked ? AppColors.silverBorder : AppColors.accentTeal. withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize:  MainAxisSize.min,
                children:  [
                  Icon(
                    feature['icon'] as IconData,
                    size: 16,
                    color: isLocked ?  AppColors.labelText : AppColors. accentTeal,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    feature['title'] as String,
                    style: TextStyle(
                      fontSize:  12,
                      fontWeight: FontWeight. w500,
                      color: isLocked ?  AppColors.labelText : AppColors.accentTeal,
                    ),
                  ),
                  if (isComingSoon) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color:  AppColors.gold. withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child:  Text(
                        'SOON',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight. w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ] else if (isLocked) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.lock_outline, size: 12, color: AppColors.labelText),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildManageSubscriptionSection(UserSubscription subscription) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius:  BorderRadius.circular(16),
        border: Border.all(color: AppColors.silverBorder),
      ),
      child: Column(
        crossAxisAlignment:  CrossAxisAlignment.start,
        children:  [
          Row(
            children: const [
              Icon(Icons.settings_rounded, color: AppColors.primaryNavy, size: 20),
              SizedBox(width:  8),
              Text(
                'Manage Subscription',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildManageOption(
            icon: Icons.autorenew_rounded,
            title: 'Auto-Renewal',
            subtitle: subscription.autoRenew ? 'Enabled' : 'Disabled',
            trailing: Switch(
              value:  subscription.autoRenew,
              onChanged: subscription.isUnlimited
                  ? null
                  : (value) {
                final user = FirebaseAuth. instance.currentUser;
                if (user != null) {
                  context. read<SubscriptionBloc>().add(
                    UpdateAutoRenew(userId: user.uid, autoRenew:  value),
                  );
                }
              },
              activeColor: AppColors. accentTeal,
            ),
          ),
          const Divider(height: 20),
          _buildManageOption(
            icon: Icons. upgrade_rounded,
            title: 'Upgrade Plan',
            subtitle:  'Switch to a higher tier',
            onTap: _navigateToPlans,
          ),
          const Divider(height: 20),
          _buildManageOption(
            icon: Icons.cancel_rounded,
            title: 'Cancel Subscription',
            subtitle: 'End your subscription',
            titleColor: Colors.red. shade600,
            onTap: () => _showCancelDialog(subscription),
          ),
        ],
      ),
    );
  }

  Widget _buildManageOption({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child:  Row(
        children: [
          Icon(icon, color: titleColor ?? AppColors.secondaryText, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize:  14,
                    fontWeight: FontWeight. w600,
                    color: titleColor ?? AppColors.primaryNavy,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: AppColors.labelText),
                ),
              ],
            ),
          ),
          if (trailing != null)
            trailing
          else if (onTap != null)
            const Icon(Icons.chevron_right_rounded, color: AppColors.labelText, size: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:  AppColors.lightGray,
        borderRadius: BorderRadius. circular(16),
        border: Border. all(color: AppColors.silverBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment. start,
        children: [
          Row(
            children:  const [
              Icon(Icons.security_rounded, color: AppColors.primaryNavy, size: 20),
              SizedBox(width: 8),
              Text(
                'Secure Payment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPaymentBadge('Razorpay', Icons.account_balance_wallet_rounded),
              const SizedBox(width: 10),
              _buildPaymentBadge('Stripe', Icons.credit_card_rounded),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isIndia
                ? 'Payments in India are processed securely via Razorpay'
                : 'International payments are processed securely via Stripe',
            style: TextStyle(fontSize: 11, color: AppColors.labelText),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(String name, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentTeal.withOpacity(0.1),
        borderRadius: BorderRadius. circular(8),
        border: Border.all(color: AppColors.accentTeal.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accentTeal),
          const SizedBox(width:  4),
          Text(
            name,
            style: TextStyle(
              fontSize:  11,
              fontWeight: FontWeight.w600,
              color:  AppColors.accentTeal,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(UserSubscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(20)),
        title: const Text(
          'Cancel Subscription? ',
          style:  TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors. primaryNavy,
          ),
        ),
        content: Text(
          subscription.isUnlimited
              ? 'Are you sure you want to cancel your lifetime subscription?  This action cannot be undone.'
              : 'Are you sure you want to cancel?  You will lose access to premium features on ${subscription.formattedEndDate}.',
          style: const TextStyle(fontSize: 14, color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'KEEP PLAN',
              style:  TextStyle(
                color: AppColors.accentTeal,
                fontWeight: FontWeight. w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator. pop(context);
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                context.read<SubscriptionBloc>().add(CancelSubscription(user.uid));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red. shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(10)),
            ),
            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight. w700)),
          ),
        ],
      ),
    );
  }

  void _navigateToPlans() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => BlocProvider. value(
          value: context.read<SubscriptionBloc>(),
          child: const SubscriptionPlansScreen(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:  Tween<Offset>(
              begin: const Offset(0, 1),
              end:  Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve:  Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}