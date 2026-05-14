class Product {
  final int? id;
  final String name;
  final int price;
  final String description;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString() ?? 'Tanpa Nama',
      price: json['price'] != null
          ? (double.tryParse(json['price'].toString())?.toInt() ?? 0)
          : 0,
      description: json['description']?.toString() ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'price': price, 'description': description};
  }
}
