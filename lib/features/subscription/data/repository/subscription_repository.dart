import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entity/subscription_plan.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore;

  SubscriptionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    // In production, fetch from Firestore
    // For now, returning hardcoded plans
    return [
      const SubscriptionPlan(
        id: 'base_1month',
        name: '1 MONTH PLAN',
        tier: 'BASE',
        durationMonths: 1,
        price: 90,
        currency: 'USD',
        features: [
          'limited attempts',
          'Test Analytics',
          'Dashboard overview',
        ],
        isPopular: false,
      ),
      const SubscriptionPlan(
        id: 'pro_6month',
        name: '6 MONTH PLAN',
        tier: 'PRO',
        durationMonths: 6,
        price: 120,
        currency: 'USD',
        features: [
          'Unlimited attempts',
          'Test Analytics',
          'Dashboard overview',
        ],
        isPopular: true,
      ),
      const SubscriptionPlan(
        id: 'plus_1year',
        name: '1 YEAR PLAN',
        tier: 'PLUS',
        durationMonths: 12,
        price: 260,
        currency: 'USD',
        features: [
          'Unlimited attempts',
          'Test Analytics with marks',
          'Dashboard overview',
        ],
        isPopular: false,
      ),
    ];
  }

  Future<UserSubscription?> getUserSubscription(String userId) async {
    try {
      final doc = await _firestore
          .collection('subscriptions')
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return UserSubscription(
        userId: data['userId'],
        planId: data['planId'],
        startDate: (data['startDate'] as Timestamp).toDate(),
        endDate: (data['endDate'] as Timestamp).toDate(),
        isActive: data['isActive'],
        paymentId: data['paymentId'],
        paymentGateway: data['paymentGateway'],
      );
    } catch (e) {
      print('Error getting subscription: $e');
      return null;
    }
  }

  Future<UserSubscription> createSubscription({
    required String userId,
    required SubscriptionPlan plan,
    required String paymentId,
    required String paymentGateway,
  }) async {
    final startDate = DateTime.now();
    final endDate = DateTime.now().add(
      Duration(days: plan.durationMonths * 30),
    );

    final subscription = UserSubscription(
      userId: userId,
      planId: plan.id,
      startDate: startDate,
      endDate: endDate,
      isActive: true,
      paymentId: paymentId,
      paymentGateway: paymentGateway,
    );

    final data = {
      'userId': userId,
      'planId': plan.id,
      'planName': plan.name,
      'planTier': plan.tier,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': true,
      'paymentId': paymentId,
      'paymentGateway': paymentGateway,
      'amount': plan.price,
      'currency': plan.currency,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('subscriptions').doc(userId).set(data);

    return subscription;
  }

  Future<void> cancelSubscription(String userId) async {
    await _firestore.collection('subscriptions').doc(userId).update({
      'isActive': false,
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }
}