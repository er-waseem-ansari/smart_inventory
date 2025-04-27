import 'dart:convert';
import 'dart:io';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_inventory/functions/confirm_dialog.dart';
import 'package:smart_inventory/screens/login_screen/LoginScreen.dart';
import 'package:smart_inventory/utils/color_palette.dart';
import 'package:smart_inventory/widgets/product_group_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescriptionController = TextEditingController();
  final TextEditingController _productCategoryController = TextEditingController();
  final TextEditingController _productCodeController = TextEditingController();

  List<Map<String, String>> productGroups = [];
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchProductGroups();
  }

  Future<void> fetchProductGroups() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8082/products'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        productGroups = data.map<Map<String, String>>((item) {
          return {
            'productName': item['productName']?.toString() ?? '',
            'productCategory': item['productCategory']?.toString() ?? '',
            'productDescription': item['productDescription']?.toString() ?? '',
            'productCode': item['productCode']?.toString() ?? '',
            'productId': item['productId']?.toString() ?? '',
            'imageData': item['imageData']?.toString() ?? '',
          };
        }).toList();
      });
    } else {
      print("Failed to load product groups");
    }
  }

  Future<void> addProductGroup() async {
    String? base64Image;
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8082/products/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "productName": _productNameController.text,
        "productDescription": _productDescriptionController.text,
        "productCategory": _productCategoryController.text,
        "productCode": _productCodeController.text,
        "imageData": base64Image,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop(); // Close dialog
      setState(() {
        _selectedImage = null; // Reset image
      });
      fetchProductGroups(); // Refresh UI
    } else {
      print("Failed to add product group: ${response.body}");
    }
  }

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
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  void showAddProductGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Product Group", style: TextStyle(fontFamily: "Nunito")),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    // Image preview with border
                    GestureDetector(
                      onTap: () async {
                        try {
                          final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            final file = File(pickedFile.path);
                            if (await file.exists()) {
                              setDialogState(() {
                                _selectedImage = file;
                              });
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
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorPalette.timberGreen, width: 2),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            height: 100,
                            width: 100,
                            errorBuilder: (context, error, stackTrace) {
                              print("Error displaying image: $error");
                              return const Center(
                                child: Text(
                                  "Error",
                                  style: TextStyle(fontFamily: "Nunito", color: Colors.red),
                                ),
                              );
                            },
                          ),
                        )
                            : const Center(
                          child: Text(
                            "Select image",
                            style: TextStyle(fontFamily: "Nunito", color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildTextField("Product Name", _productNameController),
                    const SizedBox(height: 10),
                    buildTextField("Product Description", _productDescriptionController),
                    const SizedBox(height: 10),
                    buildTextField("Product Category", _productCategoryController),
                    const SizedBox(height: 10),
                    buildTextField("Product Code", _productCodeController),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null; // Reset image on cancel
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_productNameController.text.isNotEmpty &&
                        _productDescriptionController.text.isNotEmpty &&
                        _productCategoryController.text.isNotEmpty &&
                        _productCodeController.text.isNotEmpty &&
                        _selectedImage != null) {
                      addProductGroup();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all fields and select an image")),
                      );
                    }
                  },
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        hintText: hint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 10),
        child: FloatingActionButton(
          onPressed: showAddProductGroupDialog,
          backgroundColor: ColorPalette.pacificBlue,
          child: const Icon(Icons.add, color: ColorPalette.white),
        ),
      ),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Tap back again to leave'),
        ),
        child: Container(
          color: ColorPalette.pacificBlue,
          child: SafeArea(
            child: Container(
              color: ColorPalette.aquaHaze,
              height: double.infinity,
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 10, left: 20, right: 15),
                    width: double.infinity,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: ColorPalette.pacificBlue,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "SmartInventory",
                          style: TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              splashColor: ColorPalette.timberGreen,
                              icon: const Icon(Icons.search, color: Colors.white),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.power_settings_new, color: Colors.white),
                              onPressed: () {
                                showConfirmDialog(
                                  context,
                                  "Are you sure you want to Logout?",
                                  "No",
                                  "Yes",
                                      () async {
                                    Navigator.of(context).pop();
                                  },
                                      () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.setBool('isLoggedIn', false);
                                    await prefs.remove('loggedInEmail');
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (context) => LoginScreen()),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
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
                            Row(
                              children: [
                                const Text(
                                  "Product Groups",
                                  style: TextStyle(
                                    color: ColorPalette.timberGreen,
                                    fontSize: 20,
                                    fontFamily: "Nunito",
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: fetchProductGroups,
                                  icon: const Icon(Icons.refresh),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                ),
                                itemCount: productGroups.length,
                                itemBuilder: (context, index) {
                                  final reversedList = productGroups.reversed.toList();
                                  return ProductGroupCard(
                                    name: reversedList[index]['productName'],
                                    type: reversedList[index]['productCategory'],
                                    description: reversedList[index]['productDescription'],
                                    code: reversedList[index]['productCode'],
                                    id: int.parse(reversedList[index]['productId']!),
                                    imageData: reversedList[index]['imageData'], // Pass imageData
                                    key: UniqueKey(),
                                  );
                                },
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
      ),
    );
  }
}