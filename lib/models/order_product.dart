class OrderProduct{
  final int id;
  final int quantity;
  final String nameOnCreated;
  final int priceOnCreated;
  final int purchasePriceOnCreated;

  OrderProduct({
    required this.id,
    required this.quantity,
    required this.nameOnCreated,
    required this.priceOnCreated,
    required this.purchasePriceOnCreated,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'],
      quantity: json['quantity'],
      nameOnCreated: json['name_on_created'],
      priceOnCreated: json['price_on_created'],
      purchasePriceOnCreated: json['purchase_price_on_created'],
    );
  }
}