import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/const.dart';
import '../../widgets/cusom_textfield.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController _namecontroller = TextEditingController();
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
                SizedBox(height: 140.h),
                Center(
                  child: Text(
                    'Create Account',
                    style:
                        TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Text(
                    'Let’s Create Account Together',
                    style: TextStyle(color: Color(0xFF707B81), fontSize: 16.sp),
                  ),
                ),
                SizedBox(height: 50.h),
                Text(
                  'Your Name',
                  style:
                      TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
                ),
                Customtextfield(
                  hint: 'Enter name',
                  visibility: false,
                  controlls: _namecontroller,
                ),
                SizedBox(height: 10.h),
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
                      icon: Icon(CupertinoIcons.eye_slash, size: 20.sp)),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: SizedBox(
                    height: 50.h,
                    width: 400.w,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B9EE1)),
                      onPressed: () {},
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 70.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
