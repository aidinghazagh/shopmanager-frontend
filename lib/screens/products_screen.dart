import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_manager/helpers/api_helper.dart';
import 'package:shop_manager/helpers/api_response.dart';
import 'package:shop_manager/helpers/app_language.dart';
import 'package:shop_manager/models/product.dart';
import 'package:shop_manager/screens/product_detail_screen.dart';
import 'package:shop_manager/widgets/custom_snack_bar.dart';

import '../widgets/delete_button.dart';
import '../widgets/dynamic_form.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> products = [];
  bool isLoading = true;
  String errorMessage = '';

  Future<void> fetchProducts() async {
    try {
      ApiResponse response = await ApiHelper.get('product');
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
          fetchProducts,
        );
        return;
      }

      // Parse the products from the response
      List<Product> fetchedProducts = (response.output as List)
          .map((productJson) => Product.fromJson(productJson))
          .toList();

      setState(() {
        products = fetchedProducts;
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
        fetchProducts,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }
  void _navigateToDynamicForm({int? id, Product? product}) async {
    Map<String, String>? initialData;
    if (product != null) {
      initialData = {
        'name': product.name,
        'price': product.price.toString(),
        'purchase_price': product.purchasePrice.toString(),
        'inventory': product.inventoryLogs.fold<int>(
          0,
          (sum, log) => sum + log.quantityChange,
        ).toString(),
      };
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DynamicForm(
          fields: ['name', 'price', 'purchase_price', 'inventory'], // Specify form fields
          endpoint: 'product',
          title: AppLanguage().translate('product'),
          id: id,
          initialData: initialData,
        ),
      ),
    );

    fetchProducts();
  }
  Future<void> _deleteProduct(int productId) async {
    try {
      ApiResponse response = await ApiHelper.delete('product/$productId');
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
      fetchProducts();
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
        title: Text(AppLanguage().translate('products')),
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
          : products.isEmpty
          ? Center(child: Text(AppLanguage().translate('no_products_available')))
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final totalStock = product.inventoryLogs.fold<int>(
            0,
                (sum, log) => sum + log.quantityChange,
          );
          final formattedDate = DateFormat('yyyy-MM-dd').format(product.createdAt);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              borderRadius: BorderRadius.circular(10), // Matches the card's border radius
              onTap: () {
                // Navigate to the product details screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Inventory Count with Icon
                    CircleAvatar(
                      radius: 20, // Fixed size
                      backgroundColor: totalStock > 0 ? Colors.green : Colors.grey,
                      child: FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0), // Adds padding to prevent text from touching edges
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inventory, size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                totalStock.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            '${AppLanguage().translate('price')}: ${product.price.toString()}',
                          ),
                          Text('${AppLanguage().translate('purchase_price')}: ${product.purchasePrice.toString()}'),
                          Text('${AppLanguage().translate('created_at')}: $formattedDate'),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _navigateToDynamicForm(id: product.id, product: product),
                      tooltip: AppLanguage().translate('edit'),
                    ),
                    DeleteButton(
                      onDelete: () => _deleteProduct(product.id),
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