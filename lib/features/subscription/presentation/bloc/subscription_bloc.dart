import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/subscription_repository.dart';
import '../../domain/entity/subscription_plan.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';
import '../../data/services/payment_service.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository subscriptionRepository;
  final RazorpayService razorpayService;
  final StripeService stripeService;
  final LocationService locationService;

  SubscriptionPlan? _selectedPlan;
  String? _currentUserId;
  bool _isIndia = true;

  SubscriptionBloc({
    required this.subscriptionRepository,
    required this.razorpayService,
    required this.stripeService,
    required this.locationService,
  }) : super(SubscriptionInitial()) {
    on<LoadSubscriptionPlans>(_onLoadPlans);
    on<SelectPlan>(_onSelectPlan);
    on<CheckSubscriptionStatus>(_onCheckStatus);
    on<StartPayment>(_onStartPayment);
    on<PaymentCompleted>(_onPaymentCompleted);
    on<PaymentFailed>(_onPaymentFailed);
    on<ActivateFreeTrial>(_onActivateFreeTrial);
    on<UpdateAutoRenew>(_onUpdateAutoRenew);
    on<CancelSubscription>(_onCancelSubscription);

    // Set up Razorpay callbacks
    razorpayService. setCallbacks(
      onSuccess: (paymentId) {
        print('DEBUG BLOC: Razorpay payment success callback - paymentId: $paymentId');
        add(PaymentCompleted(
          paymentId:  paymentId,
          paymentGateway:  'razorpay',
          isIndia: true,
        ));
      },
      onError: (error) {
        print('DEBUG BLOC:  Razorpay payment error callback - error: $error');
        add(PaymentFailed(error));
      },
    );
  }

  Future<void> _onLoadPlans(
      LoadSubscriptionPlans event,
      Emitter<SubscriptionState> emit,
      ) async {
    print('DEBUG BLOC:  Loading subscription plans.. .');
    emit(SubscriptionLoading());

    try {
      _isIndia = await locationService.isUserInIndia();
      print('DEBUG BLOC:  User location - isIndia: $_isIndia');

      final plans = await subscriptionRepository.getSubscriptionPlans();
      print('DEBUG BLOC:  Loaded ${plans.length} plans');

      emit(SubscriptionPlansLoaded(
        plans: plans,
        selectedPlan: _selectedPlan,
        isIndia: _isIndia,
      ));
    } catch (e) {
      print('DEBUG BLOC: Error loading plans - $e');
      emit(PaymentFailure('Failed to load plans:  $e'));
    }
  }

  Future<void> _onSelectPlan(
      SelectPlan event,
      Emitter<SubscriptionState> emit,
      ) async {
    print('DEBUG BLOC: Plan selected - ${event.plan.name} (${event.plan.tier})');
    _selectedPlan = event.plan;

    if (state is SubscriptionPlansLoaded) {
      final currentState = state as SubscriptionPlansLoaded;
      emit(SubscriptionPlansLoaded(
        plans: currentState.plans,
        selectedPlan: event.plan,
        isIndia: currentState.isIndia,
      ));
    }
  }

  Future<void> _onCheckStatus(
      CheckSubscriptionStatus event,
      Emitter<SubscriptionState> emit,
      ) async {
    print('DEBUG BLOC: Checking subscription status for userId: ${event.userId}');
    _currentUserId = event.userId;
    emit(SubscriptionLoading());

    try {
      final subscription = await subscriptionRepository.getUserSubscription(
        event.userId,
      );

      if (subscription != null) {
        print('DEBUG BLOC:  Subscription found: ');
        print('  - planName: ${subscription.planName}');
        print('  - planTier: ${subscription.planTier}');
        print('  - isActive: ${subscription.isActive}');
        print('  - isExpired:  ${subscription.isExpired}');

        if (subscription.isActive && ! subscription.isExpired) {
          print('DEBUG BLOC:  Subscription is ACTIVE');
          emit(SubscriptionActive(subscription));
        } else {
          print('DEBUG BLOC: Subscription is INACTIVE (expired or not active)');
          emit(SubscriptionInactive());
        }
      } else {
        print('DEBUG BLOC: No subscription found - user is INACTIVE');
        emit(SubscriptionInactive());
      }
    } catch (e) {
      print('DEBUG BLOC: Error checking status - $e');
      emit(SubscriptionInactive());
    }
  }

  Future<void> _onStartPayment(
      StartPayment event,
      Emitter<SubscriptionState> emit,
      ) async {
    print('DEBUG BLOC: Starting payment...');
    print('  - Plan: ${event.plan.name} (${event.plan.tier})');
    print('  - UserId: ${event. userId}');
    print('  - isIndia: ${event.isIndia}');

    emit(PaymentProcessing());
    _selectedPlan = event. plan;
    _currentUserId = event.userId;
    _isIndia = event.isIndia;

    try {
      if (event.isIndia) {
        print('DEBUG BLOC:  Processing payment with Razorpay...');
        print('  - Amount: ₹${event. plan.priceINR}');

        await razorpayService.processPayment(
          amount: event.plan. priceINR,
          currency: 'INR',
          userId: event.userId,
          planId: event.plan.id,
          planName: event.plan.name,
        );
        // Payment result will be handled by Razorpay callbacks
      } else {
        print('DEBUG BLOC: Processing payment with Stripe...');
        print('  - Amount: \$${event.plan.priceUSD}');

        final paymentId = await stripeService.processPayment(
          amount: event.plan.priceUSD,
          currency: 'USD',
          userId:  event.userId,
          planId: event.plan.id,
        );

        print('DEBUG BLOC: Stripe payment successful - paymentId:  $paymentId');

        // Stripe returns immediately after successful payment
        add(PaymentCompleted(
          paymentId: paymentId,
          paymentGateway: 'stripe',
          isIndia: false,
        ));
      }
    } catch (e) {
      print('DEBUG BLOC: Payment error - $e');
      emit(PaymentFailure('Payment failed: $e'));
    }
  }

  Future<void> _onPaymentCompleted(
      PaymentCompleted event,
      Emitter<SubscriptionState> emit,
      ) async {
    print('DEBUG BLOC: Payment completed! ');
    print('  - paymentId: ${event.paymentId}');
    print('  - paymentGateway: ${event.paymentGateway}');
    print('  - isIndia: ${event.isIndia}');

    try {
      if (_selectedPlan == null) {
        print('DEBUG BLOC: ERROR - selectedPlan is null');
        emit(const PaymentFailure('Invalid payment state:  No plan selected'));
        return;
      }

      if (_currentUserId == null) {
        print('DEBUG BLOC:  ERROR - currentUserId is null');
        emit(const PaymentFailure('Invalid payment state: No user ID'));
        return;
      }

      print('DEBUG BLOC:  Creating subscription in Firestore...');

      // Save subscription to Firestore
      final subscription = await subscriptionRepository.createSubscription(
        userId:  _currentUserId! ,
        plan: _selectedPlan!,
        paymentId: event. paymentId,
        paymentGateway: event.paymentGateway,
        isIndia: event.isIndia,
      );

      print('DEBUG BLOC: Subscription created successfully!');
      print('  - planName: ${subscription.planName}');
      print('  - endDate: ${subscription. formattedEndDate}');

      emit(PaymentSuccess(subscription));
    } catch (e) {
      print('DEBUG BLOC: Error saving subscription - $e');
      emit(PaymentFailure('Failed to save subscription: $e'));
    }
  }

  Future<void> _onPaymentFailed(
      PaymentFailed event,
      Emitter<SubscriptionState> emit,
      ) async {
    print('DEBUG BLOC:  Payment failed - ${event.error}');
    emit(PaymentFailure(event.error));
  }

  Future<void> _onActivateFreeTrial(
      ActivateFreeTrial event,
      Emitter<SubscriptionState> emit,
      ) async {
    print('DEBUG BLOC: Activating free trial for userId: ${event.userId}');
    emit(SubscriptionLoading());

    try {
      final subscription = await subscriptionRepository.activateFreeTrial(event.userId);

      print('DEBUG BLOC: Free trial activated successfully!');
      print('  - endDate: ${subscription. formattedEndDate}');

      emit(FreeTrialActivated(subscription));
    } catch (e) {
      print('DEBUG BLOC: Error activating free trial - $e');
      emit(PaymentFailure('Failed to activate free trial:  $e'));
    }
  }

  Future<void> _onUpdateAutoRenew(
      UpdateAutoRenew event,
      Emitter<SubscriptionState> emit,
      ) async {
    print('DEBUG BLOC: Updating auto-renew to ${event.autoRenew} for userId: ${event.userId}');

    try {
      await subscriptionRepository.updateAutoRenew(event.userId, event.autoRenew);

      print('DEBUG BLOC: Auto-renew updated successfully!');
      emit(AutoRenewUpdated(event. autoRenew));

      // Refresh subscription status
      add(CheckSubscriptionStatus(event.userId));
    } catch (e) {
      print('DEBUG BLOC: Error updating auto-renew - $e');
      emit(PaymentFailure('Failed to update auto-renew: $e'));
    }
  }

  Future<void> _onCancelSubscription(
      CancelSubscription event,
      Emitter<SubscriptionState> emit,
      ) async {
    print('DEBUG BLOC: Cancelling subscription for userId: ${event.userId}');

    try {
      await subscriptionRepository.cancelSubscription(event.userId);

      print('DEBUG BLOC: Subscription cancelled successfully!');
      emit(SubscriptionCancelled());

      // Refresh subscription status
      add(CheckSubscriptionStatus(event.userId));
    } catch (e) {
      print('DEBUG BLOC:  Error cancelling subscription - $e');
      emit(PaymentFailure('Failed to cancel subscription: $e'));
    }
  }

  @override
  Future<void> close() {
    razorpayService. dispose();
    return super.close();
  }
}