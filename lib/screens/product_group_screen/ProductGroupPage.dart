import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_inventory/models/Product.dart';
import 'package:smart_inventory/screens/new_product_screen/NewProductPage.dart';
import 'package:smart_inventory/screens/search_product_group/SearchProductInGroupPage.dart';
import 'package:smart_inventory/utils/color_palette.dart';
import 'package:smart_inventory/widgets/product_card.dart';
import 'package:http/http.dart' as http;

class ProductGroupPage extends StatefulWidget {
  final String? name;
  final int? id;
  const ProductGroupPage({Key? key, this.name, this.id}) : super(key: key);

  @override
  State<ProductGroupPage> createState() => _ProductGroupPageState();
}

class _ProductGroupPageState extends State<ProductGroupPage> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  Future<void> deleteProduct(BuildContext context) async {
    try {
      print("INSIDE DELETE PRODUCT with ID: ${widget.id}");

      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8082/products/${widget.id}'),
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

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8082/products/items/productName/${widget.name}"),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Product.fromMap(item)).toList();
    } else {
      throw Exception("Failed to load products");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 10),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NewProductPage(group: widget.name),
              ),
            ).then((value) {
              if (value == true) {
                setState(() {
                  futureProducts = fetchProducts(); // Refresh after adding product
                });
              }
            });
          },
          splashColor: ColorPalette.bondyBlue,
          backgroundColor: ColorPalette.pacificBlue,
          child: const Icon(Icons.add, color: ColorPalette.white),
        ),
      ),
      body: Container(
        color: ColorPalette.pacificBlue,
        child: SafeArea(
          child: Container(
            color: ColorPalette.aquaHaze,
            width: double.infinity,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text(
                              "Products",
                              style: TextStyle(
                                color: ColorPalette.timberGreen,
                                fontSize: 20,
                                fontFamily: "Nunito",
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: ColorPalette.timberGreen),
                              onPressed: () {
                                setState(() {
                                  futureProducts = fetchProducts();
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: FutureBuilder<List<Product>>(
                            future: futureProducts,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text("Error: ${snapshot.error}"));
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text("No products available"));
                              }

                              List<Product> products = snapshot.data!;
                              return ListView.builder(
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  return ProductCard(
                                    product: products[index],
                                    docID: products[index].id.toString(),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
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

  Widget _buildHeader() {
    return Container(
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
                icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 35),
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true to refresh HomeScreen
                },
              ),
              Text(
                widget.name!.length > 14 ? '${widget.name!.substring(0, 12)}..' : widget.name!,
                style: const TextStyle(fontFamily: "Nunito", fontSize: 28, color: Colors.white),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                splashColor: ColorPalette.timberGreen,
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SearchProductInGroupPage(name: widget.name),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () => deleteProduct(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}