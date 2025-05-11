import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String customerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No orders found.'),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ExpansionTile(
                  title: Text(
                    'Status: ${data['status'] ?? 'Unknown'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Total: RM ${data['grandTotal']?.toStringAsFixed(2) ?? '0.00'}'),
                      if (data['paymentPlan'] == 'Installment (3 months)' &&
                          data['monthlyPayment'] != null)
                        Text(
                          'Monthly Payment: RM ${data['monthlyPayment'].toStringAsFixed(2)}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Payment Method: ${data['paymentMethod'] ?? '-'}'),
                          Text('Payment Plan: ${data['paymentPlan'] ?? '-'}'),
                          const SizedBox(height: 8),
                          Text('Delivery Address:'),
                          Text(data['deliveryAddress'] ?? '-',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Ordered Items:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ..._buildOrderItems(data['items'] ?? []),
                          if (data['paym  entPlan'] == 'Installment (3 months)')
                            _buildInstallmentDetails(data, context),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildOrderItems(List<dynamic> items) {
    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(item['name'] ?? 'Unknown Item')),
            Text('x${item['quantity'] ?? 1}'),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildInstallmentDetails(
      Map<String, dynamic> data, BuildContext context) {
    // Ensure 'grandTotal' and 'monthlyPayment' are not null
    double remainingBalance = 0.0;
    if (data['grandTotal'] != null && data['monthlyPayment'] != null) {
      remainingBalance = data['grandTotal'] -
          (data['monthlyPayment'] * (data['paidMonths'] ?? 0));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text('Remaining Balance: RM ${remainingBalance.toStringAsFixed(2)}'),
        if (remainingBalance > 0)
          ElevatedButton(
            onPressed: () {
              final orderId = data['orderId'];
              if (orderId != null) {
                _makePayment(context, orderId, remainingBalance);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order ID is missing!')),
                );
              }
            },
            child: const Text('Make Payment'),
          ),
      ],
    );
  }

  Future<void> _makePayment(
      BuildContext context, String orderId, double amount) async {
    if (orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid order ID')),
      );
      return;
    }

    // Proceed with payment logic
    try {
      // Mock payment logic here
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('orders')
          .doc(orderId)
          .update({
        'paidMonths': FieldValue.increment(1), // Increment paid months
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making payment: $e')),
      );
    }
  }
}
