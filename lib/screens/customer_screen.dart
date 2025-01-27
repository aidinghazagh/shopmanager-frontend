import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_manager/models/customer.dart';
import 'package:shop_manager/screens/order_screen.dart';

import '../helpers/api_helper.dart';
import '../helpers/api_response.dart';
import '../helpers/app_language.dart';
import '../widgets/custom_snack_bar.dart';
import '../widgets/delete_button.dart';
import '../widgets/dynamic_form.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  List<Customer> customers = [];
  bool isLoading = true;
  String errorMessage = '';

  Future<void> fetchCustomers() async {
    try {
      ApiResponse response = await ApiHelper.get('customer');
      // If any errors
      if (! response.status) {
        if(response.errors.isNotEmpty){
          setState(() {
            errorMessage = response.errors[0];
            isLoading = false;
          });
        } else{
          setState(() {
            errorMessage = AppLanguage().translate('server_error');
            isLoading = false;
          });
        }
        customSnackBar(
          context,
          errorMessage,
          fetchCustomers,
        );
        return;
      }

      // Parse the products from the response
      List<Customer> customerListTemp = (response.output as List)
          .map((customerJson) => Customer.fromJson(customerJson))
          .toList();

      setState(() {
        customers = customerListTemp;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "${AppLanguage().translate('network_error')} : $e";
        isLoading = false;
      });
      customSnackBar(
        context,
        errorMessage,
        fetchCustomers,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }
  void _navigateToDynamicForm({int? id, Customer? customer}) async {
    Map<String, String>? initialData;
    if (customer != null) {
      initialData = {
        'name': customer.name,
        'phone': customer.phone,
      };
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DynamicForm(
          fields: ['name', 'phone'], // Specify form fields
          endpoint: 'customer',
          title: AppLanguage().translate('customer'),
          id: id,
          initialData: initialData,
        ),
      ),
    );

    fetchCustomers();
  }
  Future<void> _deleteCustomer(int customerId) async {
    try {
      ApiResponse response = await ApiHelper.delete('customer/$customerId');
      if (!response.status) {
        setState(() {
          errorMessage = response.errors.isNotEmpty
              ? response.errors[0]
              : AppLanguage().translate('server_error');
        });
        customSnackBar(context, errorMessage, null);
        return;
      }

      // Refresh the product list after deletion
      fetchCustomers();
    } catch (e) {
      setState(() {
        errorMessage = "${AppLanguage().translate('network_error')} : $e";
      });
      customSnackBar(context, errorMessage, null);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLanguage().translate('customers')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToDynamicForm(),
            tooltip: AppLanguage().translate('store'),
          ),
        ],

      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : customers.isEmpty
          ? Center(child: Text(AppLanguage().translate('no_customers_available')))
          : ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];

          final formattedCreatedAt = DateFormat('yyyy-MM-dd').format(customer.createdAt);
          final formattedUpdatedAt = DateFormat('yyyy-MM-dd').format(customer.updatedAt);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              borderRadius: BorderRadius.circular(10), // Matches the card's border radius
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => OrderScreen(customer: customer),));
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            '${AppLanguage().translate('phone')}: ${customer.phone}',
                          ),
                          Text('${AppLanguage().translate('created_at')}: $formattedCreatedAt'),
                          Text('${AppLanguage().translate('updated_at')}: $formattedUpdatedAt'),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _navigateToDynamicForm(id: customer.id, customer: customer),
                      tooltip: AppLanguage().translate('edit'),
                    ),
                    DeleteButton(
                      onDelete: () => _deleteCustomer(customer.id),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
