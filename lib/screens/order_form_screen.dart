import 'package:flutter/material.dart';
import 'package:shop_manager/helpers/api_helper.dart';
import 'package:shop_manager/helpers/api_response.dart';
import 'package:shop_manager/helpers/app_language.dart';
import 'package:shop_manager/models/customer_dropdown.dart';
import 'package:shop_manager/models/product_dropdown.dart';
import 'package:shop_manager/widgets/custom_snack_bar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dynamic_form.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> with RouteAware {
  CustomerDropDown? selectedCustomer;
  List<CustomerDropDown> customers = [];
  List<CustomerDropDown> filteredCustomers = [];
  List<Map<String, dynamic>> selectedProducts = [];
  List<ProductDropDown> products = [];
  List<ProductDropDown> filteredProducts = [];
  final TextEditingController discountController = TextEditingController();
  final TextEditingController paidController = TextEditingController(text: '0');
  final TextEditingController searchController = TextEditingController();
  final TextEditingController customerSearchController = TextEditingController();
  bool isPaidChecked = false;
  bool isLoading = true;
  String errorMessage = '';
  int totalPriceProducts = 0;

  void togglePaid(bool? value) {
    setState(() {
      isPaidChecked = value ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCustomersAndProducts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchCustomersAndProducts() async {
    try {
      final customerResponse = await ApiHelper.get('customer/dropdown');
      if (!customerResponse.status) {
        if (customerResponse.errors.isNotEmpty) {
          setState(() {
            errorMessage = customerResponse.errors[0];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = AppLanguage().translate('server_error');
            isLoading = false;
          });
        }
        customSnackBar(context, errorMessage, fetchCustomersAndProducts);
        return;
      }

      final productResponse = await ApiHelper.get('product/dropdown');
      if (!productResponse.status) {
        if (productResponse.errors.isNotEmpty) {
          setState(() {
            errorMessage = productResponse.errors[0];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = AppLanguage().translate('server_error');
            isLoading = false;
          });
        }
        customSnackBar(context, errorMessage, fetchCustomersAndProducts);
        return;
      }

      setState(() {
        customers = (customerResponse.output as List)
            .map((json) => CustomerDropDown.fromJson(json))
            .toList();
        filteredCustomers = customers;
        products = (productResponse.output as List)
            .map((json) => ProductDropDown.fromJson(json))
            .toList();
        filteredProducts = products;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "${AppLanguage().translate('network_error')} : $e";
        isLoading = false;
      });
    }
  }

  void addProduct(ProductDropDown product) {
    int index = selectedProducts.indexWhere((p) => p['id'] == product.id);
    if (index != -1) {
      setState(() {
        selectedProducts[index]['quantity'] += 1; // Update quantity if product exists
      });
    } else {
      setState(() {
        selectedProducts.add({
          'id': product.id,
          'name': product.name,
          'quantity': 1,
        });
      });
    }
  }

  void submitOrder() async {
    Map<String, dynamic> orderData = {
      'customer_id': selectedCustomer?.id,
      'discount': discountController.text.isEmpty ? null : int.tryParse(discountController.text),
      'products': {for (var p in selectedProducts) p['id'].toString(): p['quantity']},
      'paid': isPaidChecked ? totalPriceProducts : int.tryParse(paidController.text),
    };

    try {
      ApiResponse response = await ApiHelper.post('order', body: orderData);
      if (!response.status) {
        if (response.errors.isNotEmpty) {
          customSnackBar(context, response.errors[0], null);
          return;
        } else if (response.validations.isNotEmpty) {
          customSnackBar(context, response.validations.toString(), null);
          return;
        }
        customSnackBar(context, AppLanguage().translate('server_error'), null);
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      customSnackBar(context, "${AppLanguage().translate('network_error')} : $e", null);
    }
  }

  void filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredProducts = products;
      });
    } else {
      setState(() {
        filteredProducts = products
            .where((product) => product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void filterCustomers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCustomers = customers;
        selectedCustomer = null; // Reset selection when search is cleared
      });
    } else {
      setState(() {
        filteredCustomers = customers
            .where((customer) => customer.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        // Ensure that selectedCustomer is only set if there's exactly one match
        if (filteredCustomers.length == 1) {
          selectedCustomer = filteredCustomers[0];
        } else {
          selectedCustomer = null; // Reset selection if there are multiple or no results
        }
      });
    }
  }

  void _navigateToDynamicFormCustomer() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DynamicForm(
          fields: ['name', 'phone'],
          endpoint: 'customer',
          title: AppLanguage().translate('customer'),
        ),
      ),
    ).then((_) => fetchCustomersAndProducts()); // Refresh customers after returning
  }

  void _navigateToDynamicFormProduct(BuildContext modalContext) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DynamicForm(
          fields: ['name', 'price', 'purchase_price', 'inventory'],
          endpoint: 'product',
          title: AppLanguage().translate('product'),
        ),
      ),
    ).then((_) {
      fetchCustomersAndProducts().then((_) {
        Navigator.pop(modalContext); // Close the modal
        showProductModal(); // Reopen the updated modal
      });
    });
  }
  void showProductModal() {
    showModalBottomSheet(
      context: context,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: AppLanguage().translate('search_product'),
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchController.clear();
                            filterProducts('');
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filterProducts(value);
                      });
                    },
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  onPressed: () => _navigateToDynamicFormProduct(modalContext),
                  label: Text(AppLanguage().translate('store_product')),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text(product.price.toString()),
                          onTap: () {
                            setState(() {
                              addProduct(product);
                              totalPriceProducts += product.price;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLanguage().translate('new_order'))),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar for customers
            TextField(
              controller: customerSearchController,
              decoration: InputDecoration(
                labelText: AppLanguage().translate('search_customer'),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      customerSearchController.clear();
                      filterCustomers('');
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  filterCustomers(value);
                });
              },
            ),
            const SizedBox(height: 10),
            // Dropdown for customers
            DropdownButtonFormField<CustomerDropDown>(
              decoration: InputDecoration(labelText: AppLanguage().translate('customer')),
              value: selectedCustomer,
              onChanged: (CustomerDropDown? value) {
                setState(() {
                  selectedCustomer = value;
                });
              },
              items: [
                DropdownMenuItem<CustomerDropDown>(
                  value: null,
                  child: Text(AppLanguage().translate('select_customer')),
                ),
                ...filteredCustomers.map((customer) {
                  return DropdownMenuItem<CustomerDropDown>(
                    value: customer,
                    child: Text(customer.name),
                  );
                }),
              ],
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToDynamicFormCustomer(),
              label: Text(AppLanguage().translate('store_customer')),
            ),
            CustomTextField(
              controller: discountController,
              labelText: AppLanguage().translate('discount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: Text(AppLanguage().translate('mark_as_paid')),
              value: isPaidChecked,
              onChanged: togglePaid,
            ),
            if (!isPaidChecked)
              CustomTextField(
                controller: paidController,
                labelText: AppLanguage().translate('paid_amount'),
                keyboardType: TextInputType.number,
              ),
            ElevatedButton(
              onPressed: showProductModal,
              child: Text(AppLanguage().translate('add_product')),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = selectedProducts[index];
                  return ListTile(
                    title: Text(product['name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            final ProductDropDown matchingProduct = products.firstWhere(
                                  (productItem) => productItem.id == product['id'],
                              orElse: () => throw Exception('Product not found'),
                            );
                            setState(() {
                              if (product['quantity'] > 1) {
                                product['quantity'] -= 1;
                              } else {
                                selectedProducts.removeAt(index);
                              }
                              totalPriceProducts -= matchingProduct.price;
                            });
                          },
                        ),
                        Text(product['quantity'].toString()),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final ProductDropDown matchingProduct = products.firstWhere(
                                  (productItem) => productItem.id == product['id'],
                              orElse: () => throw Exception('Product not found'),
                            );
                            setState(() {
                              product['quantity'] += 1;
                              totalPriceProducts += matchingProduct.price;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Text("${AppLanguage().translate('total_amount')}: $totalPriceProducts"),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitOrder,
                child: Text(AppLanguage().translate('submit')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}