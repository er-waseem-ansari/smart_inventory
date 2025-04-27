import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:smart_inventory/models/Product.dart';
import 'package:smart_inventory/utils/color_palette.dart';
import 'package:smart_inventory/widgets/location_drop_down.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product? product;
  final String? docID;
  const ProductDetailsPage({Key? key, this.product, this.docID}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
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

  Future<void> updateProduct(BuildContext context) async {
    try {
      String? base64Image;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(bytes);
        widget.product!.image = base64Image; // Update product image
      }

      final response = await http.put(
        Uri.parse('http://10.0.2.2:8082/products/${widget.product?.id}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": widget.product!.id,
          "name": widget.product!.name,
          "cost": widget.product!.cost,
          "group": widget.product!.group,
          "location": widget.product!.location,
          "company": widget.product!.company,
          "quantity": widget.product!.quantity,
          "image": widget.product!.image,
          "description": widget.product!.description,
          "productName": widget.product!.group,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
        Navigator.of(context).pop(true); // Return true to trigger refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update product: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> deleteProductItem(BuildContext context) async {
    try {
      print("INSIDE DELETE PRODUCT ITEM with ID: ${widget.product?.id}");

      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8082/products/${widget.product?.id}'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully!')),
        );
        Navigator.of(context).pop(true); // Return true to trigger refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete product: ${response.body}')),
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
          onPressed: () => updateProduct(context),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left_rounded,
                              size: 35,
                              color: Colors.white, // Fixed color
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Text(
                            "Edit Product",
                            style: TextStyle(
                              fontFamily: "Nunito",
                              fontSize: 28,
                              color: Colors.white, // Fixed color
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white, // Fixed color
                        ),
                        onPressed: () => deleteProductItem(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 50,
                                  ),
                                  margin: const EdgeInsets.only(top: 75),
                                  decoration: const BoxDecoration(
                                    color: ColorPalette.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8, bottom: 12),
                                          child: Text(
                                            "Product Group : ${widget.product!.group}",
                                            style: const TextStyle(
                                              fontFamily: "Nunito",
                                              fontSize: 17,
                                              color: ColorPalette.nileBlue,
                                            ),
                                          ),
                                        ),
                                        Container(
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
                                            initialValue: widget.product!.name ?? '',
                                            onChanged: (value) => widget.product!.name = value,
                                            textInputAction: TextInputAction.next,
                                            key: UniqueKey(),
                                            keyboardType: TextInputType.text,
                                            style: const TextStyle(
                                              fontFamily: "Nunito",
                                              fontSize: 16,
                                              color: ColorPalette.nileBlue,
                                            ),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Product Name",
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
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
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
                                                  initialValue: widget.product!.cost?.toString() ?? '',
                                                  onChanged: (value) =>
                                                  widget.product!.cost = double.tryParse(value),
                                                  textInputAction: TextInputAction.next,
                                                  key: UniqueKey(),
                                                  keyboardType: TextInputType.number,
                                                  style: const TextStyle(
                                                    fontFamily: "Nunito",
                                                    fontSize: 16,
                                                    color: ColorPalette.nileBlue,
                                                  ),
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: "Cost",
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
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Container(
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
                                                  initialValue: widget.product!.quantity?.toString() ?? '',
                                                  onChanged: (value) =>
                                                  widget.product!.quantity = int.tryParse(value),
                                                  textInputAction: TextInputAction.next,
                                                  key: UniqueKey(),
                                                  keyboardType: TextInputType.number,
                                                  style: const TextStyle(
                                                    fontFamily: "Nunito",
                                                    fontSize: 16,
                                                    color: ColorPalette.nileBlue,
                                                  ),
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: "Quantity",
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
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Container(
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
                                            initialValue: widget.product!.company ?? '',
                                            onChanged: (value) => widget.product!.company = value,
                                            textInputAction: TextInputAction.next,
                                            key: UniqueKey(),
                                            keyboardType: TextInputType.text,
                                            style: const TextStyle(
                                              fontFamily: "Nunito",
                                              fontSize: 16,
                                              color: ColorPalette.nileBlue,
                                            ),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Company",
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
                                        ),
                                        const SizedBox(height: 20),
                                        Container(
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
                                            initialValue: widget.product!.description ?? '',
                                            onChanged: (value) => widget.product!.description = value,
                                            textInputAction: TextInputAction.next,
                                            key: UniqueKey(),
                                            keyboardType: TextInputType.text,
                                            style: const TextStyle(
                                              fontFamily: "Nunito",
                                              fontSize: 16,
                                              color: ColorPalette.nileBlue,
                                            ),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Description",
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
                                        ),
                                        const SizedBox(height: 20),
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8, bottom: 5),
                                          child: Text(
                                            "Location",
                                            style: TextStyle(
                                              fontFamily: "Nunito",
                                              fontSize: 14,
                                              color: ColorPalette.nileBlue,
                                            ),
                                          ),
                                        ),
                                        LocationDD(product: widget.product),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
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
                                                print("Error displaying selected image: $error");
                                                return const Center(
                                                  child: Icon(
                                                    Icons.image,
                                                    color: ColorPalette.nileBlue,
                                                  ),
                                                );
                                              },
                                            )
                                                : widget.product!.image != null &&
                                                widget.product!.image!.isNotEmpty
                                                ? Image.memory(
                                              base64Decode(widget.product!.image!
                                                  .replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                print("Error decoding image: $error");
                                                return const Center(
                                                  child: Icon(
                                                    Icons.image,
                                                    color: ColorPalette.nileBlue,
                                                  ),
                                                );
                                              },
                                            )
                                                : const Center(
                                              child: Icon(
                                                Icons.image,
                                                color: ColorPalette.nileBlue,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
}