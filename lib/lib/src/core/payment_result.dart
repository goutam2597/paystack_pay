abstract class PaymentResult {
  const PaymentResult(this.gatewayName);
  final String gatewayName;
  bool get isSuccess;
}

class PaymentSuccess extends PaymentResult {
  const PaymentSuccess(super.gatewayName, {this.data});
  final Map<String, dynamic>? data;
  @override
  bool get isSuccess => true;
}

class PaymentFailure extends PaymentResult {
  const PaymentFailure(super.gatewayName, this.message, {this.cause});
  final String message;
  final Object? cause;
  @override
  bool get isSuccess => false;
}
