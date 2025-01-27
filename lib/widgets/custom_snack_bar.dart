import 'package:flutter/material.dart';
import 'package:shop_manager/helpers/app_language.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> customSnackBar(
    BuildContext context,
    String message,
    void Function()? function,
){
  SnackBarAction? action;
  if(function != null){
    action = SnackBarAction(label: AppLanguage().translate('retry'), onPressed: () => function());
  }
  return  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      action: action,
    ),
  );
}