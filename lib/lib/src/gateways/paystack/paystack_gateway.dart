import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/payment_gateway.dart';
import '../../core/payment_result.dart';
import 'paystack_webview.dart';

class PaystackGateway implements PaymentGateway {
  PaystackGateway({required this.publicKey});
  final String publicKey;

  @override
  String get name => 'Paystack';

  String _genRef() {
    final r = Random.secure().nextInt(1 << 32);
    return 'PS_${DateTime.now().millisecondsSinceEpoch}_$r';
  }

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
