// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:shop_manager/helpers/api_helper.dart';
import 'package:shop_manager/helpers/api_response.dart';
import 'package:shop_manager/helpers/app_language.dart';
import 'package:shop_manager/screens/customer_screen.dart';
import 'package:shop_manager/screens/order_screen.dart';
import 'package:shop_manager/screens/products_screen.dart';
import 'package:shop_manager/widgets/custom_snack_bar.dart';
import '../helpers/shared_prefs_helper.dart'; // Import the helper
import '../models/shop.dart';
import 'auth_wrapper.dart'; // Import the AuthWrapper

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Shop shopInfo = Shop(
    name: 'Loading...',
    language: 'en',
    phone: '000-000-0000',
    validUntil: DateTime.now(),
  );

  fetchShopInfo() async{
    try{
      final ApiResponse response = await ApiHelper.get('shop');
      // Request with errors
      if(! response.status) {
        customSnackBar(
            context, response.errors[0],
            fetchShopInfo,
        );
        setState(() {
          shopInfo.name = AppLanguage().translate('error_shop_info');
        });
        return;
      }
      // Request with no errors
      setState(() {
        shopInfo = Shop.fromJson(response.output);
      });
    }catch(e){
      customSnackBar(
          context, "${AppLanguage().translate('network_error')}: $e",
          fetchShopInfo,
      );
    }

  }

  @override
  void initState() {
    super.initState();
    fetchShopInfo(); // Fetch shop information when the Home screen is initialized
  }


  Future <void> _logout(BuildContext context) async{
    try{
      ApiResponse response = await ApiHelper.post('logout');
      await SharedPrefsHelper.removeUserToken();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
      if(! response.status){
        if(response.errors.isNotEmpty){
          customSnackBar(context, response.errors[0], null);
          return;
        }
        customSnackBar(context, AppLanguage().translate('server_error'), null);
        return;
      }

    } catch(e){
      customSnackBar(context, "${AppLanguage().translate('network_error')}: $e", null);
    }
  }

  // Grid helper
  Widget gridElement(String label, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // List of grid elements
    final List<Widget> homeGrid = [
      gridElement(AppLanguage().translate('products'), Icons.shopping_bag, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductsScreen()));
      }),
      gridElement(AppLanguage().translate('orders'), Icons.shopping_cart, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => OrderScreen()));

      }),
      gridElement(AppLanguage().translate('customers'), Icons.person, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CustomerScreen()));

      }),
      gridElement(AppLanguage().translate('payments'), Icons.credit_score, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));
      }),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(shopInfo.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: homeGrid,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: Text(AppLanguage().translate('logout')),
            ),
          ],
        ),
      ),
    );
  }
}
