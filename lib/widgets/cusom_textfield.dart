import 'package:flutter/material.dart';

class Customtextfield extends StatelessWidget {
  Customtextfield(
      {super.key,
      required this.hint,
      required this.visibility,
      this.suffix,
      this.prefix,
      this.controlls});

  bool visibility;
  String hint;
  Widget? suffix;
  Widget? prefix;
  TextEditingController? controlls;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlls,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return ("Please enter ${hint}");
        } else {
          return null;
        }
      },
      obscureText: visibility,
      decoration: InputDecoration(
          hintText: hint,
          labelStyle: TextStyle(color: Colors.black),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(
              Radius.circular(40),
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(
              Radius.circular(40),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(
              Radius.circular(40),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: suffix,
          prefixIcon: prefix),
    );
  }
}
