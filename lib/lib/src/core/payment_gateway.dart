import 'package:flutter/widgets.dart';
import 'payment_result.dart';

abstract class PaymentGateway {
  String get name;

  Future<PaymentResult> pay({
    required BuildContext context,
    required int amountSmallestUnit, // e.g. kobo for NGN
    required String email,
    String currency = 'NGN',
    String? reference,
  });
}
