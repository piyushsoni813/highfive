import 'dart:convert';
import 'package:flutter/material.dart';

class User extends ChangeNotifier {
  String name_;
  String? nickname_;
  String roll_;
  String? mobile_;
  String? room_;
  String? image_;
  bool isCompleted_;
  bool isVerfied_;
  bool isAdmin_;

  String get name => name_;
  String? get nickname => nickname_;
  String get roll => roll_;
  String? get mobile => mobile_;
  String? get room => room_;
  String? get image => image_;
  bool get isCompleted => isCompleted_;
  bool get isVerfied => isVerfied_;
  bool get isAdmin => isAdmin_;

  void updateUser(rawjsonData) {
    final jsonData = jsonDecode(rawjsonData);
    name_ = jsonData['name'];
    nickname_ = jsonData['nickName'];
    roll_ = jsonData['rollNumber'];
    mobile_ = jsonData['mobileNumber'];
    room_ = jsonData['roomNumber'];
    image_ = jsonData['photo'];
    isCompleted_ = jsonData['isCompleted'];
    isVerfied_ = jsonData['isVerified'];
    isAdmin_ = jsonData['isAdmin'];
    notifyListeners();
  }

  User(
      {required this.name_,
      this.nickname_,
      required this.roll_,
      this.mobile_,
      this.room_,
      this.image_,
      required this.isCompleted_,
      required this.isVerfied_,
      required this.isAdmin_});
}
