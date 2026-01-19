import 'package:equatable/equatable.dart';
import '../../domain/entity/subscription_plan.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscriptionPlans extends SubscriptionEvent {}

class SelectPlan extends SubscriptionEvent {
  final SubscriptionPlan plan;

  const SelectPlan(this.plan);

  @override
  List<Object?> get props => [plan];
}

class CheckSubscriptionStatus extends SubscriptionEvent {
  final String userId;

  const CheckSubscriptionStatus(this.userId);

  @override
  List<Object?> get props => [userId];
}

class StartPayment extends SubscriptionEvent {
  final SubscriptionPlan plan;
  final String userId;
  final bool isIndia;

  const StartPayment({
    required this.plan,
    required this.userId,
    required this.isIndia,
  });

  @override
  List<Object?> get props => [plan, userId, isIndia];
}

class PaymentCompleted extends SubscriptionEvent {
  final String paymentId;
  final String paymentGateway;

  const PaymentCompleted({
    required this.paymentId,
    required this.paymentGateway,
  });

  @override
  List<Object?> get props => [paymentId, paymentGateway];
}

class PaymentFailed extends SubscriptionEvent {
  final String error;

  const PaymentFailed(this.error);

  @override
  List<Object?> get props => [error];
}