import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderManagementTab extends StatelessWidget {
  const OrderManagementTab({Key? key}) : super(key: key);

  final List<String> statusOptions = const [
    'Paid',
    'Processing',
    'Shipping',
    'In Delivery',
    'Delivered',
    'Cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No orders found.'));
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final data = order.data() as Map<String, dynamic>;

            final timestamp = (data['createdAt'] as Timestamp?)?.toDate();
            final formattedDate = timestamp != null
                ? DateFormat('dd/MM/yyyy').format(timestamp)
                : 'Unknown Date';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index == 0 ||
                      (orders[index - 1].data()
                              as Map<String, dynamic>)['createdAt'] ==
                          null ||
                      DateFormat('dd/MM/yyyy').format(
                            (orders[index - 1].data()
                                        as Map<String, dynamic>)['createdAt']
                                    ?.toDate() ??
                                DateTime(0),
                          ) !=
                          formattedDate)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      onTap: () => _showOrderDetail(context, order),
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Text(
                          data['paymentMethod'] != null
                              ? data['paymentMethod'][0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        'Order ID: ${order.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(data['deliveryAddress'] ?? '-'),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data['status'] ?? 'Unknown',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showOrderDetail(BuildContext context, QueryDocumentSnapshot order) {
    final data = order.data() as Map<String, dynamic>;
    final timestamp = (data['createdAt'] as Timestamp?)?.toDate();
    final formattedDate = timestamp != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp)
        : 'Unknown Date';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Order ID: ${order.id}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Date: $formattedDate'),
                const SizedBox(height: 8),
                Text('Status: ${data['status'] ?? '-'}'),
                const SizedBox(height: 8),
                Text('Payment Method: ${data['paymentMethod'] ?? '-'}'),
                Text('Payment Plan: ${data['paymentPlan'] ?? '-'}'),
                const SizedBox(height: 8),
                const Text('Delivery Address:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(data['deliveryAddress'] ?? '-'),
                const SizedBox(height: 12),
                const Text('Items:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ..._buildOrderItems(data['items'] ?? []),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _editStatusDialog(
                        context, order.reference, data['status']),
                    child: const Text('Edit Status'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildOrderItems(List<dynamic> items) {
    return items.map((item) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(item['name'] ?? 'Unknown Item'),
        trailing: Text('x${item['quantity'] ?? 1}'),
      );
    }).toList();
  }

  void _editStatusDialog(
      BuildContext context, DocumentReference orderRef, String? currentStatus) {
    String selectedStatus = currentStatus ?? 'Processing';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Select Status',
                border: OutlineInputBorder(),
              ),
              items: statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedStatus = value;
                  });
                }
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await orderRef.update({'status': selectedStatus});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order status updated')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
