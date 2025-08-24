import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:paystack_pay/lib/widgets/custom_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaystackWebView extends StatefulWidget {
  const PaystackWebView({
    super.key,
    required this.publicKey, // pk_test_...
    required this.amountSmallestUnit, // kobo for NGN
    required this.currency, // 'NGN'
    required this.email,
    required this.reference,
    this.title = 'Paystack',
  });

  final String publicKey;
  final int amountSmallestUnit;
  final String currency;
  final String email;
  final String reference;
  final String title;

  @override
  State<PaystackWebView> createState() => _PaystackWebViewState();
}

class _PaystackWebViewState extends State<PaystackWebView> {
  late final WebViewController _controller;
  bool _loading = true;

  String _html() {
    final amount = widget.amountSmallestUnit;
    final currency = widget.currency;
    final email = widget.email;
    final ref = widget.reference;
    final key = widget.publicKey;

    return '''
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1">
  <title>Paystack</title>
  <script src="https://js.paystack.co/v1/inline.js"></script>
  <style>
    body { font-family: -apple-system, Segoe UI, Roboto, system-ui, sans-serif; padding: 24px; }
    button { padding: 12px 16px; border-radius: 12px; border: 0; box-shadow: 0 6px 18px rgba(0,0,0,.1); }
  </style>
</head>
<body>
  <h3>Pay ${currency == 'NGN' ? '₦' : ''}${(amount / 100).toStringAsFixed(0)}</h3>
  <p>$email</p>
  <button id="pay">Pay with Paystack</button>

  <script>
    const post = (obj) => {
      if (window.FlutterChannel) {
        window.FlutterChannel.postMessage(JSON.stringify(obj));
      }
    };
    function launch() {
      const handler = PaystackPop.setup({
        key: "$key",
        email: "$email",
        amount: $amount,
        currency: "$currency",
        ref: "$ref",
        callback: function(resp) { post({ event: "success", reference: resp.reference }); },
        onClose: function() { post({ event: "closed" }); }
      });
      handler.openIframe();
    }
    document.getElementById('pay').addEventListener('click', launch);
    window.onload = launch;
  </script>
</body>
</html>
''';
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (m) {
          try {
            final data = jsonDecode(m.message) as Map<String, dynamic>;
            if (data['event'] == 'success') {
              Navigator.pop(context, {
                'status': 'success',
                'reference': data['reference'],
              });
            } else if (data['event'] == 'closed') {
              Navigator.pop(context, {'status': 'cancelled'});
            }
          } catch (e) {
            Navigator.pop(context, {'status': 'error', 'error': e.toString()});
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
        ),
      )
      ..loadHtmlString(_html());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: widget.title),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading) const LinearProgressIndicator(minHeight: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
