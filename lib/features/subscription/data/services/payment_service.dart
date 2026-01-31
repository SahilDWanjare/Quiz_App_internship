import 'dart:ui';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class PaymentService {
  Future<String> processPayment({
    required double amount,
    required String currency,
    required String userId,
    required String planId,
  });
}

class RazorpayService implements PaymentService {
  late Razorpay _razorpay;
  String? _paymentId;
  Function(String)? _onSuccess;
  Function(String)? _onError;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  Future<String> processPayment({
    required double amount,
    required String currency,
    required String userId,
    required String planId,
  }) async {
    // Convert amount to paise (smallest currency unit in India)
    final amountInPaise = (amount * 100).toInt();
    try {
      _razorpay.open(options);
      // Wait for payment result
      return await _waitForPayment();
    } catch (e) {
      throw Exception('Razorpay payment failed: $e');
    }
  }

  Future<String> _waitForPayment() async {
    // This is a simplified implementation
    // In production, use a Completer to handle async payment callback
    return Future.delayed(
      const Duration(seconds: 30),
          () => _paymentId ?? '',
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _paymentId = response.paymentId;
    print('Razorpay Payment Success: ${response.paymentId}');
    _onSuccess?.call(response.paymentId ?? '');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Razorpay Payment Error: ${response.code} - ${response.message}');
    _onError?.call(response.message ?? 'Payment failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  void setCallbacks({
    required Function(String) onSuccess,
    required Function(String) onError,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
  }

  void dispose() {
    _razorpay.clear();
  }
}

class StripeService implements PaymentService {
  static const String publishableKey = 'pk_test_51Sp0kqRHjxIVc7vXcgIp8azNjvOanvq9Ex60M6stQOGUe5epGqsCqKmspxyU3Bq9coZT0nWDSLTjN1f065y7y3lt00j55APbFs';
  static const String secretKey = 'sk_test_51Sp0kqRHjxIVc7vXZrHwooMwVN32B6zvt68TGMFnEDQyygQraUHnBNT3CkV3roBJQkE6q4EipUkUkLsETFKvyDFJ00VhUv6KOo';

  StripeService() {
    Stripe.publishableKey = publishableKey;
  }

  @override
  Future<String> processPayment({
    required double amount,
    required String currency,
    required String userId,
    required String planId,
  }) async {
    try {
      // Step 1: Create payment intent on server
      final paymentIntent = await _createPaymentIntent(
        amount: amount,
        currency: currency,
      );

      // Step 2: Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'ID Aspire Assessment',
          // style: ThemeMode.light,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFF0D121F),
            ),
          ),
        ),
      );

      // Step 3: Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Step 4: Payment successful
      print('Stripe Payment Success: ${paymentIntent['id']}');
      return paymentIntent['id'];
    } catch (e) {
      if (e is StripeException) {
        print('Stripe Error: ${e.error.localizedMessage}');
        throw Exception('Stripe payment failed: ${e.error.localizedMessage}');
      } else {
        throw Exception('Stripe payment failed: $e');
      }
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent({
    required double amount,
    required String currency,
  }) async {
    try {
      // Convert amount to smallest currency unit (cents for USD)
      final amountInCents = (amount * 100).toInt();

      // This should be called on your backend server
      // For demo purposes, this is a direct API call
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountInCents.toString(),
          'currency': currency.toLowerCase(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }
}

class LocationService {
  Future<bool> isUserInIndia() async {
    try {
      // Method 1: Using IP-based geolocation API
      final response = await http.get(
        Uri.parse('http://ip-api.com/json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final countryCode = data['countryCode'] as String?;
        print('Detected country: $countryCode');
        return countryCode == 'IN';
      }

      // Fallback: assume not in India
      return false;
    } catch (e) {
      print('Error detecting location: $e');
      // Default to false (Stripe) if detection fails
      return false;
    }
  }

// Alternative: Using geolocator (requires GPS permission)
// Future<bool> isUserInIndiaGPS() async {
//   try {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return false;
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return false;
//     }
//
//     Position position = await Geolocator.getCurrentPosition();
//     List<Placemark> placemarks = await placemarkFromCoordinates(
//       position.latitude,
//       position.longitude,
//     );
//
//     if (placemarks.isNotEmpty) {
//       return placemarks.first.isoCountryCode == 'IN';
//     }
//     return false;
//   } catch (e) {
//     return false;
//   }
// }
}
