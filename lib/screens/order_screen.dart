import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_manager/helpers/api_helper.dart';
import 'package:shop_manager/helpers/api_response.dart';
import 'package:shop_manager/helpers/app_language.dart';
import 'package:shop_manager/models/order.dart';
import 'package:shop_manager/widgets/custom_snack_bar.dart';

import '../models/customer.dart';
import 'order_detail_screen.dart';
import 'order_form_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key, this.customer});
  final Customer? customer;


  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<Order> orders = [];
  bool isLoading = true;
  String errorMessage = '';

  Future<void> fetchOrders() async {
    try {
      ApiResponse response = widget.customer != null ? await ApiHelper.get('customer/${widget.customer!.id}/orders') : await ApiHelper.get('order');
      if (!response.status) {
        setState(() {
          errorMessage = response.errors.isNotEmpty
              ? response.errors[0]
              : AppLanguage().translate('server_error');
          isLoading = false;
        });
        customSnackBar(context, errorMessage, fetchOrders);
        return;
      }

      List<Order> fetchedOrders = (response.output as List)
          .map((orderJson) => Order.fromJson(orderJson))
          .toList();

      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "${AppLanguage().translate('network_error')} : $e";
        isLoading = false;
      });
      customSnackBar(context, errorMessage, fetchOrders);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }
  Future<void> deleteOrder(int orderId) async {
    try {
      ApiResponse response = await ApiHelper.delete('order/$orderId');
      if (!response.status) {
        customSnackBar(context, response.errors.isNotEmpty ? response.errors[0] : AppLanguage().translate('server_error'), null);
        return;
      }
      setState(() {
        orders.removeWhere((order) => order.id == orderId);
      });
    } catch (e) {
      customSnackBar(context, "${AppLanguage().translate('network_error')} : $e", null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer != null ? "${AppLanguage().translate('order_list_for')}: ${widget.customer!.name}" : AppLanguage().translate('orders')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderFormScreen()),
              );
            },
            tooltip: AppLanguage().translate('store'),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : orders.isEmpty
          ? Center(child: Text(AppLanguage().translate('no_orders_available')))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final formattedDate = DateFormat('yyyy-MM-dd').format(order.createdAt);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text("${AppLanguage().translate('order')} #${order.id}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.customer != null)
                    Text("${AppLanguage().translate('customer')}: ${order.customer!.name}"),
                    Text("${AppLanguage().translate('total_amount')}: ${order.orderProduct.fold<int>(
                      0,
                      (sum, product) => sum + product.priceOnCreated,
                    ).toString()}"),
                  Text("${AppLanguage().translate('discount')}: ${order.discount ?? '0'}"),
                  Text("${AppLanguage().translate('created_at')}: $formattedDate"),
                  Text("${AppLanguage().translate('products')}: "),
                  ...order.orderProduct.map((product) => Text("- ${product.nameOnCreated} (x${product.quantity})")),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteOrder(order.id),
                  ),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailScreen(order: order),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
