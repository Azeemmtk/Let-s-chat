import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_chat/api/apis.dart';
import 'package:lets_chat/helper/dialogs.dart';
import 'package:lets_chat/model/user_model.dart';
import 'package:lets_chat/screens/profile_screen.dart';
import 'package:lets_chat/widgets/user_chat_card.dart';
import 'package:provider/provider.dart';

import '../view_model/user_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _initFuture;

  // for storing all users
  List<UserModel> _list = [];

  // for storing searched items
  final List<UserModel> _searchList = [];
  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    Apis.getSelfinfo();

    // for updating user active status according to lifecycle events
    // resume -- active or online
    // pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (Apis.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          Apis.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          Apis.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserViewModel>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 3,
            title: _isSearching
                ? TextFormField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Email, name...",
                    ),
                    style: TextStyle(fontSize: 18),
                    autofocus: true,
                    onChanged: (value) {
                      value = value.toLowerCase();
                      // Clear the search list before adding new results
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(value) ||
                            i.email.toLowerCase().contains(value)) {
                          _searchList.add(i);
                        }
                      }
                      setState(() {}); // This will trigger the UI update
                    },
                  )
                : Text(
                    'Lets chat',
                    style: TextStyle(fontSize: 20.sp),
                  ),
            leading: IconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.home, size: 24.sp),
            ),
            actions: [
              IconButton(
                tooltip: 'search',
                onPressed: () => setState(() => _isSearching = !_isSearching),
                icon: Icon(
                  _isSearching ? CupertinoIcons.clear_circled : Icons.search,
                  size: 24.sp,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        user: Apis.me,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.more_vert, size: 24.sp),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showMessageUpdateDialogue();
            },
            child: Icon(Icons.add),
          ),
          body: StreamBuilder(
            stream: Apis.getMyUserId(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                case ConnectionState.active:
                case ConnectionState.done:
                  final userIds =
                      snapshot.data?.docs.map((e) => e.id).toList() ?? [];

                  if (userIds.isEmpty) {
                    // Display a message when no userIds are available
                    return const Center(child: Text('No users available'));
                  }

                  return StreamBuilder(
                    stream: Apis.getAllUsers(userIds),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                              child: CircularProgressIndicator());

                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => UserModel.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              itemCount: _isSearching
                                  ? _searchList.length
                                  : _list.length,
                              padding: EdgeInsets.only(top: 10.h),
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return UserChatCard(
                                  user: _isSearching
                                      ? _searchList[index]
                                      : _list[index],
                                );
                              },
                            );
                          } else {
                            return const Center(child: Text('No users found'));
                          }
                      }
                    },
                  );
              }
            },
          )),
    );
  }

  void _showMessageUpdateDialogue() {
    String email = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.person_add,
              color: Colors.blue,
              size: 20.h,
            ),
            Text('  Add user')
          ],
        ),
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration: InputDecoration(
            hintText: 'Email id',
            prefixIcon: Icon(
              Icons.email,
              color: Colors.blue,
            ),
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
            onPressed: () async {
              Navigator.pop(context);
              if (email.isNotEmpty) {
                await Apis.addChatUser(email).then(
                  (value) {
                    if (!value) {
                      Dialogs.showsnackbar(context, 'user does not exist');
                    }
                  },
                );
              }
            },
            child: Text(
              'add',
              style: TextStyle(color: Colors.blue, fontSize: 18),
            ),
          )
        ],
      ),
    );
  }
}
