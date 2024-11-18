import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_chat/screens/splash_screen.dart';
import 'package:lets_chat/utils/const.dart';
import 'package:lets_chat/view_model/auth_viewmodel.dart';
import 'package:lets_chat/view_model/message_viewmodel.dart';
import 'package:lets_chat/view_model/user_viewmodel.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then(
    (value) async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      runApp(const Myapp());
    },
  );
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthViewmodel(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => MessageViewmodel(),
        )
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690), // Choose the base screen size
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              appBarTheme: const AppBarTheme(
                elevation: 1,
                centerTitle: true,
                titleTextStyle: TextStyle(fontSize: 25, color: Colors.black),
                backgroundColor: Color(0xFFd5e6f9),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: secondaycolor,
              ),
            ),
            home: child,
          );
        },
        child: const SplashScreen(),
      ),
    );
  }
}
