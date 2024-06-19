import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  String? username;

  UserData({this.username});

  void updateUserData(String username) {
    this.username = username;
    notifyListeners();
  }

  void clearUser() {
    username = null;
    notifyListeners();
  }
}
