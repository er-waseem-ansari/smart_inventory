class Product {
  final int productId;
  final String productName;
  final String productDescription;
  final String productCategory;
  final String productCode;

  Product({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productCategory,
    required this.productCode,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productId: map['product_id'] ?? 0,
      productName: map['product_name'] ?? '',
      productDescription: map['product_description'] ?? '',
      productCategory: map['product_category'] ?? '',
      productCode: map['product_code'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_description': productDescription,
      'product_category': productCategory,
      'product_code': productCode,
    };
  }
}
