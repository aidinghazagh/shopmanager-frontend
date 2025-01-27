import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_manager/helpers/api_helper.dart';
import 'package:shop_manager/helpers/api_response.dart';
import 'package:shop_manager/helpers/app_language.dart';
import 'package:shop_manager/models/order.dart';
import 'package:shop_manager/models/payment.dart';
import 'package:shop_manager/widgets/custom_snack_bar.dart';

import '../widgets/dynamic_form.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<Payment> payments = [];
  bool isLoading = true;
  String errorMessage = '';

  Future<void> fetchPayments() async {
    try {
      ApiResponse response = await ApiHelper.get('order/${widget.order.id}/payment');
      if (!response.status) {
        setState(() {
          errorMessage = response.errors.isNotEmpty
              ? response.errors[0]
              : AppLanguage().translate('server_error');
          isLoading = false;
        });
        customSnackBar(context, errorMessage, fetchPayments);
        return;
      }

      List<Payment> fetchedPayments = (response.output as List)
          .map((paymentJson) => Payment.fromJson(paymentJson))
          .toList();

      setState(() {
        payments = fetchedPayments;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "${AppLanguage().translate('network_error')} : $e";
        isLoading = false;
      });
      customSnackBar(context, errorMessage, fetchPayments);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  void _navigateToDynamicFormPayment() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DynamicForm(
          fields: ['amount'],
          endpoint: 'order/${widget.order.id}/payment',
          title: AppLanguage().translate('payment'),
        ),
      ),
    );
    fetchPayments();
  }

  Future<void> _deletePayment(int paymentId) async {
    try {
      ApiResponse response = await ApiHelper.delete('payment/$paymentId');
      if (!response.status) {
        customSnackBar(context, response.errors.isNotEmpty ? response.errors[0] : AppLanguage().translate('server_error'), null);
        return;
      }
      fetchPayments();
    } catch (e) {
      customSnackBar(context, "${AppLanguage().translate('network_error')} : $e", null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(widget.order.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text("${AppLanguage().translate('order')} #${widget.order.id}"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${AppLanguage().translate('customer')}: ${widget.order.customer?.name ?? AppLanguage().translate('unknown')}",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text("${AppLanguage().translate('total_amount')}: ${widget.order.orderProduct.fold<int>(0, (sum, product) => sum + product.priceOnCreated)}"),
            Text("${AppLanguage().translate('discount')}: ${widget.order.discount ?? '0'}"),
            Text("${AppLanguage().translate('created_at')}: $formattedDate"),
            const SizedBox(height: 20),
            Text("${AppLanguage().translate('products')}:", style: Theme.of(context).textTheme.titleMedium),
            ...widget.order.orderProduct.map((product) => Text("- ${product.nameOnCreated} (x${product.quantity})")),
            const SizedBox(height: 20),
            Text("${AppLanguage().translate('payments')}:", style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToDynamicFormPayment(),
              label: Text(AppLanguage().translate('store_payment')),
            ),
            payments.isEmpty
                ? Text(AppLanguage().translate('no_payments_found'))
                : Column(
              children: payments
                  .map((payment) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text("${AppLanguage().translate('amount')}: ${payment.amount}"),
                  subtitle: Text("${AppLanguage().translate('created_at')}: ${DateFormat('yyyy-MM-dd').format(payment.createdAt)}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePayment(payment.id),
                  ),
                ),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}