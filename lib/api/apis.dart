import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'package:lets_chat/model/message_model.dart';
import 'package:lets_chat/model/user_model.dart';

class Apis {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static User get user => auth.currentUser!;
  // check user exist or not
  static late UserModel me;
  // static UserModel me = UserModel(
  //     id: user.uid,
  //     name: user.displayName.toString(),
  //     email: user.email.toString(),
  //     about: "Hey, I'm using Lets Chat!",
  //     image: user.photoURL.toString(),
  //     createdAt: '',
  //     isOnline: false,
  //     lastActive: '',
  //     pushToken: '');

  static Future<void> getSelfinfo() async {
    await firestore.collection('users').doc(user.uid).get().then(
      (user) async {
        if (user.exists) {
          me = UserModel.fromJson(user.data()!);
          await getFirebaseMessagingTocken();
          Apis.updateActiveStatus(true);
        } else {
          await createUser().then(
            (value) => getSelfinfo(),
          );
        }
      },
    );
  }

  static Future<bool> userExists() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  //create user
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatuser = UserModel(
        image: user.photoURL.toString(),
        about: 'Hello',
        name: user.displayName.toString(),
        createdAt: time,
        isOnline: false,
        id: user.uid,
        lastActive: time,
        email: user.email.toString(),
        pushToken: '');
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatuser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      UserModel user) {
    return firestore
        .collection('chat/${getConversationId(user.id)}/messages/')
        .orderBy('send', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('userIds   $userIds');
    return firestore
        .collection('users')
        .where('id', whereIn: userIds)
        //.where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> sendFirstMessage(
      UserModel chatuser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatuser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then(
      (value) => sendMessage(chatuser, msg, type),
    );
  }

  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Future<void> updateimage(String image) async {
    await firestore.collection('users').doc(user.uid).update({'image': image});
  }

  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Future<void> sendMessage(
      UserModel chatuser, String msg, Type type) async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final MessageModel message = MessageModel(
        msg: msg,
        toid: chatuser.id,
        read: '',
        type: type,
        fromid: user.uid,
        send: time);

    final ref = firestore
        .collection('chat/${getConversationId(chatuser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  //${getConversationId(message.fromid)}
//bxquRYzl81Ubi3Yz4Wgjz4TNfnK2 _7a1h9fSp9ze1qG5SxeRtuNqcRU73
  static Future<void> updateMessageReadStataus(MessageModel message) async {
    print(
        'id====================================${getConversationId(message.fromid)}');
    await firestore
        .collection('chat/${getConversationId(message.fromid)}/messages/')
        .doc(message.send)
        .update({'read': DateTime.now().microsecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      UserModel user) {
    return firestore
        .collection('chat/${getConversationId(user.id)}/messages/')
        .orderBy('send', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(UserModel chatuser, String image) async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    // Assuming the image URL is passed as a string, you can use it directly as the message
    final MessageModel message = MessageModel(
      msg: image, // Store the image URL in the msg field
      toid: chatuser.id,
      read: '',
      type: Type
          .image, // You can set the type to 'image' to signify this message is an image
      fromid: user.uid,
      send: time,
    );

    final ref = firestore
        .collection('chat/${getConversationId(chatuser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      UserModel chatuser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatuser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().microsecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  static Future<void> getFirebaseMessagingTocken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then(
      (t) {
        if (t != null) {
          me.pushToken = t;
          log('push token----------------------------$t');
        }
      },
    );
  }

  static Future<void> sendPushNotification(
      UserModel chatuser, String msg) async {
    final body = {
      "to": chatuser.pushToken,
      "notification": {
        "title": chatuser.name, //our name should be send
        "body": msg,
      }
    };

    var response = await post(Uri.parse('https://fcm.googleapis.com/send'),
        body: jsonEncode(body));
    log('Response status: ${response.statusCode}');
    log('Response body: ${response.body}');
  }

  static Future<void> delateMaessage(MessageModel message) async {
    await firestore
        .collection('chat/${getConversationId(message.toid)}/messages/')
        .doc(message.send)
        .delete();
  }

  static Future<void> updateMaessage(
      MessageModel message, String updatedmsg) async {
    await firestore
        .collection('chat/${getConversationId(message.toid)}/messages/')
        .doc(message.send)
        .update({'msg': updatedmsg});
  }
}
