import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;

  const CheckoutPage({
    Key? key,
    required this.cartItems,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  TextEditingController _addressController = TextEditingController();
  LatLng? selectedLocation;

  String selectedPaymentPlan = 'Full Payment'; // Default
  final LatLng initialMelaka = LatLng(2.2008, 102.2405);
  final double deliveryRadiusKm = 10;

  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    try {
      final url = 'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=${latLng.latitude},${latLng.longitude}'
          '&key=AIzaSyA6N1sDHWMWExJGPVxc7tWxaO6KA_6mZ1Q';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        } else {
          return "No address found";
        }
      } else {
        return "Failed with status code ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<void> handlePaymentAndSaveOrder() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      if (_addressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your delivery address.')),
        );
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final customerId = user.uid;

      double serviceTax = widget.totalPrice * 0.06;
      double extraInstallmentTax =
          selectedPaymentPlan == 'Installment (3 months)'
              ? (widget.totalPrice * 0.02)
              : 0.0;

      double grandTotal = widget.totalPrice + serviceTax + extraInstallmentTax;
      double monthlyPayment = selectedPaymentPlan == 'Installment (3 months)'
          ? (grandTotal / 3)
          : 0.0;

      // 🔄 Reduce stock quantity
      for (var item in widget.cartItems) {
        final String furnitureId =
            item['id']; // Make sure your item has an 'id'
        final int quantity = item['quantity'];

        final docRef = firestore.collection('Furniture').doc(furnitureId);
        final docSnap = await docRef.get();

        if (!docSnap.exists) {
          throw Exception('Furniture item not found: $furnitureId');
        }

        int currentStock = docSnap['quantity'];
        if (currentStock < quantity) {
          throw Exception('Not enough stock for ${item['name']}');
        }

        await docRef.update({'quantity': currentStock - quantity});
      }

      // 📦 Order data
      final orderData = {
        'items': widget.cartItems,
        'subtotal': widget.totalPrice,
        'serviceTax': serviceTax,
        'extraInstallmentTax': extraInstallmentTax,
        'grandTotal': grandTotal,
        'monthlyPayment': monthlyPayment,
        'paymentPlan': selectedPaymentPlan,
        'paymentMethod': 'QR Payment',
        'deliveryAddress': _addressController.text,
        'status': 'Processing',
        'createdAt': FieldValue.serverTimestamp(),
        'customerId': customerId,
      };

      // 📝 Save to Firestore
      await firestore
          .collection('customers')
          .doc(customerId)
          .collection('orders')
          .add(orderData);

      await firestore
          .collection('admin')
          .doc('orders')
          .collection('all_orders')
          .add(orderData);
      await clearCustomerCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }
  }

  Future<void> clearCustomerCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartItemsRef = FirebaseFirestore.instance
        .collection('customers')
        .doc(user.uid)
        .collection('cart_items');

    final cartItemsSnapshot = await cartItemsRef.get();

    for (var doc in cartItemsSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    double serviceTax = widget.totalPrice * 0.06;
    double extraInstallmentTax = selectedPaymentPlan == 'Installment (3 months)'
        ? widget.totalPrice * 0.02
        : 0.0;

    double grandTotal = widget.totalPrice + serviceTax + extraInstallmentTax;

    double monthlyPayment = selectedPaymentPlan == 'Installment (3 months)'
        ? (grandTotal / 3)
        : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...widget.cartItems.map((item) => ListTile(
                  title: Text(item['name'] ?? ''),
                  subtitle: Text('Qty: ${item['quantity']}'),
                  trailing: Text(
                      'RM ${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                )),
            const Divider(),
            ListTile(
              title: const Text('Subtotal'),
              trailing: Text('RM ${widget.totalPrice.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Service Tax (6%)'),
              trailing: Text('RM ${serviceTax.toStringAsFixed(2)}'),
            ),
            if (selectedPaymentPlan == 'Installment (3 months)')
              ListTile(
                title: const Text('Installment Extra Tax (2%)'),
                trailing: Text('RM ${extraInstallmentTax.toStringAsFixed(2)}'),
              ),
            ListTile(
              title: const Text('Grand Total'),
              trailing: Text('RM ${grandTotal.toStringAsFixed(2)}'),
            ),
            const SizedBox(height: 20),
            const Text('Payment Plan:', style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: selectedPaymentPlan,
              items: ['Full Payment', 'Installment (3 months)']
                  .map((plan) =>
                      DropdownMenuItem(value: plan, child: Text(plan)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPaymentPlan = value!;
                });
              },
            ),
            if (selectedPaymentPlan == 'Installment (3 months)')
              ListTile(
                title: const Text('Monthly Payment'),
                trailing:
                    Text('RM ${monthlyPayment.toStringAsFixed(2)} per month'),
              ),
            const SizedBox(height: 20),
            const Text('Delivery Address', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                hintText: 'Enter delivery address',
              ),
            ),
            SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  center: initialMelaka,
                  zoom: 13.0,
                  onTap: (tapPosition, latLng) async {
                    setState(() {
                      selectedLocation = latLng;
                    });
                    String fetchedAddress = await _getAddressFromLatLng(latLng);
                    setState(() {
                      _addressController.text = fetchedAddress;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  if (selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80,
                          height: 80,
                          point: selectedLocation!,
                          child: const Icon(Icons.location_pin,
                              color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Mock QR Code (Scan to Pay)',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Center(
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=MockPaymentLink1234',
                height: 200,
                width: 200,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handlePaymentAndSaveOrder,
              child: const Text('Confirm Order'),
            ),
          ],
        ),
      ),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? selectedPoint;
  final LatLng initialCenter = LatLng(2.2008, 102.2405); // Melaka center
  bool isInsideMelaka(LatLng point) {
    return point.latitude >= 2.10 &&
        point.latitude <= 2.50 &&
        point.longitude >= 102.00 &&
        point.longitude <= 102.40;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: FlutterMap(
        options: MapOptions(
          center: initialCenter,
          zoom: 13,
          onTap: (tapPosition, point) {
            if (isInsideMelaka(point)) {
              setState(() {
                selectedPoint = point;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Selected location is outside Melaka! Please pick again.'),
                ),
              );
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          if (selectedPoint != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: selectedPoint!,
                  width: 80,
                  height: 80,
                  child: const Icon(Icons.location_pin,
                      color: Colors.red, size: 40),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: selectedPoint != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pop(context, selectedPoint);
              },
              label: const Text('Confirm Location'),
              icon: const Icon(Icons.check),
            )
          : null,
    );
  }
}
