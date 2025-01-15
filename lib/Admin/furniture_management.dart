import 'package:flutter/material.dart';

class FurnitureManagementTab extends StatefulWidget {
  const FurnitureManagementTab({Key? key}) : super(key: key);

  @override
  State<FurnitureManagementTab> createState() => _FurnitureManagementTabState();
}

class _FurnitureManagementTabState extends State<FurnitureManagementTab> {
  // In-memory list of furniture items
  List<Map<String, dynamic>> furnitureItems = [];

  // Controllers for managing inputs
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController detailController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  // Dropdown category options
  final List<String> categories = ['Sofa', 'Table', 'Chair', 'Bed', 'Cabinet'];
  String? selectedCategory;

  // Add a new furniture item
  void addFurniture() {
    setState(() {
      furnitureItems.add({
        'name': nameController.text,
        'price': priceController.text,
        'category': selectedCategory,
        'detail': detailController.text,
        'quantity': quantityController.text,
      });
    });
    clearInputs();
    Navigator.pop(context); // Close the dialog
  }

  // Edit an existing furniture item
  void editFurniture(int index) {
    final currentItem = furnitureItems[index];

    // Pre-fill inputs with current item details
    nameController.text = currentItem['name'] ?? '';
    priceController.text = currentItem['price'] ?? '';
    selectedCategory = currentItem['category'];
    detailController.text = currentItem['detail'] ?? '';
    quantityController.text = currentItem['quantity'] ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Furniture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTextField('Furniture Name', nameController),
            buildTextField('Price', priceController, isNumeric: true),
            buildDropdown(),
            buildTextField('Detail', detailController),
            buildTextField('Quantity', quantityController, isNumeric: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                furnitureItems[index] = {
                  'name': nameController.text,
                  'price': priceController.text,
                  'category': selectedCategory,
                  'detail': detailController.text,
                  'quantity': quantityController.text,
                };
              });
              clearInputs();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              clearInputs();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Clear input fields
  void clearInputs() {
    nameController.clear();
    priceController.clear();
    detailController.clear();
    quantityController.clear();
    selectedCategory = null;
  }

  // Show dialog to add a new furniture item
  void showAddFurnitureDialog() {
    clearInputs();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Furniture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTextField('Furniture Name', nameController),
            buildTextField('Price', priceController, isNumeric: true),
            buildDropdown(),
            buildTextField('Detail', detailController),
            buildTextField('Quantity', quantityController, isNumeric: true),
          ],
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

  // Build a text field widget
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

  // Build a dropdown widget for category selection
  Widget buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value:
            selectedCategory, // You will need a variable to store the selected category
        items: <String>['Sofa', 'Bed', 'Table', 'Chair'] // Your categories
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        title: const Text('Furniture Management'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: ListView.builder(
        itemCount: furnitureItems.length,
        itemBuilder: (context, index) {
          final item = furnitureItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0), // Add margin for spacing between cards
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0), // Padding inside the ListTile
              title: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  item['name'] ?? 'Unnamed Furniture',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'Price: \$${item['price'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'Category: ${item['category'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'Quantity: ${item['quantity'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      item['detail'] ?? 'No details provided.',
                      style:
                          const TextStyle(fontSize: 14.0, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => editFurniture(index),
              ),
            ),
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

// For showing the dialog to add or edit furniture
}
