import 'package:flutter/foundation.dart';

class UserModel {
  UserModel({
    @required this.name,
    @required this.email,
    @required this.avatarUrl,
  });

  final String name;
  final String email;
  final String avatarUrl;

  factory UserModel.fromData(dynamic data) {
    final name = data["fullName"];
    final email = data["email"];
    final avatarUrl = data["avatarUrl"];

    return UserModel(
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );
  }
}
