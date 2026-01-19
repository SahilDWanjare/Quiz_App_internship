import 'package:equatable/equatable.dart';

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final String tier; // BASE, PRO, PLUS
  final int durationMonths;
  final double price;
  final String currency;
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.tier,
    required this.durationMonths,
    required this.price,
    required this.currency,
    required this.features,
    this.isPopular = false,
  });

  String get displayPrice {
    if (durationMonths == 1) {
      return '\$${price.toInt()}/Month';
    } else if (durationMonths == 6) {
      return '\$${price.toInt()}/6 M\'s';
    } else {
      return '\$${price.toInt()}/Year';
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    tier,
    durationMonths,
    price,
    currency,
    features,
    isPopular,
  ];
}

class UserSubscription extends Equatable {
  final String userId;
  final String planId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String paymentId;
  final String paymentGateway; // stripe or razorpay

  const UserSubscription({
    required this.userId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.paymentId,
    required this.paymentGateway,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);

  @override
  List<Object?> get props => [
    userId,
    planId,
    startDate,
    endDate,
    isActive,
    paymentId,
    paymentGateway,
  ];
}