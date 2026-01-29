import 'package:equatable/equatable.dart';

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final String tier; // FREE, BRONZE, SILVER, GOLD
  final int durationDays; // Duration in days (-1 for lifetime)
  final double priceINR;
  final double priceUSD;
  final List<String> features;
  final bool isPopular;
  final bool isBestValue;
  final String description;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this. tier,
    required this.durationDays,
    required this.priceINR,
    required this.priceUSD,
    required this.features,
    this.isPopular = false,
    this.isBestValue = false,
    this.description = '',
  });

  String getDisplayPrice(bool isIndia) {
    if (isIndia) {
      if (priceINR == 0) return 'FREE';
      return '₹${priceINR.toInt()}';
    } else {
      if (priceUSD == 0) return 'FREE';
      return '\$${priceUSD.toInt()}';
    }
  }

  String get durationText {
    if (durationDays == 14) return '2 Weeks';
    if (durationDays == 60) return '2 Months';
    if (durationDays == 365) return '1 Year';
    if (durationDays == -1) return 'Lifetime';
    return '$durationDays Days';
  }

  double getPrice(bool isIndia) {
    return isIndia ? priceINR : priceUSD;
  }

  String getCurrency(bool isIndia) {
    return isIndia ? 'INR' :  'USD';
  }

  @override
  List<Object? > get props => [
    id,
    name,
    tier,
    durationDays,
    priceINR,
    priceUSD,
    features,
    isPopular,
    isBestValue,
    description,
  ];
}

class UserSubscription extends Equatable {
  final String id;
  final String userId;
  final String planId;
  final String planName;
  final String planTier;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String paymentId;
  final String paymentGateway;
  final double amount;
  final String currency;
  final bool isUnlimited;
  final bool autoRenew;

  const UserSubscription({
    required this.id,
    required this.userId,
    required this. planId,
    required this.planName,
    required this.planTier,
    required this. startDate,
    required this.endDate,
    required this.isActive,
    required this.paymentId,
    required this.paymentGateway,
    required this.amount,
    required this.currency,
    this.isUnlimited = false,
    this.autoRenew = true,
  });

  bool get isExpired {
    if (isUnlimited) return false;
    return DateTime.now().isAfter(endDate);
  }

  int get daysRemaining {
    if (isUnlimited) return -1;
    final remaining = endDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  String get formattedEndDate {
    if (isUnlimited) return 'Lifetime Access';
    return '${endDate.day. toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
  }

  String get formattedStartDate {
    return '${startDate. day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';
  }

  // Create from Firebase document
  factory UserSubscription.fromFirestore(Map<String, dynamic> data, String docId) {
    DateTime startDate;
    DateTime endDate;

    // Handle Timestamp conversion
    if (data['startDate'] != null) {
      startDate = (data['startDate'] as dynamic).toDate();
    } else {
      startDate = DateTime.now();
    }

    if (data['endDate'] != null) {
      endDate = (data['endDate'] as dynamic).toDate();
    } else {
      endDate = DateTime. now().add(const Duration(days: 14));
    }

    return UserSubscription(
      id:  docId,
      userId: data['userId'] ?? '',
      planId: data['planId'] ?? '',
      planName: data['planName'] ??  'Unknown',
      planTier: data['planTier'] ?? 'FREE',
      startDate: startDate,
      endDate: endDate,
      isActive: data['isActive'] ??  false,
      paymentId: data['paymentId'] ??  '',
      paymentGateway: data['paymentGateway'] ?? '',
      amount: (data['amount'] ??  0).toDouble(),
      currency: data['currency'] ??  'INR',
      isUnlimited: data['isUnlimited'] ?? false,
      autoRenew: data['autoRenew'] ?? true,
    );
  }

  // Convert to Firebase document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'planId': planId,
      'planName': planName,
      'planTier': planTier,
      'startDate': startDate,
      'endDate': endDate,
      'isActive':  isActive,
      'paymentId':  paymentId,
      'paymentGateway': paymentGateway,
      'amount': amount,
      'currency': currency,
      'isUnlimited': isUnlimited,
      'autoRenew': autoRenew,
    };
  }

  @override
  List<Object? > get props => [
    id,
    userId,
    planId,
    planName,
    planTier,
    startDate,
    endDate,
    isActive,
    paymentId,
    paymentGateway,
    amount,
    currency,
    isUnlimited,
    autoRenew,
  ];
}