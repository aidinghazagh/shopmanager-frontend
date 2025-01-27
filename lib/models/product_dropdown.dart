class ProductDropDown{
  final int id;
  final String name;
  final int price;

  ProductDropDown({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ProductDropDown.fromJson(Map<String, dynamic> json) {
    return ProductDropDown(
      id: json['id'],
      name: json['name'],
      price: json['price'],
    );
  }
}