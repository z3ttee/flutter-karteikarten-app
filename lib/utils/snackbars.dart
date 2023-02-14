
import 'package:flutter/material.dart';

class Snackbars {

  static message(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

}