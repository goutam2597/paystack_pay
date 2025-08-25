import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/payment_gateway.dart';
import '../../core/payment_result.dart';
import 'paystack_webview.dart';

/// Client-side Paystack gateway implementation that launches a WebView
/// checkout flow and resolves with a [PaymentResult].
///
/// Use this class when you want to charge a user in-app with their card or
/// other Paystack-supported methods.
///
/// Example:
/// ```dart
/// final gateway = PaystackGateway(publicKey: 'pk_test_123');
/// final result = await gateway.pay(
///   context: context,
///   amountSmallestUnit: 150000, // ₦1,500.00
///   email: 'customer@example.com',
/// );
///
/// if (result is PaymentSuccess) {
///   debugPrint('Payment OK: ${result.data}');
/// } else if (result is PaymentFailure) {
///   debugPrint('Payment failed: ${result.message}');
/// }
/// ```
class PaystackGateway implements PaymentGateway {
  /// Creates a new [PaystackGateway] with the given Paystack **public key**.
  ///
  /// Only use your `pk_test_...` or `pk_live_...` public key here.
  /// Do not embed secret keys in the client.
  PaystackGateway({required this.publicKey});

  /// Paystack **public key** (`pk_...`) used to initialize checkout.
  final String publicKey;

  @override
  String get name => 'Paystack';

  /// Generates a random reference string if the caller does not supply one.
  ///
  /// Format: `PS_<epochMillis>_<randomInt>`
  String _genRef() {
    final r = Random.secure().nextInt(1 << 32);
    return 'PS_${DateTime.now().millisecondsSinceEpoch}_$r';
  }

  /// Opens a Paystack WebView checkout and resolves to a [PaymentResult].
  ///
  /// Parameters:
  /// - [context]: Build context used to push the WebView route.
  /// - [amountSmallestUnit]: Amount in the smallest unit (e.g., kobo for NGN).
  /// - [email]: Customer email address.
  /// - [currency]: ISO code of the currency (defaults to `'NGN'`).
  /// - [reference]: Optional transaction reference. If omitted, one is
  ///   generated via [_genRef].
  ///
  /// Returns:
  /// - [PaymentSuccess] with data including reference, currency, amount,
  ///   and email, if the payment succeeds.
  /// - [PaymentFailure] if the checkout is closed, cancelled, or errors.
  @override
  Future<PaymentResult> pay({
    required BuildContext context,
    required int amountSmallestUnit,
    required String email,
    String currency = 'NGN',
    String? reference,
  }) async {
    final ref = reference ?? _genRef();
    try {
      final result = await Navigator.push<Map<String, dynamic>?>(
        context,
        MaterialPageRoute(
          builder: (_) => PaystackWebView(
            publicKey: publicKey,
            amountSmallestUnit: amountSmallestUnit,
            currency: currency,
            email: email,
            reference: ref,
          ),
        ),
      );

      if (result == null) {
        return PaymentFailure(name, 'Payment cancelled.');
      }
      final status = result['status'];
      if (status == 'success') {
        return PaymentSuccess(name, data: {
          'reference': result['reference'] ?? ref,
          'currency': currency,
          'amount_smallest_unit': amountSmallestUnit,
          'email': email,
        });
      }
      if (status == 'cancelled') {
        return PaymentFailure(name, 'Closed by user.');
      }
      return PaymentFailure(name, 'Payment error.', cause: result);
    } catch (e) {
      return PaymentFailure(name, 'Exception', cause: e);
    }
  }
}
