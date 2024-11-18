import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:lets_chat/model/user_model.dart';

import '../api/apis.dart';
import '../model/message_model.dart';

class MessageViewmodel extends ChangeNotifier {
  List<MessageModel> messagesList = [];
  bool isLoading = true;

  void listenToMessages({required UserModel chatuser}) {
    isLoading = true;

    // Update this query to listen to all messages from all conversations
    Apis.firestore
        .collectionGroup(
            'messages') // Fetch messages from all conversation subcollections
        //.orderBy('send', descending: true)
        .snapshots()
        .listen((snapshot) {
      List<MessageModel> tempMessages = [];

      for (var doc in snapshot.docs) {
        print('Message: ${jsonEncode(doc.data())}');
        // Convert each document to a MessageModel and add it to the tempMessages list
        tempMessages.add(MessageModel.fromJson(doc.data()));
      }

      // Avoid clearing the list; only add new messages
      if (messagesList.isEmpty || tempMessages.length > messagesList.length) {
        messagesList = tempMessages;
      }

      // Debug: Print all the messages after they are fetched
      for (var i in messagesList) {
        print(' Messages====================${i.msg}');
      }

      isLoading = false;
      notifyListeners(); // Notify listeners after updating the messages list
    });
  }

  void removeMessage(MessageModel message) {
    // Remove the message from the list by matching the 'fromid' and 'send' timestamp (or any unique field)
    messagesList.removeWhere(
        (msg) => msg.fromid == message.fromid && msg.send == message.send);
    notifyListeners();
  }

  void updateMessage(MessageModel oldMessage, String newMessage) {
    // Find the message and update it with the new message
    int index = messagesList.indexWhere((msg) =>
        msg.fromid == oldMessage.fromid && msg.send == oldMessage.send);
    if (index != -1) {
      messagesList[index].msg = newMessage;
      notifyListeners(); // Notify the UI about the change
    }
  }
}
