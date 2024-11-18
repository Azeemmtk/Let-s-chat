import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lets_chat/helper/my_dateutil.dart';
import 'package:lets_chat/model/message_model.dart';
import 'package:lets_chat/screens/view_profile_screen.dart';
import 'package:lets_chat/utils/const.dart';
import 'package:lets_chat/view_model/message_viewmodel.dart';
import 'package:lets_chat/widgets/message_card.dart';
import 'package:provider/provider.dart';

import '../api/apis.dart';
import '../model/user_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});

  final UserModel user;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    Apis.getSelfinfo();
  }

  String? _image;

  Future<void> _uploadImage() async {
    if (_image == null) return; // Return if no image is selected

    try {
      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/dtxzelelh/image/upload');
      final request = http.MultipartRequest('POST', url);

      // Cloudinary API required fields
      request.fields['upload_preset'] = 'skhnmr4d';
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
        await Apis.sendChatImage(widget.user, imageUrl);
      } else {
        log('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Image upload error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MessageViewmodel>(context);
    TextEditingController _chatcontoller = TextEditingController();
    List<MessageModel> _list = [];
    bool _showemoji = false;

    return Scaffold(
      backgroundColor: Color(0xFFEBFEFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ViewProfileScreen(user: widget.user)));
            },
            child: StreamBuilder(
              stream: Apis.getUserInfo(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => UserModel.fromJson(e.data())).toList() ??
                        [];
                return Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CachedNetworkImage(
                        height: 40.h,
                        width: 40.w,
                        imageUrl:
                            list.isNotEmpty ? list[0].image : widget.user.image,
                        errorWidget: (context, url, error) => CircleAvatar(
                          radius: 25.r,
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(Icons.person,
                              size: 28.sp, color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.isNotEmpty ? list[0].name : widget.user.name,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                                  ? 'Online'
                                  : MyDateutil.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive)
                              : MyDateutil.getLastActiveTime(
                                  context: context,
                                  lastActive: widget.user.lastActive),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                  child: StreamBuilder(
                stream: Apis.getAllMessages(widget.user),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const SizedBox();

                    //if some or all data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list = data
                              ?.map((e) => MessageModel.fromJson(e.data()))
                              .toList() ??
                          [];
                      for (var i in _list) {
                        print(
                            '===========--------------===================${i.msg}');
                      }
                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            reverse: true,
                            itemCount: _list.length,
                            padding: EdgeInsets.only(top: 10.h),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return MessageCard(message: _list[index]);
                            });
                      } else {
                        return const Center(
                          child: Text('Say Hii! 👋',
                              style: TextStyle(fontSize: 20)),
                        );
                      }
                  }
                },
              )),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() => _showemoji = !_showemoji);
                            },
                            icon: Icon(
                              Icons.emoji_emotions,
                              color: backgroundcolor,
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _chatcontoller,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: 'Type here....',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (image != null) {
                                log('image: ${image.path} image mimetype: ${image.mimeType}');
                                setState(() {
                                  _image = image.path;
                                });
                                await _uploadImage(); // Upload image after selection
                              }
                            },
                            icon: Icon(
                              Icons.image,
                              color: backgroundcolor,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                  source: ImageSource.camera);
                              if (image != null) {
                                log('image: ${image.path} image mimetype: ${image.mimeType}');
                                setState(() {
                                  _image = image.path;
                                });
                                await _uploadImage(); // Upload image after capture
                              }
                            },
                            icon: Icon(
                              Icons.camera,
                              color: backgroundcolor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      if (_chatcontoller.text.isNotEmpty) {
                        if (_list.isEmpty) {
                          Apis.sendFirstMessage(
                              widget.user, _chatcontoller.text, Type.text);
                          _chatcontoller.clear();
                        } else {
                          Apis.sendMessage(
                              widget.user, _chatcontoller.text, Type.text);
                          _chatcontoller.clear();
                        }
                      }
                    },
                    color: backgroundcolor,
                    shape: CircleBorder(),
                    minWidth: 0,
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              )
            ],
          ),
        ),
      ),
    );
  }
}
