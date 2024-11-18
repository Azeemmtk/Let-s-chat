import 'package:flutter/material.dart';
import 'package:lets_chat/api/apis.dart';

import '../model/user_model.dart';

class UserViewModel extends ChangeNotifier {
  List<UserModel> data = [];
  bool isLoading = true;
  List<UserModel> allUsers = [];
  List<UserModel> searchList = [];

  UserViewModel() {
    fetchAllUsers(); // Fetch users on initialization
  }

  void fetchAllUsers() {
    isLoading = true;
    allUsers.clear(); // Clear previous users data
    Apis.firestore
        .collection('users')
        .where('id', isNotEqualTo: Apis.user.uid) // Exclude current user
        .snapshots()
        .listen((snapshot) {
      allUsers =
          snapshot.docs.map((e) => UserModel.fromJson(e.data())).toList();
      isLoading = false;
      notifyListeners();
    });
  }

  void searchUsers(String query) {
    searchList = allUsers.where((user) {
      return user.name.toLowerCase().contains(query.toLowerCase()) ||
          user.email.toLowerCase().contains(query.toLowerCase());
    }).toList();
    notifyListeners();
  }

  // Method to clear the current user's data (e.g., after logout)
  void clearData() {
    allUsers.clear();
    searchList.clear();
    notifyListeners();
  }

  // Listen to messages collection and log data to console
}
