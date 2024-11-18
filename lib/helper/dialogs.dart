import 'package:flutter/material.dart';
import 'package:lets_chat/utils/const.dart';

class Dialogs {
  static void showsnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(fontSize: 15),
        ),
        backgroundColor: maincolor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showprogressbar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
