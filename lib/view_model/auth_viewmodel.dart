import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lets_chat/api/apis.dart';
import 'package:lets_chat/helper/dialogs.dart';
import 'package:lets_chat/screens/home_screen.dart';

import '../services/firebase_services.dart';

class AuthViewmodel extends ChangeNotifier {
  bool loading = false;

  Future<void> logintwithGoogle({required BuildContext context}) async {
    try {
      loading = true;
      notifyListeners();

      await signInWithGoogle().then(
        (user) async {
          if (user != null) {
            if ((await Apis.userExists())) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            } else {
              await Apis.createUser().then(
                (value) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                  );
                },
              );
            }
          }
        },
      );

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      notifyListeners();
      Dialogs.showsnackbar(context, 'Something went wrong! check internet');
      log('Error during Google login: $e');
    }
  }
}
