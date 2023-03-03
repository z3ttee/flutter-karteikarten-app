
import 'package:flutter/material.dart';

class Snackbars {

  /// Print a snackbar showing a message
  static message(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  /// Print a snackbar indicating an error
  static error(String message, BuildContext context) {
    Snackbars.message(message, context);
  }

}