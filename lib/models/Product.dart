import 'dart:ffi';

class Product {
  Product({
    this.id,
    this.name,
    this.cost,
    this.group,
    this.location,
    this.company,
    this.quantity,
    this.image,
    this.description,
  });

  int? id;
  String? name;
  double? cost;
  String? group;
  String? location;
  String? company;
  int? quantity;
  String? image;
  String? description;

  factory Product.fromMap(Map<String, dynamic> json) => Product(
    id: json["id"] as int?,
    name: json["name"] as String?,
    cost: json["cost"] as double?,
    group: json["group"] as String?,
    location: json["location"] as String?,
    company: json["company"] as String?,
    quantity: json["quantity"] as int?,
    image: json["image"] as String?,
    description: json["description"] as String?,
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "cost": cost,
    "group": group,
    "location": location,
    "company": company,
    "quantity": quantity,
    "image": image,
    "description": description,
  };
}