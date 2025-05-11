import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ItemDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;
  const ItemDetailPage({Key? key, required this.item}) : super(key: key);

  void addToCart(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add items to cart')),
      );
      return;
    }

    try {
      final cartRef = FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .collection('cart_items')
          .doc(item['id']); // Ensure item['id'] exists in your data

      final cartSnapshot = await cartRef.get();

      if (cartSnapshot.exists) {
        await cartRef.update({
          'quantity': FieldValue.increment(1),
        });
      } else {
        await cartRef.set({
          'id': item['id'],
          'name': item['name'],
          'price': item['price'],
          'imageUrl': item['imageUrl'],
          'detail': item['detail'],
          'quantity': 1,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${item['name']} added to cart'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      print('Error adding to cart: $e'); // Debug output
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to add to cart: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item['name'] ?? 'Furniture Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['imageUrl'] != null)
              Center(
                child: Image.network(
                  item['imageUrl'],
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              item['name'] ?? 'No Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Price: RM ${item['price']}',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            Text(
              item['detail'] ?? 'No Name',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => addToCart(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 235, 235, 235),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
