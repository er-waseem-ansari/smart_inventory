import 'package:flutter/material.dart';
import 'package:smart_inventory/models/Product.dart';
import 'package:smart_inventory/screens/new_product_screen/NewProductPage.dart';
import 'package:smart_inventory/screens/search_product_group/SearchProductInGroupPage.dart';
import 'package:smart_inventory/utils/color_palette.dart';
import 'package:smart_inventory/widgets/product_card.dart';

class ProductGroupPage extends StatefulWidget {
  final String? name;
  ProductGroupPage({Key? key, this.name}) : super(key: key);

  @override
  State<ProductGroupPage> createState() => _ProductGroupPageState();
}

class _ProductGroupPageState extends State<ProductGroupPage> {
  final List<Map<String, dynamic>> dummyProducts = [
    {
      "name": "Product 1",
      "group": "Group A",
      "description": "Description of Product 1",
      "code": "P001",
    },
    {
      "name": "Product 2",
      "group": "Group A",
      "description": "Description of Product 2",
      "code": "P002",
    },
    {
      "name": "Product 3",
      "group": "Group B",
      "description": "Description of Product 3",
      "code": "P003",
    },
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 10,
          right: 10,
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return NewProductPage(
                    group: widget.name,
                  );
                },
              ),
            );
          },
          splashColor: ColorPalette.bondyBlue,
          backgroundColor: ColorPalette.pacificBlue,
          child: const Icon(
            Icons.add,
            color: ColorPalette.white,
          ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                          Text(
                            widget.name!.length > 14
                                ? '${widget.name!.substring(0, 12)}..'
                                : widget.name!,
                            style: const TextStyle(
                              fontFamily: "Nunito",
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            splashColor: ColorPalette.timberGreen,
                            icon: const Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SearchProductInGroupPage(
                                    name: widget.name,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              //TODO
                            },
                          ),
                        ],
                      )
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
                          Row(
                            children: const [
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                          const Text(
                            "Products",
                            style: TextStyle(
                              color: ColorPalette.timberGreen,
                              fontSize: 20,
                              fontFamily: "Nunito",
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Expanded(
                          //   child: StreamBuilder(
                          //     stream: _firestore
                          //         .collection("products")
                          //         .where("group", isEqualTo: name)
                          //         .orderBy('name')
                          //         .snapshots(),
                          //     builder: (
                          //         BuildContext context,
                          //         AsyncSnapshot<
                          //             QuerySnapshot<Map<String, dynamic>>>
                          //         snapshot,
                          //         ) {
                          //       if (!snapshot.hasData) {
                          //         return const Center(
                          //           child: SizedBox(
                          //             height: 40,
                          //             width: 40,
                          //             child: CircularProgressIndicator(
                          //               color: Colors.black,
                          //             ),
                          //           ),
                          //         );
                          //       }
                          //       return ListView.builder(
                          //         itemCount: snapshot.data!.docs.length,
                          //         itemBuilder:
                          //             (BuildContext context, int index) {
                          //           return ProductCard(
                          //             product: Product.fromMap(
                          //               snapshot.data!.docs[index].data(),
                          //             ),
                          //             docID: snapshot.data!.docs[index].id,
                          //           );
                          //         },
                          //       );
                          //     },
                          //   ),
                          // ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: dummyProducts.length,
                              itemBuilder: (BuildContext context, int index) {
                                final product = dummyProducts[index];
                                return ProductCard(
                                  product: Product.fromMap(
                                      product), // Converting map to Product object
                                  docID: product[
                                      "code"], // Using code as a dummy document ID
                                );
                              },
                            ),
                          )
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
