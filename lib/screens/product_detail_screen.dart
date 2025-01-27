import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_manager/helpers/app_language.dart';
import 'package:shop_manager/models/product.dart'; // Your product model

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  // Constructor to accept the product details
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formattedProductDate = DateFormat('yyyy-MM-dd').format(product.createdAt);
    final totalStock = product.inventoryLogs.fold<int>(
      0,
          (sum, log) => sum + log.quantityChange,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLanguage().translate('details')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${AppLanguage().translate('name')}: ${product.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${AppLanguage().translate('price')}: ${product.price}'),
            Text('${AppLanguage().translate('purchase_price')}: ${product.purchasePrice}'),
            Text('${AppLanguage().translate('created_at')}: $formattedProductDate'),
            Text('${AppLanguage().translate('inventory')}: $totalStock'),

            const SizedBox(height: 16),

            // Product Logs Section
            if (product.logs.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('${AppLanguage().translate('product_logs')}:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: product.logs.length,
                  itemBuilder: (context, index) {
                    final log = product.logs[index];
                    final formattedProductLogDate = DateFormat('yyyy-MM-dd').format(log.createdAt);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(AppLanguage().translate(log.changedField)),
                        subtitle: Text(
                          '${AppLanguage().translate('changed_from')}: ${log.oldValue} \n${AppLanguage().translate('to')}: ${log.newValue}',
                        ),
                        trailing: Text(formattedProductLogDate),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Inventory Logs Section
            if (product.inventoryLogs.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('${AppLanguage().translate('inventory_logs')}:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: product.inventoryLogs.length,
                  itemBuilder: (context, index) {
                    final inventoryLog = product.inventoryLogs[index];
                    final formattedInventoryLogDate = DateFormat('yyyy-MM-dd').format(inventoryLog.createdAt);

                    // Determine if the quantity is positive or negative
                    final isPositiveChange = inventoryLog.quantityChange >= 0;
                    final changeText = '${isPositiveChange ? '+' : ''}${inventoryLog.quantityChange}';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: isPositiveChange ? Colors.green : Colors.red,
                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Center(
                                child: Text(
                                  changeText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formattedInventoryLogDate),
                            Icon(
                              isPositiveChange ? Icons.add_circle : Icons.remove_circle,
                              color: isPositiveChange ? Colors.green : Colors.red,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
