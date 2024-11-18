import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_chat/helper/my_dateutil.dart';

import '../model/user_model.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<ViewProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 3,
          title: Text(
            widget.user.name,
            style: TextStyle(fontSize: 20.sp),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Joined on : ",
              style: TextStyle(fontSize: 16.sp),
            ),
            Text(
              MyDateutil.getLastMessageTime(
                  context: context,
                  time: widget.user.createdAt,
                  showYear: true),
              style: TextStyle(fontSize: 16.sp, color: Colors.black45),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: ScreenUtil.defaultSize.width,
                height: 20.h,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  height: 130.h,
                  width: 150.w,
                  fit: BoxFit.fill,
                  imageUrl: widget.user.image,
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: 25.r,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.person, size: 28.sp, color: Colors.grey),
                  ),
                ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "About: ",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  Text(
                    widget.user.about,
                    style: TextStyle(fontSize: 16.sp, color: Colors.black45),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
