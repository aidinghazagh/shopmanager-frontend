import 'package:flutter/foundation.dart';
import 'package:shop_manager/helpers/shared_prefs_helper.dart';

class AppLanguage with ChangeNotifier {
  // Singleton instance
  static final AppLanguage _instance = AppLanguage._internal();

  // Factory constructor to return the singleton instance
  factory AppLanguage() {
    return _instance;
  }

  // Private constructor
  AppLanguage._internal();

  // Static translations map
  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'language': 'Language',
      'welcome': 'Welcome',
      'login': 'Login',
      'phone': 'Phone',
      'password': 'Password',
      'home': 'Home',
      'logout': 'Logout',
      'product': 'Product',
      'products': 'Products',
      'order': 'Order',
      'orders': 'Orders',
      'customer': 'Customer',
      'customers': 'Customers',
      'payment': 'Payment',
      'payments': 'Payments',
      'store_payment': 'Store Payment',
      'enter_phone': 'Please enter your phone',
      'name': 'Name',
      'enter_password': 'Please enter your password',
      'error_shop_info': 'Error trying to fetch shop info',
      'no_products_available': 'No products available',
      'server_error': 'Server Error',
      'network_error': 'Network Error',
      'retry': 'Retry',
      'price': 'Price',
      'purchase_price': 'Purchase Price',
      'created_at': 'Created at',
      'updated_at': 'Updated at',
      'details': 'Details',
      'product_logs': 'Product Logs',
      'inventory_logs': 'Inventory Logs',
      'product_name': 'Product name',
      'changed_from': 'Changed from',
      'to': 'To',
      'quantity_change': 'Quantity change',
      'submit': 'Submit',
      'store': 'Store',
      'request_success': 'Request was successfully sent',
      'edit': 'Edit',
      'inventory': 'Inventory',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'confirm_deletion': 'Confirm Deletion',
      'delete_message': 'Are you sure you want to delete this item?',
      'no_customers_available': 'No customers available',
      'no_orders_available': 'No orders available',
      'price_on_created': 'Price on created',
      'purchase_price_on_created': 'Purchase price on created',
      'select_customer': 'Please select a customer',
      'store_customer': 'Store a new customer',
      'total_amount': 'Total amount',
      'add_product': 'Add product',
      'store_product': 'Store a new product',
      'search_product': 'Search product',
      'paid_amount': 'Paid amount',
      'mark_as_paid': 'Mark as paid',
      'discount': 'Discount',
      'search_customer': 'Search customer',
      'new_order': 'New order',
      'order_list_for': 'Order list for',
      'amount': 'Amount',
    },
    'fa': {
      'language': 'زبان',
      'welcome': 'خوش آمدید',
      'login': 'ورود',
      'phone': 'شماره تلفن',
      'password': 'رمز عبور',
      'home': 'خانه',
      'logout': 'خروج',
      'product': 'محصول',
      'products': 'محصولات',
      'order': 'سفارش',
      'orders': 'سفارشات',
      'customer': 'مشتری',
      'customers': 'مشتری ها',
      'payment': 'پرداختی',
      'payments': 'پرداختی ها',
      'store_payment': 'دخیره پرداختی',
      'enter_phone': 'لطفا شماره تلفن خود را وارد کنید',
      'enter_password': 'لطفا رمز عبور خود را وارد کنید',
      'error_shop_info': 'مشکل در دریافت اطلاعات فروشگاه',
      'no_products_available': 'هیچ محصولی برای نمایش موجود نیست',
      'server_error': 'خطلای سرور',
      'network_error': 'خطای شبکه ای',
      'retry': 'امتحان مجدد',
      'name': 'نام',
      'price': 'قیمت',
      'purchase_price': 'قیمت خرید',
      'created_at': 'ثبت شده در',
      'updated_at': 'آخرین تغییر در',
      'details': 'جزییات',
      'product_logs': 'تغییرات محصول',
      'inventory_logs': 'تغییرات موجودی',
      'changed_from': 'تغییر کرد از',
      'to': 'به',
      'quantity_change': 'تغییر تعداد',
      'submit': 'ارسال',
      'store': 'دخیره',
      'request_success': 'درخواست با موفقیت انجام شد',
      'edit': 'ویرایش',
      'inventory': 'موجودی',
      'delete': 'حذف',
      'cancel': 'انصراف',
      'confirm_deletion': 'تایید حذف',
      'delete_message': 'آیا مطمعن هستید این آیتم را میخواهید حذف کنید ؟',
      'no_customers_available': 'هیچ کاربر ای برای نمایش موجود نیست',
      'no_orders_available': 'هیچ سفارشی برای نمایش موجود نیست',
      'price_on_created': 'قیمت در زمان ساخت',
      'purchase_price_on_created': 'قیمت خرید در زمان فروش',
      'select_customer': 'لطفا یک مشتری انتخاب کنید',
      'store_customer': 'ساخت مشتری جدید',
      'total_amount': 'قیمت کل',
      'add_product': 'اضافه کردن محصول',
      'store_product': 'ذخیره یک محصول جدید',
      'search_product': 'جستجوی محصول',
      'paid_amount': 'مقدار پرداخت شده',
      'mark_as_paid': 'پرداخت شده',
      'discount': 'تخفیف',
      'search_customer': 'جستجوی مشتری',
      'new_order': 'سفارش جدید',
      'order_list_for': 'لیست سفارش های',
      'amount': 'مقدار',
    },
  };

  // Current language code
  String _languageCode = 'en'; // Default language

  // Getter for the current language code
  String get languageCode => _languageCode;

  // Initialize the language from SharedPreferences
  Future<void> initialize() async {
    final savedLanguage = await SharedPrefsHelper.getUserLanguage();
    if (_translations.containsKey(savedLanguage)) {
      _languageCode = savedLanguage;
    } else {
      if(kDebugMode){
        print('Saved language ($savedLanguage) is invalid. Falling back to "en".');
      }
      _languageCode = 'en';
    }
  }

  // Setter for updating the language code
  void setLanguage(String newLanguageCode) {
    if (_translations.containsKey(newLanguageCode)) {
      _languageCode = newLanguageCode;
      SharedPrefsHelper.saveUserLanguage(newLanguageCode);
      notifyListeners();
    } else {
      throw ArgumentError('Invalid language code: $newLanguageCode');
    }
  }

  // Translate method
  String translate(String key) {
    final translation = _translations[_languageCode]?[key];
    if (translation == null) {
      if(kDebugMode){
        print("Translation not found for key: $key");
      }
      return key;  // Or return a fallback text like `key not available in this language`
    }
    return translation;
  }

  bool isRtl(){
    return _languageCode == 'fa';
  }
}