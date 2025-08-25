import 'package:flutter/material.dart';
import 'package:paystack_pay/paystack_pay.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paystack Example',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const publicKey = String.fromEnvironment(
    'PAYSTACK_PUBLIC_KEY',
    defaultValue: 'pk_test_example_for_dev_only',
  );

  @override
  Widget build(BuildContext context) {
    final gateway = PaystackGateway(publicKey: publicKey);

    return Scaffold(
      appBar: AppBar(title: const Text('Paystack (WebView) Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final res = await gateway.pay(
              context: context,
              amountSmallestUnit: 150000, // ₦1,500
              email: 'customer@example.com',
            );
            final msg = res.isSuccess
                ? 'SUCCESS: ${(res as PaymentSuccess).data}'
                : 'FAIL: ${(res as PaymentFailure).message}';
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg)),
              );
            }
          },
          child: const Text('Pay ₦1,500'),
        ),
      ),
    );
  }
}
