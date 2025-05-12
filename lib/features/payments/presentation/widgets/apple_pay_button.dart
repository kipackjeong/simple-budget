import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget that displays a styled Apple Pay button
class CustomApplePayButton extends ConsumerWidget {
  /// Creates an Apple Pay button widget
  const CustomApplePayButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handlePaymentRequest(context, ref),
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  'https://developer.apple.com/design/human-interface-guidelines/apple-pay/images/apple-pay-mark_2x.png',
                  height: 24,
                  errorBuilder: (context, err, stackTrace) {
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
        ),
      ),
    );
  }

  /// Handles the payment request when the button is tapped
  void _handlePaymentRequest(BuildContext context, WidgetRef ref) {
    // In a real implementation, this would initiate the Apple Pay flow
    // and integrate with the payment providers
    
    // For now, just show a dialog to simulate the payment flow
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apple Pay'),
        content: const Text('Apple Pay integration would be triggered here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
