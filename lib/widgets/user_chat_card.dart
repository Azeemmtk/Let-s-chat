import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_chat/api/apis.dart';
import 'package:lets_chat/helper/my_dateutil.dart';
import 'package:lets_chat/model/message_model.dart';

import '../model/user_model.dart';
import '../screens/chat_screen.dart';

class UserChatCard extends StatelessWidget {
  final UserModel user;

  const UserChatCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    MessageModel? _message;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
      child: Card(
        elevation: 0.8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      user: user,
                    ),
                  ));
            },
            child: StreamBuilder(
              stream: Apis.getLastMessage(user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list = data
                        ?.map((e) => MessageModel.fromJson(e.data()))
                        .toList() ??
                    [];
                if (list.isNotEmpty) _message = list[0];
                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      height: 53.h,
                      width: 53.w,
                      imageUrl: user.image,
                      errorWidget: (context, url, error) => CircleAvatar(
                        radius: 25.r,
                        backgroundColor: Colors.grey.shade300,
                        child:
                            Icon(Icons.person, size: 28.sp, color: Colors.grey),
                      ),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    _message != null
                        ? _message?.type == Type.image
                            ? 'Image'
                            : _message!.msg
                        : user.about,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                  ),
                  trailing: _message == null
                      ? null
                      : _message!.read.isEmpty &&
                              _message!.fromid != Apis.user.uid
                          ? Container(
                              height: 15.h,
                              width: 15.w,
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGreen,
                                shape: BoxShape.circle,
                              ),
                            )
                          : Text(MyDateutil.getLastMessageTime(
                              context: context, time: _message!.send)),
                );
              },
            )),
      ),
    );
  }
}
