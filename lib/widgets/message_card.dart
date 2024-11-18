import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:lets_chat/api/apis.dart';
import 'package:lets_chat/helper/dialogs.dart';
import 'package:lets_chat/helper/my_dateutil.dart';
import 'package:lets_chat/model/message_model.dart';
import 'package:lets_chat/utils/const.dart';
import 'package:provider/provider.dart';

import '../view_model/message_viewmodel.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final MessageModel message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = Apis.user.uid == widget.message.fromid;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenmessage() : _bluemessage(),
    );
  }

  Widget _bluemessage() {
    if (widget.message.read.isEmpty) {
      Apis.updateMessageReadStataus(widget.message);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(
                    widget.message.type == Type.image ? 5.sp : 10.sp),
                decoration: BoxDecoration(
                    color: secondaycolor,
                    border: Border.all(color: maincolor),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.r),
                        topLeft: Radius.circular(20.r),
                        bottomRight: Radius.circular(20.r))),
                child: widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style: TextStyle(color: Colors.blue),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15.r),
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                          errorWidget: (context, url, error) => Icon(
                              Icons.image,
                              size: 50.sp,
                              color: Colors.grey),
                        ),
                      ),
              ),
            ),
            Text(
              MyDateutil.getFormatedtime(
                  context: context, time: widget.message.send),
              style: TextStyle(fontSize: 12, color: Colors.black45),
            )
          ],
        ),
        SizedBox(
          height: 4.h,
        )
      ],
    );
  }

  Widget _greenmessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (widget.message.read.isNotEmpty)
                  Icon(
                    Icons.done_all,
                    size: 15,
                    color: Colors.blue,
                  ),
                Text(
                  MyDateutil.getFormatedtime(
                      context: context, time: widget.message.send),
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
            Flexible(
              child: Container(
                padding: EdgeInsets.all(
                    widget.message.type == Type.image ? 5.sp : 10.sp),
                decoration: BoxDecoration(
                    color: Colors.greenAccent.shade100,
                    border: Border.all(color: maincolor),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.r),
                        topLeft: Radius.circular(20.r),
                        bottomLeft: Radius.circular(20.r))),
                child: widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style: TextStyle(color: Colors.blue),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15.r),
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                          errorWidget: (context, url, error) => Icon(
                              Icons.image,
                              size: 50.sp,
                              color: Colors.grey),
                        ),
                      ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 4.h,
        )
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 15.h, horizontal: 150.w),
              decoration: BoxDecoration(
                  color: CupertinoColors.inactiveGray,
                  borderRadius: BorderRadius.circular(10)),
            ),
            widget.message.type == Type.text
                ? Optionitm(
                    icon: Icon(
                      Icons.copy_all,
                      color: maincolor,
                    ),
                    name: 'Copy text',
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then(
                        (value) {
                          Navigator.pop(context);
                          Dialogs.showsnackbar(context, 'Text copied');
                        },
                      );
                    },
                  )
                : Optionitm(
                    icon: Icon(
                      Icons.download_rounded,
                      color: maincolor,
                    ),
                    name: 'Save image',
                    onTap: () async {
                      await _saveImageToGallery(widget.message.msg).then(
                        (value) {
                          Navigator.pop(context);
                          Dialogs.showsnackbar(context, 'Image saved');
                        },
                      );
                    },
                  ),
            if (isMe)
              Divider(
                color: Colors.black54,
                endIndent: 10.w,
                indent: 10.h,
              ),
            if (widget.message.type == Type.text && isMe)
              Optionitm(
                icon: Icon(
                  Icons.edit,
                  color: maincolor,
                ),
                name: 'Edit message',
                onTap: () async {
                  Navigator.pop(context);

                  setState(() {
                    _shoeMessageUpdateDialogue();
                  });
                },
              ),
            if (isMe)
              Optionitm(
                icon: Icon(
                  Icons.delete_forever,
                  color: Colors.redAccent,
                ),
                name: 'Delete message',
                onTap: () async {
                  await Apis.delateMaessage(widget.message).then(
                    (value) {
                      Provider.of<MessageViewmodel>(context, listen: false)
                          .removeMessage(widget.message);
                      Navigator.pop(context);
                      setState(() {});
                    },
                  );
                },
              ),
            Divider(
              color: Colors.black54,
              endIndent: 10.w,
              indent: 10.h,
            ),
            Optionitm(
              icon: Icon(
                Icons.remove_red_eye,
                color: Colors.blue,
              ),
              name:
                  'Sent at: ${MyDateutil.getFormatedtime(context: context, time: widget.message.send)}',
              onTap: () {},
            ),
            Optionitm(
              icon: Icon(
                Icons.remove_red_eye,
                color: Colors.redAccent,
              ),
              name: widget.message.read.isEmpty
                  ? "Read at: Not seen yet"
                  : 'Read at: ${MyDateutil.getFormatedtime(context: context, time: widget.message.read)}',
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  void _shoeMessageUpdateDialogue() {
    String updatedMessage = widget.message.msg;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.message,
              color: Colors.blue,
              size: 20.h,
            ),
            Text('Update message')
          ],
        ),
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => updatedMessage = value,
          initialValue: updatedMessage,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.blue, fontSize: 18),
            ),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              Apis.updateMaessage(widget.message, updatedMessage);
              Provider.of<MessageViewmodel>(context, listen: false)
                  .updateMessage(widget.message, updatedMessage);
            },
            child: Text(
              'Update',
              style: TextStyle(color: Colors.blue, fontSize: 18),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _saveImageToGallery(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final result =
            await ImageGallerySaver.saveImage(Uint8List.fromList(bytes));
        if (result != null && result['isSuccess'] == true) {
          Dialogs.showsnackbar(context, 'Image saved to gallery');
        } else {
          Dialogs.showsnackbar(context, 'Failed to save image');
        }
      } else {
        Dialogs.showsnackbar(context, 'Failed to load image');
      }
    } catch (e) {
      Dialogs.showsnackbar(context, 'Error: $e');
    }
  }
}

class Optionitm extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const Optionitm(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(left: 20.w, top: 7.h, bottom: 7.h),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '   $name',
              style: TextStyle(fontSize: 18, color: Colors.black45),
            ))
          ],
        ),
      ),
    );
  }
}
