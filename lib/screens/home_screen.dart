// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:shop_manager/helpers/api_helper.dart';
import 'package:shop_manager/helpers/api_response.dart';
import 'package:shop_manager/helpers/app_language.dart';
import 'package:shop_manager/widgets/custom_snack_bar.dart';
import '../helpers/shared_prefs_helper.dart'; // Import the helper
import 'auth_wrapper.dart'; // Import the AuthWrapper

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future <void> _logout(BuildContext context) async{
    try{
      ApiResponse response = await ApiHelper.post('logout', token: true);
      if(! response.status){
        customSnackBar(context, response.errors[0], SnackBarAction(label: 'Retry', onPressed: () => _logout(context)));
        return;
      }
      // Clear the token and go back to the Login Page
      await SharedPrefsHelper.removeUserToken();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );

    } catch(e){
      SnackBar(
        content: Text("Error during logout: $e"),
        duration: Duration(seconds: 3),
      );
    }
  }
  Widget gridElement(String label, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap, // Make the square clickable
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
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));
      }),
      gridElement(AppLanguage().translate('orders'), Icons.shopping_cart, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));

      }),
      gridElement(AppLanguage().translate('customers'), Icons.person, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));

      }),
      gridElement(AppLanguage().translate('payments'), Icons.credit_score, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));
      }),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
          children: [
            // GridView with shrinkWrap to take only the space it needs
            GridView.count(
              shrinkWrap: true, // Prevents infinite height
              physics: const NeverScrollableScrollPhysics(), // Disables scrolling
              crossAxisCount: 2, // Number of columns in the grid
              crossAxisSpacing: 10, // Spacing between columns
              mainAxisSpacing: 10, // Spacing between rows
              children: homeGrid,
            ),
            const SizedBox(height: 20), // Spacing between grid and button
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
