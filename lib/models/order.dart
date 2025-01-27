import 'package:shop_manager/models/order_product.dart';

import 'customer.dart';

class Order{
  final int id;
  final Customer? customer;
  final int? discount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderProduct> orderProduct;

  Order({
    required this.id,
    required this.customer,
    required this.discount,
    required this.createdAt,
    required this.updatedAt,
    required this.orderProduct
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      discount: json['discount'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      orderProduct: (json['order_products'] as List).map((orderProducts) =>
          OrderProduct.fromJson(orderProducts)).toList(),
    );
  }

}