import 'package:flutter/material.dart';

class QRCodePaymentPage extends StatelessWidget {
  final Function onPaymentSuccess;

  const QRCodePaymentPage({super.key, required this.onPaymentSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR to Pay')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=PAYMENT12345'), // Mock QR
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulate payment success
                onPaymentSuccess();
                Navigator.pop(context);
              },
              child: const Text('I have paid'),
            ),
          ],
        ),
      ),
    );
  }
}
