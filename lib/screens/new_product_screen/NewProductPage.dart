import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:smart_inventory/models/Product.dart';
import 'package:smart_inventory/utils/color_palette.dart';
import 'package:smart_inventory/widgets/location_drop_down.dart';

class NewProductPage extends StatefulWidget {
  final String? group;
  const NewProductPage({Key? key, this.group}) : super(key: key);

  @override
  State<NewProductPage> createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final Product newProduct = Product();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (await file.exists()) {
          setState(() {
            _selectedImage = file;
          });
        } else {
          print("Error: Selected file does not exist at path: ${pickedFile.path}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to load image")),
          );
        }
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  Future<void> addProduct(BuildContext context) async {
    try {
      String? base64Image;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final url = Uri.parse('http://10.0.2.2:8082/products/items');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": newProduct.id,
          "name": newProduct.name,
          "cost": newProduct.cost,
          "group": newProduct.group ?? widget.group,
          "location": newProduct.location,
          "company": newProduct.company,
          "quantity": newProduct.quantity,
          "image": base64Image, // Send Base64 string
          "description": newProduct.description,
          "productName": widget.group,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        Navigator.of(context).pop(); // Close the page after successful submission
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 10),
        child: FloatingActionButton(
          onPressed: () => addProduct(context),
          splashColor: ColorPalette.bondyBlue,
          backgroundColor: ColorPalette.pacificBlue,
          child: const Icon(Icons.done, color: ColorPalette.white),
        ),
      ),
      body: Container(
        color: ColorPalette.pacificBlue,
        child: SafeArea(
          child: Container(
            color: ColorPalette.aquaHaze,
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 15),
                  width: double.infinity,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: ColorPalette.pacificBlue,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 35),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        "New Product",
                        style: TextStyle(fontFamily: "Nunito", fontSize: 28, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: SizedBox(
                                height: 100,
                                width: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Container(
                                    color: ColorPalette.white,
                                    child: _selectedImage != null
                                        ? Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        print("Error displaying image: $error");
                                        return const Center(child: Icon(Icons.image, color: Colors.grey));
                                      },
                                    )
                                        : const Center(child: Icon(Icons.image, color: Colors.grey)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 12),
                            child: Text(
                              "Product Group : ${widget.group}",
                              style: const TextStyle(fontFamily: "Nunito", fontSize: 17, color: ColorPalette.nileBlue),
                            ),
                          ),
                          _buildTextField(
                            hintText: "Product Name",
                            initialValue: newProduct.name,
                            onChanged: (value) => newProduct.name = value,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  hintText: "Cost",
                                  initialValue: newProduct.cost?.toString(),
                                  onChanged: (value) => newProduct.cost = double.tryParse(value),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildTextField(
                                  hintText: "Quantity",
                                  initialValue: newProduct.quantity?.toString(),
                                  onChanged: (value) => newProduct.quantity = int.tryParse(value),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            hintText: "Company",
                            initialValue: newProduct.company,
                            onChanged: (value) => newProduct.company = value,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            hintText: "Description",
                            initialValue: newProduct.description,
                            onChanged: (value) => newProduct.description = value,
                          ),
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.only(left: 8, bottom: 5),
                            child: Text(
                              "Location",
                              style: TextStyle(fontFamily: "Nunito", fontSize: 14, color: ColorPalette.nileBlue),
                            ),
                          ),
                          LocationDD(product: newProduct),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    String? initialValue,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 3),
            blurRadius: 6,
            color: ColorPalette.nileBlue.withOpacity(0.1),
          ),
        ],
      ),
      height: 50,
      child: TextFormField(
        initialValue: initialValue ?? '',
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: "Nunito", fontSize: 16, color: ColorPalette.nileBlue),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          filled: true,
          fillColor: Colors.transparent,
          hintStyle: TextStyle(
            fontFamily: "Nunito",
            fontSize: 16,
            color: ColorPalette.nileBlue.withOpacity(0.58),
          ),
        ),
        cursorColor: ColorPalette.timberGreen,
      ),
    );
  }
}