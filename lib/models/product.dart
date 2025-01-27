import 'package:shop_manager/models/inventory_log.dart';
import 'package:shop_manager/models/product_log.dart';

class Product {
  final int id;
  final String name;
  final int price;
  final int purchasePrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProductLog> logs;
  final List<InventoryLog> inventoryLogs;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.purchasePrice,
    required this.logs,
    required this.inventoryLogs,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      purchasePrice: json['purchase_price'],
      logs: (json['logs'] as List).map((log) => ProductLog.fromJson(log)).toList(),
      inventoryLogs: (json['inventory_logs'] as List).map((log) => InventoryLog.fromJson(log)).toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}