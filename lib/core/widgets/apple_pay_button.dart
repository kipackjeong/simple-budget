import 'package:flutter/material.dart';

/// Widget that displays a styled Apple Pay button
class CustomApplePayButton extends StatelessWidget {
  /// Creates an Apple Pay button widget
  const CustomApplePayButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'https://developer.apple.com/design/human-interface-guidelines/apple-pay/images/apple-pay-mark_2x.png',
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.apple, color: Colors.white);
              },
            ),
            const SizedBox(width: 6),
            const Text(
              'Pay with Apple Pay',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the payment configuration JSON string
  String _getPaymentConfig() {
    return '''
    {
      "provider": "apple_pay",
      "data": {
        "merchantIdentifier": "merchant.com.spendingtracker",
        "displayName": "Spending Tracker",
        "merchantCapabilities": ["3DS", "debit", "credit"],
        "supportedNetworks": ["amex", "visa", "discover", "masterCard"],
        "countryCode": "US",
        "currencyCode": "USD"
      }
    }
    ''';
  }
}
