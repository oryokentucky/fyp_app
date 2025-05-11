import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_app/pages/Checkout.dart';

class CartPage extends StatefulWidget {
  CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // List to hold cart items
  List<Map<String, dynamic>> _cartItems = [];

  // Fetch cart items from Firestore's cart_items subcollection
  Future<void> fetchCartItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartItemsSnapshot = await FirebaseFirestore.instance
        .collection('customers')
        .doc(user.uid)
        .collection('cart_items')
        .get(); // Fetch all items in the cart_items subcollection

    setState(() {
      _cartItems = cartItemsSnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Remove an item from the cart
  void removeFromCart(BuildContext context, Map<String, dynamic> item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartItemRef = FirebaseFirestore.instance
        .collection('customers')
        .doc(user.uid)
        .collection('cart_items')
        .doc(item['id']); // Use the item's ID as the document ID

    await cartItemRef.delete(); // Delete the specific item document

    // Reload the cart after removing the item
    await fetchCartItems();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name'] ?? 'Item'} removed from cart'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Increase the quantity of an item in the cart
  void increaseQuantity(BuildContext context, Map<String, dynamic> item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final itemId = item['id']; // Get item ID from cart
    final currentQuantity = item['quantity'] ?? 1;

    // Fetch current stock from 'furniture' collection
    final furnitureDoc = await FirebaseFirestore.instance
        .collection('Furniture')
        .doc(itemId)
        .get();

    if (furnitureDoc.exists) {
      final stock = furnitureDoc.data()?['quantity'] ?? 0;

      if (currentQuantity >= stock) {
        // Show a message if the cart quantity has reached the stock limit
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot add more than available stock ($stock)'),
            backgroundColor: Colors.orange,
          ),
        );
        return; // Prevent increment
      }

      // Otherwise, increment quantity
      final cartItemRef = FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .collection('cart_items')
          .doc(itemId);

      await cartItemRef.update({
        'quantity': FieldValue.increment(1),
      });

      await fetchCartItems();
    } else {
      // Fallback if item no longer exists
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item no longer available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Decrease the quantity of an item in the cart
  void decreaseQuantity(BuildContext context, Map<String, dynamic> item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (item['quantity'] > 1) {
      final cartItemRef = FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .collection('cart_items')
          .doc(item['id']); // Use the item's ID as the document ID

      await cartItemRef.update({
        'quantity': FieldValue.increment(-1), // Decrement quantity by 1
      });

      // Reload the cart after updating the quantity
      await fetchCartItems();
    }
  }

  // Build the UI for each cart item
  Widget _buildCartItem(BuildContext context, Map<String, dynamic> item) {
    final itemName = item['name'] ?? 'No Name';
    final itemPrice = item['price'] ?? 0.0;
    final itemImageUrl = item['imageUrl'] ??
        'https://via.placeholder.com/150'; // Placeholder if imageUrl is null
    final itemQuantity =
        item['quantity'] ?? 1; // Default to 1 if quantity is null

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(itemImageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'RM $itemPrice',
                    style: const TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => decreaseQuantity(context, item),
                      ),
                      Text(
                        '$itemQuantity', // Show the quantity
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => increaseQuantity(context, item),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => removeFromCart(context, item),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCartItems(); // Load cart items when the page is loaded
  }

  double getTotalPrice() {
    double total = 0.0;
    for (var item in _cartItems) {
      double price = item['price'] ?? 0.0;
      int quantity = item['quantity'] ?? 1;
      total += price * quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: Column(
        children: [
          Expanded(
            child: _cartItems.isEmpty
                ? const Center(child: Text('Your cart is empty.'))
                : ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      return _buildCartItem(context, _cartItems[index]);
                    },
                  ),
          ),
          if (_cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'RM ${getTotalPrice().toStringAsFixed(2)}',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final shouldRefresh = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(
                            cartItems: _cartItems,
                            totalPrice: getTotalPrice(),
                          ),
                        ),
                      );

                      if (shouldRefresh == true) {
                        fetchCartItems(); // Refresh the cart after returning from checkout
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40)),
                    child: const Text('Proceed to Checkout'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
