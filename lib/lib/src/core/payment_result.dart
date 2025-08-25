/// Base type for results returned from a payment gateway.
///
/// Each result knows which [gatewayName] it came from, and exposes
/// [isSuccess] to distinguish between [PaymentSuccess] and [PaymentFailure].
abstract class PaymentResult {
  /// Creates a result tagged with the name of the originating gateway.
  const PaymentResult(this.gatewayName);

  /// The human-readable name of the payment gateway that produced this result
  /// (e.g., `"Paystack"`, `"Mollie"`).
  final String gatewayName;

  /// Whether this result represents a successful payment.
  bool get isSuccess;
}

/// A successful payment outcome.
///
/// Contains optional provider-specific [data], such as transaction reference,
/// amount, currency, or other metadata returned by the gateway.
///
/// Example:
/// ```dart
/// if (result is PaymentSuccess) {
///   print('Ref: ${result.data?['reference']}');
/// }
/// ```
class PaymentSuccess extends PaymentResult {
  /// Creates a successful result from [gatewayName] with optional [data].
  const PaymentSuccess(super.gatewayName, {this.data});

  /// Provider-specific data payload (e.g., reference, amount, currency).
  final Map<String, dynamic>? data;

  @override
  bool get isSuccess => true;
}

/// A failed or cancelled payment outcome.
///
/// Contains a [message] describing the error and an optional [cause]
/// with the underlying exception or raw payload.
///
/// Example:
/// ```dart
/// if (result is PaymentFailure) {
///   print('Payment failed: ${result.message}');
/// }
/// ```
class PaymentFailure extends PaymentResult {
  /// Creates a failure result from [gatewayName] with a [message]
  /// and optional underlying [cause].
  const PaymentFailure(super.gatewayName, this.message, {this.cause});

  /// A human-readable message describing the failure.
  final String message;

  /// The underlying error or raw cause of the failure, if available.
  final Object? cause;

  @override
  bool get isSuccess => false;
}
