import 'package:flutter/material.dart';

class Helpers {
  // SnackBar success
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text(message)),
    );
  }

  // SnackBar error
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(message)),
    );
  }

  // Loading dialog
  static void showLoading(BuildContext context, {String? message}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message ?? "Memuat..."),
          ],
        ),
      ),
    );
  }

  // Close dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Random ID helper
  static String randomId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
