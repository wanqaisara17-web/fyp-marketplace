import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../providers/marketplace_provider.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String selectedCategory = "Books";

  final List<String> categories = [
    "Books",
    "Electronics",
    "Clothing",
    "Furniture",
    "Others",
  ];

  Future<void> submitProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        final itemName = _nameController.text;
        final itemPriceText = _priceController.text;
        final description = _descriptionController.text;

        final response = await http.post(
          Uri.parse("http://127.0.0.1:8080/demo/add_item.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "item_name": itemName,
            "item_price": itemPriceText,
            "description": description,
            "category": selectedCategory,
          }),
        );

        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          final newItem = Item(
            id: DateTime.now().millisecondsSinceEpoch,
            itemName: itemName,
            itemPrice: double.parse(itemPriceText),
            description: description,
            category: selectedCategory,
            createdAt: DateTime.now().toString(),
            status: "available",
          );

          context.read<MarketplaceProvider>().addItem(newItem);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Item added successfully")),
          );

          _nameController.clear();
          _priceController.clear();
          _descriptionController.clear();

          setState(() {
            selectedCategory = "Books";
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Failed to add item")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Connection error: $e")));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Item"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 50),
                      SizedBox(height: 8),
                      Text('Upload Image'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Item Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Enter item name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter price";
                  }
                  if (double.tryParse(value) == null) {
                    return "Enter a valid price";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((cat) {
                  return DropdownMenuItem<String>(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: submitProduct,
                  child: const Text(
                    "Post Item",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
