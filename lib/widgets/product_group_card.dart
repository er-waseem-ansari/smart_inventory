import 'package:flutter/material.dart';
import 'package:smart_inventory/screens/product_group_screen/ProductGroupPage.dart';
import 'package:smart_inventory/utils/color_palette.dart';



class ProductGroupCard extends StatelessWidget {
  final String? name;
  final String? type;
  final String? description;
  final String? code;
  final String? imageUrl; // URL or asset path for the image.

  const ProductGroupCard({
    Key? key,
    this.name,
    this.type,
    this.description,
    this.code,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ProductGroupPage(
                  name: name,
                );
              },
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ColorPalette.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 5),
                blurRadius: 6,
                color: const Color(0xff000000).withOpacity(0.16),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left 1/3 part - Image
              Container(
                width: MediaQuery.of(context).size.width / 3, // Adjust as needed
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: imageUrl != null
                        ? NetworkImage(imageUrl!) // For network image
                        : const AssetImage('assets/images/default_category_image.png') as ImageProvider, // Default image
                    // fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Right 2/3 part - Text Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading (name)
                    Text(
                      name ?? "No Name",
                      style: const TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    // Details
                    Text(
                      "Type: ${type ?? "Unknown"}",
                      style: const TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Description: ${description ?? "No Description"}",
                      style: const TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Code: ${code ?? "N/A"}",
                      style: const TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}