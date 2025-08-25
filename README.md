# Paystack WebView (Flutter)

A simple Flutter helper to accept **Paystack** payments via an in-app WebView.

- ✅ Sandbox & Live support (public keys)  
- ✅ Typed success/failure result objects  
- ✅ Minimal API (`PaystackGateway.pay(...)`)  
- ⚠️ Only use your **public key** (`pk_...`) in client apps. Never expose your secret key.

> This package is not an official Paystack SDK.

---

## Features

- Create a Paystack checkout session from your Flutter app
- Open payment UI inside a WebView
- Handle success or failure with clear callbacks
- Example project included

---

## Getting started

### Installation

Add the dependency in `pubspec.yaml`:

```yaml
dependencies:
  paystack_pay: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### Provide your public key

Use `--dart-define` to avoid hardcoding:

```bash
flutter run --dart-define=PAYSTACK_PUBLIC_KEY=pk_test_xxx
```

Access it in code:

```dart
static const publicKey = String.fromEnvironment(
  'PAYSTACK_PUBLIC_KEY',
  defaultValue: 'pk_test_example_for_dev_only',
);
```

---

## Usage

```dart
final gateway = PaystackGateway(publicKey: publicKey);
final result = await gateway.pay(
  context: context,
  amountSmallestUnit: 150000, // ₦1,500.00
  email: 'customer@example.com',
);

if (result.isSuccess) {
  final data = (result as PaymentSuccess).data;
  // handle success
} else {
  final message = (result as PaymentFailure).message;
  // handle failure
}
```

---

## Example

See the [example app](example/lib/main.dart).

```dart
ElevatedButton(
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  },
  child: const Text('Pay ₦1,500'),
)
```

---

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE).
