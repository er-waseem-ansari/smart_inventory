import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
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
  final TextEditingController _newProductGroup = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final List<String> productGroups = [
      'Electronics',
      'Groceries',
      'Clothing',
      'Stationery',
      'Toys',
      'Home Appliances',
      'Books',
      'Sports Equipment'
    ];

    return Scaffold(
      floatingActionButton: Padding(padding: const EdgeInsets.only(
        bottom: 10,
        right: 10
      ),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    "Add Product Group",
                    style: TextStyle(fontFamily: "Nunito"),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: ColorPalette.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 3),
                              blurRadius: 6,
                              color: const Color(0xff000000).withOpacity(0.16),
                            ),
                          ],
                        ),
                        height: 50,
                        child: TextField(
                          textInputAction: TextInputAction.next,
                          key: UniqueKey(),
                          controller: _newProductGroup,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 16,
                            color: ColorPalette.nileBlue,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Product Group Name",
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
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (_newProductGroup.text != null &&
                              _newProductGroup.text != "") {
                          //   try {
                          //     final DocumentSnapshot<Map<String, dynamic>>
                          //     _doc = await _firestore
                          //         .collection("utils")
                          //         .doc("productGroups")
                          //         .get();
                          //     final List<dynamic> _tempList =
                          //     _doc.data()!['list'] as List<dynamic>;
                          //     if (_tempList.contains(_newProductGroup.text)) {
                          //       showTextToast("Group Name already created");
                          //     } else {
                          //       _tempList.add(_newProductGroup.text);
                          //       _firestore
                          //           .collection('utils')
                          //           .doc("productGroups")
                          //           .update({'list': _tempList});
                          //       showTextToast("Added Successfully");
                          //     }
                          //   } catch (e) {
                          //     showTextToast("An Error Occured!");
                          //   }
                          //   // ignore: use_build_context_synchronously
                          //   Navigator.of(context).pop();
                          //   _newProductGroup.text = "";
                          // } else {
                          //   showTextToast("Enter Valid Name!");
                          }
                        },
                        child: Container(
                          height: 45,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: ColorPalette.pacificBlue,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 3),
                                blurRadius: 6,
                                color:
                                const Color(0xff000000).withOpacity(0.16),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Done",
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: "Nunito",
                                color: ColorPalette.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 20,
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
                        const Text(
                          "Homepage",
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
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (context) =>
                                //     const GlobalSearchPage(),
                                //   ),
                                // );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.power_settings_new,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showConfirmDialog(
                                  context,
                                  "Are you sure you want to Logout?",
                                  "No",
                                  "Yes", () async {
                                  Navigator.of(context).pop();
                                }, () async {
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
                            )
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
                              "Product Groups",
                              style: TextStyle(
                                color: ColorPalette.timberGreen,
                                fontSize: 20,
                                fontFamily: "Nunito",
                              ),
                            ),
                            const SizedBox(height: 20),
                            /*Expanded(
                              child: StreamBuilder(
                                stream:
                                _firestore.collection("utils").snapshots(),
                                builder: (
                                    BuildContext context,
                                    AsyncSnapshot<
                                        QuerySnapshot<Map<String, dynamic>>>
                                    snapshot,
                                    ) {
                                  if (snapshot.hasData) {
                                    final List<dynamic> _productGroups =
                                    snapshot.data!.docs[0].data()['list']
                                    as List<dynamic>;
                                    _productGroups.sort();
                                    return GridView.builder(
                                      gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 2,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                      ),
                                      itemCount: _productGroups.length,
                                      itemBuilder: (context, index) {
                                        return ProductGroupCard(
                                          name: _productGroups[index] as String,
                                          key: UniqueKey(),
                                        );
                                      },
                                    );
                                  } else {
                                    return const Center(
                                      child: SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: CircularProgressIndicator(
                                          color: ColorPalette.pacificBlue,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            )*/
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
                                  return ProductGroupCard(
                                    name: productGroups[index],
                                    key: UniqueKey(),
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
      ),
    );
  }
}
