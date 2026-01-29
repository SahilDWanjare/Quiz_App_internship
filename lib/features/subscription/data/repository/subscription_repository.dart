import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entity/subscription_plan.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore;

  SubscriptionRepository({FirebaseFirestore?  firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Subscription Plans with new pricing
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    return [
      const SubscriptionPlan(
        id:  'free_evaluation',
        name:  'Evaluation',
        tier:  'FREE',
        durationDays: 14,
        priceINR: 0,
        priceUSD: 0,
        description: '2 weeks free trial',
        features: [
          'Text content access',
          '2 Mock Tests (20 Questions each)',
          'Basic Analytics',
          'Email Support',
        ],
        isPopular: false,
        isBestValue: false,
      ),
      const SubscriptionPlan(
        id: 'bronze_pro',
        name:  'Pro',
        tier: 'BRONZE',
        durationDays:  60,
        priceINR:  149,
        priceUSD: 2,
        description: '2 months subscription',
        features:  [
          'All Evaluation features',
          '10 Mock Tests',
          'Detailed Analytics',
          'Priority Support',
          'Performance Reports',
        ],
        isPopular:  true,
        isBestValue: false,
      ),
      const SubscriptionPlan(
        id: 'silver_annual',
        name:  'Annual',
        tier: 'SILVER',
        durationDays:  365,
        priceINR:  999,
        priceUSD: 10,
        description:  '1 year subscription',
        features:  [
          'All Pro features',
          'Unlimited Mock Tests',
          'Advanced Analytics',
          'Certificate of Completion',
          'Early Access to New Features',
          'Priority Support',
        ],
        isPopular:  false,
        isBestValue: true,
      ),
      const SubscriptionPlan(
        id: 'gold_unlimited',
        name:  'Unlimited',
        tier: 'GOLD',
        durationDays: -1,
        priceINR: 1,
        priceUSD: 20,
        description:  'Lifetime access',
        features:  [
          'All Annual features',
          'Lifetime Access',
          'All Future Updates',
          'Exclusive Webinars',
          'VIP Support',
          'Personalized Dashboard',
          'Custom Reports',
        ],
        isPopular:  false,
        isBestValue: false,
      ),
    ];
  }

  Future<UserSubscription? > getUserSubscription(String userId) async {
    try {
      print('DEBUG:  Fetching subscription for userId: $userId');

      final doc = await _firestore
          .collection('subscriptions')
          .doc(userId)
          .get();

      if (! doc.exists) {
        print('DEBUG: No subscription document found for userId: $userId');
        return null;
      }

      final data = doc.data()!;
      print('DEBUG:  Subscription data found: $data');

      final subscription = UserSubscription. fromFirestore(data, doc.id);

      print('DEBUG: Parsed subscription: ');
      print('  - planName: ${subscription.planName}');
      print('  - planTier: ${subscription.planTier}');
      print('  - isActive: ${subscription. isActive}');
      print('  - isExpired: ${subscription. isExpired}');
      print('  - endDate: ${subscription. formattedEndDate}');

      return subscription;
    } catch (e, stackTrace) {
      print('ERROR getting subscription: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<UserSubscription> createSubscription({
    required String userId,
    required SubscriptionPlan plan,
    required String paymentId,
    required String paymentGateway,
    required bool isIndia,
  }) async {
    try {
      print('DEBUG: Creating subscription for userId: $userId');
      print('DEBUG: Plan:  ${plan.name} (${plan.tier})');

      final startDate = DateTime.now();
      final bool isUnlimited = plan. durationDays == -1;

      DateTime endDate;
      if (isUnlimited) {
        endDate = DateTime(2099, 12, 31);
      } else {
        endDate = startDate.add(Duration(days: plan. durationDays));
      }

      final amount = plan.getPrice(isIndia);
      final currency = plan.getCurrency(isIndia);

      final data = {
        'userId': userId,
        'planId':  plan.id,
        'planName':  plan.name,
        'planTier': plan.tier,
        'startDate':  Timestamp.fromDate(startDate),
        'endDate':  Timestamp.fromDate(endDate),
        'isActive': true,
        'paymentId': paymentId,
        'paymentGateway': paymentGateway,
        'amount': amount,
        'currency': currency,
        'isUnlimited': isUnlimited,
        'autoRenew': ! isUnlimited,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt':  FieldValue.serverTimestamp(),
      };

      print('DEBUG: Saving subscription data to Firestore:  $data');

      await _firestore.collection('subscriptions').doc(userId).set(data);

      print('DEBUG:  Subscription saved successfully! ');

      // Also save to payments collection for history
      await _savePaymentRecord(
        userId: userId,
        paymentId: paymentId,
        planId: plan.id,
        planName: plan.name,
        amount: amount,
        currency: currency,
        paymentGateway:  paymentGateway,
        status: 'success',
      );

      return UserSubscription(
        id: userId,
        userId:  userId,
        planId: plan.id,
        planName: plan.name,
        planTier: plan.tier,
        startDate:  startDate,
        endDate: endDate,
        isActive: true,
        paymentId: paymentId,
        paymentGateway: paymentGateway,
        amount: amount,
        currency: currency,
        isUnlimited: isUnlimited,
        autoRenew: !isUnlimited,
      );
    } catch (e, stackTrace) {
      print('ERROR creating subscription:  $e');
      print('Stack trace:  $stackTrace');
      rethrow;
    }
  }

  Future<UserSubscription> activateFreeTrial(String userId) async {
    try {
      print('DEBUG: Activating free trial for userId: $userId');

      final startDate = DateTime.now();
      final endDate = startDate. add(const Duration(days: 14));

      final data = {
        'userId': userId,
        'planId': 'free_evaluation',
        'planName': 'Evaluation',
        'planTier':  'FREE',
        'startDate':  Timestamp.fromDate(startDate),
        'endDate':  Timestamp.fromDate(endDate),
        'isActive':  true,
        'paymentId': 'free_trial_${DateTime.now().millisecondsSinceEpoch}',
        'paymentGateway': 'none',
        'amount': 0,
        'currency': 'INR',
        'isUnlimited': false,
        'autoRenew': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('DEBUG:  Saving free trial data to Firestore:  $data');

      await _firestore.collection('subscriptions').doc(userId).set(data);

      print('DEBUG: Free trial activated successfully!');

      return UserSubscription(
        id: userId,
        userId:  userId,
        planId: 'free_evaluation',
        planName: 'Evaluation',
        planTier: 'FREE',
        startDate: startDate,
        endDate: endDate,
        isActive: true,
        paymentId: 'free_trial_${DateTime.now().millisecondsSinceEpoch}',
        paymentGateway: 'none',
        amount:  0,
        currency: 'INR',
        isUnlimited: false,
        autoRenew: false,
      );
    } catch (e, stackTrace) {
      print('ERROR activating free trial: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> cancelSubscription(String userId) async {
    try {
      print('DEBUG: Cancelling subscription for userId: $userId');

      await _firestore.collection('subscriptions').doc(userId).update({
        'isActive': false,
        'autoRenew': false,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt':  FieldValue.serverTimestamp(),
      });

      print('DEBUG: Subscription cancelled successfully!');
    } catch (e) {
      print('ERROR cancelling subscription:  $e');
      rethrow;
    }
  }

  Future<void> updateAutoRenew(String userId, bool autoRenew) async {
    try {
      print('DEBUG: Updating auto-renew to $autoRenew for userId: $userId');

      await _firestore.collection('subscriptions').doc(userId).update({
        'autoRenew': autoRenew,
        'updatedAt':  FieldValue.serverTimestamp(),
      });

      print('DEBUG: Auto-renew updated successfully!');
    } catch (e) {
      print('ERROR updating auto-renew: $e');
      rethrow;
    }
  }

  Future<void> _savePaymentRecord({
    required String userId,
    required String paymentId,
    required String planId,
    required String planName,
    required double amount,
    required String currency,
    required String paymentGateway,
    required String status,
  }) async {
    try {
      await _firestore.collection('payments').add({
        'userId': userId,
        'paymentId':  paymentId,
        'planId':  planId,
        'planName': planName,
        'amount': amount,
        'currency': currency,
        'paymentGateway':  paymentGateway,
        'status': status,
        'createdAt':  FieldValue.serverTimestamp(),
      });
      print('DEBUG: Payment record saved successfully!');
    } catch (e) {
      print('ERROR saving payment record: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBillingHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs. map((doc) => {
        ... doc.data(),
        'id': doc.id,
      }).toList();
    } catch (e) {
      print('ERROR getting billing history: $e');
      return [];
    }
  }
}