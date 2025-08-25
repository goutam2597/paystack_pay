import 'package:flutter/widgets.dart';
import 'payment_result.dart';

/// Contract that all payment gateways must implement.
///
/// A [PaymentGateway] is responsible for opening a checkout flow (for example,
/// a WebView with the provider’s payment page), and resolving to a
/// [PaymentResult] indicating success or failure.
abstract class PaymentGateway {
  /// The human-readable name of this gateway (e.g., `"Paystack"`, `"Mollie"`).
  String get name;

  /// Starts a payment flow and returns a [PaymentResult].
  ///
  /// Parameters:
  /// - [context]: Used to push any UI needed for checkout (e.g., a WebView route).
  /// - [amountSmallestUnit]: Amount to charge in the smallest unit of the
  ///   currency (for NGN, kobo; ₦1,500 = `150000`).
  /// - [email]: The customer’s email, passed to the provider.
  /// - [currency]: ISO currency code (defaults to `"NGN"`).
  /// - [reference]: Optional transaction reference. If not provided,
  ///   the gateway should generate one.
  ///
  /// Returns:
  /// - A [PaymentSuccess] if the transaction succeeds.
  /// - A [PaymentFailure] if cancelled, declined, or errors occur.
  Future<PaymentResult> pay({
    required BuildContext context,
    required int amountSmallestUnit,
    required String email,
    String currency = 'NGN',
    String? reference,
  });
}
