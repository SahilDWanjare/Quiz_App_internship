import 'package:equatable/equatable.dart';
import '../../domain/entity/subscription_plan.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionPlansLoaded extends SubscriptionState {
  final List<SubscriptionPlan> plans;
  final SubscriptionPlan? selectedPlan;

  const SubscriptionPlansLoaded({
    required this.plans,
    this.selectedPlan,
  });

  @override
  List<Object?> get props => [plans, selectedPlan];
}

class SubscriptionActive extends SubscriptionState {
  final UserSubscription subscription;

  const SubscriptionActive(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionInactive extends SubscriptionState {}

class PaymentProcessing extends SubscriptionState {}

class PaymentSuccess extends SubscriptionState {
  final UserSubscription subscription;

  const PaymentSuccess(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class PaymentFailure extends SubscriptionState {
  final String error;

  const PaymentFailure(this.error);

  @override
  List<Object?> get props => [error];
}