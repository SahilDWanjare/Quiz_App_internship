import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entity/subscription_plan.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';
import '../../data/services/payment_service.dart';
import '../widgets/plan_card.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(LoadSubscriptionPlans());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D121F)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            _showSuccessDialog();
          } else if (state is PaymentFailure) {
            _showErrorDialog(state.error);
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0D121F),
              ),
            );
          }

          if (state is SubscriptionPlansLoaded) {
            return _buildPlansView(state.plans, state.selectedPlan);
          }

          if (state is PaymentProcessing) {
            return _buildProcessingView();
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPlansView(
      List<SubscriptionPlan> plans,
      SubscriptionPlan? selectedPlan,
      ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHOOSE YOUR PLAN',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D121F),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                ...plans.map((plan) {
                  final isSelected = selectedPlan?.id == plan.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PlanCard(
                      plan: plan,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<SubscriptionBloc>().add(
                          SelectPlan(plan),
                        );
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        _buildBottomButton(selectedPlan),
      ],
    );
  }

  Widget _buildBottomButton(SubscriptionPlan? selectedPlan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedPlan != null ? () => _handlePayment(selectedPlan) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D121F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: const Text(
              'PROCEED TO SUBSCRIBE',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF0D121F),
          ),
          const SizedBox(height: 24),
          const Text(
            'Processing Payment...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D121F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we process your payment',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment(SubscriptionPlan plan) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog('Please sign in to continue');
      return;
    }

    // Check user location
    final locationService = LocationService();
    final isIndia = await locationService.isUserInIndia();

    print('User location: ${isIndia ? "India" : "International"}');
    print('Payment gateway: ${isIndia ? "Razorpay" : "Stripe"}');

    if (!mounted) return;

    // Start payment
    context.read<SubscriptionBloc>().add(
      StartPayment(
        plan: plan,
        userId: user.uid,
        isIndia: isIndia,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Success!'),
          ],
        ),
        content: const Text(
          'Your subscription has been activated successfully. You can now proceed with the assessment.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to home
            },
            child: const Text(
              'CONTINUE',
              style: TextStyle(
                color: Color(0xFF0D121F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Payment Failed'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'TRY AGAIN',
              style: TextStyle(
                color: Color(0xFF0D121F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}