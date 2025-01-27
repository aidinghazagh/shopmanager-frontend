import 'package:shop_manager/models/inventory_log.dart';
import 'package:shop_manager/models/product_log.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final List<ProductLog> logs;
  final List<InventoryLog> inventoryLogs;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.logs,
    required this.inventoryLogs,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      logs: json['logs'],
      inventoryLogs: json['inventory_logs']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'logs': logs,
      'inventory_logs': inventoryLogs
    };
  }
}