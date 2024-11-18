import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lets_chat/api/apis.dart';
import 'package:lets_chat/helper/dialogs.dart';
import 'package:lets_chat/screens/auth/signin_screen.dart';
import 'package:lets_chat/utils/const.dart';

import '../model/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;

  Future<void> _uploadImage() async {
    if (_image == null) return; // Return if no image is selected

    try {
      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/dtxzelelh/image/upload');
      final request = http.MultipartRequest('POST', url);

      // Cloudinary API required fields
      request.fields['upload_preset'] = 'vz3arkhr';
      request.fields['api_key'] =
          '257469391712497'; // Set your Cloudinary API key here

      // Attach the selected image file
      request.files.add(await http.MultipartFile.fromPath('file', _image!));

      // Send the request
      final response = await request.send();

      // Process response
      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final data = json.decode(responseData.body);

        // Extract the image URL
        final imageUrl = data['secure_url'];
        log('Uploaded Image URL: $imageUrl');
        await Apis.updateimage(imageUrl);

        // setState(() {
        //   widget.user.image =
        //       imageUrl; // Update the user's image with the new URL
        // });
      } else {
        log('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Image upload error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 3,
          title: Text(
            'Profile',
            style: TextStyle(fontSize: 20.sp),
          ),
        ),
        body: Form(
          key: _formkey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: ScreenUtil.defaultSize.width,
                  height: 20.h,
                ),
                Stack(
                  children: [
                    _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(100.r),
                            child: Image.file(
                              File(_image!),
                              height: 130.h,
                              width: 150.w,
                              fit: BoxFit.fill,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              height: 130.h,
                              width: 150.w,
                              fit: BoxFit.fill,
                              imageUrl: widget.user.image,
                              errorWidget: (context, url, error) =>
                                  CircleAvatar(
                                radius: 25.r,
                                backgroundColor: Colors.grey.shade300,
                                child: Icon(Icons.person,
                                    size: 28.sp, color: Colors.grey),
                              ),
                            ),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: MaterialButton(
                        onPressed: () {
                          _showBottomSheet();
                        },
                        shape: CircleBorder(),
                        color: Colors.white,
                        child: Icon(
                          Icons.edit,
                          color: backgroundcolor,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: ScreenUtil.defaultSize.width,
                  height: 30.h,
                ),
                Text(
                  widget.user.email,
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(
                  height: 10.h,
                ),
                TextFormField(
                  initialValue: widget.user.name,
                  onSaved: (newValue) => Apis.me.name = newValue ?? '',
                  validator: (value) => value != null && value.isNotEmpty
                      ? null
                      : 'Required field',
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person,
                      color: maincolor,
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: maincolor), // Blue border color
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: maincolor), // Blue border when enabled
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: maincolor,
                          width: 2), // Thicker blue border when focused
                    ),
                    label: Text('Name'),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                TextFormField(
                  onSaved: (newValue) => Apis.me.about = newValue ?? '',
                  validator: (value) => value != null && value.isNotEmpty
                      ? null
                      : 'Required field',
                  initialValue: widget.user.about,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.info,
                      color: maincolor,
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: maincolor), // Blue border color
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: maincolor), // Blue border when enabled
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: maincolor,
                          width: 2), // Thicker blue border when focused
                    ),
                    label: Text('About'),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(maincolor),
                      ),
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          _formkey.currentState!.save();
                          Apis.updateUserInfo().then(
                            (value) {
                              Dialogs.showsnackbar(
                                  context, 'Profile updated successfully');
                            },
                          );
                        }
                      },
                      label: Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: 30.w,
                    ),
                    ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.red.shade400),
                      ),
                      onPressed: () async {
                        Dialogs.showprogressbar(context);
                        await Apis.updateActiveStatus(false);
                        await Apis.auth.signOut().then(
                          (value) async {
                            await GoogleSignIn().signOut().then(
                              (value) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Apis.auth = FirebaseAuth.instance;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Signin(),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      label: Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            Text('Pick Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 70.h,
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      log('image: ${image.path} image mimetype: ${image.mimeType}');
                      setState(() {
                        _image = image.path;
                      });
                      Navigator.pop(context);
                      await _uploadImage(); // Upload image after selection
                    }
                  },
                  icon: Icon(Icons.image),
                ),
                SizedBox(width: 20.w),
                IconButton(
                  iconSize: 70.h,
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      log('image: ${image.path} image mimetype: ${image.mimeType}');
                      setState(() {
                        _image = image.path;
                      });
                      Navigator.pop(context);
                      await _uploadImage(); // Upload image after selection
                    }
                  },
                  icon: Icon(Icons.camera),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
