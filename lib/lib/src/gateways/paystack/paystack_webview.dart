import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:paystack_africa/lib/widgets/custom_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A full-screen widget that opens a [WebView] to handle Paystack checkout.
///
/// This widget loads a small HTML page that invokes the Paystack inline
/// JavaScript SDK. Once the user completes or cancels payment, the result is
/// sent back to Flutter over a JavaScript channel, and this page will
/// [Navigator.pop] with a result map.
///
/// ### Example
///
/// ```dart
/// final result = await Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => PaystackWebView(
///       publicKey: 'pk_test_12345',
///       amountSmallestUnit: 150000, // ₦1,500 in kobo
///       currency: 'NGN',
///       email: 'customer@example.com',
///       reference: 'order-123',
///     ),
///   ),
/// );
///
/// if (result['status'] == 'success') {
///   debugPrint('Payment ref: ${result['reference']}');
/// } else if (result['status'] == 'cancelled') {
///   debugPrint('User closed the checkout.');
/// }
/// ```
class PaystackWebView extends StatefulWidget {
  /// Creates a new Paystack checkout view.
  ///
  /// - [publicKey] should be your Paystack **public** key (`pk_test_...` or `pk_live_...`).
  /// - [amountSmallestUnit] is the amount in the **smallest unit** of the currency
  ///   (for NGN, kobo; so ₦1,500 = `150000`).
  /// - [currency] is the three-letter ISO code (e.g. `"NGN"`, `"USD"`).
  /// - [email] is the payer’s email.
  /// - [reference] is your unique transaction reference.
  /// - [title] sets the text in the custom app bar.
  const PaystackWebView({
    super.key,
    required this.publicKey,
    required this.amountSmallestUnit,
    required this.currency,
    required this.email,
    required this.reference,
    this.title = 'Paystack',
  });

  /// Paystack **public key** (`pk_test_...`).
  final String publicKey;

  /// Amount to charge in the smallest unit (e.g., kobo).
  final int amountSmallestUnit;

  /// ISO currency code for the charge (e.g., `"NGN"`, `"USD"`).
  final String currency;

  /// Customer email to associate with the charge.
  final String email;

  /// Unique reference string for this transaction.
  final String reference;

  /// Title displayed in the [CustomAppBar].
  final String title;

  @override
  State<PaystackWebView> createState() => _PaystackWebViewState();
}

class _PaystackWebViewState extends State<PaystackWebView> {
  late final WebViewController _controller;
  bool _loading = true;

  /// Builds the HTML document that includes the Paystack inline JS checkout.
  ///
  /// This HTML is loaded directly into the WebView using [WebViewController.loadHtmlString].
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

  /// Renders the scaffold with [CustomAppBar] and the embedded [WebViewWidget].
  ///
  /// Displays a [LinearProgressIndicator] while the page is loading.
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
