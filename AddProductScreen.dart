import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _categories = [
    'All',
    'Fruits',
    'Vegetables',
    'Dairy & Eggs',
    'Meat & Seafood',
    'Bakery & Bread',
    'Frozen Foods',
    'Canned & Packaged Goods',
    'Snacks & Sweets',
    'Beverages',
    'Grains & Pasta',
    'Spices & Condiments',
    'Personal Care',
    'Household Items',
    'Baby Care',
    'Pet Care'
  ];
  final _firestore = FirebaseFirestore.instance;
  String selectedCategory = 'Fruits';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  static const String backendUrl = 'https://grocerybackendapi.vercel.app';

  void _showProductForm({DocumentSnapshot? doc}) {
    final isEdit = doc != null;
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: doc?['name'] ?? '');
    final priceController = TextEditingController(text: doc?['price']?.toString() ?? '');
    final descController = TextEditingController(text: doc?['description'] ?? '');
    String category = doc?['category'] ?? 'Fruits';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF2c5364),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05, // Responsive padding
          vertical: 24,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEdit ? "Update Product" : "Add Product",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Product Name"),
                        validator: (val) => val!.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: category,
                        dropdownColor: const Color(0xFF2c5364),
                        decoration: _inputDecoration("Category"),
                        items: _categories
                            .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(
                            cat,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                            .toList(),
                        onChanged: (val) => category = val!,
                        validator: (val) => val == null ? "Select category" : null,
                        isExpanded: true,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Price"),
                        validator: (val) => val!.isEmpty ? 'Enter price' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Description"),
                        validator: (val) => val!.isEmpty ? 'Enter description' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isEdit)
                      TextButton(
                        onPressed: () async {
                          final productId = doc!['productId'];
                          await doc.reference.delete();
                          final productData = {
                            'productId': productId,
                            'name': nameController.text.trim(),
                            'category': category,
                            'price': double.parse(priceController.text.trim()),
                          };
                          final response = await http.post(
                            Uri.parse('$backendUrl/delete-product'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode(productData),
                          );
                          if (response.statusCode != 201) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to delete product in Neo4j: ${response.body}')),
                            );
                          }
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "DELETE",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        final productData = {
                          "name": nameController.text.trim(),
                          "category": category,
                          "price": double.parse(priceController.text.trim()),
                          "description": descController.text.trim(),
                          "productId": isEdit ? doc!['productId'] : const Uuid().v4(),
                        };
                        final firebaseData = {
                          ...productData,
                          "timestamp": FieldValue.serverTimestamp(),
                        };

                        if (isEdit) {
                          await doc!.reference.update(firebaseData);
                          final response = await http.post(
                            Uri.parse('$backendUrl/update-product'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode(productData),
                          );
                          if (response.statusCode != 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to update product in Neo4j: ${response.body}')),
                            );
                          }
                        } else {
                          await _firestore.collection("products").add(firebaseData);
                          final response = await http.post(
                            Uri.parse('$backendUrl/create-product'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode(productData),
                          );
                          if (response.statusCode != 201) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to create product in Neo4j: ${response.body}')),
                            );
                          }
                        }

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        isEdit ? "UPDATE" : "ADD",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF203a43),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0f2027),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => searchQuery = value.toLowerCase());
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: const Color(0xFF203a43),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF203a43),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    dropdownColor: const Color(0xFF203a43),
                    style: const TextStyle(color: Colors.white),
                    underline: Container(),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedCategory = value!);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection("products").orderBy("timestamp", descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.tealAccent));
                }

                final filtered = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nameMatch = data['name'].toLowerCase().contains(searchQuery);
                  final categoryMatch =
                      selectedCategory == 'All' || data['category'] == selectedCategory;
                  return nameMatch && categoryMatch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                        'No products found',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: isSmallScreen ? 16 : 18)),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16, vertical: 8),
                  itemBuilder: (context, index) {
                    final data = filtered[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: const Color(0xFF203a43),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(data['name'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                        subtitle: Text(
                            "₹${data['price']} • ${data['category']}",
                            style: const TextStyle(color: Colors.white70)),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.tealAccent),
                          onPressed: () => _showProductForm(doc: filtered[index]),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        onPressed: () => _showProductForm(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}