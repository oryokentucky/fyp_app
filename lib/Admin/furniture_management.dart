import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FurnitureManagementTab extends StatefulWidget {
  const FurnitureManagementTab({Key? key}) : super(key: key);

  @override
  State<FurnitureManagementTab> createState() => _FurnitureManagementTabState();
}

class _FurnitureManagementTabState extends State<FurnitureManagementTab> {
  final CollectionReference furnitureItems =
      FirebaseFirestore.instance.collection('Furniture');

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  final List<String> categories = ['Sofa', 'Table', 'Chair', 'Bed', 'Cabinet'];
  String? selectedCategory;
  int quantity = 0;

  void addFurniture() async {
    final furnitureData = {
      'name': nameController.text.trim(),
      'price': double.tryParse(priceController.text) ?? 0.0,
      'category': selectedCategory,
      'detail': detailController.text.trim(),
      'quantity': quantity,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await furnitureItems.add(furnitureData);
      clearInputs();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      print('Error adding furniture: $e');
    }
  }

  void editFurniture(String docId, Map<String, dynamic> currentItem) {
    nameController.text = currentItem['name'] ?? '';
    priceController.text = currentItem['price'].toString();
    selectedCategory = currentItem['category'];
    detailController.text = currentItem['detail'] ?? '';
    quantity = currentItem['quantity'] ?? 0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Furniture'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildTextField('Furniture Name', nameController),
                buildTextField('Price', priceController, isNumeric: true),
                buildDropdown(),
                buildTextField('Detail', detailController),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Quantity"),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setDialogState(() {
                                if (quantity > 0) quantity--;
                              });
                            },
                          ),
                          Text('$quantity'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setDialogState(() {
                                quantity++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final updatedData = {
                'name': nameController.text.trim(),
                'price': double.tryParse(priceController.text) ?? 0.0,
                'category': selectedCategory,
                'detail': detailController.text.trim(),
                'quantity': quantity,
                'timestamp': FieldValue.serverTimestamp(),
              };

              try {
                await FirebaseFirestore.instance
                    .collection('Furniture')
                    .doc(docId)
                    .update(updatedData);
                Navigator.pop(context);
              } catch (e) {
                print('Error updating furniture: $e');
              }
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void deleteFurniture(String docId) async {
    try {
      await furnitureItems.doc(docId).delete();
      await removeItemFromAllCarts(docId);
      print("Furniture item deleted successfully.");
    } catch (e) {
      print("Error deleting furniture: $e");
    }
  }

  void clearInputs() {
    nameController.clear();
    priceController.clear();
    detailController.clear();
    selectedCategory = null;
    quantity = 0;
  }

  void showAddFurnitureDialog() {
    clearInputs();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Furniture'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildTextField('Furniture Name', nameController),
                buildTextField('Price', priceController, isNumeric: true),
                buildDropdown(),
                buildTextField('Detail', detailController),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Quantity"),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setDialogState(() {
                                if (quantity > 0) quantity--;
                              });
                            },
                          ),
                          Text('$quantity'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setDialogState(() {
                                quantity++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: addFurniture,
            child: const Text('Add'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.all(8.0),
        ),
      ),
    );
  }

  Widget buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        items: categories
            .map((category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                ))
            .toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedCategory = newValue!;
          });
        },
        decoration: const InputDecoration(
          labelText: 'Category',
          contentPadding: EdgeInsets.all(8.0),
        ),
      ),
    );
  }

  Widget buildQuantitySelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Quantity"),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (quantity > 0) quantity--;
                  });
                },
              ),
              Text('$quantity'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    quantity++;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> removeItemFromAllCarts(String furnitureId) async {
    final cartsSnapshot = await FirebaseFirestore.instance
        .collectionGroup('carts_item')
        .where('id', isEqualTo: furnitureId)
        .get();

    for (var doc in cartsSnapshot.docs) {
      await doc.reference.delete();
    }

    print("Item removed from all carts.");
  }

  void showDeleteConfirmation(String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Furniture"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                deleteFurniture(docId);
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Furniture Management'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Furniture').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No furniture items available.'));
          }

          final furnitureDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: furnitureDocs.length,
            itemBuilder: (context, index) {
              final item = furnitureDocs[index];
              final docId = item.id;
              return Card(
                child: ListTile(
                  title: Text(item['name']),
                  subtitle: Text(
                      'Price: \RM${item['price']} | Quantity: ${item['quantity']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => editFurniture(
                            docId, item.data() as Map<String, dynamic>),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => showDeleteConfirmation(docId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddFurnitureDialog,
        backgroundColor: Colors.lightBlue[200],
        child: const Icon(Icons.add),
      ),
    );
  }
}
