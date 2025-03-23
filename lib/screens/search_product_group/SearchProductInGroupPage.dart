import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_inventory/models/Product.dart';
import 'package:smart_inventory/screens/product_details_screen/ProductDetailsPage.dart';
import 'package:smart_inventory/utils/color_palette.dart';
import 'package:smart_inventory/widgets/product_card.dart';
import 'package:http/http.dart' as http;
class SearchProductInGroupPage extends StatefulWidget {
  final String? name;
  const SearchProductInGroupPage({Key? key, this.name}) : super(key: key);

  @override
  State<SearchProductInGroupPage> createState() => _SearchProductInGroupPageState();
}

class _SearchProductInGroupPageState extends State<SearchProductInGroupPage> {
  FocusNode? inputFieldNode;
  String searchQuery = '';
  List<Product> products = [];
  bool isLoading = false;
  Timer? _debounceTimer; // Timer for debouncing

  @override
  void initState() {
    super.initState();
    inputFieldNode = FocusNode();
    if (widget.name != null) {
      searchQuery = widget.name!;
      fetchProducts(searchQuery); // Immediate search if name is provided
    }
  }

  @override
  void dispose() {
    inputFieldNode!.dispose();
    _debounceTimer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  Future<void> fetchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        products = [];
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8082/products/items/search?query=$query'),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          products = jsonResponse.map((data) => Product.fromMap(data as Map<String, dynamic>)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Debounce the API call
  void debounceSearch(String value) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel(); // Cancel any existing timer
    }

    _debounceTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        searchQuery = value;
        fetchProducts(searchQuery); // Call API after 2 seconds
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 10,
                    right: 15,
                  ),
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
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 35,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Expanded(
                        child: TextFormField(
                          focusNode: inputFieldNode,
                          autofocus: true,
                          initialValue: searchQuery,
                          onChanged: (value) {
                            debounceSearch(value); // Call debounce on every change
                          },
                          onFieldSubmitted: (value) {
                            // Immediate search on Enter key
                            if (_debounceTimer?.isActive ?? false) {
                              _debounceTimer!.cancel();
                            }
                            setState(() {
                              searchQuery = value;
                              fetchProducts(searchQuery);
                            });
                          },
                          textInputAction: TextInputAction.search,
                          key: UniqueKey(),
                          keyboardType: TextInputType.text,
                          style: const TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 24,
                            color: ColorPalette.timberGreen,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Product Name",
                            filled: true,
                            fillColor: Colors.transparent,
                            hintStyle: TextStyle(
                              fontFamily: "Nunito",
                              fontSize: 24,
                              color: Colors.white.withOpacity(0.58),
                            ),
                          ),
                          cursorColor: ColorPalette.timberGreen,
                        ),
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
                          if (isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (products.isEmpty && searchQuery.isNotEmpty)
                            const Center(
                              child: Text(
                                'No exact matches. Showing similar products...',
                                style: TextStyle(
                                  fontFamily: "Nunito",
                                  fontSize: 16,
                                  color: ColorPalette.timberGreen,
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductDetailsPage(
                                            product: product,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ProductCard(product: product),
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
    );
  }
}