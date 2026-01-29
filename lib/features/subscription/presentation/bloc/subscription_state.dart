import 'package:equatable/equatable.dart';
import '../../domain/entity/subscription_plan.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object? > get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionPlansLoaded extends SubscriptionState {
  final List<SubscriptionPlan> plans;
  final SubscriptionPlan?  selectedPlan;
  final bool isIndia;

  const SubscriptionPlansLoaded({
    required this.plans,
    this.selectedPlan,
    this.isIndia = true,
  });

  @override
  List<Object?> get props => [plans, selectedPlan, isIndia];
}

class SubscriptionActive extends SubscriptionState {
  final UserSubscription subscription;

  const SubscriptionActive(this.subscription);

  // Convenience getters
  String get planName => subscription.planName;
  String get planTier => subscription.planTier;
  String get expiryDate => subscription.formattedEndDate;
  String get startDate => subscription.formattedStartDate;
  int get daysRemaining => subscription.daysRemaining;
  bool get isUnlimited => subscription. isUnlimited;
  bool get autoRenew => subscription.autoRenew;
  double get amount => subscription. amount;
  String get currency => subscription. currency;

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

class FreeTrialActivated extends SubscriptionState {
  final UserSubscription subscription;

  const FreeTrialActivated(this. subscription);

  @override
  List<Object?> get props => [subscription];
}

class AutoRenewUpdated extends SubscriptionState {
  final bool autoRenew;

  const AutoRenewUpdated(this.autoRenew);

  @override
  List<Object?> get props => [autoRenew];
}

class SubscriptionCancelled extends SubscriptionState {}