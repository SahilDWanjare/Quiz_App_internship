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

    // Set up Razorpay callbacks
    razorpayService.setCallbacks(
      onSuccess: (paymentId) {
        add(PaymentCompleted(
          paymentId: paymentId,
          paymentGateway: 'razorpay',
        ));
      },
      onError: (error) {
        add(PaymentFailed(error));
      },
    );
  }

  Future<void> _onLoadPlans(
      LoadSubscriptionPlans event,
      Emitter<SubscriptionState> emit,
      ) async {
    emit(SubscriptionLoading());

    try {
      final plans = await subscriptionRepository.getSubscriptionPlans();
      emit(SubscriptionPlansLoaded(
        plans: plans,
        selectedPlan: _selectedPlan,
      ));
    } catch (e) {
      emit(PaymentFailure('Failed to load plans: $e'));
    }
  }

  Future<void> _onSelectPlan(
      SelectPlan event,
      Emitter<SubscriptionState> emit,
      ) async {
    _selectedPlan = event.plan;

    if (state is SubscriptionPlansLoaded) {
      final currentState = state as SubscriptionPlansLoaded;
      emit(SubscriptionPlansLoaded(
        plans: currentState.plans,
        selectedPlan: event.plan,
      ));
    }
  }

  Future<void> _onCheckStatus(
      CheckSubscriptionStatus event,
      Emitter<SubscriptionState> emit,
      ) async {
    _currentUserId = event.userId;
    emit(SubscriptionLoading());

    try {
      final subscription = await subscriptionRepository.getUserSubscription(
        event.userId,
      );

      if (subscription != null && subscription.isActive && !subscription.isExpired) {
        emit(SubscriptionActive(subscription));
      } else {
        emit(SubscriptionInactive());
      }
    } catch (e) {
      emit(SubscriptionInactive());
    }
  }

  Future<void> _onStartPayment(
      StartPayment event,
      Emitter<SubscriptionState> emit,
      ) async {
    emit(PaymentProcessing());

    try {
      final String paymentId;
      final String gateway;

      if (event.isIndia) {
        // Use Razorpay for India
        print('Processing payment with Razorpay...');
        gateway = 'razorpay';
        paymentId = await razorpayService.processPayment(
          amount: event.plan.price,
          currency: 'INR',
          userId: event.userId,
          planId: event.plan.id,
        );
      } else {
        // Use Stripe for international
        print('Processing payment with Stripe...');
        gateway = 'stripe';
        paymentId = await stripeService.processPayment(
          amount: event.plan.price,
          currency: 'USD',
          userId: event.userId,
          planId: event.plan.id,
        );
      }

      // Payment processing continues in callback
      // The PaymentCompleted event will be triggered by the payment gateway callback
    } catch (e) {
      print('Payment error: $e');
      emit(PaymentFailure('Payment failed: $e'));
    }
  }

  Future<void> _onPaymentCompleted(
      PaymentCompleted event,
      Emitter<SubscriptionState> emit,
      ) async {
    try {
      if (_selectedPlan == null || _currentUserId == null) {
        emit(const PaymentFailure('Invalid payment state'));
        return;
      }

      // Save subscription to Firestore
      final subscription = await subscriptionRepository.createSubscription(
        userId: _currentUserId!,
        plan: _selectedPlan!,
        paymentId: event.paymentId,
        paymentGateway: event.paymentGateway,
      );

      emit(PaymentSuccess(subscription));
    } catch (e) {
      emit(PaymentFailure('Failed to save subscription: $e'));
    }
  }

  Future<void> _onPaymentFailed(
      PaymentFailed event,
      Emitter<SubscriptionState> emit,
      ) async {
    emit(PaymentFailure(event.error));
  }

  @override
  Future<void> close() {
    razorpayService.dispose();
    return super.close();
  }
}