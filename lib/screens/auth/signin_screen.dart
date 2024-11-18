import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_chat/view_model/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../utils/const.dart';
import '../../widgets/cusom_textfield.dart';
import '../home_screen.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaycolor,
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 80.h),
                Center(
                  child: Text(
                    'Hello Again!',
                    style:
                        TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Text(
                    'Welcome Back You’ve Been Missed!',
                    style: TextStyle(color: Color(0xFF707B81), fontSize: 16.sp),
                  ),
                ),
                SizedBox(height: 50.h),
                Text(
                  'Email Address',
                  style:
                      TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.h),
                Customtextfield(
                  hint: 'Enter email',
                  visibility: false,
                  controlls: _emailcontroller,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Password',
                  style:
                      TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.h),
                Customtextfield(
                  hint: 'Enter password',
                  visibility: true,
                  controlls: _passwordcontroller,
                  suffix: IconButton(
                    onPressed: () {},
                    icon: Icon(CupertinoIcons.eye_slash, size: 20.sp),
                  ),
                ),
                SizedBox(height: 50.h),
                Center(
                  child: SizedBox(
                    height: 40.h,
                    width: 400.w,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: backgroundcolor),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Consumer<AuthViewmodel>(
                  builder: (context, value, child) => value.loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        )
                      : Center(
                          child: InkWell(
                            onTap: () {
                              value.logintwithGoogle(context: context);
                            },
                            child: Container(
                              height: 40.h,
                              width: 400.w,
                              decoration: BoxDecoration(
                                  color: backgroundcolor,
                                  borderRadius: BorderRadius.circular(40.r)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/google logo.png",
                                    width: 40,
                                    height: 40,
                                  ),
                                  SizedBox(
                                    width: 15.w,
                                  ),
                                  Text(
                                    'Sign in with google',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.sp,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t Have An Account?',
                        style: TextStyle(fontSize: 14.sp)),
                    TextButton(
                        onPressed: () {},
                        child: Text(
                          'Sign up for free',
                          style:
                              TextStyle(color: Colors.black, fontSize: 14.sp),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
