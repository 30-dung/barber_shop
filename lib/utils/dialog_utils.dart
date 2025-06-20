// lib/utils/dialog_utils.dart
import 'package:flutter/material.dart';

class DialogUtils {
  static Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String content, {
    String confirmButtonText = 'OK',
    String cancelButtonText = 'Cancel',
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled
              },
              child: Text(cancelButtonText),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
              child: Text(confirmButtonText),
            ),
          ],
        );
      },
    );
  }

  // NEW: Phương thức hiển thị AlertDialog đơn giản
  static Future<void> showAlertDialog(
    BuildContext context,
    String title,
    String content, {
    String buttonText = 'OK',
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }
}
