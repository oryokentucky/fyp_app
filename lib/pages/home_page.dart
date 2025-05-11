import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_app/auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_app/pages/login_register_page.dart';
import 'package:fyp_app/pages/ItemDetailPage.dart.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  Future<void> signOut(BuildContext context) async {
    await Auth().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  Widget _buildFurnitureCard(
      BuildContext context, Map<String, dynamic> item, String itemId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailPage(item: item),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['name'] ?? 'No Name',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'RM ${item['price']}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Category: ${item['category'] ?? 'No Category'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        title: const Text(
          'ASE Furniture',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Row(
            children: [
              Text(
                user?.email ?? 'User',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  print('Profile icon clicked');
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for furniture...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.lightBlue),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Furniture')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No furniture available.'));
                }

                var furnitureList = snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  data['id'] = doc.id; // Store the document ID
                  return data;
                }).toList();

                // Filter search results
                var filteredList = furnitureList.where((item) {
                  String itemName = item['name']?.toLowerCase() ?? '';
                  String itemCategory = item['category']?.toLowerCase() ?? '';
                  return itemName.contains(searchQuery) ||
                      itemCategory.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return _buildFurnitureCard(context, filteredList[index],
                        filteredList[index]['id']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
